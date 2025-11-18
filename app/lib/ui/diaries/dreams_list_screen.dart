// lib/ui/diaries/dreams_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/repositories/dream_repository.dart';
import '../../models/dream.dart';
import 'dream_form_screen.dart';

class DreamsListScreen extends StatefulWidget {
  const DreamsListScreen({super.key});

  @override
  State<DreamsListScreen> createState() => _DreamsListScreenState();
}

class _DreamsListScreenState extends State<DreamsListScreen> {
  final _repo = DreamRepository();

  @override
  Widget build(BuildContext context) {
    final dreams = _repo.getAll();

    return Scaffold(
      body: dreams.isEmpty
          ? const Center(
              child:
                  Text('Nenhum sonho anotado ainda. Toque em + para registrar.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: dreams.length,
              itemBuilder: (context, index) {
                final d = dreams[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(d.title ?? '(Sem título)'),
                    subtitle: Text(
                      '${d.date.day.toString().padLeft(2, '0')}/'
                      '${d.date.month.toString().padLeft(2, '0')}/'
                      '${d.date.year.toString()}',
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DreamFormScreen(
                            repository: _repo,
                            existing: d,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _repo.delete(d.id);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DreamFormScreen(repository: _repo),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
