// lib/ui/more/more_screen.dart
import 'package:flutter/material.dart';
import '../../data/static_data.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mais'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const _SectionTitle('Biblioteca mágica'),
          ...defaultCrystals.map(
            (c) => ListTile(
              leading: const Icon(Icons.auto_fix_high_outlined),
              title: Text(c.name),
              subtitle: Text(c.description),
            ),
          ),
          const Divider(),
          const _SectionTitle('Cores mágicas'),
          ...defaultMagicColors.map(
            (c) => ListTile(
              leading: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(int.parse(c.hex.replaceFirst('#', '0xff'))),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(c.name),
              subtitle: Text(c.description),
            ),
          ),
          const Divider(),
          const _SectionTitle('Sigilos (em breve)'),
          const ListTile(
            leading: Icon(Icons.gesture_outlined),
            title: Text('Criar sigilo'),
            subtitle: Text(
              'Gerar sigilos com a roda alfabética das bruxas estará disponível nas próximas versões.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
