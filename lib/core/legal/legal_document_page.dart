import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/app_theme.dart';
import '../theme/grimoire_colors.dart';

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

  static const terms = LegalDocumentPage(
    title: 'Termos de Uso',
    assetPath: 'assets/legal/termos_de_uso.md',
  );

  static const privacy = LegalDocumentPage(
    title: 'Política de Privacidade',
    assetPath: 'assets/legal/politica_de_privacidade.md',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(title),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: context.gc.lilac),
            );
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
