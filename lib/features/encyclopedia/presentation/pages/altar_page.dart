import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/expansion_magical_card.dart';

/// Página informativa sobre altares
class AltarPage extends StatelessWidget {
  const AltarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('O Altar Mágico'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🛐', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sobre o Altar',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Um altar é seu espaço sagrado pessoal - um ponto focal para sua prática mágica. '
                    'Não precisa ser elaborado ou caro; o que importa é a intenção e o respeito com que você o trata. '
                    'Seu altar é uma extensão da sua energia e um portal entre o mundo físico e o espiritual.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore as seções abaixo para aprender a montar, purificar, manter e utilizar seu altar.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // NOVO: Passo-a-Passo para Iniciantes
            _buildPassoAPasso(context),

            const SizedBox(height: 16),

            // Como montar
            ExpansionMagicalCard(
              title: 'Como Montar seu Altar',
              emoji: '🏡',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildStep(
                    context,
                    '1. Escolha o local',
                    'Selecione um espaço tranquilo onde você possa ter privacidade. '
                        'Pode ser uma mesa, prateleira, cômoda ou até um canto do seu quarto. '
                        'Evite banheiros e lavanderias (pontos de saída de energia).',
                  ),
                  _buildStep(
                    context,
                    '2. Limpe o espaço',
                    'Limpe fisicamente a superfície e energeticamente com fumaça de ervas '
                        '(alecrim, arruda, sálvia) ou borrife água com sal.',
                  ),
                  _buildStep(
                    context,
                    '3. Use uma toalha ou tecido',
                    'Opcional, mas recomendado. Use cores que ressoem com você: '
                        'preto (proteção), branco (pureza), roxo (espiritualidade), verde (cura).',
                  ),
                  _buildStep(
                    context,
                    '4. Represente os 4 elementos',
                    'Cada elemento traz uma energia essencial para o altar:\n\n'
                        '🌍 Terra (Norte): Cristais, sal, pedras, plantas, pentáculo\n'
                        '💧 Água (Oeste): Taça com água, conchas, água lunar\n'
                        '🔥 Fogo (Sul): Vela, caldeirão, athame\n'
                        '💨 Ar (Leste): Incenso, penas, sinos, varinha\n\n'
                        '💡 Dica: Posicione cada elemento na direção cardeal correspondente quando possível.',
                  ),
                  _buildStep(
                    context,
                    '5. Adicione itens pessoais',
                    'Imagens de divindades, fotos de ancestrais, símbolos que fazem sentido para você, '
                        'ferramentas mágicas (athame, caldeirão, varinha), livro de sombras.',
                  ),
                ],
              ),
            ),

            // O que usar
            ExpansionMagicalCard(
              title: 'O que Usar no Altar',
              emoji: '✨',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildItem(context, '🕯️ Velas',
                      'Representam o elemento Fogo e a luz divina. Use cores correspondentes às suas intenções.'),
                  _buildItem(context, '💎 Cristais',
                      'Amplificam energia e trazem propriedades específicas (quartzo rosa para amor, ametista para espiritualidade).'),
                  _buildItem(context, '🌿 Ervas',
                      'Secas ou frescas, cada erva tem correspondências mágicas únicas.'),
                  _buildItem(context, '🔮 Objetos simbólicos',
                      'Pentáculo, símbolos lunares, runas, tarot, estatuetas de divindades.'),
                  _buildItem(context, '💧 Taça com água',
                      'Elemento Água, pode ser trocada regularmente ou usada em rituais.'),
                  _buildItem(context, '🧂 Sal',
                      'Purificação e proteção, representa a Terra.'),
                  _buildItem(context, '📿 Incenso',
                      'Elemento Ar, limpa energia e eleva vibrações.'),
                  _buildItem(context, '📖 Grimório',
                      'Seu livro de sombras ou diário de práticas.'),
                  _buildItem(context, '🌙 Itens lunares',
                      'Representações da lua, água lunar, calendário lunar.'),
                  _buildItem(context, '🪶 Penas',
                      'Elemento Ar, conexão com o divino.'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lilac.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.lilac.withOpacity(0.3)),
                    ),
                    child: Text(
                      '💡 Lembre-se: Não existe lista obrigatória. Use o que ressoa com você e sua prática.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // O que não usar
            ExpansionMagicalCard(
              title: 'O que Evitar no Altar',
              emoji: '⚠️',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildWarning(context, 'Itens de energia negativa',
                      'Objetos que tragam memórias ruins ou sensações desconfortáveis.'),
                  _buildWarning(context, 'Excesso de objetos',
                      'Um altar lotado dispersa a energia. Mantenha organizado e intencional.'),
                  _buildWarning(context, 'Itens emprestados sem permissão',
                      'Cada objeto carrega a energia de seu dono.'),
                  _buildWarning(context, 'Lixo ou sujeira',
                      'Mantenha seu altar limpo fisicamente e energeticamente.'),
                  _buildWarning(context, 'Objetos alheios à sua prática',
                      'Não coloque símbolos de tradições que você não pratica por modismo.'),
                  _buildWarning(context, 'Plantas mortas',
                      'Retire folhas secas e plantas mortas regularmente.'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.alert.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.alert.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SEGURANÇA: Nunca deixe velas acesas sem supervisão. Mantenha materiais inflamáveis longe das chamas.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Como purificar
            ExpansionMagicalCard(
              title: 'Como Purificar seu Altar',
              emoji: '🌊',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'A purificação remove energias estagnadas ou negativas, renovando o espaço sagrado.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildMethod(context, '🔥 Defumação',
                      'Use alecrim, arruda, sálvia, ou pau santo. Passe a fumaça por todo o altar e objetos com intenção de limpeza.'),
                  _buildMethod(context, '💧 Água e sal',
                      'Borrife água com sal grosso (ou água lunar) pelo espaço. Cuidado com objetos que não podem molhar.'),
                  _buildMethod(context, '🔔 Som',
                      'Use sinos, tigelas tibetanas ou palmas para quebrar energia estagnada.'),
                  _buildMethod(context, '🌙 Luz da lua',
                      'Deixe objetos sob a luz da lua cheia para limpeza energética profunda.'),
                  _buildMethod(context, '🧘 Visualização',
                      'Visualize luz branca ou dourada preenchendo o altar e dissolvendo energias densas.'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Text(
                      '🌙 Frequência recomendada: A cada lua nova ou cheia, ou quando sentir a energia pesada.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Como manter
            ExpansionMagicalCard(
              title: 'Como Manter seu Altar',
              emoji: '🧹',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildMaintenance(context, 'Limpeza física regular',
                      'Tire poeira, limpe superfícies, organize objetos. Idealmente na lua minguante.'),
                  _buildMaintenance(context, 'Troque oferendas',
                      'Se você deixa oferendas (flores, alimentos, água), troque antes que estraguem.'),
                  _buildMaintenance(context, 'Recarregue cristais',
                      'Limpe e recarregue cristais regularmente (lua, sol, terra, fumaça).'),
                  _buildMaintenance(context, 'Atualize conforme as estações',
                      'Adapte decorações e elementos sazonais (Sabbats, solstícios, equinócios).'),
                  _buildMaintenance(context, 'Visite diariamente',
                      'Mesmo que brevemente. Acenda uma vela, agradeça, medite. Mantenha a energia viva.'),
                  _buildMaintenance(context, 'Reorganize quando necessário',
                      'Seu altar pode evoluir com você. Remova o que não ressoa mais, adicione o novo.'),
                  _buildMaintenance(context, 'Proteja energeticamente',
                      'Renove proteções regularmente com sal ao redor, visualizações ou sigilos.'),
                ],
              ),
            ),

            // Como utilizar
            ExpansionMagicalCard(
              title: 'Como Utilizar seu Altar',
              emoji: '✨',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildUsage(context, 'Meditação e conexão',
                      'Sente-se em frente ao altar para meditar, centrar-se e conectar-se com o divino.'),
                  _buildUsage(context, 'Feitiços e rituais',
                      'Use como espaço de trabalho mágico. Acenda velas, prepare poções, consagre ferramentas.'),
                  _buildUsage(context, 'Oferendas e agradecimentos',
                      'Deixe oferendas para divindades, ancestrais ou espíritos que você honra.'),
                  _buildUsage(context, 'Celebrações sazonais',
                      'Decore e celebre Sabbats, luas cheias, equinócios no altar.'),
                  _buildUsage(context, 'Carregamento de objetos',
                      'Deixe itens (talismãs, joias, cristais) no altar para carregar com energia.'),
                  _buildUsage(context, 'Divinação',
                      'Pratique tarot, runas, pêndulo ou outras formas de divinação no altar.'),
                  _buildUsage(context, 'Ponto focal diário',
                      'Comece ou termine o dia no altar, definindo intenções ou refletindo.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.mint.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💚 Sugestão de rotina diária:',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppColors.mint),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Manhã: Acenda uma vela, defina intenção do dia\n'
                          '• Tarde: Momento de gratidão ou reflexão breve\n'
                          '• Noite: Agradeça pelo dia, apague a vela com reverência',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Considerações finais
            ExpansionMagicalCard(
              title: 'Considerações Finais',
              emoji: '🌟',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Seu altar é uma expressão pessoal da sua espiritualidade. Não existe forma "certa" ou "errada" - '
                    'o que importa é que ele seja significativo para VOCÊ. '
                    '\n\nUm altar simples com três velas e um cristal carregado de intenção é mais poderoso '
                    'que um altar elaborado sem conexão emocional. '
                    '\n\nPermita que seu altar cresça organicamente, reflita suas mudanças e seja sempre um espaço de paz, '
                    'poder e conexão com o sagrado.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      '✨🕯️🌙',
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

  Widget _buildPassoAPasso(BuildContext context) {
    return MagicalCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Passo-a-Passo para Iniciantes',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lilac,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seu primeiro encontro com seu altar',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.lilac),
          const SizedBox(height: 16),

          // Introdução
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lilac.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lilac.withOpacity(0.3)),
            ),
            child: Text(
              'Não se preocupe se você não tem todos os itens "tradicionais". '
              'Um altar pode começar com uma vela e uma intenção. O importante é que '
              'seja significativo para VOCÊ. Não existe altar errado quando é feito com coração.',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Passos numerados
          _buildPassoNumerado(
              '1',
              'Escolha o Local',
              'Um cantinho onde você não será perturbado(a). Pode ser uma mesinha, prateleira, ou até uma caixa que você abre quando for praticar.',
              'Não precisa ser grande! Um espaço de 30x30cm já é suficiente.'),

          _buildPassoNumerado(
              '2',
              'Limpe o Espaço',
              'Limpe fisicamente com um pano, depois passe fumaça de incenso ou visualize uma luz branca purificando.',
              'Diga: "Que este espaço seja purificado e abençoado."'),

          _buildPassoNumerado(
              '3',
              'Adicione uma Vela',
              'A vela é o coração do altar - representa o fogo e a luz divina. Uma única vela branca já é suficiente.',
              'Velas brancas são universais e podem substituir qualquer cor.'),

          _buildPassoNumerado(
              '4',
              'Adicione Itens Significativos',
              'Coloque o que tem significado para você: foto de ancestrais, cristal que ganhou, flores, uma concha da praia.',
              'Comece com 3-5 itens e vá adicionando com o tempo.'),

          _buildPassoNumerado(
              '5',
              'Consagre seu Altar',
              'Acenda a vela, respire fundo e diga: "Consagro este altar como meu espaço sagrado. Que ele seja um portal de conexão."',
              'Use suas próprias palavras! O importante é a intenção.'),

          const SizedBox(height: 20),

          // O que fazer no altar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mint.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌟 Nas primeiras vezes no altar',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.mint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildListaSimples(
                    '1. Acenda a vela com intenção, observe a chama'),
                _buildListaSimples(
                    '2. Faça 3 respirações profundas para se centrar'),
                _buildListaSimples(
                    '3. Agradeça pelo dia, pela vida, por algo bom'),
                _buildListaSimples(
                    '4. Defina uma intenção: "Hoje eu peço/agradeço..."'),
                _buildListaSimples(
                    '5. Fique alguns minutos em silêncio ou converse'),
                _buildListaSimples(
                    '6. Feche: "Agradeço pela conexão. Que assim seja."'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // O que falar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.starYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.starYellow.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💬 O que falar no altar?',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.starYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildExemploFala(context, 'Para abrir:',
                    '"Acendo esta vela como símbolo da minha conexão com o sagrado."'),
                _buildExemploFala(context, 'Para pedir:',
                    '"Peço orientação para [situação]. Que a sabedoria ilumine meu caminho."'),
                _buildExemploFala(context, 'Para agradecer:',
                    '"Agradeço por [bênção específica]. Meu coração está cheio de gratidão."'),
                _buildExemploFala(context, 'Para fechar:',
                    '"Agradeço a conexão. Que a magia continue comigo. Assim seja."'),
                const SizedBox(height: 8),
                Text(
                  'Lembre-se: Não existe fórmula errada. O universo entende sua intenção!',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Dúvidas comuns
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.pink.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '❓ Dúvidas Comuns de Iniciantes',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDuvida(context, 'Posso ter um altar secreto?',
                    'Sim! Use uma caixa que você abre quando for praticar.'),
                _buildDuvida(context, 'Preciso ir ao altar todo dia?',
                    'Não há regra. Vá quando sentir vontade. Uma rotina fortalece, mas não é obrigatória.'),
                _buildDuvida(context, 'Posso mexer nas coisas?',
                    'Sim! O altar é vivo e deve mudar com você.'),
                _buildDuvida(context, 'E se eu esquecer as palavras?',
                    'Improvise! O divino não se importa com palavras perfeitas.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassoNumerado(
      String numero, String titulo, String descricao, String dica) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.lilac.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lilac),
            ),
            child: Center(
              child: Text(
                numero,
                style: const TextStyle(
                  color: AppColors.lilac,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.lilac,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 ', style: TextStyle(color: AppColors.starYellow)),
                    Expanded(
                      child: Text(
                        dica,
                        style: TextStyle(
                          color: AppColors.starYellow,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaSimples(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildExemploFala(BuildContext context, String titulo, String fala) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: AppColors.starYellow,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              fala,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuvida(BuildContext context, String pergunta, String resposta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pergunta,
            style: TextStyle(
              color: AppColors.pink,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            resposta,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, String iconTitle, String description) {
    final emoji = iconTitle.substring(0, iconTitle.indexOf(' ') + 1);
    final title = iconTitle.substring(iconTitle.indexOf(' ') + 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
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

  Widget _buildWarning(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel, color: AppColors.alert, size: 20),
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

  Widget _buildMethod(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenance(
      BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.mint, size: 20),
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

  Widget _buildUsage(BuildContext context, String title, String description) {
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
