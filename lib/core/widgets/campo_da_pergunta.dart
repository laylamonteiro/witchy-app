import 'package:flutter/material.dart';

import '../divination/regra_da_tiragem.dart';
import '../theme/grimoire_colors.dart';
import 'magical_card.dart';

/// A caixa da pergunta, a mesma nas três adivinhações.
///
/// Ela vive na tela de ESCOLHA, acima do leque, e continua editável enquanto a
/// pessoa escolhe a carta — a pergunta é parte do gesto de tirar, não um
/// formulário antes dele.
///
/// Embaixo do campo vai o aviso do que aquela pergunta custa, ANTES de
/// qualquer escolha. É a razão de o widget existir: a surpresa cara é a outra
/// ordem — escolher a carta e só então descobrir que aquela pergunta gastava a
/// tiragem do dia, ou que não havia mais tiragem.
///
/// O widget não tem estado, banco nem provider: tudo chega pronto, e é isso
/// que deixa a mesma caixa servir três repositórios diferentes. Ele também
/// NUNCA cria o próprio [focusNode] nem mexe no foco — quem manda no foco é a
/// página. Com um nó interno, uma reconstrução que re-infla a subárvore leva o
/// foco junto e o teclado fecha sozinho no Android.
class CampoDaPergunta extends StatelessWidget {
  const CampoDaPergunta({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.rotulo,
    required this.dica,
    required this.situacao,
    this.mostrarCota = true,
    this.textoDoAviso,
    this.rotuloDoAtalho,
    this.aoUsarOAtalho,
    this.habilitado = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  /// "Sua pergunta" — o mesmo rótulo nas três, de propósito.
  final String rotulo;

  /// O convite, este sim diferente em cada ferramenta.
  final String dica;

  final SituacaoDaTiragem situacao;

  /// Premium não tem cota, então o aviso de cota não diz nada a ele. "Mesa já
  /// feita" continua aparecendo: vale para qualquer plano.
  final bool mostrarCota;

  /// A frase do aviso, já traduzida. Nulo = nada a dizer neste estado.
  final String? textoDoAviso;

  /// O rótulo da saída oferecida junto do aviso ("Voltar para a pergunta de
  /// hoje", "Ver a mesa"). Nulo = sem atalho.
  final String? rotuloDoAtalho;
  final VoidCallback? aoUsarOAtalho;

  final bool habilitado;

  Color _corDoAviso(BuildContext context) => switch (situacao) {
        SituacaoDaTiragem.livre => context.gc.success,
        SituacaoDaTiragem.gastaUma => context.gc.starYellow,
        SituacaoDaTiragem.semCota => context.gc.alert,
        SituacaoDaTiragem.jaFeita => context.gc.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final gold = context.gc.gold;
    final aviso = (situacao == SituacaoDaTiragem.jaFeita || mostrarCota)
        ? textoDoAviso
        : null;
    return MagicalCard.accent(
      accent: gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey('campo-da-pergunta'),
            controller: controller,
            focusNode: focusNode,
            enabled: habilitado,
            maxLines: 2,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(color: context.gc.textPrimary),
            decoration: InputDecoration(
              labelText: rotulo,
              labelStyle: TextStyle(color: gold, fontWeight: FontWeight.w600),
              hintText: dica,
              hintStyle: TextStyle(
                color: context.gc.starYellow.withValues(alpha: 0.7),
                fontSize: 13,
              ),
              prefixIcon: Icon(Icons.auto_awesome, color: gold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: gold.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: gold.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: gold, width: 1.5),
              ),
            ),
          ),
          if (aviso != null) ...[
            const SizedBox(height: 8),
            // `liveRegion` porque o aviso muda enquanto a pessoa digita: quem
            // usa leitor de tela precisa ouvir que o custo mudou.
            Semantics(
              liveRegion: true,
              child: Text(
                aviso,
                key: const ValueKey('aviso-da-pergunta'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _corDoAviso(context),
                    ),
              ),
            ),
          ],
          if (rotuloDoAtalho != null && aoUsarOAtalho != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const ValueKey('atalho-da-pergunta'),
                onPressed: aoUsarOAtalho,
                style: TextButton.styleFrom(
                  foregroundColor: context.gc.lilac,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(rotuloDoAtalho!),
              ),
            ),
        ],
      ),
    );
  }
}
