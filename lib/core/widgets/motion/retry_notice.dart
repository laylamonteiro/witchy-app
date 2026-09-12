import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/grimoire_colors.dart';
import '../magical_card.dart';

/// A falha que fica na tela, igual em toda ferramenta: o que aconteceu e,
/// quando há como tentar de novo, o convite explícito.
///
/// Um aviso que some deixa a pessoa sem resultado e sem saber o que fazer.
/// Aqui nada é refeito sozinho e nada anuncia sucesso: a retomada é sempre
/// uma escolha, e quem decide o que ela repete é a tela que chamou.
class RetryNotice extends StatelessWidget {
  const RetryNotice({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.retryKey,
    this.card = true,
  });

  /// O que aconteceu, já na língua da pessoa.
  final String message;

  /// Null quando não há o que repetir — a mensagem fica, sem convite.
  final VoidCallback? onRetry;

  /// Rótulo do convite; por padrão, o "Tentar de novo" comum do app.
  final String? retryLabel;

  /// Chave do convite. Cada ferramenta mantém a sua, que é por onde os
  /// testes tocam nele.
  final Key? retryKey;

  /// Em `false` devolve só o conteúdo, para telas que já têm o cartão.
  final bool card;

  @override
  Widget build(BuildContext context) {
    final colors = context.gc;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: colors.alert, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: colors.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: retryKey ?? const ValueKey('retry-notice-action'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(retryLabel ?? AppLocalizations.of(context).commonTryAgain),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.lilac,
              side: BorderSide(color: colors.lilac),
            ),
          ),
        ],
      ],
    );
    return card ? MagicalCard(child: content) : content;
  }
}
