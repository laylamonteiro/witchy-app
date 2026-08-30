/// O card "Ritos de Hoje" celebra o dia selado UMA vez — na transição real
/// 2/3 → 3/3 vista com o card em cena — e nunca porque a tela reconstruiu
/// ou porque o dia já veio 3/3 do banco. Este arquivo é o contrato disso:
/// selo e haptic não podem virar spam de rebuild, e "reduzir movimento"
/// leva direto ao estado final sem prender pumpAndSettle.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/dream_model.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/gratitude_model.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/providers/dream_provider.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/providers/gratitude_provider.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/widgets/daily_rites_card.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Check-in sem banco: o card só conversa com isLoaded/isRiteDone e com o
/// completeRite idempotente — o resto do provider real não entra em cena.
class _CheckinFake extends DailyCheckinProvider {
  final Set<String> feitos = {};

  @override
  bool get isLoaded => true;

  @override
  bool isRiteDone(String riteId) => feitos.contains(riteId);

  @override
  Future<void> completeRite(String riteId) async {
    if (feitos.contains(riteId)) return;
    feitos.add(riteId);
    notifyListeners();
  }

  void cutuca() => notifyListeners();
}

class _GratidaoFake extends GratitudeProvider {
  List<GratitudeModel> lista = [];
  bool carregando = false;

  @override
  List<GratitudeModel> get gratitudes => lista;

  @override
  bool get isLoading => carregando;

  void registraHoje() {
    lista = [GratitudeModel(title: 'g', content: 'g', tags: const [])];
    notifyListeners();
  }

  void comecaLoad() {
    carregando = true;
    notifyListeners();
  }

  void terminaLoad({bool comRegistro = false}) {
    if (comRegistro) {
      lista = [GratitudeModel(title: 'g', content: 'g', tags: const [])];
    }
    carregando = false;
    notifyListeners();
  }
}

class _SonhosFake extends DreamProvider {
  List<DreamModel> lista = [];

  @override
  List<DreamModel> get dreams => lista;

  void registraHoje() {
    lista = [DreamModel(title: 's', content: 's', tags: const [])];
    notifyListeners();
  }
}

/// Premium neutraliza o selo da Quiromancia nos dias em que ela é o rito
/// rotativo — o teste fica estável em qualquer data.
class _AuthPremium extends AuthProvider {
  @override
  bool get isPremiumEffective => true;
}

void main() {
  late List<String> hapticos;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    hapticos = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        hapticos.add(call.arguments as String);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget app({
    required _CheckinFake checkin,
    required _GratidaoFake gratidao,
    required _SonhosFake sonhos,
    bool semAnimacoes = false,
    ValueListenable<bool>? emCena,
  }) {
    // Sem toggle, o card fica direto no Scaffold (TickerMode.of devolve true,
    // ou seja, "em cena"). Com toggle, o TickerMode simula a aba escondida do
    // IndexedStack, como o HomePage faz de verdade.
    const card = DailyRitesCard();
    final Widget body = emCena == null
        ? card
        : ValueListenableBuilder<bool>(
            valueListenable: emCena,
            builder: (_, visivel, child) =>
                TickerMode(enabled: visivel, child: child!),
            child: card,
          );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DailyCheckinProvider>.value(value: checkin),
        ChangeNotifierProvider<GratitudeProvider>.value(value: gratidao),
        ChangeNotifierProvider<DreamProvider>.value(value: sonhos),
        ChangeNotifierProvider<AuthProvider>(create: (_) => _AuthPremium()),
      ],
      child: MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: semAnimacoes
            ? (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: child!,
                )
            : null,
        home: Scaffold(body: body),
      ),
    );
  }

  testWidgets('dia já 3/3 no primeiro build assenta sem celebração nem haptic',
      (tester) async {
    final checkin = _CheckinFake()
      ..feitos.add(DailyRites.featuredToday())
      ..feitos.add(DailyRites.dayComplete);
    final gratidao = _GratidaoFake()..registraHoje();
    final sonhos = _SonhosFake()..registraHoje();

    await tester.pumpWidget(
        app(checkin: checkin, gratidao: gratidao, sonhos: sonhos));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(hapticos, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('terceiro rito em cena celebra uma vez; rebuild não repete',
      (tester) async {
    final checkin = _CheckinFake()..feitos.add(DailyRites.featuredToday());
    final gratidao = _GratidaoFake()..registraHoje();
    final sonhos = _SonhosFake();

    await tester.pumpWidget(
        app(checkin: checkin, gratidao: gratidao, sonhos: sonhos));
    await tester.pumpAndSettle();
    hapticos.clear();

    sonhos.registraHoje(); // 2/3 → 3/3, com o card montado e em cena
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(hapticos, ['HapticFeedbackType.lightImpact']);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // Reconstruções com o mesmo estado não repetem selo nem haptic.
    checkin.cutuca();
    await tester.pumpAndSettle();
    expect(hapticos.length, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rito individual dá um clique leve, uma vez', (tester) async {
    final checkin = _CheckinFake();
    final gratidao = _GratidaoFake();
    final sonhos = _SonhosFake();

    await tester.pumpWidget(
        app(checkin: checkin, gratidao: gratidao, sonhos: sonhos));
    await tester.pumpAndSettle();
    hapticos.clear();

    gratidao.registraHoje(); // 0/3 → 1/3
    await tester.pump();
    await tester.pumpAndSettle();

    expect(hapticos, ['HapticFeedbackType.selectionClick']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduzir movimento: selamento vai direto ao estado final',
      (tester) async {
    final checkin = _CheckinFake()..feitos.add(DailyRites.featuredToday());
    final gratidao = _GratidaoFake()..registraHoje();
    final sonhos = _SonhosFake();

    await tester.pumpWidget(app(
      checkin: checkin,
      gratidao: gratidao,
      sonhos: sonhos,
      semAnimacoes: true,
    ));
    await tester.pumpAndSettle();
    hapticos.clear();

    sonhos.registraHoje();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(hapticos, ['HapticFeedbackType.lightImpact']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dia selado fora de cena não gasta a celebração; ela vem na volta',
      (tester) async {
    final emCena = ValueNotifier<bool>(true);
    addTearDown(emCena.dispose);
    final checkin = _CheckinFake()..feitos.add(DailyRites.featuredToday());
    final gratidao = _GratidaoFake()..registraHoje(); // 2/3
    final sonhos = _SonhosFake();

    await tester.pumpWidget(app(
      checkin: checkin,
      gratidao: gratidao,
      sonhos: sonhos,
      emCena: emCena,
    ));
    await tester.pumpAndSettle();
    hapticos.clear();

    // A pessoa foi para o Diário registrar o sonho: o card sai de cena.
    emCena.value = false;
    await tester.pump();

    // O sonho registrado fecha o dia com o card fora de vista.
    sonhos.registraHoje();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(hapticos, isEmpty,
        reason: 'celebração não roda para ninguém ver');

    // Volta ao Seu Dia: a transição ficou pendente e é celebrada agora.
    emCena.value = true;
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    expect(hapticos, ['HapticFeedbackType.lightImpact']);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'convidado: primeiro load do diário assenta em silêncio; rito real '
      'depois celebra', (tester) async {
    final checkin = _CheckinFake();
    final gratidao = _GratidaoFake();
    final sonhos = _SonhosFake();

    await tester.pumpWidget(
        app(checkin: checkin, gratidao: gratidao, sonhos: sonhos));
    await tester.pumpAndSettle();
    hapticos.clear();

    // Conta local: o diário só lê o banco quando a pessoa abre o Diário, e o
    // registro de hoje chegando no primeiro load é passado, não rito agora.
    gratidao.comecaLoad();
    await tester.pump();
    gratidao.terminaLoad(comRegistro: true);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(hapticos, isEmpty,
        reason: 'dado do primeiro load não comemora');

    // Diário agora confiável: uma conclusão real (o rito do dia) celebra.
    await checkin.completeRite(DailyRites.featuredToday());
    await tester.pump();
    await tester.pumpAndSettle();
    expect(hapticos, ['HapticFeedbackType.selectionClick']);
    expect(tester.takeException(), isNull);
  });
}
