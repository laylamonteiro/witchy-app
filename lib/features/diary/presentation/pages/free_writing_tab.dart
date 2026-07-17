import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/free_writing_provider.dart';
import '../../data/models/free_writing_model.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/app_theme.dart';
import 'free_writings_list_page.dart';

/// Aba 💡 de Diários: canvas de escrita livre.
///
/// Superfície fluida e sem pressão — a pessoa simplesmente escreve. O texto é
/// salvo automaticamente (debounce), guardado no histórico e sincronizado.
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
  Timer? _debounce;

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
    _debounce?.cancel();
    _controller.removeListener(_onChanged);
    // Salvamento final (best-effort) do que ficou pendente no canvas.
    _persist();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    // Rebuild leve para alternar a visibilidade do FAB conforme há texto.
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _persist);
  }

  /// Persiste (upsert) ou apaga a reflexão atual conforme o conteúdo do canvas.
  void _persist() {
    final text = _controller.text;

    if (text.trim().isEmpty) {
      // Canvas vazio: não deixa reflexão vazia no histórico.
      if (_current != null) {
        _provider.delete(_current!.id);
        _current = null;
      }
      return;
    }

    final model = _current == null
        ? FreeWritingModel(content: text)
        : _current!.copyWith(content: text);
    _current = model;
    _provider.save(model);
  }

  Future<void> _openHistory() async {
    _debounce?.cancel();
    _persist();
    final selected = await Navigator.of(context).push<FreeWritingModel>(
      MaterialPageRoute(builder: (_) => const FreeWritingsListPage()),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _current = selected;
      _controller.text = selected.content;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  void _newReflection() {
    _debounce?.cancel();
    _persist(); // garante que a atual foi salva antes de limpar
    FocusScope.of(context).unfocus();
    setState(() {
      _current = null;
      _controller.clear();
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia ✨';
    if (hour < 18) return 'Boa tarde ✨';
    return 'Boa noite ✨';
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
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
                          color: AppColors.lilac,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.history, color: AppColors.lilac),
                    tooltip: 'Reflexões anteriores',
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
                  cursorColor: AppColors.lilac,
                  style: const TextStyle(
                    color: AppColors.softWhite,
                    fontSize: 17,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'O que está na sua mente hoje?',
                    hintStyle: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.4),
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
    );
  }
}
