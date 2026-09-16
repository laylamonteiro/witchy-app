import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/grimoire_colors.dart';
import '../widgets/folha_com_saida.dart';
import '../widgets/magical_button.dart';
import 'convite_de_avaliacao.dart';
import 'regra_do_convite.dart';

/// O que a pessoa respondeu ao convite.
enum RespostaDoConvite {
  /// Tocou em "Avaliar".
  avaliou,

  /// Disse "agora não" — ou fechou a folha, que é a mesma coisa dita de outro
  /// jeito.
  agoraNao,
}

/// O convite para avaliar o app.
///
/// É NEUTRO de propósito: não pergunta se a pessoa está gostando, e não manda
/// quem diz "sim" para a loja e quem diz "não" para um formulário. Filtrar
/// opinião assim é o que a política da loja proíbe — e é o que dá suspensão.
/// Aqui só há dois caminhos, e os dois são honestos.
///
/// Fechar pelo X, pela alça ou tocando fora conta como "agora não": quem fecha
/// sem responder está respondendo.
Future<RespostaDoConvite> mostrarConviteDeAvaliacao(BuildContext context) async {
  final resposta = await mostrarFolhaComSaida<RespostaDoConvite>(
    context: context,
    builder: (context) => const _FolhaDeAvaliacao(),
  );
  return resposta ?? RespostaDoConvite.agoraNao;
}

class _FolhaDeAvaliacao extends StatelessWidget {
  const _FolhaDeAvaliacao();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: BotaoFecharFolha(
                onPressed: () => Navigator.of(context)
                    .pop(RespostaDoConvite.agoraNao),
              ),
            ),
            Icon(Icons.auto_awesome, size: 40, color: context.gc.starYellow),
            const SizedBox(height: 16),
            Text(
              l10n.conviteAvaliacaoTitulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.headlineSmall
                  ?.copyWith(color: context.gc.lilac),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.conviteAvaliacaoCorpo,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: context.gc.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            MagicalButton(
              key: const ValueKey('convite-avaliar'),
              text: l10n.conviteAvaliacaoAvaliar,
              icon: Icons.star_rounded,
              onPressed: () =>
                  Navigator.of(context).pop(RespostaDoConvite.avaliou),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const ValueKey('convite-agora-nao'),
              onPressed: () =>
                  Navigator.of(context).pop(RespostaDoConvite.agoraNao),
              style: TextButton.styleFrom(
                foregroundColor: context.gc.textSecondary,
              ),
              child: Text(l10n.conviteAvaliacaoAgoraNao),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostra o convite e guarda a resposta.
///
/// Devolve `true` quando a pessoa foi para a loja.
Future<bool> convidarEGuardar(
  BuildContext context,
  ConviteDeAvaliacao convite,
) async {
  await convite.registrarConvite();
  if (!context.mounted) return false;
  final resposta = await mostrarConviteDeAvaliacao(context);
  if (resposta == RespostaDoConvite.avaliou) {
    return convite.avaliar();
  }
  await convite.registrarDispensa();
  return false;
}

/// O convite inteiro, do começo ao fim.
///
/// Esta é a função que a política do Google torna delicada, e por isso ela mora
/// aqui, testável, em vez de ficar solta dentro do widget que a dispara: ONDE
/// HÁ CARD NATIVO, NADA NOSSO APARECE ANTES DELE. Inverter as duas partes
/// deixaria a suíte inteira verde e o app em desacordo com a loja — "your app
/// shouldn't ask the user any questions before or while presenting the rating
/// button or card".
///
/// A folha continua existindo para o único caso em que ela funciona: há Play no
/// aparelho, mas o fluxo do card falhou. Onde não há Play nenhum ninguém é
/// convidado — a folha manda para uma ficha que aquela pessoa não tem como
/// usar, e ainda marcaria "já avaliou" para sempre.
Future<void> convidarAgora(
  BuildContext context,
  ConviteDeAvaliacao convite,
  UsoAtePagora uso,
) async {
  if (convite.temCardNativo) {
    if (!convite.devoMostrarCard(uso)) return;
    final desfecho = await convite.pedirCardNativo();
    if (desfecho != DesfechoDoCard.falhou) return;
    if (!context.mounted) return;
  }
  if (!convite.devoConvidar(uso)) return;
  await convidarEGuardar(context, convite);
}
