import 'package:flutter/material.dart';
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
      child: MaterialApp(
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

void main() {
  testWidgets('sai de reflexão nova sem salvar', (tester) async {
    final provider = FakeFreeWritingProvider();
    await pumpFreeWritingTab(tester, provider);

    await tester.enterText(find.byType(TextField), 'rascunho novo');
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved, isEmpty);
    expect(provider.freeWritings, isEmpty);
  });

  testWidgets('edita reflexão existente e volta mantendo conteúdo antigo',
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
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved, isEmpty);
    expect(provider.freeWritings.single.content, 'Conteúdo antigo');
  });

  testWidgets('botão de voltar descarta alterações sem salvar', (tester) async {
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
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved, isEmpty);
    expect(provider.freeWritings.single.content, 'Conteúdo antigo');
  });

  testWidgets('gesto/pop descarta alterações sem salvar', (tester) async {
    final provider = FakeFreeWritingProvider();
    await pumpFreeWritingTab(tester, provider);

    await tester.enterText(find.byType(TextField), 'rascunho do pop');
    await tester.pump();
    Navigator.of(tester.element(find.byType(TextField))).pop();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(provider.saved, isEmpty);
    expect(provider.freeWritings, isEmpty);
  });
}
