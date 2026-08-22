import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/input_formatters.dart';

/// Campo de data que se DIGITA (dd/mm/aaaa), com o calendário como atalho.
///
/// O seletor de data do Material tem um modo de digitação, mas ele pede o
/// teclado `datetime` — e em vários teclados de Android (o da Samsung, por
/// exemplo) esse teclado é um teclado numérico SEM a barra: quem tentava
/// escrever a data de nascimento digitava "07041993", via "Formato
/// inválido" e não tinha como completar. Aqui a barra não é digitada: o
/// [DateInputFormatter] a coloca sozinho enquanto a pessoa digita os
/// números, então o teclado numérico basta.
///
/// O ícone de calendário continua abrindo o seletor — em modo
/// `calendarOnly`, sem o caminho de digitação quebrado.
class DateInputField extends StatefulWidget {
  const DateInputField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.hint,
    required this.invalidMessage,
    required this.firstDate,
    required this.lastDate,
    this.helperText,
    this.calendarStart,
  });

  /// Data atual (de fora), ou `null` enquanto não houver uma válida.
  final DateTime? value;

  /// Chamado a cada mudança: a data válida, ou `null` enquanto o que está
  /// escrito ainda não for uma.
  final ValueChanged<DateTime?> onChanged;

  final String label;
  final String hint;

  /// Mensagem de data impossível (32/13, fora do intervalo).
  final String invalidMessage;

  final DateTime firstDate;
  final DateTime lastDate;
  final String? helperText;

  /// Mês em que o calendário abre quando ainda não há data escrita. Para
  /// data de nascimento vale apontar para umas décadas atrás: abrir em
  /// hoje faria rolar trinta anos de calendário para trás.
  final DateTime? calendarStart;

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  late final TextEditingController _controller;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == null ? '' : formatDate(widget.value!),
    );
  }

  @override
  void didUpdateWidget(DateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A data pode chegar depois (perfil salvo carregado do disco): o campo
    // acompanha, mas sem atropelar o que estiver sendo digitado agora.
    final novo = widget.value;
    if (novo != oldWidget.value && novo != parseDate(_controller.text)) {
      _controller.text = novo == null ? '' : formatDate(novo);
      _erro = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Data completa e possível, dentro do intervalo permitido.
  DateTime? _valida(String texto) {
    final data = parseDate(texto);
    if (data == null) return null;
    if (data.isBefore(widget.firstDate) || data.isAfter(widget.lastDate)) {
      return null;
    }
    return data;
  }

  void _aoDigitar(String texto) {
    // Só reclama de data inválida com os 8 dígitos escritos: acusar no meio
    // da digitação seria erro em cima de quem ainda está escrevendo.
    final completa = texto.length == 10;
    final data = completa ? _valida(texto) : null;
    setState(() {
      _erro = completa && data == null ? widget.invalidMessage : null;
    });
    widget.onChanged(data);
  }

  Future<void> _abrirCalendario() async {
    final atual = _valida(_controller.text) ?? widget.value;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual ?? widget.calendarStart ?? widget.lastDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      // Sem o modo de digitação: é justamente o que o teclado numérico de
      // alguns Androids não deixa completar (não tem a barra).
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (escolhida == null || !mounted) return;
    setState(() {
      _controller.text = formatDate(escolhida);
      _erro = null;
    });
    widget.onChanged(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        DateInputFormatter(),
      ],
      onChanged: _aoDigitar,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: _erro,
        prefixIcon: const Icon(Icons.calendar_today, size: 18),
        suffixIcon: IconButton(
          icon: const Icon(Icons.edit_calendar_outlined),
          tooltip: MaterialLocalizations.of(context).datePickerHelpText,
          onPressed: _abrirCalendario,
        ),
      ),
    );
  }
}
