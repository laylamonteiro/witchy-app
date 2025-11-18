// lib/ui/diaries/desires_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/repositories/desire_repository.dart';
import '../../models/desire.dart';
import 'desire_form_screen.dart';

class DesiresListScreen extends StatefulWidget {
  const DesiresListScreen({super.key});

  @override
  State<DesiresListScreen> createState() => _DesiresListScreenState();
}

class _DesiresListScreenState extends State<DesiresListScreen> {
  final _repo = DesireRepository();

  @override
  Widget build(BuildContext context) {
    final desires = _repo.getAll();

    return Scaffold(
      body: desires.isEmpty
          ? const Center(
              child:
                  Text('Nenhum desejo anotado ainda. Toque em + para registrar.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: desires.length,
              itemBuilder: (context, index) {
                final d = desires[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(d.title),
                    subtitle: Text(_statusLabel(d.status)),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DesireFormScreen(
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
              builder: (_) => DesireFormScreen(repository: _repo),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _statusLabel(DesireStatus status) {
    switch (status) {
      case DesireStatus.open:
        return 'Em aberto';
      case DesireStatus.inProgress:
        return 'Em processo';
      case DesireStatus.realized:
        return 'Realizado';
    }
  }
}
