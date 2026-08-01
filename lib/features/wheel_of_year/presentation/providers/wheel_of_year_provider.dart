import 'package:flutter/foundation.dart';
import '../../data/models/sabbat_model.dart';

class WheelOfYearProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  
  DateTime get selectedDate => _selectedDate;

  // Obter todos os sabbats do ano atual
  List<Sabbat> getAllSabbats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentYear = now.year;
    final sabbats = <Sabbat>[];

    for (final type in SabbatType.values) {
      final date = type.getDateForYear(currentYear);

      // Comparação por DIA DE CALENDÁRIO: no próprio dia o sabbat ainda é
      // deste ano; só vira o do próximo ano a partir do dia seguinte.
      if (date.isBefore(today)) {
        sabbats.add(Sabbat(
          type: type,
          date: type.getDateForYear(currentYear + 1),
        ));
      } else {
        sabbats.add(Sabbat(
          type: type,
          date: date,
        ));
      }
    }

    // Ordenar por data
    sabbats.sort((a, b) => a.date.compareTo(b.date));

    return sabbats;
  }

  // Obter próximo sabbat (INCLUI o de hoje — "próximo" nunca pula o dia
  // do próprio sabbat; a véspera mostra 1 dia, o dia mostra "é hoje").
  Sabbat? getNextSabbat() {
    final sabbats = getAllSabbats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final sabbat in sabbats) {
      if (!sabbat.date.isBefore(today)) {
        return sabbat;
      }
    }

    return sabbats.isNotEmpty ? sabbats.first : null;
  }

  // Obter sabbat mais próximo (passado ou futuro)
  Sabbat? getCurrentSabbat() {
    final sabbats = getAllSabbats();
    final now = DateTime.now();

    Sabbat? closest;
    int minDifference = 999999;

    for (final sabbat in sabbats) {
      final difference = (sabbat.date.difference(now).inDays).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closest = sabbat;
      }
    }

    return closest;
  }

  // Verificar se hoje é um sabbat
  bool isTodaySabbat() {
    final now = DateTime.now();
    final sabbats = getAllSabbats();

    for (final sabbat in sabbats) {
      if (sabbat.date.year == now.year &&
          sabbat.date.month == now.month &&
          sabbat.date.day == now.day) {
        return true;
      }
    }

    return false;
  }

  // Obter sabbat de hoje (se houver)
  Sabbat? getTodaySabbat() {
    final now = DateTime.now();
    final sabbats = getAllSabbats();

    for (final sabbat in sabbats) {
      if (sabbat.date.year == now.year &&
          sabbat.date.month == now.month &&
          sabbat.date.day == now.day) {
        return sabbat;
      }
    }

    return null;
  }
}
