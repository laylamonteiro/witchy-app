// lib/ui/grimorio/spells_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/spell.dart';
import '../../services/repositories/spell_repository.dart';
import 'spell_form_screen.dart';

class SpellsListScreen extends StatefulWidget {
  const SpellsListScreen({super.key});

  @override
  State<SpellsListScreen> createState() => _SpellsListScreenState();
}

class _SpellsListScreenState extends State<SpellsListScreen> {
  final _repo = SpellRepository();

  @override
  Widget build(BuildContext context) {
    final spells = _repo.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grimório'),
      ),
      body: spells.isEmpty
          ? const Center(
              child:
                  Text('Nenhum feitiço ainda. Toque em + para criar o primeiro.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: spells.length,
              itemBuilder: (context, index) {
                final spell = spells[index];
                return _SpellItem(
                  spell: spell,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SpellFormScreen(
                          repository: _repo,
                          existing: spell,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  onDelete: () {
                    setState(() {
                      _repo.delete(spell.id);
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SpellFormScreen(repository: _repo),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SpellItem extends StatelessWidget {
  final Spell spell;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SpellItem({
    required this.spell,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeLabel = spell.type == SpellType.attraction
        ? 'Atração / Crescimento'
        : 'Banimento / Corte';

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(spell.name),
        subtitle: Text(typeLabel),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
