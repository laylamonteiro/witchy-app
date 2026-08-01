import 'journey_model.dart' show JourneyText;

/// Textos das jornadas — português (idioma-base). Ids invariantes.
/// Paridade verificada em test/content_models_parity_test.dart.
const Map<String, JourneyText> journeyTextsPt = {
  'iniciante_01': (title: 'Primeiros Passos', description: 'Comece sua jornada magica aprendendo o basico'),
  'grimorio_01': (title: 'Mestre do Grimorio', description: 'Construa um grimorio poderoso com seus feitiços'),
  'gratidao_01': (title: 'Coracao Grato', description: 'Cultive a gratidão em sua vida diaria'),
  'sonhos_01': (title: 'Viajante Onirico', description: 'Explore o mundo dos sonhos'),
  'divinacao_01': (title: 'Vidente', description: 'Domine as artes divinatórias'),
  'desejos_01': (title: 'Manifestador', description: 'Aprenda a manifestar seus desejos'),
  'rituais_01': (title: 'Ritualista', description: 'Viva a magia das datas: sabbats, luas e águas mágicas'),
};

const Map<String, JourneyText> journeyStepTextsPt = {
  'ini_01_01': (title: 'Crie seu primeiro feitico', description: 'Registre seu primeiro feitico no grimorio'),
  'ini_01_02': (title: 'Escreva no diario de sonhos', description: 'Registre um sonho no seu diario'),
  'ini_01_03': (title: 'Pratique gratidão', description: 'Escreva sua primeira entrada de gratidão'),
  'ini_01_04': (title: 'Consulte as runas', description: 'Faca sua primeira leitura de runas'),
  'ini_01_05': (title: 'Descubra seu mapa astral', description: 'Gere seu mapa astral completo'),
  'grim_01_01': (title: 'Aprendiz', description: 'Crie 5 feitiços'),
  'grim_01_02': (title: 'Praticante', description: 'Crie 10 feitiços'),
  'grim_01_03': (title: 'Mestre', description: 'Crie 25 feitiços'),
  'grim_01_04': (title: 'Arquimago', description: 'Crie 50 feitiços'),
  'grat_01_01': (title: 'Despertar', description: 'Pratique gratidão por 3 dias seguidos'),
  'grat_01_02': (title: 'Habito', description: 'Pratique gratidão por 7 dias seguidos'),
  'grat_01_03': (title: 'Devocao', description: 'Pratique gratidão por 21 dias seguidos'),
  'grat_01_04': (title: 'Iluminacao', description: 'Pratique gratidão por 30 dias seguidos'),
  'son_01_01': (title: 'Primeiro Registro', description: 'Registre seu primeiro sonho'),
  'son_01_02': (title: 'Sonhador Dedicado', description: 'Registre 10 sonhos'),
  'son_01_03': (title: 'Mestre dos Sonhos', description: 'Registre 30 sonhos'),
  'son_01_04': (title: 'Oráculo Onírico', description: 'Registre 50 sonhos'),
  'div_01_01': (title: 'Iniciacao nas Runas', description: 'Faca 5 leituras de runas'),
  'div_01_02': (title: 'Leitor de Oráculo', description: 'Faca 5 leituras do oráculo'),
  'div_01_03': (title: 'Mestre do Pêndulo', description: 'Faca 10 consultas ao pêndulo'),
  'div_01_04': (title: 'Oráculo Completo', description: 'Faca 25 leituras no total'),
  'des_01_01': (title: 'Primeiro Desejo', description: 'Registre seu primeiro desejo'),
  'des_01_02': (title: 'Lista de Desejos', description: 'Registre 10 desejos'),
  'des_01_03': (title: 'Primeira Manifestacao', description: 'Manifeste seu primeiro desejo'),
  'des_01_04': (title: 'Mestre Manifestador', description: 'Manifeste 5 desejos'),
  'rit_01_01': (title: 'Primeiro Ritual', description: 'Complete seu primeiro ritual guiado'),
  'rit_01_02': (title: 'Praticante da Roda', description: 'Complete 3 rituais guiados'),
  'rit_01_03': (title: 'Guardiã dos Ciclos', description: 'Complete 8 rituais guiados'),
  'rit_01_04': (title: 'Mestra dos Rituais', description: 'Complete 13 rituais guiados'),
};
