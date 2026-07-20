import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data_en.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data_es.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data_pt.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data_en.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data_es.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data_pt.dart';

/// Garante que as variantes pt/en/es da camada de conteúdo estático têm o
/// mesmo número de itens, as mesmas chaves estáveis e a mesma ordem — a
/// tradução nunca pode alterar identidade nem estrutura do conteúdo.
void main() {
  group('Runas', () {
    test('as três línguas têm 24 runas na mesma ordem', () {
      expect(runesPt.length, 24);
      expect(runesEn.length, runesPt.length);
      expect(runesEs.length, runesPt.length);

      for (var i = 0; i < runesPt.length; i++) {
        // Nomes e símbolos são invariantes entre idiomas.
        expect(runesEn[i].name, runesPt[i].name);
        expect(runesEs[i].name, runesPt[i].name);
        expect(runesEn[i].symbol, runesPt[i].symbol);
        expect(runesEs[i].symbol, runesPt[i].symbol);
      }
    });

    test('todas as runas têm keywords e descrição não vazias', () {
      for (final list in [runesPt, runesEn, runesEs]) {
        for (final rune in list) {
          expect(rune.keywords, isNotEmpty, reason: rune.name);
          expect(rune.description.trim(), isNotEmpty, reason: rune.name);
          expect(rune.keywords.length, 3, reason: rune.name);
        }
      }
    });
  });

  group('Oráculo', () {
    test('as três línguas têm 44 cartas com os mesmos ids e emojis na mesma ordem',
        () {
      expect(oracleCardsPt.length, 44);
      expect(oracleCardsEn.length, oracleCardsPt.length);
      expect(oracleCardsEs.length, oracleCardsPt.length);

      for (var i = 0; i < oracleCardsPt.length; i++) {
        // Ids e emojis são invariantes entre idiomas.
        expect(oracleCardsEn[i].id, oracleCardsPt[i].id);
        expect(oracleCardsEs[i].id, oracleCardsPt[i].id);
        expect(oracleCardsEn[i].emoji, oracleCardsPt[i].emoji);
        expect(oracleCardsEs[i].emoji, oracleCardsPt[i].emoji);
      }
    });

    test('todas as cartas têm campos não vazios e 3 keywords', () {
      for (final list in [oracleCardsPt, oracleCardsEn, oracleCardsEs]) {
        for (final card in list) {
          expect(card.name.trim(), isNotEmpty, reason: 'id ${card.id}');
          expect(card.message.trim(), isNotEmpty, reason: 'id ${card.id}');
          expect(card.emoji.trim(), isNotEmpty, reason: 'id ${card.id}');
          expect(card.guidance.trim(), isNotEmpty, reason: 'id ${card.id}');
          expect(card.keywords, isNotEmpty, reason: 'id ${card.id}');
          expect(card.keywords.length, 3, reason: 'id ${card.id}');
          for (final keyword in card.keywords) {
            expect(keyword.trim(), isNotEmpty, reason: 'id ${card.id}');
          }
        }
      }
    });
  });
}
