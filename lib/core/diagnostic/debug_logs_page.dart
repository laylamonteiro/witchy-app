import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/debug_log_service.dart';
import '../theme/app_theme.dart';
import '../theme/grimoire_colors.dart';

/// Página para visualizar logs de debug
class DebugLogsPage extends StatefulWidget {
  const DebugLogsPage({super.key});

  @override
  State<DebugLogsPage> createState() => _DebugLogsPageState();
}

class _DebugLogsPageState extends State<DebugLogsPage> {
  final _logService = DebugLogService();
  final _scrollController = ScrollController();
  String _filterTag = 'ALL';

  final List<String> _tags = ['ALL', 'AUTH', 'SYSTEM', 'NAV', 'ERROR'];

  @override
  void initState() {
    super.initState();
    // Scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DebugLogEntry> get _filteredLogs {
    if (_filterTag == 'ALL') return _logService.logs;
    return _logService.logs.where((l) => l.tag == _filterTag).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Debug Logs'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copiar logs',
            onPressed: _copyLogs,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpar logs',
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tags.map((tag) {
                  final isSelected = _filterTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _filterTag = tag),
                      backgroundColor: const Color(0xFF1A1A2E),
                      selectedColor: context.gc.lilac.withValues(alpha: 0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? context.gc.lilac : context.gc.textSecondary,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? context.gc.lilac : context.gc.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Total: ${_filteredLogs.length} logs',
                  style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  'Última atualização: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Logs list
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum log encontrado',
                      style: TextStyle(color: context.gc.textSecondary),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return _buildLogEntry(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(DebugLogEntry log) {
    final time = '${log.timestamp.hour.toString().padLeft(2, '0')}:'
        '${log.timestamp.minute.toString().padLeft(2, '0')}:'
        '${log.timestamp.second.toString().padLeft(2, '0')}.'
        '${log.timestamp.millisecond.toString().padLeft(3, '0')}';

    Color tagColor;
    switch (log.tag) {
      case 'AUTH':
        tagColor = context.gc.lilac;
        break;
      case 'ERROR':
        tagColor = Colors.red;
        break;
      case 'NAV':
        tagColor = context.gc.mint;
        break;
      case 'SYSTEM':
        tagColor = context.gc.starYellow;
        break;
      default:
        tagColor = context.gc.textSecondary;
    }

    final isSessionStart = log.message.contains('═══');

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isSessionStart
            ? context.gc.lilac.withValues(alpha: 0.1)
            : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(4),
        border: isSessionStart
            ? Border.all(color: context.gc.lilac.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            time,
            style: TextStyle(
              color: context.gc.textPrimary.withValues(alpha: 0.4),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              log.tag,
              style: TextStyle(
                color: tagColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Message
          Expanded(
            child: Text(
              log.message,
              style: TextStyle(
                color: isSessionStart ? context.gc.lilac : context.gc.textPrimary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLogs() {
    final logsText = _logService.exportLogs();
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logs copiados para a área de transferência'),
        backgroundColor: context.gc.mint,
      ),
    );
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title:
            Text('Limpar Logs?', style: TextStyle(color: context.gc.textPrimary)),
        content: Text(
          'Isso removerá todos os logs salvos.',
          style: TextStyle(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Limpar', style: TextStyle(color: context.gc.textPrimary)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _logService.clearLogs();
      setState(() {});
    }
  }
}
