import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetype_identity.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_en.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_es.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/data_sources/archetypes_data_pt.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/arcane_entry_model.dart';

void main() {
  // O idioma de conteúdo é um singleton de processo: um teste que troca o
  // idioma e não devolve contamina os seguintes.
  tearDown(() => ContentLocale.instance.setLocale(const Locale('pt', 'BR')));

  // Golden da identidade gravada: id ↔ arquétipo, na ordem do catálogo.
  // Mudar um id destes é mudar o que está gravado no aparelho de quem já fez
  // o teste — não é renomear variável, é perder resultado. Reordenar as
  // listas de conteúdo sem mexer aqui também: o id passaria a apontar para
  // outro arquétipo.
  const goldenNames = <String, String>{
    'a_bruxa': 'A Bruxa',
    'a_curandeira': 'A Curandeira',
    'a_vidente': 'A Vidente',
    'a_guardia': 'A Guardiã',
    'a_sabia': 'A Sábia',
    'a_donzela': 'A Donzela',
    'a_mae': 'A Mãe',
    'a_cacadora': 'A Caçadora',
    'a_tecela': 'A Tecelã',
    'a_alquimista': 'A Alquimista',
    'a_rainha_sombria': 'A Rainha Sombria',
  };

  group('identidade dos arquétipos', () {
    test('um id por arquétipo, na ordem do catálogo', () {
      expect(archetypeIds.length, archetypesPt.length);
      expect(archetypeIds.toSet().length, archetypeIds.length,
          reason: 'ids repetidos fariam dois arquétipos disputarem a mesma '
              'gravação');
      for (var i = 0; i < archetypeIds.length; i++) {
        expect(goldenNames[archetypeIds[i]], archetypesPt[i].name,
            reason: 'id ${archetypeIds[i]} na posição $i');
      }
    });

    test('o id não depende de fonte: só ASCII minúsculo', () {
      final ascii = RegExp(r'^[a-z0-9_]+$');
      for (final id in archetypeIds) {
        expect(ascii.hasMatch(id), isTrue, reason: id);
      }
    });

    test('o id é o mesmo slug que já nomeia a imagem do verbete', () {
      for (var i = 0; i < archetypeIds.length; i++) {
        expect(arcaneImageAsset('arquetipos', archetypesPt[i].name),
            'assets/images/arquetipos/${archetypeIds[i]}.webp');
      }
    });
  });

  group('leitura de um valor gravado', () {
    test('o id de hoje volta como ele mesmo', () {
      for (final id in archetypeIds) {
        expect(archetypeIdForStoredKey(id), id);
      }
    });

    test('o emoji gravado pela versão anterior vira o id do mesmo arquétipo',
        () {
      for (var i = 0; i < archetypesPt.length; i++) {
        expect(archetypeIdForStoredKey(archetypesPt[i].emoji), archetypeIds[i],
            reason: archetypesPt[i].name);
      }
    });

    test('o nome em português, gravado antes do emoji, também volta', () {
      for (var i = 0; i < archetypesPt.length; i++) {
        expect(archetypeIdForStoredKey(archetypesPt[i].name), archetypeIds[i],
            reason: archetypesPt[i].name);
      }
    });

    test('um valor que não casa com nada é ausência, não exceção', () {
      // Emoji desenhado por outra fonte, lixo, vazio e nome traduzido de uma
      // gravação estrangeira: nada disso pode derrubar a tela nem virar o
      // primeiro arquétipo da lista.
      for (final desconhecido in ['', '?', '\u{1F9D9}', 'A Feiticeira', '🦄']) {
        expect(archetypeIdForStoredKey(desconhecido), isNull,
            reason: 'valor: $desconhecido');
        expect(archetypeForId(desconhecido), isNull);
      }
    });
  });

  group('resolução do verbete', () {
    test('cada id abre o arquétipo da sua posição', () {
      for (var i = 0; i < archetypeIds.length; i++) {
        expect(archetypeForId(archetypeIds[i])?.name, archetypesPt[i].name);
      }
    });

    test('o mesmo id atravessa a troca de idioma sem virar outro arquétipo',
        () {
      // O nome muda com o idioma — por isso ele não serve de chave; o emoji
      // (o desenho) é o mesmo nos três, e é por ele que se confere.
      for (var i = 0; i < archetypeIds.length; i++) {
        ContentLocale.instance.setLocale(const Locale('en'));
        expect(archetypeForId(archetypeIds[i])?.name, archetypesEn[i].name);
        expect(archetypeForId(archetypeIds[i])?.emoji, archetypesPt[i].emoji);

        ContentLocale.instance.setLocale(const Locale('es'));
        expect(archetypeForId(archetypeIds[i])?.name, archetypesEs[i].name);
        expect(archetypeForId(archetypeIds[i])?.emoji, archetypesPt[i].emoji);
      }
    });
  });

  group('mapeamento a partir do emoji do conteúdo', () {
    test('o emoji do catálogo aponta para o id do mesmo arquétipo', () {
      for (var i = 0; i < archetypesPt.length; i++) {
        expect(archetypeIdForEmoji(archetypesPt[i].emoji), archetypeIds[i]);
      }
    });

    test('emoji fora do catálogo não inventa arquétipo', () {
      expect(archetypeIdForEmoji('🦄'), isNull);
      expect(archetypeIdForEmoji(''), isNull);
    });
  });
}
