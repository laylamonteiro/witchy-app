import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/ai/ai_service.dart';

// A página do cristal falhou com o Groq em 404 e o Gemini em 503 logo
// atrás, sem ninguém tentar de novo. Esta é a regra que decide o que merece
// nova tentativa — e o que só faria a pessoa esperar mais.
void main() {
  group('ehStatusTransitorio', () {
    test('429 e 503 passam: somem sozinhos em segundos', () {
      // 429 é o teto de requisições por minuto (deslizante).
      expect(AIService.ehStatusTransitorio(429), isTrue);
      // 503 é "modelo sobrecarregado" do Gemini.
      expect(AIService.ehStatusTransitorio(503), isTrue);
    });

    test('404 não: modelo fora do catálogo não volta por insistência', () {
      expect(AIService.ehStatusTransitorio(404), isFalse);
    });

    test('erro de pedido e falha do servidor não repetem', () {
      for (final status in [400, 401, 403, 413, 422, 500, 502]) {
        expect(AIService.ehStatusTransitorio(status), isFalse,
            reason: 'HTTP $status');
      }
    });

    test('sem status (queda de rede) fica com quem chamou', () {
      expect(AIService.ehStatusTransitorio(null), isFalse);
    });

    test('sucesso nunca é tentado de novo', () {
      expect(AIService.ehStatusTransitorio(200), isFalse);
    });
  });
}
