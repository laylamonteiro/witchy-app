import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/core/widgets/magical_button.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/user_entry_model.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/add_entry_page.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/providers/encyclopedia_provider.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O novo fluxo do Guia da Natureza: foto obrigatória, nome, "Gerar
/// conteúdo" — igual para erva e cristal. A única diferença é o atalho
/// "Não sei o nome — identificar pela foto", que só a erva tem. A IA e o
/// picker são dublês: o que se prova aqui é a máquina de estados da tela.
class _AuthPremium extends AuthProvider {
  @override
  bool get isPremiumEffective => true;

  @override
  AccessResult checkFeatureAccess(AppFeature feature) => AccessResult.full();
}

/// Sem Premium: a foto não é escolhida e a tela mostra a prévia dos campos.
class _AuthSemPremium extends AuthProvider {
  @override
  bool get isPremiumEffective => false;

  @override
  AccessResult checkFeatureAccess(AppFeature feature) =>
      AccessResult.preview();
}

class _EnciclopediaFake extends EncyclopediaProvider {
  _EnciclopediaFake() : super(statusDoSync: const Stream<SyncStatus>.empty());

  @override
  Future<int> userEntriesCreatedToday() async => 0;
}

class _CheckinFake extends DailyCheckinProvider {
  @override
  bool get isLoaded => true;

  @override
  Future<void> completeRite(String riteId) async {}
}

class _IaDeMentira implements GuiaDaNaturezaIa {
  int identificacoes = 0;
  int geracoes = 0;
  Uint8List? bytesGerados;

  @override
  Future<Map<String, dynamic>> identificarErva({
    required Uint8List jpegBytes,
  }) async {
    identificacoes++;
    return {
      'identified': true,
      'candidates': [
        {
          'name': 'Alecrim',
          'scientific': 'Salvia rosmarinus',
          'confidence': 'high',
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> gerar({
    required String name,
    required String categoryKey,
    required Uint8List jpegBytes,
  }) async {
    geracoes++;
    bytesGerados = jpegBytes;
    return {
      'name': name,
      'description': 'Uma pagina de mentira.',
      'magicalProperties': ['protecao'],
    };
  }
}

void main() {
  // PNG 1×1 de verdade: bytes inválidos fariam o Image.memory acusar erro.
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB'
    '0C8AAAAASUVORK5CYII=',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget app(AddEntryPage page, {AuthProvider Function()? auth}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => (auth ?? _AuthPremium.new)(),
          ),
          ChangeNotifierProvider<EncyclopediaProvider>(
            create: (_) => _EnciclopediaFake(),
          ),
          ChangeNotifierProvider<DailyCheckinProvider>(
            create: (_) => _CheckinFake(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: page,
        ),
      );

  AppLocalizations l10nDe(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(AddEntryPage)));

  MagicalButton gerar(WidgetTester tester) =>
      tester.widget<MagicalButton>(find.byType(MagicalButton).first);

  OutlinedButton identificar(WidgetTester tester, AppLocalizations l10n) =>
      tester.widget<OutlinedButton>(find.ancestor(
        of: find.text(l10n.encyAddIdentifyCta),
        matching: find.bySubtype<OutlinedButton>(),
      ));

  TextField campoNome(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField));

  Future<void> tocar(WidgetTester tester, String rotulo) async {
    await tester.ensureVisible(find.text(rotulo));
    await tester.tap(find.text(rotulo));
    await tester.pump();
    // O MagicalButton solta partículas por 400 ms: o timer precisa vencer.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  Future<_IaDeMentira> montar(
    WidgetTester tester,
    UserEntryCategory category, {
    AuthProvider Function()? auth,
  }) async {
    final ia = _IaDeMentira();
    await tester.pumpWidget(app(
      AddEntryPage(
        category: category,
        escolherFoto: (_) async => png,
        ia: ia,
      ),
      auth: auth,
    ));
    await tester.pumpAndSettle();
    return ia;
  }

  /// Toca no campo do nome (abre o teclado) e devolve o Element dele — a
  /// prova de que o campo NÃO renasceu é o mesmo Element continuar vivo.
  Future<Element> focarNome(WidgetTester tester) async {
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.testTextInput.hasAnyClients, isTrue,
        reason: 'o teclado abriu');
    return tester.element(find.byType(TextField));
  }

  testWidgets('erva: sem foto, Gerar fica desabilitado e o atalho espera',
      (tester) async {
    final ia = await montar(tester, UserEntryCategory.herb);
    final l10n = l10nDe(tester);

    expect(find.text(l10n.encyAddPhotoFirstHint), findsOneWidget);
    expect(gerar(tester).enabled, isFalse);
    expect(find.text(l10n.encyAddIdentifyCta), findsOneWidget);
    expect(identificar(tester, l10n).onPressed, isNull);

    // Tocar no botão desabilitado não gasta IA nenhuma.
    await tocar(tester, l10n.encyAddGenerateCta);
    expect(ia.geracoes, 0);
    expect(ia.identificacoes, 0);
  });

  testWidgets('erva: foto → identificar preenche o nome → gerar leva a foto',
      (tester) async {
    final ia = await montar(tester, UserEntryCategory.herb);
    final l10n = l10nDe(tester);

    await tocar(tester, l10n.encyAddTakePhoto);
    expect(find.text(l10n.encyAddPhotoFirstHint), findsNothing);
    expect(gerar(tester).enabled, isTrue);
    expect(identificar(tester, l10n).onPressed, isNotNull);

    await tocar(tester, l10n.encyAddIdentifyCta);
    expect(ia.identificacoes, 1);
    expect(campoNome(tester).controller!.text, 'Alecrim');
    expect(find.text(l10n.encyAddIdentifiedAs), findsOneWidget);

    await tocar(tester, l10n.encyAddGenerateCta);
    expect(ia.geracoes, 1);
    expect(ia.bytesGerados, png, reason: 'o verbete considera a foto real');
    expect(find.text(l10n.encyAddPreviewTitle), findsOneWidget);
    expect(find.text('Alecrim'), findsWidgets);
  });

  testWidgets('cristal: mesma jornada, sem identificação por foto',
      (tester) async {
    final ia = await montar(tester, UserEntryCategory.crystal);
    final l10n = l10nDe(tester);

    expect(find.text(l10n.encyAddIdentifyCta), findsNothing);
    expect(gerar(tester).enabled, isFalse);

    await tocar(tester, l10n.encyAddTakePhoto);
    expect(gerar(tester).enabled, isTrue);

    await tester.enterText(find.byType(TextField), 'Ametista');
    await tester.pump();
    await tocar(tester, l10n.encyAddGenerateCta);

    expect(ia.identificacoes, 0, reason: 'cristal nunca chama a visão');
    expect(ia.geracoes, 1);
    expect(find.text(l10n.encyAddPreviewTitle), findsOneWidget);
  });

  testWidgets('trocar a foto só limpa o nome que veio da identificação',
      (tester) async {
    final ia = await montar(tester, UserEntryCategory.herb);
    final l10n = l10nDe(tester);

    await tester.enterText(find.byType(TextField), 'Manjericao');
    await tester.pump();
    await tocar(tester, l10n.encyAddTakePhoto);
    expect(campoNome(tester).controller!.text, 'Manjericao',
        reason: 'o que a pessoa digitou continua valendo');

    await tocar(tester, l10n.encyAddIdentifyCta);
    expect(campoNome(tester).controller!.text, 'Alecrim');

    await tocar(tester, l10n.encyAddFromGallery);
    expect(campoNome(tester).controller!.text, isEmpty,
        reason: 'nome da IA era da foto anterior');
    expect(find.text(l10n.encyAddIdentifiedAs), findsNothing);
    expect(ia.identificacoes, 1);
  });

  // O bug da web: "o teclado aparece e some". Um campo que renasce noutra
  // posição da árvore perde o foco — e o teclado fecha. Dois cards entram
  // ACIMA ou DENTRO do card do nome sem aviso: a prévia Premium e o título
  // "Encontrei!". Com chaves, o campo é o mesmo antes e depois.
  testWidgets('identificar não recria o campo do nome: o teclado fica aberto',
      (tester) async {
    await montar(tester, UserEntryCategory.herb);
    final l10n = l10nDe(tester);
    await tocar(tester, l10n.encyAddTakePhoto);

    final antes = await focarNome(tester);
    await tocar(tester, l10n.encyAddIdentifyCta);

    expect(find.text(l10n.encyAddIdentifiedAs), findsOneWidget);
    expect(identical(antes, tester.element(find.byType(TextField))), isTrue,
        reason: 'o título entrou antes do campo, mas o campo é o mesmo');
    expect(tester.testTextInput.hasAnyClients, isTrue,
        reason: 'o teclado continua aberto');
  });

  testWidgets('sem Premium, a prévia entra acima e o nome continua no mesmo '
      'campo, com o texto', (tester) async {
    await montar(tester, UserEntryCategory.crystal, auth: _AuthSemPremium.new);
    final l10n = l10nDe(tester);

    final antes = await focarNome(tester);
    await tester.enterText(find.byType(TextField), 'Ametista');
    await tester.pump();

    // Sem pumpAndSettle: a prévia traz o VeuVivo, que anima em loop e nunca
    // "assenta" — quadros contados bastam para a prévia aparecer.
    await tester.tap(find.text(l10n.encyAddTakePhoto));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l10n.encyLockedSaved), findsOneWidget,
        reason: 'a prévia dos campos apareceu');
    expect(identical(antes, tester.element(find.byType(TextField))), isTrue);
    expect(campoNome(tester).controller!.text, 'Ametista');
    expect(tester.testTextInput.hasAnyClients, isTrue);
  });

  testWidgets('o campo do nome é de uma linha: Enter conclui e não quebra',
      (tester) async {
    await montar(tester, UserEntryCategory.crystal);
    final campo = campoNome(tester);
    expect(campo.maxLines, 1);
    expect(campo.textInputAction, TextInputAction.done);

    await tester.enterText(find.byType(TextField), 'Quartzo\nrosa');
    await tester.pump();
    expect(campoNome(tester).controller!.text, 'Quartzorosa',
        reason: 'quebra de linha não entra no nome');
  });
}
