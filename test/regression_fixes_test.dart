import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:grimorio_de_bolso/core/services/payment_service.dart';
import 'package:grimorio_de_bolso/core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/core/services/notification_service.dart';
import 'package:grimorio_de_bolso/core/providers/language_provider.dart';
import 'package:grimorio_de_bolso/core/providers/sync_provider.dart';
import 'package:grimorio_de_bolso/core/widgets/mascot/cat_chat_bubble.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/transit_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/services/transit_interpreter.dart';
import 'package:grimorio_de_bolso/features/astrology/presentation/pages/daily_magical_weather_page.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/widgets/premium_blur_widget.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/settings/presentation/pages/privacy_settings_page.dart';
import 'package:grimorio_de_bolso/features/settings/presentation/pages/settings_page.dart';
import 'package:grimorio_de_bolso/features/subscription/presentation/pages/subscription_page.dart';
import 'package:grimorio_de_bolso/features/subscription/presentation/widgets/pro_feature_gate.dart';
import 'package:grimorio_de_bolso/features/subscription/presentation/widgets/subscription_offer_widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/data_sources/spells_data.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/providers/spell_provider.dart';

void _ignoreSubscriptionSelection(SubscriptionType _) {}
void _ignoreTap() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Feitiços globais multiusuário', () {
    Map<String, dynamic> spellRow({
      required String id,
      required String userId,
      required bool isPreloaded,
      required int createdAt,
      String name = 'Feitiço',
      int synced = 0,
    }) {
      return {
        'id': id,
        'user_id': userId,
        'name': name,
        'purpose': 'Teste',
        'type': SpellType.attraction.name,
        'category': SpellCategory.other.name,
        'moon_phase': null,
        'ingredients': '',
        'steps': 'Passo',
        'duration': null,
        'observations': null,
        'is_preloaded': isPreloaded ? 1 : 0,
        'created_at': createdAt,
        'updated_at': createdAt,
        'synced': synced,
      };
    }

    List<Map<String, dynamic>> migratePreloadedSpellRows(
      List<Map<String, dynamic>> rows,
    ) {
      return rows.map((row) {
        final copy = Map<String, dynamic>.from(row);
        if (copy['is_preloaded'] == 1 &&
            (copy['user_id'] == 'local_user' ||
                copy['user_id'] == 'current_user')) {
          copy['user_id'] = SpellModel.globalUserId;
          copy['synced'] = 1;
        }
        return copy;
      }).toList();
    }

    List<Map<String, dynamic>> claimLegacySpellRows(
      List<Map<String, dynamic>> rows,
      String userId,
    ) {
      return rows.map((row) {
        final copy = Map<String, dynamic>.from(row);
        if (copy['is_preloaded'] != 1 &&
            (copy['user_id'] == 'local_user' ||
                copy['user_id'] == 'current_user')) {
          copy['user_id'] = userId;
          copy['synced'] = 0;
        }
        return copy;
      }).toList();
    }

    List<Map<String, dynamic>> visibleForUser(
      List<Map<String, dynamic>> rows,
      String userId,
    ) {
      final visible = rows
          .where((row) => row['user_id'] == userId || row['is_preloaded'] == 1)
          .map(Map<String, dynamic>.from)
          .toList();
      visible.sort((a, b) {
        final preloaded =
            (a['is_preloaded'] as int).compareTo(b['is_preloaded'] as int);
        if (preloaded != 0) return preloaded;
        final created =
            (b['created_at'] as int).compareTo(a['created_at'] as int);
        if (created != 0) return created;
        final name = (a['name'] as String)
            .toLowerCase()
            .compareTo((b['name'] as String).toLowerCase());
        if (name != 0) return name;
        return (a['id'] as String).compareTo(b['id'] as String);
      });
      return visible;
    }

    test('login inicial reivindica apenas feitiços pessoais legados', () {
      final rows = claimLegacySpellRows(migratePreloadedSpellRows([
        spellRow(
          id: 'global-1',
          userId: 'local_user',
          isPreloaded: true,
          createdAt: 1,
        ),
        spellRow(
          id: 'personal-1',
          userId: 'local_user',
          isPreloaded: false,
          createdAt: 2,
        ),
      ]), 'user-a');

      expect(
        rows.singleWhere((row) => row['id'] == 'global-1')['user_id'],
        SpellModel.globalUserId,
      );
      expect(rows.singleWhere((row) => row['id'] == 'personal-1')['user_id'],
          'user-a');
    });

    test('logout/login mantém globais compartilhados e pessoais isolados', () {
      final rows = [
        spellRow(
          id: 'global-1',
          userId: SpellModel.globalUserId,
          isPreloaded: true,
          createdAt: 4,
        ),
        spellRow(
          id: 'user-a-1',
          userId: 'user-a',
          isPreloaded: false,
          createdAt: 3,
        ),
        spellRow(
          id: 'user-b-1',
          userId: 'user-b',
          isPreloaded: false,
          createdAt: 2,
        ),
      ];

      expect(visibleForUser(rows, 'user-a').map((row) => row['id']),
          ['user-a-1', 'global-1']);
      expect(visibleForUser(rows, 'user-b').map((row) => row['id']),
          ['user-b-1', 'global-1']);
    });

    test('troca entre dois userId não reassocia feitiços globais', () {
      final afterUserA = claimLegacySpellRows([
        spellRow(
          id: 'global-1',
          userId: SpellModel.globalUserId,
          isPreloaded: true,
          createdAt: 1,
        ),
        spellRow(
          id: 'legacy-personal',
          userId: 'local_user',
          isPreloaded: false,
          createdAt: 2,
        ),
      ], 'user-a');
      final afterUserB = claimLegacySpellRows(afterUserA, 'user-b');

      expect(
        afterUserB.singleWhere((row) => row['id'] == 'global-1')['user_id'],
        SpellModel.globalUserId,
      );
      expect(
        afterUserB
            .singleWhere((row) => row['id'] == 'legacy-personal')['user_id'],
        'user-a',
      );
    });

    test('limpeza/reinstalação local grava precarregados com marcador global', () {
      final map = SpellModel(
        id: 'preloaded-fresh-install',
        name: 'Global',
        purpose: 'Teste',
        type: SpellType.attraction,
        category: SpellCategory.other,
        ingredients: const [],
        steps: 'Passo',
        isPreloaded: true,
      ).toMap();

      expect(map['user_id'], SpellModel.globalUserId);
      expect(map['user_id'], isNot('local_user'));
    });

    test('modo offline e sync após novo login preservam globais fora da conta', () {
      final offlineRows = [
        spellRow(
          id: 'global-offline',
          userId: SpellModel.globalUserId,
          isPreloaded: true,
          createdAt: 1,
          synced: 1,
        ),
        spellRow(
          id: 'offline-personal',
          userId: 'local_user',
          isPreloaded: false,
          createdAt: 2,
          synced: 0,
        ),
      ];
      final afterLogin = claimLegacySpellRows(offlineRows, 'new-user');
      final syncable = afterLogin.where(
        (row) => row['synced'] == 0 &&
            row['user_id'] == 'new-user' &&
            row['is_preloaded'] != 1,
      );

      expect(
        afterLogin
            .singleWhere((row) => row['id'] == 'global-offline')['user_id'],
        SpellModel.globalUserId,
      );
      expect(syncable.map((row) => row['id']), ['offline-personal']);
    });
  });

  group('DataSyncService converters', () {
    final service = DataSyncService();

    test('converte timestamps e booleanos nos dois sentidos', () {
      final local = {
        'id': '00000000-0000-4000-8000-000000000001',
        'user_id': 'local_user',
        'name': 'Teste',
        'purpose': 'Teste',
        'type': 'attraction',
        'category': 'other',
        'steps': 'Passo',
        'ingredients': '',
        'is_preloaded': 0,
        'created_at': 1700000000000,
        'updated_at': 1700000001000,
        'synced': 0,
      };
      final remote = service.toRemoteForTest(
        'spells',
        local,
        '00000000-0000-4000-8000-000000000099',
      );

      expect(remote['user_id'], '00000000-0000-4000-8000-000000000099');
      expect(remote['is_preloaded'], isFalse);
      expect(remote['created_at'], isA<String>());
      expect(remote, isNot(contains('synced')));

      final roundTrip = service.toLocalForTest('spells', remote);
      expect(roundTrip['is_preloaded'], 0);
      expect(roundTrip['created_at'], 1700000000000);
      expect(roundTrip['updated_at'], 1700000001000);
      expect(roundTrip['synced'], 1);
    });

    test('converte JSON textual para JSONB e de volta', () {
      final remote = service.toRemoteForTest(
        'birth_charts',
        {
          'id': '00000000-0000-4000-8000-000000000001',
          'chart_data': '{"userId":"local_user"}',
          'unknown_birth_time': 1,
          'birth_date': 1700000000000,
          'calculated_at': 1700000000000,
          'updated_at': 1700000000000,
          'synced': 0,
        },
        '00000000-0000-4000-8000-000000000099',
      );
      expect(remote['chart_data'], isA<Map<String, dynamic>>());
      expect(remote['unknown_birth_time'], isTrue);

      final local = service.toLocalForTest('birth_charts', remote);
      expect(local['chart_data'], '{"userId":"local_user"}');
      expect(local['unknown_birth_time'], 1);
    });
  });

  group('Benefícios Premium', () {
    test('lista reflete diferenciais implementados sem promessas obsoletas',
        () {
      final l10n = lookupAppLocalizations(const Locale('pt', 'BR'));
      final benefits = [
        l10n.premiumBenefitAdvisor,
        l10n.premiumBenefitEncyclopedia,
        l10n.premiumBenefitDailyClimate,
        l10n.premiumBenefitUnlimitedReadings,
        l10n.premiumBenefitCloudSync,
      ];

      expect(benefits, hasLength(5));
      expect(benefits, contains('Conselheiro Místico ilimitado'));
      expect(benefits, contains('Sincronização entre dispositivos'));
      expect(benefits.any((text) => text.contains('em breve')), isFalse);
      expect(
        benefits.any((text) => text.contains('Suporte prioritário')),
        isFalse,
      );
    });

    // O paywall rola (o painel cresceu com os benefícios): o que precisa
    // continuar valendo é ele ser ÚNICO, trazer herói + planos + os textos
    // vigentes e caber em tela de celular sem estourar layout.
    testWidgets('paywall único mostra herói, planos e benefícios vigentes',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: Scaffold(body: PremiumUpgradeSheet()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PremiumOfferPanel), findsOneWidget);
      expect(find.byType(SubscriptionHero), findsOneWidget);
      expect(find.text('Conselheiro Místico ilimitado'), findsOneWidget);
      expect(find.text('Sincronização entre dispositivos'), findsOneWidget);
      expect(find.textContaining('O QUE VOCÊ DESBLOQUEIA'), findsNothing);
      expect(find.text('Cancele a qualquer momento'), findsOneWidget);
      expect(find.text('Cancele quando quiser'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Nova oferta de assinatura', () {
    testWidgets('Fazer Upgrade de Configurações abre SubscriptionPage',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final authProvider = AuthProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            // A tela de Configurações escolhe o idioma: sem este provider
            // ela nem constrói.
            ChangeNotifierProvider<LanguageProvider>(
              create: (_) => LanguageProvider(prefs),
            ),
          ],
          child: MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales,
            home: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const SettingsPage(),
              ),
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('settings_upgrade_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionPage), findsOneWidget);
      expect(find.text('Assinatura'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // A Privacidade não tem mais atalho para o Premium (a sincronização
    // deixou de ser vendida ali). O que precisa continuar valendo é a tela
    // abrir inteira e sem exceção — inclusive o alerta do Flutter sobre
    // ListTile dentro de caixa colorida, que escondia a ondulação de toque.
    testWidgets('Privacidade abre com seus controles e sem exceção',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authProvider = AuthProvider();
      final syncProvider = SyncProvider();
      addTearDown(syncProvider.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<SyncProvider>.value(value: syncProvider),
          ],
          child: MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            home: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const PrivacySettingsPage(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrivacySettingsPage), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gate genérico abre o mesmo PremiumUpgradeSheet',
        (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider()),
            ChangeNotifierProvider<PaymentService>.value(
              value: PaymentService(),
            ),
          ],
          child: MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            home: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  body: ProFeatureGate(
                    lockedChild: Text('Conteúdo bloqueado'),
                    child: Text('Conteúdo Premium'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Conteúdo bloqueado'));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumUpgradeSheet), findsOneWidget);
      expect(find.byType(PremiumOfferPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('composição completa permanece responsiva em três tamanhos',
        (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final testCase in const [
        (Size(320, 568), 1.3),
        (Size(390, 844), 1.0),
        (Size(600, 1024), 1.0),
        (Size(390, 844), 1.5),
      ]) {
        final (size, textScale) = testCase;
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            theme: AppTheme.darkTheme,
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(textScale),
              ),
              child: const Scaffold(
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: PremiumOfferPanel(
                    selectedPlan: SubscriptionType.yearly,
                    onSelected: _ignoreSubscriptionSelection,
                    monthlyPrice: 'R\$ 9,90',
                    yearlyPrice: 'R\$ 79,90',
                    purchaseLoading: false,
                    purchaseEnabled: true,
                    onPurchase: _ignoreTap,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Começar Agora'), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: 'Falhou em $size com fonte ${textScale * 100}%',
        );
      }
    });

    testWidgets('benefícios compactos exibem apenas os títulos sem overflow',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: PremiumBenefitsSection(),
            ),
          ),
        ),
      );

      expect(find.text('Conselheiro Místico ilimitado'), findsOneWidget);
      expect(
        find.text(
          'Seu Grimório protegido na nuvem e sempre com você, onde estiver',
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('planos alternam seleção e usam preços fornecidos',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(420, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var selected = SubscriptionType.yearly;

      await tester.pumpWidget(
        MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SubscriptionPlanSelector(
                selectedPlan: selected,
                onSelected: (plan) => setState(() => selected = plan),
                monthlyPrice: 'R\$ 12,34',
                yearlyPrice: 'R\$ 98,76',
              ),
            ),
          ),
        ),
      );

      expect(find.text('R\$ 12,34'), findsOneWidget);
      expect(find.text('R\$ 98,76'), findsOneWidget);
      final monthlyPrice = tester.getRect(find.text('R\$ 12,34'));
      final monthlyPeriod = tester.getRect(find.text('/mês'));
      final yearlyPrice = tester.getRect(find.text('R\$ 98,76'));
      final yearlyPeriod = tester.getRect(find.text('/ano'));
      expect(monthlyPrice.right, lessThan(monthlyPeriod.left));
      expect(yearlyPrice.right, lessThan(yearlyPeriod.left));
      expect(
        (monthlyPrice.center.dy - monthlyPeriod.center.dy).abs(),
        lessThan(8),
      );
      expect(
        (yearlyPrice.center.dy - yearlyPeriod.center.dy).abs(),
        lessThan(8),
      );
      await tester.tap(
        find.byKey(const ValueKey('subscription_plan_monthly')),
      );
      await tester.pumpAndSettle();
      expect(selected, SubscriptionType.monthly);
      expect(find.text('SELECIONADO'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('subscription_plan_yearly')),
      );
      await tester.pumpAndSettle();
      expect(selected, SubscriptionType.yearly);
      expect(tester.takeException(), isNull);
    });

    testWidgets('planos permanecem lado a lado com fonte ampliada',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          theme: AppTheme.darkTheme,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: SubscriptionPlanSelector(
                  selectedPlan: SubscriptionType.yearly,
                  onSelected: (_) {},
                  monthlyPrice: 'R\$ 9,90',
                  yearlyPrice: 'R\$ 79,90',
                ),
              ),
            ),
          ),
        ),
      );

      final monthly = tester.getRect(
        find.byKey(const ValueKey('subscription_plan_monthly')),
      );
      final yearly = tester.getRect(
        find.byKey(const ValueKey('subscription_plan_yearly')),
      );
      expect(monthly.center.dy, closeTo(yearly.center.dy, 0.01));
      expect(monthly.right, lessThan(yearly.left));
      expect(tester.takeException(), isNull);
    });

    testWidgets('botão de compra bloqueia interação durante loading',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SubscriptionPurchaseButton(
              loading: true,
              enabled: true,
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(taps, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'página Free abre paywall, usa preços do serviço e compra uma vez',
        (tester) async {
      final service = PaymentService();
      final firstPurchase = Completer<PurchaseResult>();
      final selectedPlans = <SubscriptionType>[];
      final products = [
        ProductInfo(
          identifier: 'monthly-test',
          title: 'Mensal',
          description: 'Mensal',
          priceString: 'R\$ 12,34',
          price: 12.34,
          currencyCode: 'BRL',
          type: SubscriptionType.monthly,
        ),
        ProductInfo(
          identifier: 'yearly-test',
          title: 'Anual',
          description: 'Anual',
          priceString: 'R\$ 98,76',
          price: 98.76,
          currencyCode: 'BRL',
          type: SubscriptionType.yearly,
        ),
      ];
      service.setTestProducts(
        products,
        onPurchase: (plan) {
          selectedPlans.add(plan);
          return firstPurchase.future;
        },
      );
      addTearDown(service.clearTestProducts);

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider(),
          child: const MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: SubscriptionPage()),
        ),
      );
      await tester.pump();

      expect(find.byType(PremiumOfferPanel), findsNothing);
      expect(find.text('Tem um Código Premium?'), findsOneWidget);
      expect(find.text('Restaurar Compras'), findsOneWidget);
      expect(find.text('Desbloquear Premium'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('open_premium_paywall_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PremiumUpgradeSheet), findsOneWidget);
      expect(find.byType(PremiumOfferPanel), findsOneWidget);
      expect(find.text('R\$ 12,34'), findsOneWidget);
      expect(find.text('R\$ 98,76'), findsOneWidget);

      final monthlyPlan =
          find.byKey(const ValueKey('subscription_plan_monthly'));
      await tester.ensureVisible(monthlyPlan);
      await tester.pumpAndSettle();
      await tester.tap(monthlyPlan);
      final purchaseButton = find.ancestor(
        of: find.text('Começar Agora'),
        matching: find.byType(ElevatedButton),
      );
      await tester.ensureVisible(purchaseButton);
      await tester.pumpAndSettle();
      await tester.tap(purchaseButton);
      await tester.tap(purchaseButton);
      await tester.pump();

      expect(selectedPlans, [SubscriptionType.monthly]);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      firstPurchase.complete(PurchaseResult.error('Erro de teste'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'página Free não embute oferta e paywall renderiza assets reais',
        (tester) async {
      final service = PaymentService();
      service.setTestProducts(const []);
      addTearDown(service.clearTestProducts);

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider(),
          child: const MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: SubscriptionPage()),
        ),
      );
      await tester.pump();

      expect(find.byType(PremiumOfferPanel), findsNothing);
      expect(find.text('Tem um Código Premium?'), findsOneWidget);
      expect(find.text('Restaurar Compras'), findsOneWidget);
      expect(find.text('Desbloquear Premium'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('open_premium_paywall_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionHero), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(8));
      expect(find.text('Mensal'), findsOneWidget);
      expect(find.text('Anual'), findsOneWidget);
      expect(find.text('Começar Agora'), findsOneWidget);
      expect(find.text('Pagamento seguro'), findsOneWidget);
      expect(find.text('Cancele a qualquer momento'), findsOneWidget);
      expect(find.text('Cancele quando quiser'), findsNothing);
      expect(find.text('Seus dados protegidos'), findsOneWidget);

      for (final path in [
        'assets/premium/icon_orb.png',
        'assets/premium/icon_book.png',
        'assets/premium/icon_moon.png',
        'assets/premium/icon_runes.png',
        'assets/premium/icon_cloud.png',
        'assets/premium/icon_shield.png',
        'assets/premium/icon_sync.png',
        'assets/premium/icon_lock.png',
        'assets/premium/cat_hero.png',
      ]) {
        final data = await tester.runAsync(() => rootBundle.load(path));
        expect(data!.lengthInBytes, greaterThan(0), reason: path);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('Premium mantém gerenciamento e vitalício mantém informativo',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final authProvider = AuthProvider();
      await authProvider.setUserRole(UserRole.premium);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: SubscriptionPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Gerenciar Assinatura'), findsOneWidget);
      expect(find.text('Plano Mensal'), findsWidgets);

      await authProvider.setUserRole(UserRole.admin);
      await authProvider.setUserRole(UserRole.premium);
      await tester.pumpAndSettle();
      expect(find.text('Acesso Vitalício (Código Premium)'), findsOneWidget);
      expect(
        find.text(
          'Seu acesso Premium foi resgatado via Código Premium e não expira',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Notification scheduling helpers', () {
    test('gera IDs estáveis e diferentes por evento', () {
      final date = DateTime(2026, 8, 28);
      final full = NotificationService.notificationId('full_moon', date);
      final newMoon = NotificationService.notificationId('new_moon', date);
      expect(full, NotificationService.notificationId('full_moon', date));
      expect(full, isNot(newMoon));
    });

    test('cria lembretes em horário local fixo', () {
      final event = DateTime(2026, 3, 1, 14, 30);
      expect(
        NotificationService.reminderDate(
          event,
          daysBefore: 1,
          hour: 20,
        ),
        DateTime(2026, 2, 28, 20),
      );
      expect(
        NotificationService.reminderDate(
          event,
          daysBefore: 3,
          hour: 9,
        ),
        DateTime(2026, 2, 26, 9),
      );
    });
  });

  group('Energia do Dia', () {
    final interpreter = TransitInterpreter();

    TransitAspect aspect(AspectType type) => TransitAspect(
          transitPlanet: Planet.sun,
          natalPlanet: Planet.moon,
          aspectType: type,
          orb: 1,
          interpretation: 'Teste',
          energyLevel: EnergyLevel.moderate,
        );

    test('classifica corretamente aspectos tensos e harmoniosos', () {
      expect(
        interpreter.determineOverallEnergyForTest(
          List.generate(3, (_) => aspect(AspectType.conjunction)),
        ),
        EnergyLevel.intense,
      );
      expect(
        interpreter.determineOverallEnergyForTest([
          aspect(AspectType.square),
          aspect(AspectType.opposition),
        ]),
        EnergyLevel.challenging,
      );
      expect(
        interpreter.determineOverallEnergyForTest([
          aspect(AspectType.square),
          aspect(AspectType.sextile),
        ]),
        EnergyLevel.moderate,
      );
      expect(
        interpreter.determineOverallEnergyForTest([
          aspect(AspectType.trine),
          aspect(AspectType.sextile),
        ]),
        EnergyLevel.harmonious,
      );
    });

    test('o cálculo real varia conforme a data', () async {
      final results = <EnergyLevel>{};
      for (final date in [
        DateTime(2026, 7, 1),
        DateTime(2026, 7, 2),
        DateTime(2026, 7, 11),
        DateTime(2026, 1, 12),
      ]) {
        results.add(
            (await interpreter.getDailyMagicalWeather(date)).overallEnergy);
      }
      expect(results.length, greaterThanOrEqualTo(3));
    });
  });

  group('Preview Free', () {
    test('extrai os títulos da previsão sem expor os parágrafos', () {
      const markdown = '''## Energia do Dia
Conteúdo secreto.

## Ritual Sugerido
Outro conteúdo secreto.''';
      expect(
        DailyForecastPreview.headingsFromMarkdown(markdown),
        ['Energia do Dia', 'Ritual Sugerido'],
      );
    });

    testWidgets('mantém título e subtítulo fora do blur', (tester) async {
      final auth = AuthProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            home: Scaffold(
              body: PremiumContentSection(
                feature: AppFeature.encyclopediaHerbsDetails,
                title: const Text('Usos Rituais'),
                subtitle: 'Práticas e intenções desta erva.',
                content: const Text(
                  'Conteúdo Premium real',
                  key: Key('premium-real-content'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Usos Rituais'), findsOneWidget);
      expect(find.text('Práticas e intenções desta erva.'), findsOneWidget);
      expect(find.byKey(const Key('premium-real-content')), findsNothing);
      expect(find.byType(ImageFiltered), findsOneWidget);
    });
  });

  group('Cat bubble layout', () {
    Future<Size> pumpBubble(
      WidgetTester tester,
      String message, {
      double textScale = 1,
      double width = 320,
    }) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(Size(width, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = AuthProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 500),
                textScaler: TextScaler.linear(textScale),
              ),
              child: Scaffold(
                body: Stack(
                  children: [
                    CatChatBubble(
                      key: UniqueKey(),
                      mascotPosition: ValueNotifier(const Offset(60, 220)),
                      message: message,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      return tester.getSize(find.byKey(const Key('cat-bubble-size')));
    }

    testWidgets('encolhe para texto curto e limita texto longo',
        (tester) async {
      final short = await pumpBubble(tester, 'Olá!');
      final long = await pumpBubble(
        tester,
        'Uma mensagem longa precisa quebrar linhas automaticamente sem deixar espaços vazios excessivos.',
      );
      expect(short.width, lessThan(long.width));
      expect(long.width, lessThanOrEqualTo(176));
      expect(long.height, greaterThanOrEqualTo(64));
    });

    testWidgets('não estoura em tela estreita com fonte ampliada',
        (tester) async {
      final size = await pumpBubble(
        tester,
        'Descubra a energia mágica preparada para o seu dia.',
        textScale: 1.5,
        width: 240,
      );
      expect(size.width, lessThanOrEqualTo(210));
      expect(tester.takeException(), isNull);
    });

    testWidgets('respeita telas menores que o limite padrão', (tester) async {
      final size = await pumpBubble(
        tester,
        'Uma mensagem longa também deve caber em uma tela muito estreita.',
        width: 180,
      );
      expect(size.width, lessThanOrEqualTo(164));
      expect(tester.takeException(), isNull);
    });

    testWidgets('mantém a parte digitada no layout do texto completo',
        (tester) async {
      const message = 'Que tal olhar o clima mágico do seu dia?';
      await pumpBubble(tester, message);

      final richText = tester.widget<Text>(
        find.byKey(const Key('cat-bubble-typewriter')),
      );
      final root = richText.textSpan! as TextSpan;
      final spans = root.children!.cast<TextSpan>();
      expect('${spans[0].text}${spans[1].text}', message);
      expect(spans[1].style?.color, Colors.transparent);
      expect(tester.takeException(), isNull);
    });
  });

  group('SpellProvider preloaded seed', () {
    test('restaura feitiços ancestrais mesmo após inicialização prévia', () async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('spells');

      final provider = SpellProvider();
      await provider.loadSpells();

      expect(provider.error, isNull);
      expect(provider.appSpells, hasLength(preloadedSpells.length));

      await db.delete('spells', where: 'is_preloaded = ?', whereArgs: [1]);
      expect(
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM spells WHERE is_preloaded = 1',
          ),
        ),
        0,
      );

      await provider.loadSpells();

      final restoredPreloadedRows = await db.query(
        'spells',
        columns: ['id'],
        where: 'is_preloaded = ?',
        whereArgs: [1],
      );
      final restoredIds = restoredPreloadedRows
          .map((row) => row['id'] as String)
          .toList();

      expect(provider.error, isNull);
      expect(provider.appSpells, hasLength(preloadedSpells.length));
      expect(restoredIds, hasLength(preloadedSpells.length));
      expect(restoredIds.toSet(), hasLength(preloadedSpells.length));
    });

    test('seed é idempotente: recarregar não duplica os ancestrais', () async {
      // Regressão: preloadedSpells gera UUID novo a cada execução; o seed
      // comparava por id e re-inseria os 65 feitiços a cada load.
      final db = await DatabaseHelper.instance.database;
      await db.delete('spells');

      final provider = SpellProvider();
      await provider.loadSpells();
      await provider.loadSpells();
      await provider.loadSpells();

      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM spells WHERE is_preloaded = 1',
        ),
      );
      expect(count, preloadedSpells.length);
      expect(provider.appSpells, hasLength(preloadedSpells.length));
    });
  });

}
