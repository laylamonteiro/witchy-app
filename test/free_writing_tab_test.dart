import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/pages/free_writing_tab.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/providers/free_writing_provider.dart';

class FakeFreeWritingProvider extends FreeWritingProvider {
  FakeFreeWritingProvider([List<FreeWritingModel> writings = const []])
      : _writings = List<FreeWritingModel>.from(writings);

  final List<FreeWritingModel> _writings;
  final List<FreeWritingModel> saved = [];
  final List<String> deleted = [];

  @override
  List<FreeWritingModel> get freeWritings => List.unmodifiable(_writings);

  /// Espelha o getter real: o histórico do canvas lista só as reflexões
  /// livres (o acervo unificado guarda também lições e leituras).
  @override
  List<FreeWritingModel> get reflections => _writings
      .where((w) => w.source == FreeWritingSource.free)
      .toList();

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<void> loadFreeWritings() async {}

  @override
  Future<void> save(FreeWritingModel writing) async {
    saved.add(writing);
    final index = _writings.indexWhere((item) => item.id == writing.id);
    if (index == -1) {
      _writings.add(writing);
    } else {
      _writings[index] = writing;
    }
    notifyListeners();
  }

  @override
  Future<void> delete(String id) async {
    deleted.add(id);
    _writings.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

Future<void> pumpFreeWritingTab(
  WidgetTester tester,
  FakeFreeWritingProvider provider,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<FreeWritingProvider>.value(
      value: provider,
      child: MaterialApp(locale: const Locale('pt', 'BR'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: const Scaffold(body: Text('Home')),
        routes: {
          '/write': (_) => const FreeWritingTab(),
        },
      ),
    ),
  );

  Navigator.of(tester.element(find.text('Home'))).pushNamed('/write');
  await tester.pumpAndSettle();
}

Future<void> openExistingReflection(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Reflexões anteriores'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Conteúdo antigo'));
  await tester.pumpAndSettle();
}

/// O botão de voltar do canvas. `tester.pageBack()` não serve aqui: ele
/// procura o tooltip 'Back' em inglês, e a suíte roda em pt_BR.
Future<void> tapBack(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('free_writing_back')));
  await tester.pumpAndSettle();
}

/// A escrita livre salva SOZINHA ao sair (README: "salvamento automático").
/// É promessa de produto — ninguém perde o que escreveu — e é isso que estes
/// testes fixam.
void main() {
  testWidgets('sai de reflexão nova salvando o rascunho', (tester) async {
    final provider = FakeFreeWritingProvider();
    await pumpFreeWritingTab(tester, provider);

    await tester.enterText(find.byType(TextField), 'rascunho novo');
    await tester.pump();
    await tapBack(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved.single.content, 'rascunho novo');
    expect(provider.freeWritings.single.content, 'rascunho novo');
  });

  testWidgets('edita reflexão existente e volta guardando o texto novo',
      (tester) async {
    final existing = FreeWritingModel(
      id: 'existing-id',
      content: 'Conteúdo antigo',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final provider = FakeFreeWritingProvider([existing]);
    await pumpFreeWritingTab(tester, provider);
    await openExistingReflection(tester);

    await tester.enterText(find.byType(TextField), 'Conteúdo alterado');
    await tester.pump();
    await tapBack(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved.single.id, 'existing-id');
    expect(provider.freeWritings.single.content, 'Conteúdo alterado');
  });

  testWidgets('editar e voltar grava UMA vez só', (tester) async {
    final existing = FreeWritingModel(
      id: 'existing-id',
      content: 'Conteúdo antigo',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final provider = FakeFreeWritingProvider([existing]);
    await pumpFreeWritingTab(tester, provider);
    await openExistingReflection(tester);

    await tester.enterText(find.byType(TextField), 'Conteúdo alterado');
    await tester.pump();
    await tapBack(tester);

    expect(find.text('Home'), findsOneWidget);
    // O botão salva e o PopScope roda em seguida: a guarda de conteúdo
    // inalterado evita a segunda gravação.
    expect(provider.saved, hasLength(1));
    expect(provider.freeWritings.single.content, 'Conteúdo alterado');
  });

  testWidgets('gesto/pop também salva o rascunho', (tester) async {
    final provider = FakeFreeWritingProvider();
    await pumpFreeWritingTab(tester, provider);

    await tester.enterText(find.byType(TextField), 'rascunho do pop');
    await tester.pump();
    Navigator.of(tester.element(find.byType(TextField))).pop();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved.single.content, 'rascunho do pop');
    expect(provider.freeWritings.single.content, 'rascunho do pop');
  });

  testWidgets('sair sem escrever nada não cria reflexão vazia',
      (tester) async {
    final provider = FakeFreeWritingProvider();
    await pumpFreeWritingTab(tester, provider);

    await tapBack(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved, isEmpty);
    expect(provider.freeWritings, isEmpty);
  });
}
