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

  // A página da enciclopédia passou a nascer pelo Gemini porque a Groq
  // devolvia 400 na chamada com `response_format: json_object` — o modelo
  // novo (gpt-oss-120b) não aceita o que o antigo aceitava. O log só dizia
  // "-> 400", e o app caía no provedor de reserva sem tentar nada.
  group('devePedirDeNovoSemModoJson', () {
    test('400 com modo JSON: repete sem o parâmetro', () {
      expect(
        AIService.devePedirDeNovoSemModoJson(modoJson: true, status: 400),
        isTrue,
      );
    });

    test('400 sem modo JSON: o pedido é que está errado, não o parâmetro', () {
      expect(
        AIService.devePedirDeNovoSemModoJson(modoJson: false, status: 400),
        isFalse,
      );
    });

    test('o que é passageiro ou definitivo não vira repetição sem JSON', () {
      for (final status in [429, 503, 404, 401, 500, null]) {
        expect(
          AIService.devePedirDeNovoSemModoJson(modoJson: true, status: status),
          isFalse,
          reason: 'HTTP $status',
        );
      }
    });
  });

  group('corpoDeTextoDaGroq', () {
    Map<String, dynamic> corpo({required bool modoJson, String sistema = 'S'}) =>
        AIService.corpoDeTextoDaGroq(
          modelo: 'openai/gpt-oss-120b',
          systemPrompt: sistema,
          userText: 'U',
          temperature: 0.5,
          maxTokens: 1200,
          modoJson: modoJson,
        );

    test('com modo JSON o response_format vai junto', () {
      expect(corpo(modoJson: true)['response_format'],
          {'type': 'json_object'});
    });

    test('sem modo JSON o parâmetro some — o resto continua igual', () {
      final sem = corpo(modoJson: false);
      expect(sem.containsKey('response_format'), isFalse);
      expect(sem['model'], 'openai/gpt-oss-120b');
      expect(sem['temperature'], 0.5);
      expect(sem['max_tokens'], 1200);
      expect(sem['messages'], [
        {'role': 'system', 'content': 'S'},
        {'role': 'user', 'content': 'U'},
      ]);
    });

    test('prompt de sistema vazio não vira mensagem', () {
      final mensagens = corpo(modoJson: true, sistema: '')['messages'] as List;
      expect(mensagens, hasLength(1));
      expect(mensagens.single, {'role': 'user', 'content': 'U'});
    });
  });

  // O corpo do erro chega inteiro: a função `ia` devolve o do provedor sem
  // tocar. Sem esta leitura o log dizia só "HTTP 400".
  group('motivoDoProvedor', () {
    test('erro da Groq: mensagem e tipo', () {
      expect(
        AIService.motivoDoProvedor({
          'error': {
            'message': "'response_format' is not supported",
            'type': 'invalid_request_error',
          }
        }),
        "'response_format' is not supported | invalid_request_error",
      );
    });

    test('erro do Gemini: código numérico não polui a linha', () {
      expect(
        AIService.motivoDoProvedor({
          'error': {'code': 503, 'message': 'The model is overloaded'}
        }),
        'The model is overloaded',
      );
    });

    test('recusa da nossa função vem como texto curto', () {
      expect(AIService.motivoDoProvedor({'erro': 'modelo'}), 'modelo');
    });

    test('corpo em texto puro é aproveitado; vazio e nulo viram nada', () {
      expect(AIService.motivoDoProvedor('Bad Gateway'), 'Bad Gateway');
      expect(AIService.motivoDoProvedor('   '), isNull);
      expect(AIService.motivoDoProvedor(null), isNull);
    });

    test('mensagem enorme é cortada', () {
      final motivo = AIService.motivoDoProvedor({
        'error': {'message': 'x' * 500}
      });
      expect(motivo!.length, lessThanOrEqualTo(201));
      expect(motivo, endsWith('…'));
    });
  });
}
