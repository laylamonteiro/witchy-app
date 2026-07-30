import '../models/archetype_quiz_model.dart';

/// Preguntas del Test de Arquetipo — contenido en español.
///
/// La clave `archetypeEmoji` de cada opción es invariante entre idiomas y
/// coincide con `ArcaneEntry.emoji` en `archetypes_data_pt/en/es.dart`:
/// 🧙‍♀️ La Bruja · 🌿 La Curandera · 👁️ La Vidente · 🛡️ La Guardiana ·
/// 🦉 La Sabia · 🌸 La Doncella · 🤱 La Madre · 🏹 La Cazadora ·
/// 🕸️ La Tejedora · ⚗️ La Alquimista · 🌑 La Reina Sombría.
/// Mantén el mismo orden/recuento en los tres archivos — la paridad se
/// verifica en `test/encyclopedia_content_parity_test.dart`.
const List<ArchetypeQuizQuestion> archetypeQuizQuestionsEs = [
  ArchetypeQuizQuestion('En un día difícil, ¿qué te restaura más?', [
    ArchetypeQuizOption(
        'Quedarme en silencio conmigo misma, lejos de todos', '🦉'),
    ArchetypeQuizOption(
        'Preparar un té, un baño, cuidar de mi cuerpo', '🌿'),
    ArchetypeQuizOption(
        'Salir a la naturaleza, caminar sin rumbo', '🏹'),
    ArchetypeQuizOption('Organizar mi casa y mis planes', '🛡️'),
    ArchetypeQuizOption(
        'Crear algo nuevo: cocinar, dibujar, inventar', '⚗️'),
    ArchetypeQuizOption(
        'Poner una canción y bailar como si nadie estuviera mirando', '🌸'),
  ]),
  ArchetypeQuizQuestion('¿Cuál de estos regalos te encantaría más?', [
    ArchetypeQuizOption('Una baraja de tarot antigua', '👁️'),
    ArchetypeQuizOption('Un cuaderno en blanco encuadernado a mano', '🕸️'),
    ArchetypeQuizOption('Un kit de hierbas y aceites esenciales', '🌿'),
    ArchetypeQuizOption('Un libro raro de misterios', '⚗️'),
    ArchetypeQuizOption('Una capa negra que arrastra por el suelo', '🧙‍♀️'),
    ArchetypeQuizOption(
        'Un álbum de fotografías antiguas de la familia', '🤱'),
  ]),
  ArchetypeQuizQuestion(
      '¿Cómo reaccionas cuando alguien que amas es amenazado?', [
    ArchetypeQuizOption('Me vuelvo una muralla: nadie pasa por mí', '🛡️'),
    ArchetypeQuizOption('Acojo y curo las heridas primero', '🤱'),
    ArchetypeQuizOption('Lo enfrento de frente, sin dudar', '🏹'),
    ArchetypeQuizOption('Percibo la amenaza antes que nadie', '👁️'),
    ArchetypeQuizOption(
        'Encaro al agresor con una verdad que nadie ha dicho', '🌑'),
    ArchetypeQuizOption(
        'Ato los cabos: descubro quién, cómo y por qué', '🕸️'),
  ]),
  ArchetypeQuizQuestion('¿Qué te atrae más del camino de la brujería?', [
    ArchetypeQuizOption('La libertad de ser quien soy', '🧙‍♀️'),
    ArchetypeQuizOption('Transformar el dolor en sabiduría', '⚗️'),
    ArchetypeQuizOption('Los sueños, señales y presagios', '👁️'),
    ArchetypeQuizOption(
        'Los ciclos, patrones y conexiones de todo', '🕸️'),
    ArchetypeQuizOption('El poder de sanarme a mí y a los míos', '🌿'),
    ArchetypeQuizOption(
        'Proteger a quienes amo con algo más grande que yo', '🛡️'),
  ]),
  ArchetypeQuizQuestion('¿Qué frase suena más como tú?', [
    ArchetypeQuizOption(
        '"Empiezo de nuevo cuantas veces haga falta"', '🌸'),
    ArchetypeQuizOption('"Hago crecer todo lo que toco"', '🤱'),
    ArchetypeQuizOption('"No le debo explicaciones a nadie"', '🧙‍♀️'),
    ArchetypeQuizOption('"Ya he visto esta historia antes"', '🦉'),
    ArchetypeQuizOption(
        '"Voy adonde nadie ha tenido el valor de ir"', '🏹'),
    ArchetypeQuizOption('"Veo lo que aún no ha sucedido"', '👁️'),
  ]),
  ArchetypeQuizQuestion('Ante tu propia sombra, tú…', [
    ArchetypeQuizOption(
        'Desciendo hasta ella: quiero conocerla entera', '🌑'),
    ArchetypeQuizOption(
        'Transformo: nada en mí es desecho, todo es materia prima', '⚗️'),
    ArchetypeQuizOption(
        'Escucho lo que tiene que decir, sin prisa', '🦉'),
    ArchetypeQuizOption(
        'La ilumino con prácticas de sanación y autocompasión', '🌿'),
    ArchetypeQuizOption(
        'La enfrento como presa: la miro a los ojos hasta que retrocede',
        '🏹'),
    ArchetypeQuizOption(
        'Me río con ella: la sombra también es parte de mi libertad',
        '🧙‍♀️'),
  ]),
  ArchetypeQuizQuestion(
      'Tu lugar favorito en un festival místico sería…', [
    ArchetypeQuizOption(
        'La rueda de danza, en medio de la alegría', '🌸'),
    ArchetypeQuizOption('La tienda de lecturas y oráculos', '👁️'),
    ArchetypeQuizOption('La hoguera, contando historias antiguas', '🦉'),
    ArchetypeQuizOption(
        'El puesto de artesanía: nudos, hilos y amuletos', '🕸️'),
    ArchetypeQuizOption(
        'La cocina comunitaria, alimentando a todo el mundo', '🤱'),
    ArchetypeQuizOption(
        'El ritual de medianoche, lejos de las luces', '🌑'),
  ]),
  ArchetypeQuizQuestion('¿Qué es lo que más buscan las personas en ti?', [
    ArchetypeQuizOption(
        'Protección: conmigo se sienten seguras', '🛡️'),
    ArchetypeQuizOption('Regazo: acogida y aliento', '🤱'),
    ArchetypeQuizOption('Valentía: yo voy al frente', '🏹'),
    ArchetypeQuizOption('Verdad: digo lo que nadie se atreve', '🌑'),
    ArchetypeQuizOption(
        'Ligereza: les recuerdo que volver a empezar es posible', '🌸'),
    ArchetypeQuizOption(
        'Transformación: salgo mejor de todo lo que me atraviesa', '⚗️'),
  ]),
];
