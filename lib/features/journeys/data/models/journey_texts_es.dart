import 'journey_model.dart' show JourneyText;

/// Textos de los caminos — español. Ids invariantes.
/// Paridade verificada em test/content_models_parity_test.dart.
const Map<String, JourneyText> journeyTextsEs = {
  'iniciante_01': (title: 'Primeros Pasos', description: 'Comienza tu camino mágico aprendiendo lo básico'),
  'grimorio_01': (title: 'Maestro del Grimorio', description: 'Construye un grimorio poderoso con tus hechizos'),
  'gratidao_01': (title: 'Corazón Agradecido', description: 'Cultiva la gratitud en tu vida diaria'),
  'sonhos_01': (title: 'Viajero Onírico', description: 'Explora el mundo de los sueños'),
  'divinacao_01': (title: 'Vidente', description: 'Domina las artes adivinatorias'),
  'desejos_01': (title: 'Manifestador', description: 'Aprende a manifestar tus deseos'),
  'rituais_01': (title: 'Ritualista', description: 'Vive la magia de las fechas: sabbats, lunas y aguas mágicas'),
};

const Map<String, JourneyText> journeyStepTextsEs = {
  'ini_01_01': (title: 'Crea tu primer hechizo', description: 'Registra tu primer hechizo en el grimorio'),
  'ini_01_02': (title: 'Escribe en el diario de sueños', description: 'Registra un sueño en tu diario'),
  'ini_01_03': (title: 'Practica la gratitud', description: 'Escribe tu primera entrada de gratitud'),
  'ini_01_04': (title: 'Consulta las runas', description: 'Haz tu primera lectura de runas'),
  'ini_01_05': (title: 'Descubre tu carta natal', description: 'Genera tu carta natal completa'),
  'grim_01_01': (title: 'Aprendiz', description: 'Crea 5 hechizos'),
  'grim_01_02': (title: 'Practicante', description: 'Crea 10 hechizos'),
  'grim_01_03': (title: 'Maestro', description: 'Crea 25 hechizos'),
  'grim_01_04': (title: 'Archimago', description: 'Crea 50 hechizos'),
  'grat_01_01': (title: 'Despertar', description: 'Practica la gratitud durante 3 días seguidos'),
  'grat_01_02': (title: 'Hábito', description: 'Practica la gratitud durante 7 días seguidos'),
  'grat_01_03': (title: 'Devoción', description: 'Practica la gratitud durante 21 días seguidos'),
  'grat_01_04': (title: 'Iluminación', description: 'Practica la gratitud durante 30 días seguidos'),
  'son_01_01': (title: 'Primer Registro', description: 'Registra tu primer sueño'),
  'son_01_02': (title: 'Soñador Dedicado', description: 'Registra 10 sueños'),
  'son_01_03': (title: 'Maestro de los Sueños', description: 'Registra 30 sueños'),
  'son_01_04': (title: 'Oráculo Onírico', description: 'Registra 50 sueños'),
  'div_01_01': (title: 'Iniciación en las Runas', description: 'Haz 5 lecturas de runas'),
  'div_01_02': (title: 'Lector de Oráculo', description: 'Haz 5 lecturas del oráculo'),
  'div_01_03': (title: 'Maestro del Péndulo', description: 'Haz 10 consultas al péndulo'),
  'div_01_04': (title: 'Oráculo Completo', description: 'Haz 25 lecturas en total'),
  'des_01_01': (title: 'Primer Deseo', description: 'Registra tu primer deseo'),
  'des_01_02': (title: 'Lista de Deseos', description: 'Registra 10 deseos'),
  'des_01_03': (title: 'Primera Manifestación', description: 'Manifiesta tu primer deseo'),
  'des_01_04': (title: 'Maestro Manifestador', description: 'Manifiesta 5 deseos'),
  'rit_01_01': (title: 'Primer Ritual', description: 'Completa tu primer ritual guiado'),
  'rit_01_02': (title: 'Practicante de la Rueda', description: 'Completa 3 rituales guiados'),
  'rit_01_03': (title: 'Guardiana de los Ciclos', description: 'Completa 8 rituales guiados'),
  'rit_01_04': (title: 'Maestra de los Rituales', description: 'Completa 13 rituales guiados'),
};
