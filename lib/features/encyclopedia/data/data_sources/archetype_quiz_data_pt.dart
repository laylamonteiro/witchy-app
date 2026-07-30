import '../models/archetype_quiz_model.dart';

/// Perguntas do Teste de Arquétipo — conteúdo em português (idioma-base).
///
/// A chave `archetypeEmoji` de cada opção é invariante entre idiomas e casa
/// com `ArcaneEntry.emoji` em `archetypes_data_pt/en/es.dart`:
/// 🧙‍♀️ A Bruxa · 🌿 A Curandeira · 👁️ A Vidente · 🛡️ A Guardiã ·
/// 🦉 A Sábia · 🌸 A Donzela · 🤱 A Mãe · 🏹 A Caçadora · 🕸️ A Tecelã ·
/// ⚗️ A Alquimista · 🌑 A Rainha Sombria.
/// Mantenha a mesma ordem/contagem nos três arquivos — a paridade é
/// verificada em `test/encyclopedia_content_parity_test.dart`.
const List<ArchetypeQuizQuestion> archetypeQuizQuestionsPt = [
  ArchetypeQuizQuestion('Num dia difícil, o que mais te restaura?', [
    ArchetypeQuizOption(
        'Ficar em silêncio comigo mesma, longe de todos', '🦉'),
    ArchetypeQuizOption('Preparar um chá, um banho, cuidar do corpo', '🌿'),
    ArchetypeQuizOption('Sair para a natureza, caminhar sem rumo', '🏹'),
    ArchetypeQuizOption('Organizar minha casa e meus planos', '🛡️'),
    ArchetypeQuizOption(
        'Criar algo novo: cozinhar, desenhar, inventar', '⚗️'),
    ArchetypeQuizOption(
        'Colocar uma música e dançar como ninguém está vendo', '🌸'),
  ]),
  ArchetypeQuizQuestion('Qual destes presentes te encantaria mais?', [
    ArchetypeQuizOption('Um baralho de tarot antigo', '👁️'),
    ArchetypeQuizOption('Um caderno em branco encadernado à mão', '🕸️'),
    ArchetypeQuizOption('Um kit de ervas e óleos essenciais', '🌿'),
    ArchetypeQuizOption('Um livro raro de mistérios', '⚗️'),
    ArchetypeQuizOption('Uma capa preta que arrasta no chão', '🧙‍♀️'),
    ArchetypeQuizOption(
        'Um álbum de fotografias antigas da família', '🤱'),
  ]),
  ArchetypeQuizQuestion(
      'Como você reage quando alguém que ama é ameaçado?', [
    ArchetypeQuizOption('Viro uma muralha: ninguém passa por mim', '🛡️'),
    ArchetypeQuizOption('Acolho e cuido das feridas primeiro', '🤱'),
    ArchetypeQuizOption('Enfrento de frente, sem hesitar', '🏹'),
    ArchetypeQuizOption('Percebo a ameaça antes de todo mundo', '👁️'),
    ArchetypeQuizOption(
        'Encaro o agressor com uma verdade que ninguém disse', '🌑'),
    ArchetypeQuizOption(
        'Amarro as pontas: descubro quem, como e por quê', '🕸️'),
  ]),
  ArchetypeQuizQuestion('O que mais te atrai no caminho da bruxaria?', [
    ArchetypeQuizOption('A liberdade de ser quem eu sou', '🧙‍♀️'),
    ArchetypeQuizOption('Transformar dor em sabedoria', '⚗️'),
    ArchetypeQuizOption('Os sonhos, sinais e presságios', '👁️'),
    ArchetypeQuizOption('Os ciclos, padrões e conexões de tudo', '🕸️'),
    ArchetypeQuizOption('O poder de curar a mim e aos meus', '🌿'),
    ArchetypeQuizOption('Proteger quem amo com algo maior que eu', '🛡️'),
  ]),
  ArchetypeQuizQuestion('Qual frase soa mais como você?', [
    ArchetypeQuizOption(
        '"Eu começo de novo quantas vezes precisar"', '🌸'),
    ArchetypeQuizOption('"Eu faço crescer tudo o que toco"', '🤱'),
    ArchetypeQuizOption('"Eu não devo satisfações a ninguém"', '🧙‍♀️'),
    ArchetypeQuizOption('"Eu já vi essa história antes"', '🦉'),
    ArchetypeQuizOption(
        '"Eu vou aonde ninguém teve coragem de ir"', '🏹'),
    ArchetypeQuizOption('"Eu enxergo o que ainda não aconteceu"', '👁️'),
  ]),
  ArchetypeQuizQuestion('Diante da própria sombra, você…', [
    ArchetypeQuizOption(
        'Desço até ela: quero conhecê-la inteira', '🌑'),
    ArchetypeQuizOption(
        'Transformo: nada em mim é lixo, tudo é matéria-prima', '⚗️'),
    ArchetypeQuizOption(
        'Escuto o que ela tem a dizer, sem pressa', '🦉'),
    ArchetypeQuizOption(
        'Ilumino com práticas de cura e autocompaixão', '🌿'),
    ArchetypeQuizOption(
        'Enfrento como caça: olho nos olhos até ela recuar', '🏹'),
    ArchetypeQuizOption(
        'Rio dela: sombra também é parte da minha liberdade', '🧙‍♀️'),
  ]),
  ArchetypeQuizQuestion('Seu lugar favorito num festival místico seria…', [
    ArchetypeQuizOption('A roda de dança, no meio da alegria', '🌸'),
    ArchetypeQuizOption('A tenda de leituras e oráculos', '👁️'),
    ArchetypeQuizOption('A fogueira, contando histórias antigas', '🦉'),
    ArchetypeQuizOption(
        'A barraca de artesanato: nós, fios e amuletos', '🕸️'),
    ArchetypeQuizOption(
        'A cozinha comunitária, alimentando todo mundo', '🤱'),
    ArchetypeQuizOption('O ritual de meia-noite, longe das luzes', '🌑'),
  ]),
  ArchetypeQuizQuestion('O que as pessoas mais buscam em você?', [
    ArchetypeQuizOption(
        'Proteção: comigo elas se sentem seguras', '🛡️'),
    ArchetypeQuizOption('Colo: acolhimento e incentivo', '🤱'),
    ArchetypeQuizOption('Coragem: eu vou na frente', '🏹'),
    ArchetypeQuizOption('Verdade: falo o que ninguém ousa', '🌑'),
    ArchetypeQuizOption(
        'Leveza: eu lembro a elas que recomeçar é possível', '🌸'),
    ArchetypeQuizOption(
        'Transformação: saio melhor de tudo que me atravessa', '⚗️'),
  ]),
];
