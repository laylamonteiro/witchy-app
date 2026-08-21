import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/highlighted_text.dart';

/// A marcação de realce é conteúdo editorial escrito à mão nos três idiomas.
/// Um `**` esquecido não pode virar texto quebrado na tela.
void main() {
  group('Divisão em partes', () {
    test('texto sem marcação sai inteiro, sem realce', () {
      final partes = HighlightedText.partes('Um texto simples');
      expect(partes.length, 1);
      expect(partes.first.texto, 'Um texto simples');
      expect(partes.first.realce, isFalse);
    });

    test('alterna corpo e realce na ordem', () {
      final partes = HighlightedText.partes('antes **meio** depois');
      expect(partes.map((p) => p.texto).toList(),
          ['antes ', 'meio', ' depois']);
      expect(partes.map((p) => p.realce).toList(), [false, true, false]);
    });

    test('vários realces no mesmo parágrafo', () {
      final partes = HighlightedText.partes('**um** e **dois**');
      expect(partes.where((p) => p.realce).map((p) => p.texto).toList(),
          ['um', 'dois']);
    });

    test('realce no começo e no fim', () {
      expect(HighlightedText.partes('**começo** do texto').first.realce, isTrue);
      expect(HighlightedText.partes('texto do **fim**').last.realce, isTrue);
    });

    test('marcação sem fechamento não perde texto', () {
      // O pior caso aceitável: o trecho sai sem realce, mas sai inteiro.
      final partes = HighlightedText.partes('texto **sem fechar');
      expect(partes.map((p) => p.texto).join(), 'texto **sem fechar');
    });

    test('marcação vazia não vira pedaço fantasma', () {
      final partes = HighlightedText.partes('a **** b');
      expect(partes.map((p) => p.texto).join(), 'a  b');
      expect(partes.any((p) => p.realce), isFalse);
    });

    test('texto vazio devolve lista vazia', () {
      expect(HighlightedText.partes(''), isEmpty);
    });
  });
}
