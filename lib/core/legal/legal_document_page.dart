import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../content/content_locale.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/app_theme.dart';
import '../theme/grimoire_colors.dart';
import '../widgets/loading_widget.dart';

/// Exibe um documento legal empacotado como asset (offline, sem servidor).
/// Renderiza um subconjunto simples de Markdown: #, ##, ###, listas e texto.
class LegalDocumentPage extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  // Título e documento seguem o idioma ativo. Um documento legal que a
  // pessoa não entende não a informa de nada: o app é oferecido em três
  // idiomas, e os três precisam poder ler o que autorizam.
  static LegalDocumentPage get terms => LegalDocumentPage(
        title: lookupAppLocalizations(ContentLocale.instance.locale)
            .authTermsOfUse,
        assetPath: caminhoDosTermos(),
      );

  static LegalDocumentPage get privacy => LegalDocumentPage(
        title: lookupAppLocalizations(ContentLocale.instance.locale)
            .authPrivacyPolicy,
        assetPath: caminhoDaPolitica(),
      );

  /// O português é o texto canônico — é dele que as traduções saem, e é ele
  /// que vale quando um idioma ainda não tem a sua. Por isso a variante PT
  /// não leva sufixo: o arquivo sem sufixo é a reserva de todos.
  static String caminhoDosTermos() => ContentLocale.instance.select(
        pt: 'assets/legal/termos_de_uso.md',
        en: 'assets/legal/termos_de_uso_en.md',
        es: 'assets/legal/termos_de_uso_es.md',
      );

  static String caminhoDaPolitica() => ContentLocale.instance.select(
        pt: 'assets/legal/politica_de_privacidade.md',
        en: 'assets/legal/politica_de_privacidade_en.md',
        es: 'assets/legal/politica_de_privacidade_es.md',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(title),
      ),
      body: FutureBuilder<String>(
        future: _carregarDocumento(),
        builder: (context, snapshot) {
          // A reserva cobre a tradução que falta; não cobre o asset que não
          // abre. Sem este ramo o erro vira um carregamento eterno, que é o
          // pior dos dois: a pessoa fica esperando um documento que não vem.
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Text(
                AppLocalizations.of(context).errorsGeneric,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.55),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const LoadingWidget();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _renderMarkdown(context, snapshot.data!),
            ),
          );
        },
      ),
    );
  }

  /// Uma tradução que falte no bundle cai no texto em português, que é o
  /// único que sempre existe. O que a reserva não alcança — o asset que não
  /// abre — sai daqui como erro, e quem o mostra é o ramo `hasError` acima.
  Future<String> _carregarDocumento() async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (_) {
      final reserva = assetPath.replaceFirst(RegExp(r'_(en|es)\.md$'), '.md');
      if (reserva == assetPath) rethrow;
      return rootBundle.loadString(reserva);
    }
  }

  List<Widget> _renderMarkdown(BuildContext context, String source) {
    final widgets = <Widget>[];
    for (final rawLine in source.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 10));
      } else if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Text(
            line.substring(2),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.gc.lilac,
                ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            line.substring(3),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.gc.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Text(
            line.substring(4),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: TextStyle(color: context.gc.lilac)),
              Expanded(
                child: Text(
                  _stripInlineMarks(line.substring(2)),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Text(
          _stripInlineMarks(line),
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
        ));
      }
    }
    return widgets;
  }

  /// Remove marcações inline simples (**negrito**) mantendo o texto.
  String _stripInlineMarks(String text) => text.replaceAll('**', '');
}
