import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/expansion_magical_card.dart';

/// Página informativa sobre os 4 elementos
class ElementsPage extends StatelessWidget {
  const ElementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Os Quatro Elementos'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🌍💧🔥💨', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Na Wicca e na bruxaria tradicional, os quatro elementos - Terra, Água, Fogo e Ar - '
                          'são forças fundamentais da natureza e da existência. Eles não são apenas substâncias físicas, '
                          'mas energias primordiais que compõem toda a criação.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Explore cada elemento abaixo para compreender suas qualidades, correspondências e como trabalhar com eles.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // TERRA
            ExpansionMagicalCard(
              title: 'Terra',
              emoji: '🌍',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubsection(
                    context,
                    'Essência',
                    'A Terra representa estabilidade, solidez, crescimento e manifestação física. '
                    'É o elemento da matéria, do corpo, da abundância material e da conexão com o mundo natural. '
                    'Terra é onde as ideias se tornam realidade.',
                  ),
                  _buildSubsection(
                    context,
                    'Qualidades',
                    'Estável, fértil, nutritiva, confiável, prática, paciente, enraizada',
                  ),
                  _buildSubsection(
                    context,
                    'Direção Cardeal',
                    'Norte',
                  ),
                  _buildSubsection(
                    context,
                    'Estação',
                    'Inverno (momento de recolhimento e gestação)',
                  ),
                  _buildSubsection(
                    context,
                    'Fase da Vida',
                    'Velhice e sabedoria',
                  ),
                  _buildSubsection(
                    context,
                    'Hora do Dia',
                    'Meia-noite',
                  ),
                  _buildSubsection(
                    context,
                    'Cores',
                    'Verde, marrom, preto, amarelo (tons terrosos)',
                  ),
                  _buildSubsection(
                    context,
                    'Ferramentas Mágicas',
                    'Pentáculo, cristais, sal, pedras, moedas',
                  ),
                  _buildSubsection(
                    context,
                    'Correspondências',
                    '• Cristais: Quartzo fumê, turmalina negra, jaspe, ágata, hematita\n'
                    '• Ervas: Alecrim, cedro, patchouli, vetiver, raízes\n'
                    '• Animais: Urso, veado, touro, coelho, cobra\n'
                    '• Zodíaco: Touro, Virgem, Capricórnio',
                  ),
                  _buildSubsection(
                    context,
                    'Quando Trabalhar com Terra',
                    '• Manifestação de objetivos materiais\n'
                    '• Prosperidade e abundância\n'
                    '• Enraizamento e centralização\n'
                    '• Cura física\n'
                    '• Conexão com a natureza\n'
                    '• Estabilidade e segurança\n'
                    '• Crescimento e fertilidade',
                  ),
                ],
              ),
            ),

            // ÁGUA
            ExpansionMagicalCard(
              title: 'Água',
              emoji: '💧',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubsection(
                    context,
                    'Essência',
                    'A Água representa emoções, intuição, cura e purificação. '
                    'É o elemento dos sentimentos profundos, do subconsciente, dos sonhos e da psique. '
                    'Água flui, adapta-se e reflete a verdade interior.',
                  ),
                  _buildSubsection(
                    context,
                    'Qualidades',
                    'Fluida, adaptável, emocional, intuitiva, curativa, purificadora, reflexiva',
                  ),
                  _buildSubsection(
                    context,
                    'Direção Cardeal',
                    'Oeste',
                  ),
                  _buildSubsection(
                    context,
                    'Estação',
                    'Outono (momento de colheita e reflexão)',
                  ),
                  _buildSubsection(
                    context,
                    'Fase da Vida',
                    'Maturidade',
                  ),
                  _buildSubsection(
                    context,
                    'Hora do Dia',
                    'Crepúsculo',
                  ),
                  _buildSubsection(
                    context,
                    'Cores',
                    'Azul, turquesa, prateado, índigo, roxo',
                  ),
                  _buildSubsection(
                    context,
                    'Ferramentas Mágicas',
                    'Cálice, caldeirão, espelho, taça, conchas',
                  ),
                  _buildSubsection(
                    context,
                    'Correspondências',
                    '• Cristais: Ametista, pedra da lua, água-marinha, pérola, sodalita\n'
                    '• Ervas: Camomila, gardênia, jasmim, lótus, sálvia\n'
                    '• Animais: Peixe, golfinho, cisne, sapo, lontra\n'
                    '• Zodíaco: Câncer, Escorpião, Peixes',
                  ),
                  _buildSubsection(
                    context,
                    'Quando Trabalhar com Água',
                    '• Cura emocional e espiritual\n'
                    '• Desenvolvimento da intuição\n'
                    '• Trabalho com sonhos\n'
                    '• Purificação energética\n'
                    '• Amor e relacionamentos\n'
                    '• Meditação e contemplação\n'
                    '• Conexão com o subconsciente',
                  ),
                ],
              ),
            ),

            // FOGO
            ExpansionMagicalCard(
              title: 'Fogo',
              emoji: '🔥',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubsection(
                    context,
                    'Essência',
                    'O Fogo representa transformação, paixão, vontade e poder pessoal. '
                    'É o elemento da energia vital, da coragem, da criatividade e da ação. '
                    'Fogo consome, transforma e ilumina.',
                  ),
                  _buildSubsection(
                    context,
                    'Qualidades',
                    'Dinâmico, transformador, purificador, apaixonado, corajoso, energético, criativo',
                  ),
                  _buildSubsection(
                    context,
                    'Direção Cardeal',
                    'Sul',
                  ),
                  _buildSubsection(
                    context,
                    'Estação',
                    'Verão (momento de pico de energia)',
                  ),
                  _buildSubsection(
                    context,
                    'Fase da Vida',
                    'Juventude e vigor',
                  ),
                  _buildSubsection(
                    context,
                    'Hora do Dia',
                    'Meio-dia',
                  ),
                  _buildSubsection(
                    context,
                    'Cores',
                    'Vermelho, laranja, dourado, amarelo brilhante',
                  ),
                  _buildSubsection(
                    context,
                    'Ferramentas Mágicas',
                    'Athame (adaga ritual), varinha, vela, caldeirão em chamas',
                  ),
                  _buildSubsection(
                    context,
                    'Correspondências',
                    '• Cristais: Cornalina, citrino, rubi, granada, obsidiana\n'
                    '• Ervas: Canela, gengibre, pimenta, manjericão, cravo\n'
                    '• Animais: Dragão, leão, fênix, serpente de fogo, salamandra\n'
                    '• Zodíaco: Áries, Leão, Sagitário',
                  ),
                  _buildSubsection(
                    context,
                    'Quando Trabalhar com Fogo',
                    '• Transformação pessoal\n'
                    '• Coragem e força de vontade\n'
                    '• Paixão e criatividade\n'
                    '• Proteção ativa\n'
                    '• Purificação energética\n'
                    '• Banimento de energias negativas\n'
                    '• Manifestação rápida de desejos',
                  ),
                ],
              ),
            ),

            // AR
            ExpansionMagicalCard(
              title: 'Ar',
              emoji: '💨',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubsection(
                    context,
                    'Essência',
                    'O Ar representa intelecto, comunicação, pensamento e inspiração. '
                    'É o elemento da mente, das ideias, da sabedoria e do conhecimento. '
                    'Ar carrega mensagens, dispersa e renova.',
                  ),
                  _buildSubsection(
                    context,
                    'Qualidades',
                    'Leve, móvel, comunicativo, intelectual, inspirador, livre, renovador',
                  ),
                  _buildSubsection(
                    context,
                    'Direção Cardeal',
                    'Leste',
                  ),
                  _buildSubsection(
                    context,
                    'Estação',
                    'Primavera (momento de novos começos)',
                  ),
                  _buildSubsection(
                    context,
                    'Fase da Vida',
                    'Infância e aprendizado',
                  ),
                  _buildSubsection(
                    context,
                    'Hora do Dia',
                    'Amanhecer',
                  ),
                  _buildSubsection(
                    context,
                    'Cores',
                    'Amarelo claro, branco, azul claro, lavanda',
                  ),
                  _buildSubsection(
                    context,
                    'Ferramentas Mágicas',
                    'Varinha (em algumas tradições), athame (em outras), incenso, penas, sinos',
                  ),
                  _buildSubsection(
                    context,
                    'Correspondências',
                    '• Cristais: Citrino, topázio, fluorita, ágata de renda azul\n'
                    '• Ervas: Lavanda, hortelã, eucalipto, sálvia branca, dente-de-leão\n'
                    '• Animais: Águia, borboleta, pássaros, libélula, fada\n'
                    '• Zodíaco: Gêmeos, Libra, Aquário',
                  ),
                  _buildSubsection(
                    context,
                    'Quando Trabalhar com Ar',
                    '• Estudo e aprendizado\n'
                    '• Comunicação e eloquência\n'
                    '• Viagem e movimento\n'
                    '• Inspiração criativa\n'
                    '• Clareza mental\n'
                    '• Novos começos\n'
                    '• Trabalho com divindades celestes',
                  ),
                ],
              ),
            ),

            // Equilíbrio dos Elementos
            ExpansionMagicalCard(
              title: 'O Equilíbrio Elemental',
              emoji: '⚖️',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Na prática da bruxaria, buscar o equilíbrio dos quatro elementos é essencial. '
                    'Cada elemento representa aspectos diferentes de nossa vida e personalidade:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildBalanceItem('🌍 Terra', 'Nosso corpo físico e recursos materiais'),
                  _buildBalanceItem('💧 Água', 'Nossas emoções e relacionamentos'),
                  _buildBalanceItem('🔥 Fogo', 'Nossa energia e poder pessoal'),
                  _buildBalanceItem('💨 Ar', 'Nossa mente e comunicação'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lilac.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lilac.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sinais de Desequilíbrio:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Terra em excesso: Teimosia, materialismo, resistência a mudanças\n'
                          '• Água em excesso: Emotividade excessiva, instabilidade emocional\n'
                          '• Fogo em excesso: Impulsividade, raiva, esgotamento\n'
                          '• Ar em excesso: Distração, falta de praticidade, desconexão',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Como Trabalhar com os Elementos
            ExpansionMagicalCard(
              title: 'Como Trabalhar com os Elementos',
              emoji: '✨',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildPracticeItem(
                    context,
                    'Meditação Elemental',
                    'Sente-se com um objeto representando cada elemento e medite sobre suas qualidades. '
                    'Sinta a energia do elemento fluindo através de você.',
                  ),
                  _buildPracticeItem(
                    context,
                    'Círculo Mágico',
                    'Ao lançar um círculo, invoque cada elemento em sua direção cardeal. '
                    'Isso cria um espaço sagrado equilibrado e protegido.',
                  ),
                  _buildPracticeItem(
                    context,
                    'Altar Elemental',
                    'Mantenha representações dos quatro elementos em seu altar para manter o equilíbrio energético.',
                  ),
                  _buildPracticeItem(
                    context,
                    'Feitiços Específicos',
                    'Trabalhe com o elemento correspondente à sua intenção: '
                    'Terra para prosperidade, Água para amor, Fogo para coragem, Ar para sabedoria.',
                  ),
                  _buildPracticeItem(
                    context,
                    'Conexão Diária',
                    'Passe tempo na natureza conectando-se com os elementos: '
                    'caminhe descalço (Terra), tome banho ritual (Água), acenda velas (Fogo), pratique respiração (Ar).',
                  ),
                ],
              ),
            ),

            // Considerações Finais
            ExpansionMagicalCard(
              title: 'Honrando os Elementos',
              emoji: '🌟',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Os quatro elementos não são apenas ferramentas mágicas - eles são forças vivas que sustentam toda a existência. '
                    'Ao trabalhar com os elementos, estamos nos conectando com as próprias fundações do universo. '
                    '\n\nRespeite cada elemento, aprenda suas lições e permita que suas energias guiem e fortaleçam sua prática. '
                    'Com o tempo, você desenvolverá uma relação profunda com cada elemento, reconhecendo sua presença '
                    'tanto no mundo exterior quanto dentro de si mesmo.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '🌍💧🔥💨',
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lilac,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String element, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            element,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.starYellow, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
