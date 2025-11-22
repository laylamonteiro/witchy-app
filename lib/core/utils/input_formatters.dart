import 'package:flutter/services.dart';

/// Formatter para data no formato dd/MM/yyyy
/// Adiciona barras automaticamente conforme o usuário digita
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remover tudo exceto dígitos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limitar a 8 dígitos (ddMMyyyy)
    final truncated = digitsOnly.length > 8 ? digitsOnly.substring(0, 8) : digitsOnly;

    // Formatar com barras
    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(truncated[i]);
    }

    final formattedText = buffer.toString();

    // Calcular nova posição do cursor
    int cursorPosition = formattedText.length;

    // Se o usuário está editando no meio, manter posição proporcional
    if (newValue.selection.baseOffset < newValue.text.length) {
      final oldDigitsBeforeCursor = oldValue.text
          .substring(0, oldValue.selection.baseOffset)
          .replaceAll(RegExp(r'[^\d]'), '')
          .length;
      final newDigitsBeforeCursor = newValue.text
          .substring(0, newValue.selection.baseOffset)
          .replaceAll(RegExp(r'[^\d]'), '')
          .length;

      // Calcular posição baseada nos dígitos
      int digitsCount = 0;
      for (int i = 0; i < formattedText.length && digitsCount < newDigitsBeforeCursor; i++) {
        if (formattedText[i] != '/') {
          digitsCount++;
        }
        cursorPosition = i + 1;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

/// Formatter para hora no formato HH:mm
/// Adiciona dois pontos automaticamente conforme o usuário digita
class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remover tudo exceto dígitos
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limitar a 4 dígitos (HHmm)
    final truncated = digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;

    // Formatar com dois pontos
    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i == 2) {
        buffer.write(':');
      }
      buffer.write(truncated[i]);
    }

    final formattedText = buffer.toString();

    // Calcular nova posição do cursor
    int cursorPosition = formattedText.length;

    // Se o usuário está editando no meio, manter posição proporcional
    if (newValue.selection.baseOffset < newValue.text.length) {
      final newDigitsBeforeCursor = newValue.text
          .substring(0, newValue.selection.baseOffset)
          .replaceAll(RegExp(r'[^\d]'), '')
          .length;

      int digitsCount = 0;
      for (int i = 0; i < formattedText.length && digitsCount < newDigitsBeforeCursor; i++) {
        if (formattedText[i] != ':') {
          digitsCount++;
        }
        cursorPosition = i + 1;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

/// Valida e converte string de data para DateTime
DateTime? parseDate(String text) {
  final parts = text.split('/');
  if (parts.length != 3) return null;

  try {
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    if (day < 1 || day > 31) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1900 || year > DateTime.now().year) return null;

    final date = DateTime(year, month, day);
    // Verificar se a data é válida (ex: 31/02 seria inválido)
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }

    return date;
  } catch (e) {
    return null;
  }
}

/// Valida e converte string de hora para TimeOfDay
TimeOfDay? parseTime(String text) {
  final parts = text.split(':');
  if (parts.length != 2) return null;

  try {
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    return null;
  }
}

/// Formata DateTime para string dd/MM/yyyy
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// Formata TimeOfDay para string HH:mm
String formatTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
