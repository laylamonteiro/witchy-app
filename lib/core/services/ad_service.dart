import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'premium_access.dart';

/// Ids de bloco de anúncio. Defaults são os IDS DE TESTE oficiais do Google —
/// troque pelos ids reais da conta AdMob via --dart-define:
///   flutter build apk --dart-define=ADMOB_ANDROID_INTERSTITIAL_ID=ca-app-pub-XXX/YYY
/// (o APPLICATION_ID do AdMob fica no AndroidManifest.xml / Info.plist).
class AdConfig {
  static const String androidInterstitialId = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const String iosInterstitialId = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );

  static String get interstitialId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? iosInterstitialId
          : androidInterstitialId;
}

/// Anúncios intersticiais para usuários free, exibidos após ações principais
/// que retornam resultado (tiragens, leituras, feitiço IA).
///
/// Regras:
/// - Nunca para Premium ([PremiumAccess]); nunca na web/desktop.
/// - Cooldown mínimo de 3 minutos entre anúncios e teto de 10/dia.
/// - Anúncios NÃO personalizados (npa) — sem exigência de ATT nesta fase.
/// - Falha silenciosa: sem anúncio carregado, o fluxo segue normal.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  static const Duration _cooldown = Duration(minutes: 3);
  static const int _dailyCap = 10;
  static const String _lastShownKey = 'ad_interstitial_last_ms';
  static const String _dailyCountKey = 'ad_interstitial_daily';

  InterstitialAd? _loadedAd;
  bool _initialized = false;
  bool _loading = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Inicializa o SDK e pré-carrega o primeiro intersticial. Chamar uma vez
  /// no boot (mobile); barato de chamar de novo (no-op).
  Future<void> initialize() async {
    if (!_supported || _initialized) return;
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
      _preload();
    } catch (e) {
      debugPrint('AdService: falha ao inicializar: $e');
    }
  }

  void _preload() {
    if (!_supported || _loading || _loadedAd != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialId,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _loadedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          debugPrint('AdService: falha ao carregar: $error');
        },
      ),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Mostra um intersticial se (e só se) todas as regras permitirem.
  /// Fire-and-forget: chame após revelar o resultado da ação.
  Future<void> maybeShowInterstitial() async {
    if (!_supported || !_initialized) return;
    if (PremiumAccess.instance.isPremium) return;

    final prefs = await SharedPreferences.getInstance();

    final lastShown = prefs.getInt(_lastShownKey) ?? 0;
    final sinceLast = DateTime.now().millisecondsSinceEpoch - lastShown;
    if (sinceLast < _cooldown.inMilliseconds) return;

    final dailyRaw = prefs.getString(_dailyCountKey) ?? '';
    final parts = dailyRaw.split('|');
    final today = _todayKey();
    var count = (parts.length == 2 && parts[0] == today)
        ? int.tryParse(parts[1]) ?? 0
        : 0;
    if (count >= _dailyCap) return;

    final ad = _loadedAd;
    if (ad == null) {
      _preload(); // fica pronto para a próxima ação
      return;
    }
    _loadedAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _preload();
      },
    );

    await prefs.setInt(
        _lastShownKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(_dailyCountKey, '$today|${count + 1}');
    await ad.show();
  }
}
