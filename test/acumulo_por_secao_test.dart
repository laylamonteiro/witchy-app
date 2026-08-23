import 'package:flutter/material.dart' hide Element;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/birth_chart_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/magical_profile_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/magical_profile_report.dart';
import 'package:grimorio_de_bolso/features/astrology/presentation/providers/astrology_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Concorrência do acúmulo por seção da Análise Personalizada.
///
/// Cada seção custa uma chamada de IA, e abrir um card enquanto outro ainda
/// tece é o uso normal. O defeito clássico: duas seções liam o acumulado no
/// COMEÇO, e a segunda a terminar apagava a primeira — dez chamadas de IA
/// pagas e um relatório com buraco. As duas defesas são a leitura do
/// acumulado DEPOIS da chamada e a fila de gravação (_filaDePerfil).
///
/// Sem dublê do método de risco: `generateProfileSection` roda inteiro, com
/// a gravação real no sqlite. O dublê é só o tecelão da IA (a borda de
/// rede), que aqui obedece a atrasos controlados para forçar cada ordem de
/// chegada.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '11111111-2222-3333-4444-555555555555';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('magical_profiles');
  });

  BirthChartModel mapa() => BirthChartModel(
        id: 'mapa-1',
        userId: uid,
        birthDate: DateTime(1990, 5, 4),
        birthTime: const TimeOfDay(hour: 10, minute: 30),
        birthPlace: 'Fortaleza',
        latitude: -3.7,
        longitude: -38.5,
        timezone: 'America/Fortaleza',
        planets: const [],
        houses: const [],
        aspects: const [],
        calculatedAt: DateTime(2026, 1, 1),
      );

  MagicalProfile perfil() => MagicalProfile(
        userId: uid,
        birthChartId: 'mapa-1',
        dominantElement: Element.water,
        elementDistribution: const {},
        dominantModality: Modality.fixed,
        modalityDistribution: const {},
        magicalEssence: '',
        intuitiveGifts: '',
        communicationStyle: '',
        loveAndBeauty: '',
        protectiveEnergy: '',
        houseOfMagic: '',
        houseOfSpirit: '',
        magicalStrengths: const [],
        recommendedPractices: const [],
        favorableTools: const [],
        shadowWork: const [],
        generatedAt: DateTime(2026, 1, 1),
      );

  /// Provider pronto: mapa e perfil adotados, tecelão com atraso POR seção.
  AstrologyProvider tecelante(Map<String, int> atrasosMs) {
    final provider = AstrologyProvider();
    provider.adotarMapaParaTeste(mapa(), perfil());
    provider.tecelaoDeTeste = ({
      required BirthChartModel birthChart,
      required MagicalProfile profile,
      required String sectionKey,
    }) async {
      await Future<void>.delayed(
        Duration(milliseconds: atrasosMs[sectionKey] ?? 5),
      );
      return 'corpo de $sectionKey';
    };
    return provider;
  }

  const essencia = MagicalProfileSections.essence;
  const sombra = MagicalProfileSections.shadow;

  test('a seção que termina DEPOIS não apaga a que terminou antes', () async {
    // sombra termina primeiro; essência, muito depois. Na versão com o
    // defeito, a essência tinha lido o acumulado vazio no começo e
    // sobrescrevia a sombra ao gravar.
    final provider = tecelante({essencia: 80, sombra: 10});

    await Future.wait([
      provider.generateProfileSection(essencia, hasFullAccess: true),
      provider.generateProfileSection(sombra, hasFullAccess: true),
    ]);

    expect(provider.erroDaSecao(essencia), isNull);
    expect(provider.erroDaSecao(sombra), isNull);

    final texto = provider.magicalProfile!.aiGeneratedText!;
    expect(texto, contains(MagicalProfileSections.header(essencia)));
    expect(texto, contains(MagicalProfileSections.header(sombra)),
        reason: 'a seção que chegou primeiro foi engolida pela segunda');

    // E o que ficou GRAVADO também tem as duas — a fila de gravação existe
    // para o banco não terminar com um upsert antigo por cima do novo.
    final db = await DatabaseHelper.instance.database;
    final rows = await db
        .query('magical_profiles', where: 'id = ?', whereArgs: ['mapa-1']);
    expect(rows, hasLength(1));
    final gravado = rows.first['profile_data'] as String;
    expect(gravado, contains('[$essencia]'));
    expect(gravado, contains('[$sombra]'));
  });

  test('na ordem inversa também: quem chega por último soma, não substitui',
      () async {
    final provider = tecelante({essencia: 10, sombra: 80});

    await Future.wait([
      provider.generateProfileSection(essencia, hasFullAccess: true),
      provider.generateProfileSection(sombra, hasFullAccess: true),
    ]);

    final texto = provider.magicalProfile!.aiGeneratedText!;
    expect(texto, contains(MagicalProfileSections.header(essencia)));
    expect(texto, contains(MagicalProfileSections.header(sombra)));
  });

  test('tecer a mesma seção de novo substitui, não duplica', () async {
    final provider = tecelante({});

    await provider.generateProfileSection(essencia, hasFullAccess: true);
    await provider.generateProfileSection(sombra, hasFullAccess: true);
    await provider.generateProfileSection(essencia, hasFullAccess: true);

    final texto = provider.magicalProfile!.aiGeneratedText!;
    final cabecalho = MagicalProfileSections.header(essencia);
    expect(cabecalho.allMatches(texto), hasLength(1),
        reason: 'duas cópias da mesma seção: a tela abriria a velha');
    expect(texto, contains(MagicalProfileSections.header(sombra)),
        reason: 'refazer uma seção não pode custar as outras');
  });

  test('uma falha não apaga o que já existia', () async {
    final provider = tecelante({});
    await provider.generateProfileSection(essencia, hasFullAccess: true);

    provider.tecelaoDeTeste = ({
      required BirthChartModel birthChart,
      required MagicalProfile profile,
      required String sectionKey,
    }) async =>
        throw Exception('provedor fora do ar');

    await provider.generateProfileSection(sombra, hasFullAccess: true);

    expect(provider.erroDaSecao(sombra), isNotNull);
    expect(
      provider.magicalProfile!.aiGeneratedText!,
      contains(MagicalProfileSections.header(essencia)),
      reason: 'a falha da sombra não pode custar a essência já tecida',
    );
  });

  test('sem acesso Premium não tece nem grava (fail-closed)', () async {
    var chamadas = 0;
    final provider = AstrologyProvider();
    provider.adotarMapaParaTeste(mapa(), perfil());
    provider.tecelaoDeTeste = ({
      required BirthChartModel birthChart,
      required MagicalProfile profile,
      required String sectionKey,
    }) async {
      chamadas++;
      return 'corpo';
    };

    await provider.generateProfileSection(essencia, hasFullAccess: false);

    expect(chamadas, 0, reason: 'sem acesso, nenhuma chamada de IA é gasta');
    final db = await DatabaseHelper.instance.database;
    expect(await db.query('magical_profiles'), isEmpty);
  });
}
