import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/app_session_policy.dart';

/// A volta para o app: quando ela é "nova sessão" e quando vale gastar uma
/// sincronização.
void main() {
  final agora = DateTime(2026, 8, 23, 18, 0);

  group('nova sessão', () {
    test('sem carimbo de segundo plano, não há sessão nova', () {
      expect(
        AppSessionPolicy.shouldStartNewSession(
            backgroundedAt: null, now: agora),
        isFalse,
      );
    });

    test('meia hora fora começa sessão nova', () {
      expect(
        AppSessionPolicy.shouldStartNewSession(
          backgroundedAt: agora.subtract(const Duration(minutes: 30)),
          now: agora,
        ),
        isTrue,
      );
    });

    test('uma saída rápida não recomeça nada', () {
      expect(
        AppSessionPolicy.shouldStartNewSession(
          backgroundedAt: agora.subtract(const Duration(minutes: 2)),
          now: agora,
        ),
        isFalse,
      );
    });
  });

  group('auto-sync da retomada', () {
    test('sem tentativa anterior, sincroniza', () {
      expect(
        AppSessionPolicy.deveAutoSincronizar(
            ultimaTentativa: null, now: agora),
        isTrue,
      );
    });

    test('uma TENTATIVA recente segura a próxima, mesmo que tenha falhado',
        () {
      // O carimbo é de tentativa justamente por isto: contando só sucessos,
      // uma sincronização que falha reabre a porta a cada volta para a aba —
      // e na web a varredura roda na thread da interface.
      expect(
        AppSessionPolicy.deveAutoSincronizar(
          ultimaTentativa: agora.subtract(const Duration(minutes: 3)),
          now: agora,
        ),
        isFalse,
      );
    });

    test('passada a folga, sincroniza de novo', () {
      expect(
        AppSessionPolicy.deveAutoSincronizar(
          ultimaTentativa: agora.subtract(AppSessionPolicy.folgaEntreAutoSyncs),
          now: agora,
        ),
        isTrue,
      );
    });
  });
}
