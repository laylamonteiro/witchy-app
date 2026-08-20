import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/cycles/data/data_sources/life_eras_content.dart';
import 'package:grimorio_de_bolso/features/cycles/data/data_sources/life_eras_content_en.dart';
import 'package:grimorio_de_bolso/features/cycles/data/data_sources/life_eras_content_es.dart';
import 'package:grimorio_de_bolso/features/cycles/data/data_sources/life_eras_content_pt.dart';
import 'package:grimorio_de_bolso/features/cycles/data/models/cycle_content.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/era_ruler.dart';

/// Garante que as variantes pt/en/es do conteúdo dos Ciclos têm a mesma
/// quantidade de itens, os mesmos regentes na mesma ordem e nenhum texto
/// vazio — a tradução nunca pode alterar identidade nem estrutura.
void main() {
  tearDown(() {
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  group('Eras', () {
    test('há uma Era para cada regente, na ordem canônica', () {
      expect(erasPt.length, EraRegente.values.length);
      for (var i = 0; i < EraRegente.values.length; i++) {
        expect(erasPt[i].regente, EraRegente.values[i], reason: 'posição $i');
      }
    });

    test('os três idiomas têm a mesma quantidade', () {
      expect(erasEn.length, erasPt.length);
      expect(erasEs.length, erasPt.length);
    });

    test('o regente é invariante índice a índice', () {
      for (var i = 0; i < erasPt.length; i++) {
        expect(erasEn[i].regente, erasPt[i].regente, reason: 'en na posição $i');
        expect(erasEs[i].regente, erasPt[i].regente, reason: 'es na posição $i');
      }
    });

    test('todo texto está preenchido e há exatamente três etiquetas', () {
      for (final lista in [erasPt, erasEn, erasEs]) {
        for (final era in lista) {
          final onde = era.regente.name;
          expect(era.titulo.trim(), isNotEmpty, reason: 'título de $onde');
          expect(era.corpo.trim(), isNotEmpty, reason: 'corpo de $onde');
          expect(era.sombra.trim(), isNotEmpty, reason: 'sombra de $onde');
          expect(era.convite.trim(), isNotEmpty, reason: 'convite de $onde');
          expect(era.tags.length, 3, reason: 'etiquetas de $onde');
          for (final tag in era.tags) {
            expect(tag.trim(), isNotEmpty, reason: 'etiqueta vazia em $onde');
          }
        }
      }
    });
  });

  group('Fases', () {
    test('há uma Fase para cada regente, na ordem canônica', () {
      expect(fasesPt.length, EraRegente.values.length);
      for (var i = 0; i < EraRegente.values.length; i++) {
        expect(fasesPt[i].regente, EraRegente.values[i], reason: 'posição $i');
      }
    });

    test('os três idiomas têm a mesma quantidade e os mesmos regentes', () {
      expect(fasesEn.length, fasesPt.length);
      expect(fasesEs.length, fasesPt.length);
      for (var i = 0; i < fasesPt.length; i++) {
        expect(fasesEn[i].regente, fasesPt[i].regente, reason: 'en na posição $i');
        expect(fasesEs[i].regente, fasesPt[i].regente, reason: 'es na posição $i');
      }
    });

    test('todo texto está preenchido e há exatamente três etiquetas', () {
      for (final lista in [fasesPt, fasesEn, fasesEs]) {
        for (final fase in lista) {
          final onde = fase.regente.name;
          expect(fase.titulo.trim(), isNotEmpty, reason: 'título de $onde');
          expect(fase.sabor.trim(), isNotEmpty, reason: 'sabor de $onde');
          expect(fase.tags.length, 3, reason: 'etiquetas de $onde');
          for (final tag in fase.tags) {
            expect(tag.trim(), isNotEmpty, reason: 'etiqueta vazia em $onde');
          }
        }
      }
    });
  });

  group('Seleção por idioma', () {
    test('o acessor entrega a variante do idioma ativo', () {
      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      expect(LifeErasContent.eras.first.titulo, erasPt.first.titulo);

      ContentLocale.instance.setLocale(const Locale('en'));
      expect(LifeErasContent.eras.first.titulo, erasEn.first.titulo);

      ContentLocale.instance.setLocale(const Locale('es'));
      expect(LifeErasContent.eras.first.titulo, erasEs.first.titulo);
    });

    test('a busca por regente encontra o texto certo', () {
      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
      for (final regente in EraRegente.values) {
        final EraContent era = LifeErasContent.daEra(regente);
        final FaseContent fase = LifeErasContent.daFase(regente);
        expect(era.regente, regente);
        expect(fase.regente, regente);
      }
    });
  });
}
