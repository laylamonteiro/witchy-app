import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/angels_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/angels_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/angels_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/colors_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/colors_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/colors_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/crystals_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/crystals_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/crystals_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/demons_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/demons_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/demons_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/goddesses_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/goddesses_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/goddesses_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/herbs_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/herbs_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/herbs_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/metals_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/metals_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/metals_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/sacred_symbols_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/sacred_symbols_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/sacred_symbols_data_pt.dart';

/// Paridade da enciclopédia entre pt/en/es: mesma contagem e mesma ordem em
/// cada domínio, com invariantes não textuais (enums, cores, emojis)
/// idênticos posição a posição. Nomes são traduzidos, então a identidade
/// estável é o índice.
void main() {
  test('contagens iguais nas três línguas em todos os domínios', () {
    expect(crystalsEn.length, crystalsPt.length);
    expect(crystalsEs.length, crystalsPt.length);
    expect(angelsEn.length, angelsPt.length);
    expect(angelsEs.length, angelsPt.length);
    expect(demonsEn.length, demonsPt.length);
    expect(demonsEs.length, demonsPt.length);
    expect(goddessesEn.length, goddessesPt.length);
    expect(goddessesEs.length, goddessesPt.length);
    expect(herbsEn.length, herbsPt.length);
    expect(herbsEs.length, herbsPt.length);
    expect(metalsEn.length, metalsPt.length);
    expect(metalsEs.length, metalsPt.length);
    expect(colorsEn.length, colorsPt.length);
    expect(colorsEs.length, colorsPt.length);
    expect(archetypesEn.length, archetypesPt.length);
    expect(archetypesEs.length, archetypesPt.length);
    expect(sacredSymbolsEn.length, sacredSymbolsPt.length);
    expect(sacredSymbolsEs.length, sacredSymbolsPt.length);
  });

  test('invariantes não textuais idênticos posição a posição', () {
    for (var i = 0; i < crystalsPt.length; i++) {
      expect(crystalsEn[i].element, crystalsPt[i].element, reason: 'crystal $i');
      expect(crystalsEs[i].element, crystalsPt[i].element, reason: 'crystal $i');
    }
    for (var i = 0; i < herbsPt.length; i++) {
      expect(herbsEn[i].element, herbsPt[i].element, reason: 'herb $i');
      expect(herbsEs[i].element, herbsPt[i].element, reason: 'herb $i');
      expect(herbsEn[i].planet, herbsPt[i].planet, reason: 'herb $i');
      expect(herbsEs[i].planet, herbsPt[i].planet, reason: 'herb $i');
      expect(herbsEn[i].toxic, herbsPt[i].toxic, reason: 'herb $i');
      expect(herbsEs[i].toxic, herbsPt[i].toxic, reason: 'herb $i');
      expect(herbsEn[i].edible, herbsPt[i].edible, reason: 'herb $i');
      expect(herbsEs[i].edible, herbsPt[i].edible, reason: 'herb $i');
    }
    for (var i = 0; i < metalsPt.length; i++) {
      expect(metalsEn[i].element, metalsPt[i].element, reason: 'metal $i');
      expect(metalsEs[i].element, metalsPt[i].element, reason: 'metal $i');
      expect(metalsEn[i].planet, metalsPt[i].planet, reason: 'metal $i');
      expect(metalsEs[i].planet, metalsPt[i].planet, reason: 'metal $i');
    }
    for (var i = 0; i < colorsPt.length; i++) {
      expect(colorsEn[i].color, colorsPt[i].color, reason: 'color $i');
      expect(colorsEs[i].color, colorsPt[i].color, reason: 'color $i');
    }
    for (var i = 0; i < angelsPt.length; i++) {
      expect(angelsEn[i].emoji, angelsPt[i].emoji, reason: 'angel $i');
      expect(angelsEs[i].emoji, angelsPt[i].emoji, reason: 'angel $i');
    }
    for (var i = 0; i < demonsPt.length; i++) {
      expect(demonsEn[i].emoji, demonsPt[i].emoji, reason: 'demon $i');
      expect(demonsEs[i].emoji, demonsPt[i].emoji, reason: 'demon $i');
    }
    for (var i = 0; i < archetypesPt.length; i++) {
      expect(archetypesEn[i].emoji, archetypesPt[i].emoji, reason: 'archetype $i');
      expect(archetypesEs[i].emoji, archetypesPt[i].emoji, reason: 'archetype $i');
    }
    for (var i = 0; i < sacredSymbolsPt.length; i++) {
      expect(sacredSymbolsEn[i].emoji, sacredSymbolsPt[i].emoji, reason: 'symbol $i');
      expect(sacredSymbolsEs[i].emoji, sacredSymbolsPt[i].emoji, reason: 'symbol $i');
    }
    for (var i = 0; i < goddessesPt.length; i++) {
      expect(goddessesEn[i].origin, goddessesPt[i].origin, reason: 'goddess $i');
      expect(goddessesEs[i].origin, goddessesPt[i].origin, reason: 'goddess $i');
    }
  });

  test('campos essenciais não vazios nas três línguas', () {
    void checkNames(List<String> names, String domain) {
      for (final name in names) {
        expect(name.trim(), isNotEmpty, reason: domain);
      }
    }

    for (final list in [crystalsPt, crystalsEn, crystalsEs]) {
      checkNames([for (final c in list) c.name], 'crystals');
      checkNames([for (final c in list) c.description], 'crystals');
    }
    for (final list in [herbsPt, herbsEn, herbsEs]) {
      checkNames([for (final h in list) h.name], 'herbs');
      checkNames([for (final h in list) h.description], 'herbs');
    }
    for (final list in [metalsPt, metalsEn, metalsEs]) {
      checkNames([for (final m in list) m.name], 'metals');
    }
    for (final list in [colorsPt, colorsEn, colorsEs]) {
      checkNames([for (final c in list) c.name], 'colors');
      checkNames([for (final c in list) c.meaning], 'colors');
    }
    for (final list in [angelsPt, angelsEn, angelsEs]) {
      checkNames([for (final a in list) a.name], 'angels');
      checkNames([for (final a in list) a.summary], 'angels');
    }
    for (final list in [demonsPt, demonsEn, demonsEs]) {
      checkNames([for (final d in list) d.name], 'demons');
      checkNames([for (final d in list) d.summary], 'demons');
    }
    for (final list in [goddessesPt, goddessesEn, goddessesEs]) {
      checkNames([for (final g in list) g.name], 'goddesses');
      checkNames([for (final g in list) g.description], 'goddesses');
    }
    for (final list in [archetypesPt, archetypesEn, archetypesEs]) {
      checkNames([for (final a in list) a.name], 'archetypes');
    }
    for (final list in [sacredSymbolsPt, sacredSymbolsEn, sacredSymbolsEs]) {
      checkNames([for (final s in list) s.name], 'sacred symbols');
    }
  });
}
