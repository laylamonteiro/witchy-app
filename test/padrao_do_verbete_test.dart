import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/padrao_do_verbete.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/data/models/user_entry_model.dart';

// A página gerada pela IA saía em minúscula — "aumentar a autoconfiança" nos
// chips, "lavar com água corrente" na limpeza — ao lado de um catálogo onde
// NENHUM item começa em minúscula ou termina em ponto. A tela é a mesma para
// os dois, então a diferença saltava aos olhos.
//
// Esta é a parte mecânica da régua. Ela roda na geração E na leitura (para os
// verbetes que já existem), então precisa ser idempotente.
void main() {
  group('fraseDoVerbete', () {
    test('minúscula vira maiúscula', () {
      expect(fraseDoVerbete('aumentar a autoconfiança'),
          'Aumentar a autoconfiança');
      expect(fraseDoVerbete('exposição ao luar'), 'Exposição ao luar');
    });

    test('o ponto final sai — inclusive depois de várias frases', () {
      expect(fraseDoVerbete('lavar com água corrente.'),
          'Lavar com água corrente');
      expect(
        fraseDoVerbete('A Hematita é um mineral de ferro. Traz aterramento.'),
        'A Hematita é um mineral de ferro. Traz aterramento',
      );
    });

    test('reticências, exclamação e interrogação ficam', () {
      expect(fraseDoVerbete('cuidado com o sol...'), 'Cuidado com o sol...');
      expect(fraseDoVerbete('evite água!'), 'Evite água!');
      expect(fraseDoVerbete('sabia que ela enferruja?'),
          'Sabia que ela enferruja?');
    });

    test('acento na primeira letra é respeitado', () {
      expect(fraseDoVerbete('óleo essencial deve ser diluído'),
          'Óleo essencial deve ser diluído');
    });

    test('o que não é letra minúscula fica como está', () {
      // pH viraria "PH"; o número não tem maiúscula.
      expect(fraseDoVerbete('pH neutro'), 'pH neutro');
      expect(fraseDoVerbete('mL de água'), 'mL de água');
      expect(fraseDoVerbete('3 pitadas de sal'), '3 pitadas de sal');
      expect(fraseDoVerbete('Água corrente'), 'Água corrente');
    });

    test('espaços nas pontas somem; texto vazio não explode', () {
      expect(fraseDoVerbete('  proteção suave  '), 'Proteção suave');
      expect(fraseDoVerbete(''), '');
      expect(fraseDoVerbete('   '), '');
      expect(fraseDoVerbete('.'), '');
    });

    test('aplicar duas vezes dá o mesmo resultado', () {
      const cru = 'carregue-a no bolso para proteção diária.';
      final uma = fraseDoVerbete(cru);
      expect(fraseDoVerbete(uma), uma);
    });
  });

  group('verbeteNoPadrao', () {
    Map<String, dynamic> cristal() => {
          'name': 'Hematita',
          'description': 'a hematita é um mineral de ferro.',
          'element': 'earth',
          'intentions': ['aumentar a autoconfiança', 'promover o aterramento'],
          'usageTips': ['carregue-a no bolso.'],
          'cleaningMethods': [
            {
              'method': 'lavar com água corrente',
              'isSafe': false,
              'warning': 'a água pode causar oxidação.',
            },
            {'method': 'limpar com pano seco', 'isSafe': true, 'warning': null},
          ],
          'chargingMethods': [
            {'method': 'exposição ao luar', 'isSafe': true, 'warning': null},
          ],
          'safetyWarnings': ['evite contato prolongado com água'],
        };

    test('listas, métodos e avisos entram no padrão', () {
      final saida = verbeteNoPadrao(cristal());

      expect(saida['intentions'],
          ['Aumentar a autoconfiança', 'Promover o aterramento']);
      expect(saida['usageTips'], ['Carregue-a no bolso']);
      expect(saida['safetyWarnings'], ['Evite contato prolongado com água']);
      expect(saida['description'], 'A hematita é um mineral de ferro');

      final limpeza = (saida['cleaningMethods'] as List).cast<Map>();
      expect(limpeza.first['method'], 'Lavar com água corrente');
      expect(limpeza.first['warning'], 'A água pode causar oxidação');
      expect(limpeza.last['warning'], isNull);
      expect((saida['chargingMethods'] as List).cast<Map>().single['method'],
          'Exposição ao luar');
    });

    test('nome, enums e booleanos ficam intocados', () {
      final saida = verbeteNoPadrao({
        ...cristal(),
        'edible': false,
        'toxic': true,
        'planet': 'moon',
      });

      expect(saida['name'], 'Hematita');
      expect(saida['element'], 'earth');
      expect(saida['planet'], 'moon');
      expect(saida['edible'], false);
      expect(saida['toxic'], true);
    });

    test('campo ausente ou de outro tipo não quebra a normalização', () {
      final saida = verbeteNoPadrao({
        'name': 'Alecrim',
        'intentions': 'não é lista',
        'cleaningMethods': ['nem isto é um método'],
      });

      expect(saida['intentions'], 'não é lista');
      expect(saida['cleaningMethods'], ['nem isto é um método']);
      expect(saida.containsKey('description'), isFalse);
    });

    test('o original não é alterado (a cópia é que sai no padrão)', () {
      final original = cristal();
      verbeteNoPadrao(original);
      expect(original['intentions'].first, 'aumentar a autoconfiança');
    });
  });

  // Os verbetes criados ANTES desta régua continuam torto no banco. Como a
  // conversão para o modelo da tela é o funil por onde todo texto passa, é
  // ali que eles são endireitados — sem migração e sem gerar de novo.
  group('verbete pessoal já salvo', () {
    UserEncyclopediaEntry entrada(
      UserEntryCategory categoria,
      Map<String, dynamic> dados,
    ) =>
        UserEncyclopediaEntry(
          id: 'e1',
          userId: 'u1',
          category: categoria,
          name: 'Hematita',
          data: dados,
          createdAt: DateTime(2026, 9, 8),
          updatedAt: DateTime(2026, 9, 8),
        );

    test('cristal salvo em minúscula chega na tela no padrão', () {
      final cristal = entrada(UserEntryCategory.crystal, {
        'description': 'a hematita brilha com tons metálicos escuros.',
        'element': 'earth',
        'intentions': ['aumentar a autoconfiança'],
        'usageTips': ['carregue-a no bolso'],
        'cleaningMethods': [
          {
            'method': 'lavar com água corrente',
            'isSafe': false,
            'warning': 'a água pode causar oxidação',
          }
        ],
        'chargingMethods': [
          {'method': 'exposição ao luar', 'isSafe': true, 'warning': null}
        ],
        'safetyWarnings': ['evite contato prolongado com água'],
      }).toCrystalModel();

      expect(cristal.description, 'A hematita brilha com tons metálicos escuros');
      expect(cristal.intentions, ['Aumentar a autoconfiança']);
      expect(cristal.usageTips, ['Carregue-a no bolso']);
      expect(cristal.safetyWarnings, ['Evite contato prolongado com água']);
      expect(cristal.cleaningMethods.single.method, 'Lavar com água corrente');
      expect(cristal.cleaningMethods.single.warning,
          'A água pode causar oxidação');
      expect(cristal.chargingMethods.single.method, 'Exposição ao luar');
    });

    test('erva salva em minúscula chega na tela no padrão', () {
      final erva = entrada(UserEntryCategory.herb, {
        'description': 'erva de purificação.',
        'scientificName': 'rosmarinus officinalis',
        'element': 'fire',
        'planet': 'sun',
        'magicalProperties': ['purificação', 'proteção'],
        'ritualUses': ['queime como incenso purificador.'],
        'safetyWarnings': ['evite em grandes quantidades na gravidez'],
        'edible': true,
        'toxic': false,
        'folkNames': 'alecrim-do-jardim',
      }).toHerbModel();

      expect(erva.description, 'Erva de purificação');
      expect(erva.scientificName, 'Rosmarinus officinalis');
      expect(erva.magicalProperties, ['Purificação', 'Proteção']);
      expect(erva.ritualUses, ['Queime como incenso purificador']);
      expect(erva.folkNames, 'Alecrim-do-jardim');
      // O que não é texto continua intocado.
      expect(erva.edible, isTrue);
      expect(erva.toxic, isFalse);
    });
  });
}
