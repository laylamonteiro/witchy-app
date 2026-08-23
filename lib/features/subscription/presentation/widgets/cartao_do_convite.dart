import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/models/feature_access.dart' show LimitWindow;
import '../../../auth/data/models/user_model.dart';
import '../../domain/convite_do_plano.dart';
import '../pages/pagina_de_descoberta.dart';
import 'vislumbres_do_premium.dart';

/// O convite ao Premium nas Configurações — um cartão que REAGE ao momento
/// da pessoa, em vez de repetir uma tabela.
///
/// O que havia antes era um placar: três linhas fixas com "0/10 · 0/30 ·
/// 0/1". Zero usado é exatamente quando o limite parece generoso e distante,
/// então o melhor espaço da tela era gasto para dizer "você tem muito
/// ainda" — o oposto de despertar vontade. E quando a pessoa de fato
/// esbarrava no limite, o cartão mostrava a mesma coisa, do mesmo tamanho.
///
/// Três estados, um componente só:
///
/// - **longe** — os números somem. No lugar deles, o que ela ainda não viu.
/// - **perto** — aparece UM número, o que está perto. Informação útil no
///   momento em que ela é útil.
/// - **no limite** — o cartão cresce e diz o que havia do outro lado
///   daquela consulta. Não "você atingiu o limite": o limite ela já sentiu.
///
/// O toque leva à [PaginaDeDescoberta], nunca direto à tabela de preços.
class CartaoDoConvite extends StatelessWidget {
  const CartaoDoConvite({super.key, required this.user, this.agora});

  final UserModel user;

  /// Só o teste passa: a rotação do vislumbre é por dia, e um teste que
  /// dependesse do relógio da máquina falharia sozinho à meia-noite.
  final DateTime? agora;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final limites = limitesDoPlanoGratuito(user, _rotulos(l10n));
    final momento = lerOMomento(limites);
    final noLimite = momento.estado == EstadoDoConvite.noLimite;

    return InkWell(
      onTap: () => PaginaDeDescoberta.abrir(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(noLimite ? 20 : 18),
        decoration: BoxDecoration(
          // O convite não é mais um cartão igual aos outros da tela.
          //
          // Ele era: fundo `surface` chapado e borda a 10% — a mesma casca
          // do Idioma e do Tema, logo abaixo. Um convite que se veste de
          // item de configuração é lido como item de configuração, e o
          // olho passa direto. Agora ele tem cor própria (um banho de
          // lilás sobre a superfície), borda que se enxerga e um halo
          // suave: continua sóbrio, mas se apresenta como convite.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(context.gc.surface, context.gc.lilac,
                  noLimite ? 0.20 : 0.13)!,
              Color.lerp(context.gc.surface, context.gc.pink,
                  noLimite ? 0.12 : 0.06)!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // No limite a borda acende mais: a hierarquia entre os três
            // estados continua de pé — o que mudou foi o piso.
            color: context.gc.lilac.withValues(alpha: noLimite ? 0.65 : 0.38),
            width: noLimite ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: context.gc.lilac.withValues(alpha: noLimite ? 0.22 : 0.12),
              blurRadius: noLimite ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: switch (momento.estado) {
          EstadoDoConvite.longe => _Longe(agora: agora),
          EstadoDoConvite.perto => _Perto(limite: momento.emFoco!),
          EstadoDoConvite.noLimite => _NoLimite(limite: momento.emFoco!),
        },
      ),
    );
  }

  /// Os rótulos das cotas. Os três primeiros já existiam na tela antiga e
  /// ficam como estavam — trocar o nome do que a pessoa já conhece não era
  /// o problema.
  Map<BalcaoDoLimite, String> _rotulos(AppLocalizations l10n) => {
        BalcaoDoLimite.feiticos: l10n.profileSpells,
        BalcaoDoLimite.diario: l10n.profileDiaryEntries,
        BalcaoDoLimite.conselheiro: l10n.profileMysticAdvisor,
        BalcaoDoLimite.ia: l10n.conviteRotuloIa,
        BalcaoDoLimite.runas: l10n.conviteRotuloRunas,
        BalcaoDoLimite.pendulo: l10n.conviteRotuloPendulo,
        BalcaoDoLimite.oraculo: l10n.conviteRotuloOraculo,
        BalcaoDoLimite.afirmacoes: l10n.conviteRotuloAfirmacoes,
      };
}

/// Longe de tudo: curiosidade, não contagem.
class _Longe extends StatelessWidget {
  const _Longe({this.agora});

  final DateTime? agora;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final vislumbres = vislumbresDoPremium(l10n);
    final atual =
        vislumbres[indiceDoVislumbre(agora ?? DateTime.now(), vislumbres.length)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Cabecalho(texto: l10n.conviteTituloLonge),
        const SizedBox(height: 12),
        Text(
          atual.titulo,
          style: tema.textTheme.titleMedium?.copyWith(
            color: context.gc.lilac,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          atual.linha,
          style: tema.textTheme.bodySmall?.copyWith(
            color: context.gc.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        _Convite(rotulo: l10n.conviteVerOQueAbre),
      ],
    );
  }
}

/// Na última: um número, e só o que está perto.
class _Perto extends StatelessWidget {
  const _Perto({required this.limite});

  final LimiteVisivel limite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    final frase = switch (limite.janela) {
      LimitWindow.daily => l10n.conviteUltimaHoje(limite.rotulo),
      LimitWindow.monthly => l10n.conviteUltimaEsteMes(limite.rotulo),
      LimitWindow.total => l10n.conviteUltimaNoTotal(limite.rotulo),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          frase,
          style: tema.textTheme.titleSmall?.copyWith(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: limite.fracao.clamp(0, 1),
            minHeight: 4,
            backgroundColor: context.gc.textPrimary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(context.gc.gold),
          ),
        ),
        const SizedBox(height: 14),
        _Convite(rotulo: l10n.conviteVerOQueAbre),
      ],
    );
  }
}

/// Acabou: o que havia do outro lado.
class _NoLimite extends StatelessWidget {
  const _NoLimite({required this.limite});

  final LimiteVisivel limite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Cabecalho(texto: l10n.conviteTituloNoLimite),
        const SizedBox(height: 14),
        Text(
          _oQueHavia(l10n, limite.chave),
          style: tema.textTheme.bodyMedium?.copyWith(
            color: context.gc.textPrimary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 18),
        _Convite(rotulo: l10n.conviteVerOQueAbre, forte: true),
      ],
    );
  }

  String _oQueHavia(AppLocalizations l10n, BalcaoDoLimite balcao) =>
      switch (balcao) {
        BalcaoDoLimite.feiticos => l10n.conviteAlemFeiticos,
        BalcaoDoLimite.diario => l10n.conviteAlemDiario,
        BalcaoDoLimite.conselheiro => l10n.conviteAlemConselheiro,
        BalcaoDoLimite.ia => l10n.conviteAlemIa,
        BalcaoDoLimite.runas => l10n.conviteAlemRunas,
        BalcaoDoLimite.pendulo => l10n.conviteAlemPendulo,
        BalcaoDoLimite.oraculo => l10n.conviteAlemOraculo,
        BalcaoDoLimite.afirmacoes => l10n.conviteAlemAfirmacoes,
      };
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Um emblema, e não um cadeado: cadeado diz "você não pode", que é
        // exatamente a leitura que este cartão existe para evitar.
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.gc.lilac.withValues(alpha: 0.18),
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 17,
            color: context.gc.lilac,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.gc.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

/// O convite. Sem botão de verdade: o cartão INTEIRO é tocável, e um botão
/// dentro de um cartão tocável dá dois alvos para a mesma ação.
class _Convite extends StatelessWidget {
  const _Convite({required this.rotulo, this.forte = false});

  final String rotulo;
  final bool forte;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          rotulo,
          style: TextStyle(
            color: context.gc.lilac,
            fontSize: forte ? 15 : 13,
            fontWeight: forte ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, size: forte ? 20 : 16, color: context.gc.lilac),
      ],
    );
  }
}
