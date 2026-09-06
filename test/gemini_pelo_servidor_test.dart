import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/ai_service.dart';

/// Etapa 4 de docs/CHAVES_DE_IA.md: no build web a chave da Gemini fica
/// VAZIA de propósito (ela mora na Edge Function `ia`). Antes, o app
/// decidia "tem Gemini?" olhando só a chave local — e, com ela vazia,
/// degradaria visão e sonhos para Groq em silêncio, mesmo com a chave no
/// servidor. Este teste tranca a regra nova.
void main() {
  bool tem({required bool peloServidor, required bool chaveLocal}) =>
      AIService.temGeminiDisponivel(
        peloServidor: peloServidor,
        chaveLocal: chaveLocal,
      );

  group('temGeminiDisponivel', () {
    test('pelo servidor, com chave local VAZIA ⇒ tem Gemini (o caso da web)',
        () {
      expect(tem(peloServidor: true, chaveLocal: false), isTrue);
    });

    test('caminho direto, com chave local ⇒ tem Gemini (Android de hoje)', () {
      expect(tem(peloServidor: false, chaveLocal: true), isTrue);
    });

    test('caminho direto, sem chave local ⇒ não tem (nunca inventa)', () {
      expect(tem(peloServidor: false, chaveLocal: false), isFalse);
    });

    test('pelo servidor e com chave local ⇒ tem (redundância inofensiva)',
        () {
      expect(tem(peloServidor: true, chaveLocal: true), isTrue);
    });
  });
}
