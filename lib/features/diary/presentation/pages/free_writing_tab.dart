import 'dart:async';

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
/// salvo AUTOMATICAMENTE, guardado no histórico e sincronizado: ninguém perde
/// o que escreveu por ter esquecido de apertar um botão.
///
/// Essa promessa já esteve quebrada, e por um detalhe de onde a aba mora. O
/// salvamento dependia de gestos de ROTA — abrir o histórico, começar uma
/// reflexão nova e o `PopScope`. Mas aqui não há rota: a aba é filha do
/// `TabBarView` dos Diários, e o `TabBarView` DESMONTA o filho que sai de
/// cena. Trocar para Sonhos ou Gratidão não era "o salvamento não dispara" —
/// era o State sendo destruído com o texto dentro, e o `dispose` só
/// descartava o controller. O app encerrado em segundo plano, que é o normal
/// no Android, levava tudo junto pelo mesmo caminho.
///
/// São três as travas agora, e cada uma cobre o buraco da outra:
///
/// 1. [AutomaticKeepAliveClientMixin] — trocar de aba não desmonta mais o
///    canvas. O texto continua NA TELA quando ela volta, com cursor e tudo;
/// 2. [WidgetsBindingObserver] — o app indo para segundo plano grava o que
///    está escrito, antes de o sistema poder encerrá-lo;
/// 3. o `dispose` ainda grava, sem esperar, para o caso de a página inteira
///    dos Diários sair de cena.
class FreeWritingTab extends StatefulWidget {
  /// Reflexão a abrir já carregada no canvas (ex.: leitura de quiromancia
  /// recém-salva). Null = canvas em branco, comportamento da aba do Diário.
  final FreeWritingModel? initial;

  const FreeWritingTab({super.key, this.initial});

  @override
  State<FreeWritingTab> createState() => _FreeWritingTabState();
}

class _FreeWritingTabState extends State<FreeWritingTab>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final _controller = TextEditingController();
  late FreeWritingProvider _provider;

  /// Reflexão sendo editada no momento (null = canvas em branco/nova).
  FreeWritingModel? _current;
  String _originalContent = '';

  /// Uma gravação em voo.
  ///
  /// Sem isto, o app indo para segundo plano NO MEIO de um `_save()` montaria
  /// um segundo modelo — e, no canvas em branco, modelo novo é id novo: a
  /// mesma reflexão viraria duas páginas no acervo.
  bool _gravando = false;

  /// O canvas não sai de cena quando ela troca de aba.
  ///
  /// Sem isto o `TabBarView` desmonta este State, e o texto ainda não gravado
  /// morre com ele. Gravar no `dispose` salvaria o conteúdo, mas ela voltaria
  /// para um canvas EM BRANCO e teria de procurar a própria reflexão no
  /// histórico — o que não é a mesma coisa que não ter perdido nada.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Preenche antes de registrar o listener para não disparar setState
    // durante o initState.
    final initial = widget.initial;
    if (initial != null) {
      _current = initial;
      _originalContent = initial.content;
      _controller.text = initial.content;
    }
    _controller.addListener(_onChanged);
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    // ANTES de descartar o controller: é dele que sai o texto. Sem espera,
    // porque aqui não há mais para quem esperar — o provider sobrevive à aba
    // e termina a gravação sozinho.
    _gravarSemEsperar();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  /// O app saindo de cena é a última chance de gravar.
  ///
  /// No Android o sistema encerra o processo em segundo plano sem avisar de
  /// novo; era por aqui que o desabafo longo se perdia inteiro.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _gravarSemEsperar();
    }
  }

  void _onChanged() {
    // Rebuild leve para alternar a visibilidade das ações conforme há texto.
    setState(() {});
  }

  /// O que precisa ser gravado agora, ou null se não há o que gravar.
  FreeWritingModel? _pendente() {
    final text = _controller.text;
    if (text.trim().isEmpty) return null;
    // Nada mudou em uma reflexão já carregada: evita gravações repetidas.
    if (_current != null && text == _originalContent) return null;

    return _current == null
        ? FreeWritingModel(content: text)
        : _current!.copyWith(content: text);
  }

  /// Salva a reflexão atual. Chamado automaticamente ao sair da tela ou iniciar
  /// uma nova reflexão — assim a pessoa nunca perde o que escreveu.
  Future<void> _save() async {
    final model = _pendente();
    if (model == null) return;

    _gravando = true;
    try {
      await _provider.save(model);
    } finally {
      _gravando = false;
    }
    if (!mounted) return;
    setState(() {
      _current = model;
      _originalContent = model.content;
    });
  }

  /// Gravação sem espera e sem `setState`, para os dois momentos em que não
  /// existe mais para quem esperar: o app indo para segundo plano e o State
  /// sendo desmontado.
  ///
  /// A marca de "já é esta a reflexão" é posta ANTES de disparar a gravação,
  /// e não depois: é ela que faz a chamada seguinte reaproveitar o mesmo id
  /// em vez de criar uma página nova.
  void _gravarSemEsperar() {
    if (_gravando) return;
    final model = _pendente();
    if (model == null) return;
    _current = model;
    _originalContent = model.content;
    unawaited(_provider.save(model));
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
    // Mesmas faixas do Seu Dia (greeting_header.dart): madrugada até as 5h.
    final hour = DateTime.now().hour;
    if (hour < 5) return AppLocalizations.of(context).commonGoodDawn;
    if (hour < 12) return AppLocalizations.of(context).commonGoodMorning;
    if (hour < 18) return AppLocalizations.of(context).commonGoodAfternoon;
    return AppLocalizations.of(context).commonGoodEvening;
  }

  @override
  Widget build(BuildContext context) {
    // Exigido pelo AutomaticKeepAliveClientMixin.
    super.build(context);
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
                        key: const ValueKey('free_writing_back'),
                        icon: Icon(
                          Icons.arrow_back,
                          color: context.gc.lilac,
                        ),
                        tooltip: AppLocalizations.of(context).commonBack,
                        onPressed: () async {
                          if (await _handleBack() && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.history, color: context.gc.lilac),
                      tooltip: AppLocalizations.of(context).diaryPreviousReflections,
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
                      hintText: AppLocalizations.of(context).diaryFreeWritingHint,
                      hintStyle: TextStyle(
                        color: context.gc.softWhite.withValues(alpha: 0.4),
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
