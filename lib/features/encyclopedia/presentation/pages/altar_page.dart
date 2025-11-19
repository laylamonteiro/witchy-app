import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';

/// Página informativa sobre altares
class AltarPage extends StatelessWidget {
  const AltarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🕯️', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'O Altar Mágico',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Um altar é seu espaço sagrado pessoal - um ponto focal para sua prática mágica. '
                    'Não precisa ser elaborado ou caro; o que importa é a intenção e o respeito com que você o trata. '
                    'Seu altar é uma extensão da sua energia e um portal entre o mundo físico e o espiritual.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // Como montar
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏡 Como Montar seu Altar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
                    'Terra (cristais, sal, plantas), Água (taça com água), '
                    'Fogo (vela), Ar (incenso, pena). Posicione conforme os pontos cardeais se possível: '
                    'Norte (Terra), Sul (Fogo), Leste (Ar), Oeste (Água).',
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
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ O que Usar no Altar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildItem(context, '🕯️ Velas', 'Representam o elemento Fogo e a luz divina. Use cores correspondentes às suas intenções.'),
                  _buildItem(context, '💎 Cristais', 'Amplificam energia e trazem propriedades específicas (quartzo rosa para amor, ametista para espiritualidade).'),
                  _buildItem(context, '🌿 Ervas', 'Secas ou frescas, cada erva tem correspondências mágicas únicas.'),
                  _buildItem(context, '🔮 Objetos simbólicos', 'Pentáculo, símbolos lunares, runas, tarot, estatuetas de divindades.'),
                  _buildItem(context, '💧 Taça com água', 'Elemento Água, pode ser trocada regularmente ou usada em rituais.'),
                  _buildItem(context, '🧂 Sal', 'Purificação e proteção, representa a Terra.'),
                  _buildItem(context, '📿 Incenso', 'Elemento Ar, limpa energia e eleva vibrações.'),
                  _buildItem(context, '📖 Grimório', 'Seu livro de sombras ou diário de práticas.'),
                  _buildItem(context, '🌙 Itens lunares', 'Representações da lua, água lunar, calendário lunar.'),
                  _buildItem(context, '🪶 Penas', 'Elemento Ar, conexão com o divino.'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lilac.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lilac.withOpacity(0.3)),
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
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ O que Evitar no Altar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildWarning(context, 'Itens de energia negativa', 'Objetos que tragam memórias ruins ou sensações desconfortáveis.'),
                  _buildWarning(context, 'Excesso de objetos', 'Um altar lotado dispersa a energia. Mantenha organizado e intencional.'),
                  _buildWarning(context, 'Itens emprestados sem permissão', 'Cada objeto carrega a energia de seu dono.'),
                  _buildWarning(context, 'Lixo ou sujeira', 'Mantenha seu altar limpo fisicamente e energeticamente.'),
                  _buildWarning(context, 'Objetos alheios à sua prática', 'Não coloque símbolos de tradições que você não pratica por modismo.'),
                  _buildWarning(context, 'Plantas mortas', 'Retire folhas secas e plantas mortas regularmente.'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.alert.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.alert.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SEGURANÇA: Nunca deixe velas acesas sem supervisão. Mantenha materiais inflamáveis longe das chamas.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌊 Como Purificar seu Altar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A purificação remove energias estagnadas ou negativas, renovando o espaço sagrado.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildMethod(context, '🔥 Defumação', 'Use alecrim, arruda, sálvia, ou pau santo. Passe a fumaça por todo o altar e objetos com intenção de limpeza.'),
                  _buildMethod(context, '💧 Água e sal', 'Borrife água com sal grosso (ou água lunar) pelo espaço. Cuidado com objetos que não podem molhar.'),
                  _buildMethod(context, '🔔 Som', 'Use sinos, tigelas tibetanas ou palmas para quebrar energia estagnada.'),
                  _buildMethod(context, '🌙 Luz da lua', 'Deixe objetos sob a luz da lua cheia para limpeza energética profunda.'),
                  _buildMethod(context, '🧘 Visualização', 'Visualize luz branca ou dourada preenchendo o altar e dissolvendo energias densas.'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
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
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧹 Como Manter seu Altar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildMaintenance(context, 'Limpeza física regular', 'Tire poeira, limpe superfícies, organize objetos. Idealmente na lua minguante.'),
                  _buildMaintenance(context, 'Troque oferendas', 'Se você deixa oferendas (flores, alimentos, água), troque antes que estraguem.'),
                  _buildMaintenance(context, 'Recarregue cristais', 'Limpe e recarregue cristais regularmente (lua, sol, terra, fumaça).'),
                  _buildMaintenance(context, 'Atualize conforme as estações', 'Adapte decorações e elementos sazonais (Sabbats, solstícios, equinócios).'),
                  _buildMaintenance(context, 'Visite diariamente', 'Mesmo que brevemente. Acenda uma vela, agradeça, medite. Mantenha a energia viva.'),
                  _buildMaintenance(context, 'Reorganize quando necessário', 'Seu altar pode evoluir com você. Remova o que não ressoa mais, adicione o novo.'),
                  _buildMaintenance(context, 'Proteja energeticamente', 'Renove proteções regularmente com sal ao redor, visualizações ou sigilos.'),
                ],
              ),
            ),

            // Como utilizar
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Como Utilizar seu Altar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildUsage(context, 'Meditação e conexão', 'Sente-se em frente ao altar para meditar, centrar-se e conectar-se com o divino.'),
                  _buildUsage(context, 'Feitiços e rituais', 'Use como espaço de trabalho mágico. Acenda velas, prepare poções, consagre ferramentas.'),
                  _buildUsage(context, 'Oferendas e agradecimentos', 'Deixe oferendas para divindades, ancestrais ou espíritos que você honra.'),
                  _buildUsage(context, 'Celebrações sazonais', 'Decore e celebre Sabbats, luas cheias, equinócios no altar.'),
                  _buildUsage(context, 'Carregamento de objetos', 'Deixe itens (talismãs, joias, cristais) no altar para carregar com energia.'),
                  _buildUsage(context, 'Divinação', 'Pratique tarot, runas, pêndulo ou outras formas de divinação no altar.'),
                  _buildUsage(context, 'Ponto focal diário', 'Comece ou termine o dia no altar, definindo intenções ou refletindo.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.mint.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💚 Sugestão de rotina diária:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.mint,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Manhã: Acenda uma vela, defina intenção do dia\n'
                          '• Tarde: Momento de gratidão ou reflexão breve\n'
                          '• Noite: Agradeça pelo dia, apague a vela com reverência',
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

            // Considerações finais
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌟 Considerações Finais',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
                  Center(
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

  Widget _buildItem(BuildContext context, String iconTitle, String description) {
    // Separar emoji do título (emoji é o primeiro caractere)
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

  Widget _buildMaintenance(BuildContext context, String title, String description) {
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
