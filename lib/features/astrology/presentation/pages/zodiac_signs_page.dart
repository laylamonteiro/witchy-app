import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/enums.dart';

/// Dados detalhados de cada signo do zodíaco
class ZodiacSignData {
  final ZodiacSign sign;
  final String dateRange;
  final String rulingPlanet;
  final String keywords;
  final String personality;
  final String magicalGifts;
  final String bestPractices;
  final String crystals;
  final String herbs;
  final String colors;

  const ZodiacSignData({
    required this.sign,
    required this.dateRange,
    required this.rulingPlanet,
    required this.keywords,
    required this.personality,
    required this.magicalGifts,
    required this.bestPractices,
    required this.crystals,
    required this.herbs,
    required this.colors,
  });
}

/// Base de dados completa dos 12 signos
final List<ZodiacSignData> zodiacSignsData = [
  ZodiacSignData(
    sign: ZodiacSign.aries,
    dateRange: '21 de Março - 19 de Abril',
    rulingPlanet: 'Marte',
    keywords: 'Coragem, Iniciativa, Liderança, Pioneirismo',
    personality:
        'Áries é o primeiro signo do zodíaco, representando o início de tudo. '
        'Pessoas de Áries são naturalmente corajosas, diretas e cheias de energia. '
        'Têm um espírito competitivo e adoram desafios. São líderes natos que preferem '
        'agir rapidamente a ficar planejando por muito tempo. Sua honestidade pode '
        'às vezes parecer brusca, mas vem de um lugar genuíno.',
    magicalGifts:
        'Arianos possuem uma energia vital muito forte, excelente para magia de ação '
        'e proteção. Têm facilidade natural com rituais de coragem, força de vontade '
        'e novos começos. Sua chama interior é poderosa para banimentos e limpezas energéticas.',
    bestPractices:
        'Magia de velas (especialmente vermelhas e laranjas), rituais de proteção, '
        'feitiços de coragem e força, trabalhos de Lua Nova para novos inícios, '
        'magia marcial e trabalhos com o elemento Fogo.',
    crystals: 'Cornalina, Jaspe Vermelho, Rubi, Diamante, Hematita',
    herbs: 'Pimenta, Gengibre, Alho, Canela, Urtiga',
    colors: 'Vermelho, Laranja, Dourado',
  ),
  ZodiacSignData(
    sign: ZodiacSign.taurus,
    dateRange: '20 de Abril - 20 de Maio',
    rulingPlanet: 'Vênus',
    keywords: 'Estabilidade, Sensualidade, Persistência, Abundância',
    personality:
        'Touro é o signo da terra fértil e da abundância. Pessoas de Touro valorizam '
        'segurança, conforto e prazeres sensoriais. São extremamente leais, pacientes '
        'e trabalhadoras. Apreciam as coisas belas da vida e têm um forte senso estético. '
        'Quando se comprometem com algo, vão até o fim com determinação inabalável.',
    magicalGifts:
        'Taurinos têm conexão especial com a terra e a natureza. São excelentes em '
        'magia de prosperidade, fertilidade e manifestação material. Possuem toque '
        'curativo natural e habilidade para trabalhar com plantas e cristais.',
    bestPractices:
        'Bruxaria verde e herbologia, magia de prosperidade e abundância, '
        'rituais de Lua Cheia, trabalho com cristais, jardinagem mágica, '
        'feitiços de amor e beleza, banhos rituais aromáticos.',
    crystals: 'Quartzo Rosa, Esmeralda, Jade, Malaquita, Turmalina Verde',
    herbs: 'Rosa, Verbena, Tomilho, Maçã, Hortelã',
    colors: 'Verde, Rosa, Tons terrosos',
  ),
  ZodiacSignData(
    sign: ZodiacSign.gemini,
    dateRange: '21 de Maio - 20 de Junho',
    rulingPlanet: 'Mercúrio',
    keywords: 'Comunicação, Curiosidade, Versatilidade, Intelecto',
    personality:
        'Gêmeos é o signo da dualidade e comunicação. Geminianos são curiosos, '
        'versáteis e excelentes comunicadores. Adoram aprender coisas novas e '
        'compartilhar conhecimento. Sua mente rápida pode lidar com múltiplas tarefas '
        'simultaneamente. São sociáveis, espirituosos e sempre têm algo interessante a dizer.',
    magicalGifts:
        'Geminianos têm dom natural para magia da palavra - encantamentos, sigilos '
        'e invocações. São excelentes em adivinhação, especialmente tarot e bibliomancia. '
        'Sua versatilidade permite dominar diversas formas de magia.',
    bestPractices:
        'Magia da palavra e encantamentos verbais, criação de sigilos, '
        'adivinhação (tarot, runas, pêndulo), magia de comunicação, '
        'trabalho com incensos e elemento Ar, estudos esotéricos.',
    crystals: 'Ágata, Citrino, Olho de Tigre, Água-marinha, Howlita',
    herbs: 'Lavanda, Alecrim, Menta, Feno-grego, Erva-doce',
    colors: 'Amarelo, Cinza, Azul claro',
  ),
  ZodiacSignData(
    sign: ZodiacSign.cancer,
    dateRange: '21 de Junho - 22 de Julho',
    rulingPlanet: 'Lua',
    keywords: 'Intuição, Nutrição, Proteção, Emoção',
    personality:
        'Câncer é o signo da Lua, governando emoções e intuição. Cancerianos são '
        'profundamente intuitivos, protetores e carinhosos. Valorizam família e lar '
        'acima de tudo. Têm memória emocional forte e são muito leais aos que amam. '
        'Sua sensibilidade é tanto sua força quanto sua vulnerabilidade.',
    magicalGifts:
        'Cancerianos têm conexão natural com a Lua e seus ciclos. Possuem forte '
        'intuição psíquica, dom para magia emocional e habilidade natural para '
        'proteção do lar. São excelentes em trabalhos com água e magia lunar.',
    bestPractices:
        'Magia lunar em todas as fases, proteção do lar e família, '
        'rituais com água (banhos, poções, espelhos), trabalho com ancestrais, '
        'magia de cura emocional, adivinhação por sonhos.',
    crystals: 'Pedra da Lua, Pérola, Selenita, Opala, Quartzo Leitoso',
    herbs: 'Artemísia, Jasmim, Alface, Pepino, Nenúfar',
    colors: 'Branco, Prata, Azul pálido',
  ),
  ZodiacSignData(
    sign: ZodiacSign.leo,
    dateRange: '23 de Julho - 22 de Agosto',
    rulingPlanet: 'Sol',
    keywords: 'Criatividade, Expressão, Generosidade, Poder',
    personality:
        'Leão é o signo do Sol, irradiando luz e calor. Leoninos são naturalmente '
        'carismáticos, criativos e generosos. Adoram ser o centro das atenções e '
        'têm talento para liderança. São leais, protetores e têm grande coração. '
        'Sua presença ilumina qualquer ambiente que entram.',
    magicalGifts:
        'Leoninos carregam energia solar poderosa. São mestres em magia de sucesso, '
        'glamour e manifestação. Têm dom natural para liderar rituais em grupo '
        'e canalizar energia vital. Excelentes em trabalhos de autoconfiança.',
    bestPractices:
        'Magia solar e rituais ao meio-dia, trabalhos de sucesso e reconhecimento, '
        'glamour mágico, magia de velas douradas, rituais de criatividade, '
        'feitiços de autoestima, liderança de círculos mágicos.',
    crystals: 'Âmbar, Citrino, Olho de Tigre, Pirita, Topázio',
    herbs: 'Girassol, Camomila, Canela, Louro, Calêndula',
    colors: 'Dourado, Laranja, Amarelo brilhante',
  ),
  ZodiacSignData(
    sign: ZodiacSign.virgo,
    dateRange: '23 de Agosto - 22 de Setembro',
    rulingPlanet: 'Mercúrio',
    keywords: 'Análise, Serviço, Perfeição, Praticidade',
    personality:
        'Virgem é o signo da organização e do serviço. Virginianos são analíticos, '
        'práticos e extremamente detalhistas. Têm forte senso de dever e adoram ajudar '
        'os outros. São perfeccionistas por natureza e buscam sempre melhorar. '
        'Sua mente organizada é excelente para resolver problemas complexos.',
    magicalGifts:
        'Virginianos têm talento especial para herbologia e magia curativa. '
        'São excelentes em preparar poções, tinturas e remédios mágicos. '
        'Sua atenção aos detalhes torna seus rituais precisos e eficazes.',
    bestPractices:
        'Herbologia e preparo de poções, magia de cura e saúde, '
        'rituais de purificação, organização de altares, '
        'magia prática do dia-a-dia, criação de talismãs e amuletos.',
    crystals: 'Amazonita, Peridoto, Jaspe, Cornalina, Safira',
    herbs: 'Valeriana, Erva-cidreira, Camomila, Funcho, Alfazema',
    colors: 'Verde, Marrom, Bege, Azul marinho',
  ),
  ZodiacSignData(
    sign: ZodiacSign.libra,
    dateRange: '23 de Setembro - 22 de Outubro',
    rulingPlanet: 'Vênus',
    keywords: 'Equilíbrio, Harmonia, Justiça, Relacionamentos',
    personality:
        'Libra é o signo do equilíbrio e da harmonia. Librianos são diplomáticos, '
        'justos e apreciam a beleza em todas as formas. Valorizam relacionamentos '
        'e buscam paz e cooperação. Têm forte senso estético e habilidade natural '
        'para ver todos os lados de uma questão.',
    magicalGifts:
        'Librianos são naturalmente habilidosos em magia de amor e relacionamentos. '
        'Têm dom para equilibrar energias e harmonizar ambientes. São excelentes '
        'em trabalhos de justiça e contratos mágicos.',
    bestPractices:
        'Magia de amor e relacionamentos, rituais de equilíbrio e harmonia, '
        'feitiços de beleza e glamour, trabalhos de justiça, '
        'magia de parcerias, decoração de altares estéticos.',
    crystals: 'Quartzo Rosa, Jade, Lápis-lazúli, Opala, Turmalina Rosa',
    herbs: 'Rosa, Violeta, Tomilho, Mirra, Verbena',
    colors: 'Rosa, Azul claro, Verde suave, Lavanda',
  ),
  ZodiacSignData(
    sign: ZodiacSign.scorpio,
    dateRange: '23 de Outubro - 21 de Novembro',
    rulingPlanet: 'Plutão (e Marte)',
    keywords: 'Transformação, Intensidade, Mistério, Poder',
    personality:
        'Escorpião é o signo da transformação profunda. Escorpianos são intensos, '
        'misteriosos e extremamente perceptivos. Têm capacidade de ver além das '
        'aparências e não têm medo de explorar as sombras. São leais até a morte '
        'e possuem força de vontade incomparável.',
    magicalGifts:
        'Escorpianos têm conexão natural com o oculto e a morte mística. '
        'São mestres em magia de transformação, banimento e trabalho com sombras. '
        'Possuem forte intuição psíquica e habilidade para mediunidade.',
    bestPractices:
        'Trabalho com sombras e psique profunda, magia de transformação, '
        'rituais de Samhain e contato ancestral, banimentos poderosos, '
        'magia sexual, trabalho com Plutão, necromancia respeitosa.',
    crystals: 'Obsidiana, Turmalina Negra, Granada, Labradorita, Malaquita',
    herbs: 'Absinto, Mandrágora, Basilisco, Patchouli, Sangue de Dragão',
    colors: 'Preto, Vermelho escuro, Roxo profundo',
  ),
  ZodiacSignData(
    sign: ZodiacSign.sagittarius,
    dateRange: '22 de Novembro - 21 de Dezembro',
    rulingPlanet: 'Júpiter',
    keywords: 'Expansão, Filosofia, Aventura, Otimismo',
    personality:
        'Sagitário é o signo da expansão e busca pela verdade. Sagitarianos são '
        'otimistas, aventureiros e filosóficos. Adoram viajar (física e mentalmente) '
        'e expandir seus horizontes. São honestos, generosos e têm fé na vida. '
        'Sua busca por significado os leva a explorar diversas tradições espirituais.',
    magicalGifts:
        'Sagitarianos têm conexão com sabedoria superior e expansão de consciência. '
        'São excelentes em magia de sorte, abundância e viagens astrais. '
        'Têm facilidade para conectar-se com guias espirituais e mestres ascensos.',
    bestPractices:
        'Magia de sorte e expansão, rituais de prosperidade jupiteriana, '
        'viagem astral e jornadas xamânicas, trabalho com filosofias antigas, '
        'feitiços para estudos e sabedoria, rituais em lugares sagrados.',
    crystals: 'Turquesa, Ametista, Sodalita, Lápis-lazúli, Topázio Azul',
    herbs: 'Sálvia, Cedro, Noz-moscada, Anis, Dente-de-leão',
    colors: 'Roxo, Azul royal, Turquesa',
  ),
  ZodiacSignData(
    sign: ZodiacSign.capricorn,
    dateRange: '22 de Dezembro - 19 de Janeiro',
    rulingPlanet: 'Saturno',
    keywords: 'Disciplina, Ambição, Estrutura, Responsabilidade',
    personality:
        'Capricórnio é o signo da estrutura e ambição. Capricornianos são '
        'disciplinados, responsáveis e extremamente determinados. Valorizam tradição '
        'e trabalho duro. Podem parecer sérios, mas têm senso de humor seco. '
        'Constroem suas vidas com paciência, tijolo por tijolo.',
    magicalGifts:
        'Capricornianos têm maestria em magia de manifestação a longo prazo. '
        'São excelentes em rituais de estrutura, proteção e trabalho com ancestrais. '
        'Sua disciplina permite práticas mágicas consistentes e poderosas.',
    bestPractices:
        'Magia de carreira e sucesso material, rituais saturninos, '
        'trabalho com ancestrais e tradições antigas, feitiços de proteção, '
        'magia de compromisso e contratos, rituais de Yule.',
    crystals: 'Ônix, Turmalina Negra, Obsidiana, Garnet, Jet',
    herbs: 'Confrei, Cipreste, Hera, Cardo, Raiz de Valeriana',
    colors: 'Preto, Cinza, Marrom escuro, Verde musgo',
  ),
  ZodiacSignData(
    sign: ZodiacSign.aquarius,
    dateRange: '20 de Janeiro - 18 de Fevereiro',
    rulingPlanet: 'Urano (e Saturno)',
    keywords: 'Inovação, Humanitarismo, Originalidade, Liberdade',
    personality:
        'Aquário é o signo da inovação e consciência coletiva. Aquarianos são '
        'originais, independentes e humanitários. Pensam fora da caixa e valorizam '
        'liberdade acima de tudo. São visionários que se importam genuinamente '
        'com o bem-estar da humanidade.',
    magicalGifts:
        'Aquarianos têm conexão com energias cósmicas e consciência expandida. '
        'São excelentes em magia de grupo e trabalhos para o bem coletivo. '
        'Têm facilidade para inovações mágicas e tecnomancia.',
    bestPractices:
        'Magia de grupo e círculos de bruxas, rituais para causas humanitárias, '
        'trabalho com astrologia e cartas astrais, inovações em práticas mágicas, '
        'feitiços de liberdade e independência, tecnomancia.',
    crystals: 'Ametista, Água-marinha, Fluorita, Labradorita, Angelita',
    herbs: 'Alfazema, Mirra, Olíbano, Hortelã-pimenta, Verbena',
    colors: 'Azul elétrico, Violeta, Prata, Turquesa',
  ),
  ZodiacSignData(
    sign: ZodiacSign.pisces,
    dateRange: '19 de Fevereiro - 20 de Março',
    rulingPlanet: 'Netuno (e Júpiter)',
    keywords: 'Intuição, Compaixão, Misticismo, Sonhos',
    personality:
        'Peixes é o signo da transcendência e compaixão universal. Piscianos são '
        'extremamente intuitivos, empáticos e criativos. Vivem entre o mundo material '
        'e espiritual com naturalidade. São artistas da alma, capazes de sentir '
        'profundamente as emoções dos outros e do coletivo.',
    magicalGifts:
        'Piscianos têm os dons psíquicos mais fortes do zodíaco. São naturalmente '
        'médiuns, videntes e curandeiros empáticos. Sua conexão com o mundo espiritual '
        'é inata, e têm facilidade para trabalho com sonhos e visões.',
    bestPractices:
        'Trabalho com sonhos e interpretação onírica, mediunidade e canalização, '
        'magia aquática e rituais com água, cura empática, '
        'viagem astral, conexão com seres espirituais, arte como magia.',
    crystals: 'Ametista, Água-marinha, Fluorita, Pedra da Lua, Sugilita',
    herbs: 'Jasmim, Lótus, Eucalipto, Algas, Salgueiro',
    colors: 'Azul marinho, Roxo, Verde-água, Prata',
  ),
];

class ZodiacSignsPage extends StatelessWidget {
  const ZodiacSignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signos do Zodíaco'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              child: Column(
                children: [
                  const Text('', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Os 12 Signos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Descubra as características, dons mágicos e práticas '
                    'recomendadas para cada signo do zodíaco.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.softWhite.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lista de signos
            ...zodiacSignsData.map((signData) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSignCard(context, signData),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSignCard(BuildContext context, ZodiacSignData data) {
    return MagicalCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: Text(
            data.sign.symbol,
            style: const TextStyle(fontSize: 36),
          ),
          title: Text(
            data.sign.displayName,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.lilac,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                data.dateRange,
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    data.sign.element.symbol,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${data.sign.element.displayName} | ${data.sign.modality.displayName}',
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          iconColor: AppColors.lilac,
          collapsedIconColor: AppColors.lilac,
          children: [
            const Divider(color: AppColors.lilac),
            const SizedBox(height: 8),

            // Planeta regente
            _buildSection(
              '',
              'Planeta Regente: ${data.rulingPlanet}',
              isHighlight: true,
            ),

            // Palavras-chave
            _buildSection('', data.keywords, isHighlight: true),

            const SizedBox(height: 12),

            // Personalidade
            _buildSection('Personalidade', data.personality),

            // Dons Mágicos
            _buildSection('Dons Mágicos', data.magicalGifts),

            // Práticas Recomendadas
            _buildSection('Práticas Recomendadas', data.bestPractices),

            // Cristais
            _buildSection('Cristais', data.crystals),

            // Ervas
            _buildSection('Ervas', data.herbs),

            // Cores
            _buildSection('Cores', data.colors),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                color: AppColors.lilac,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            content,
            style: TextStyle(
              color: isHighlight
                  ? AppColors.starYellow
                  : AppColors.softWhite.withOpacity(0.9),
              fontSize: isHighlight ? 13 : 14,
              height: 1.5,
              fontStyle: isHighlight ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
