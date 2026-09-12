import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/folha_com_saida.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/data_sources/oracle_cards_data.dart';
import '../../data/models/oracle_card_model.dart';
import '../../data/repositories/oracle_discovery_repository.dart';
import '../widgets/grimoire_card_back.dart';
import '../widgets/oracle_card_face.dart';

/// O álbum das 44 cartas: as que já apareceram numa tiragem confirmada
/// ficam abertas, com a data do primeiro encontro; as demais continuam
/// fechadas, sem entregar nome nem mensagem.
///
/// Abrir o álbum faz a retrospectiva silenciosa das leituras que já existem
/// neste aparelho. Nada aqui descobre carta, dá XP ou celebra: quem registra
/// é a confirmação da tiragem, e uma carta repetida não muda a contagem.
class OracleAlbumPage extends StatefulWidget {
  const OracleAlbumPage({super.key, this.repository});

  final OracleDiscoveryRepository? repository;

  @override
  State<OracleAlbumPage> createState() => _OracleAlbumPageState();
}

class _OracleAlbumPageState extends State<OracleAlbumPage> {
  late final OracleDiscoveryRepository _repository =
      widget.repository ?? OracleDiscoveryRepository();

  Map<int, DateTime> _found = const {};
  bool _loading = true;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser.id;
    _userId = userId;
    try {
      await _repository.backfill(userId);
      final found = await _repository.firstSeen(userId);
      if (!mounted || _userId != userId) return;
      setState(() {
        _found = found;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(OracleCard card, DateTime? seenAt) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: MagicalCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A saída, visível. Arrastar e tocar fora sempre fecharam
                // esta folha, mas no navegador do celular nenhum dos dois
                // gestos se anuncia — e folha sem saída anunciada é folha
                // sem saída. A alça do Material não serve aqui: esta folha
                // pinta o próprio cartão sobre fundo transparente, e a alça
                // flutuaria no escurecido, fora dele.
                const Align(
                  alignment: Alignment.centerRight,
                  child: BotaoFecharFolha(),
                ),
                Center(child: OracleCardFace(card: card, width: 120)),
                const SizedBox(height: 12),
                Text(card.name,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: context.gc.lilac)),
                if (seenAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.oracleAlbumFoundOn(_date(seenAt)),
                    style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Text(card.message,
                    style: TextStyle(color: context.gc.textPrimary, height: 1.4)),
                const SizedBox(height: 12),
                Text(card.guidance,
                    style: TextStyle(color: context.gc.textSecondary, height: 1.4)),
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final word in card.keywords)
                    Chip(
                      label: Text(word, style: const TextStyle(fontSize: 11)),
                      backgroundColor: context.gc.surface,
                      side: BorderSide(color: context.gc.surfaceBorder),
                    ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _date(DateTime when) =>
      '${when.day.toString().padLeft(2, '0')}/'
      '${when.month.toString().padLeft(2, '0')}/${when.year}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = oracleCardsData;
    final reduced = GrimoireMotion.reduced(context);
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.oracleAlbumTitle),
        backgroundColor: context.gc.surface,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    l10n.oracleAlbumProgress(_found.length, cards.length),
                    key: const ValueKey('oracle-album-count'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: context.gc.gold, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_found.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.oracleAlbumEmpty,
                      key: const ValueKey('oracle-album-empty'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    key: const ValueKey('oracle-album'),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 110,
                      childAspectRatio: OracleCardFace.aspectRatio,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final seenAt = _found[card.id];
                      return _AlbumSlot(
                        card: card,
                        seenAt: seenAt,
                        reduced: reduced,
                        order: index,
                        onTap: () => seenAt == null
                            ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(l10n.oracleAlbumLocked),
                                duration: const Duration(seconds: 2),
                              ))
                            : _open(card, seenAt),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// Uma vaga do álbum: a carta aberta, ou o verso fechado de quem ainda não
/// apareceu. O verso nunca mostra nome, mensagem nem emoji da carta.
class _AlbumSlot extends StatelessWidget {
  const _AlbumSlot({
    required this.card,
    required this.seenAt,
    required this.reduced,
    required this.order,
    required this.onTap,
  });

  final OracleCard card;
  final DateTime? seenAt;
  final bool reduced;
  final int order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final found = seenAt != null;
    final slot = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return found
            ? OracleCardFace(
                key: ValueKey('oracle-album-card-${card.id}'),
                card: card,
                width: width,
              )
            : Opacity(
                opacity: .55,
                child: GrimoireCardBack(
                  key: ValueKey('oracle-album-locked-${card.id}'),
                  width: width,
                  height: width / OracleCardFace.aspectRatio,
                  deckPosition: order,
                  face: GrimoireBackFace.oracle,
                ),
              );
      },
    );
    return Semantics(
      button: true,
      label: found
          ? card.name
          : AppLocalizations.of(context).oracleAlbumLocked,
      child: GestureDetector(
        onTap: onTap,
        child: reduced
            ? slot
            : TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: GrimoireMotion.reveal,
                curve: GrimoireMotion.enter,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.scale(scale: .94 + .06 * t, child: child),
                ),
                child: slot,
              ),
      ),
    );
  }
}
