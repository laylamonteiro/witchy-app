import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/free_writing_provider.dart';
import '../../data/models/free_writing_model.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'free_writings_list_page.dart';

/// Aba 💡 de Diários: canvas de escrita livre.
///
/// Superfície fluida e sem pressão — a pessoa simplesmente escreve. O texto é
/// salvo apenas por ação explícita, guardado no histórico e sincronizado.
class FreeWritingTab extends StatefulWidget {
  const FreeWritingTab({super.key});

  @override
  State<FreeWritingTab> createState() => _FreeWritingTabState();
}

class _FreeWritingTabState extends State<FreeWritingTab> {
  final _controller = TextEditingController();
  late FreeWritingProvider _provider;

  /// Reflexão sendo editada no momento (null = canvas em branco/nova).
  FreeWritingModel? _current;
  String _originalContent = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FreeWritingProvider>().loadFreeWritings();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = context.read<FreeWritingProvider>();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    // Rebuild leve para alternar a visibilidade das ações conforme há texto.
    setState(() {});
  }

  /// Salva a reflexão atual. Chamado automaticamente ao sair da tela ou iniciar
  /// uma nova reflexão — assim a pessoa nunca perde o que escreveu.
  Future<void> _save() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    // Nada mudou em uma reflexão já carregada: evita gravações repetidas.
    if (_current != null && text == _originalContent) return;

    final model = _current == null
        ? FreeWritingModel(content: text)
        : _current!.copyWith(content: text);

    await _provider.save(model);
    if (!mounted) return;
    setState(() {
      _current = model;
      _originalContent = text;
    });
  }

  Future<bool> _handleBack() async {
    // Salva automaticamente antes de sair.
    await _save();
    return true;
  }

  Future<void> _openHistory() async {
    // Salva a reflexão atual antes de abrir o histórico.
    await _save();
    if (!mounted) return;
    final selected = await Navigator.of(context).push<FreeWritingModel>(
      MaterialPageRoute(builder: (_) => const FreeWritingsListPage()),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _current = selected;
      _originalContent = selected.content;
      _controller.text = selected.content;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  Future<void> _newReflection() async {
    FocusScope.of(context).unfocus();
    // Salva a reflexão atual antes de abrir um canvas em branco.
    await _save();
    if (!mounted) return;
    setState(() {
      _current = null;
      _originalContent = '';
      _controller.clear();
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppLocalizations.of(context)!.commonGoodMorning;
    if (hour < 18) return AppLocalizations.of(context)!.commonGoodAfternoon;
    return AppLocalizations.of(context)!.commonGoodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _save();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      _greeting,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                    ),
                    const Spacer(),
                    if (Navigator.of(context).canPop())
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: context.gc.lilac,
                        ),
                        tooltip: AppLocalizations.of(context)!.commonBack,
                        onPressed: () async {
                          if (await _handleBack() && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.history, color: context.gc.lilac),
                      tooltip: AppLocalizations.of(context)!.diaryPreviousReflections,
                      onPressed: _openHistory,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: context.gc.lilac,
                    style: TextStyle(
                      color: context.gc.softWhite,
                      fontSize: 17,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppLocalizations.of(context)!.diaryFreeWritingHint,
                      hintStyle: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.4),
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: hasText
            ? MagicalFAB(
                onPressed: _newReflection,
                icon: Icons.edit_note,
              )
            : null,
      ),
    );
  }
}
