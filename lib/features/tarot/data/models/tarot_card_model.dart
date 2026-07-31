import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';

/// Strings do idioma atual sem BuildContext; o locale vem do ContentLocale.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Baralhos suportados. Rider-Waite primeiro; Marselha quando os assets
/// forem adicionados em assets/tarot/marseille/.
enum TarotDeck { riderWaite }

extension TarotDeckX on TarotDeck {
  String get folder => switch (this) {
        TarotDeck.riderWaite => 'rw',
      };

  String get displayName => switch (this) {
        TarotDeck.riderWaite => 'Rider-Waite',
      };
}

enum TarotSuit { major, wands, cups, swords, pentacles }

extension TarotSuitX on TarotSuit {
  String get displayName => switch (this) {
        TarotSuit.major => 'Arcanos Maiores',
        TarotSuit.wands => 'Paus',
        TarotSuit.cups => 'Copas',
        TarotSuit.swords => 'Espadas',
        TarotSuit.pentacles => 'Ouros',
      };

  String get emoji => switch (this) {
        TarotSuit.major => '✨',
        TarotSuit.wands => '🔥',
        TarotSuit.cups => '💧',
        TarotSuit.swords => '🗡️',
        TarotSuit.pentacles => '🪙',
      };

  String get assetPrefix => switch (this) {
        TarotSuit.major => 'major',
        TarotSuit.wands => 'wands',
        TarotSuit.cups => 'cups',
        TarotSuit.swords => 'swords',
        TarotSuit.pentacles => 'pentacles',
      };
}

class TarotCard {
  final TarotSuit suit;

  /// Maiores: 0-21. Menores: 1-10, 11=Valete, 12=Cavaleiro, 13=Rainha, 14=Rei.
  final int number;
  final String name;
  final List<String> keywords;
  final String upright;
  final String reversed;

  const TarotCard({
    required this.suit,
    required this.number,
    required this.name,
    required this.keywords,
    required this.upright,
    required this.reversed,
  });

  String get id =>
      '${suit.assetPrefix}_${number.toString().padLeft(2, '0')}';

  /// Código do arquivo no padrão do deck "sm_RWSa" (Wikimedia):
  /// T-00..T-21 (maiores); menores: 0A=Ás, 02..10, J1=Valete, J2=Cavaleiro,
  /// QU=Rainha, KI=Rei; X-BA = verso.
  String get _fileCode {
    if (suit == TarotSuit.major) {
      return 'T-${number.toString().padLeft(2, '0')}';
    }
    final suitCode = switch (suit) {
      TarotSuit.wands => 'W',
      TarotSuit.cups => 'C',
      TarotSuit.swords => 'S',
      TarotSuit.pentacles => 'P',
      TarotSuit.major => 'T',
    };
    final numCode = switch (number) {
      1 => '0A',
      11 => 'J1',
      12 => 'J2',
      13 => 'QU',
      14 => 'KI',
      _ => number.toString().padLeft(2, '0'),
    };
    return '$suitCode-$numCode';
  }

  /// Caminho do asset; a UI usa errorBuilder para exibir placeholder
  /// estilizado se a imagem faltar.
  String assetPath(TarotDeck deck) =>
      'assets/tarot/${deck.folder}/sm_RWSa-$_fileCode.webp';

  /// Verso oficial do baralho.
  static String backAssetPath(TarotDeck deck) =>
      'assets/tarot/${deck.folder}/sm_RWSa-X-BA.webp';

  /// Numeral exibido no placeholder (romano para maiores).
  String get displayNumber {
    if (suit == TarotSuit.major) {
      const romans = [
        '0', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
        'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX',
        'XX', 'XXI',
      ];
      return romans[number];
    }
    return switch (number) {
      1 => _l10n.tarotRankAce,
      11 => _l10n.tarotRankPage,
      12 => _l10n.tarotRankKnight,
      13 => _l10n.tarotRankQueen,
      14 => _l10n.tarotRankKing,
      _ => '$number',
    };
  }
}

/// Uma carta sorteada numa tiragem (posição + orientação).
class TarotDrawnCard {
  final TarotCard card;
  final bool isReversed;
  final String positionLabel;

  const TarotDrawnCard({
    required this.card,
    required this.isReversed,
    required this.positionLabel,
  });

  String get meaning => isReversed ? card.reversed : card.upright;
}
