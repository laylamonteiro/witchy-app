import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para armazenar e recuperar logs de debug
/// Útil para diagnosticar problemas durante a inicialização do app
class DebugLogService {
  static const String _logsKey = 'debug_logs';
  static const int _maxLogs = 200;

  static final DebugLogService _instance = DebugLogService._internal();
  factory DebugLogService() => _instance;
  DebugLogService._internal();

  final List<DebugLogEntry> _logs = [];
  bool _initialized = false;

  List<DebugLogEntry> get logs => List.unmodifiable(_logs);

  /// Inicializa o serviço carregando logs salvos
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLogs = prefs.getStringList(_logsKey) ?? [];

      _logs.clear();
      for (final logStr in savedLogs) {
        try {
          final parts = logStr.split('|||');
          if (parts.length >= 3) {
            _logs.add(DebugLogEntry(
              timestamp: DateTime.parse(parts[0]),
              tag: parts[1],
              message: parts[2],
            ));
          }
        } catch (_) {}
      }

      _initialized = true;

      // Adicionar log de início de sessão
      await log('SYSTEM', '═══ Nova sessão iniciada ═══');
    } catch (e) {
      debugPrint('Erro ao inicializar DebugLogService: $e');
    }
  }

  /// Adiciona um log e salva
  Future<void> log(String tag, String message) async {
    final entry = DebugLogEntry(
      timestamp: DateTime.now(),
      tag: tag,
      message: message,
    );

    _logs.add(entry);

    // Limitar quantidade de logs
    while (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Também printar no console
    debugPrint('[$tag] $message');

    await _gravarAgrupado();
  }

  /// Gravação em voo? E chegou linha nova enquanto ela acontecia?
  bool _gravando = false;
  bool _sujo = false;

  /// Agrupa as gravações SEM temporizador.
  ///
  /// Cada linha reescrevia as 200 do buffer inteiro no armazenamento, e na
  /// web isso é na mesma thread da interface: um punhado de linhas seguidas
  /// (um boot, uma sincronização) travava a tela. Aqui a primeira linha da
  /// rajada abre UMA gravação; as que chegam durante ela só marcam sujo, e
  /// ao terminar uma última gravação recolhe todas — duas idas ao
  /// armazenamento no lugar de vinte.
  ///
  /// Sem `Timer` de propósito: um temporizador pendente é gravação que pode
  /// nunca acontecer (o app fecha antes) e, nos testes de widget, é o
  /// "A Timer is still pending even after the widget tree was disposed"
  /// que derrubou dois deles.
  Future<void> _gravarAgrupado() async {
    if (_gravando) {
      _sujo = true;
      return;
    }
    _gravando = true;
    try {
      do {
        _sujo = false;
        await _saveLogs();
      } while (_sujo);
    } finally {
      _gravando = false;
    }
  }

  /// Salva logs no SharedPreferences
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logStrings = _logs.map((e) =>
          '${e.timestamp.toIso8601String()}|||${e.tag}|||${e.message}'
      ).toList();
      await prefs.setStringList(_logsKey, logStrings);
    } catch (e) {
      debugPrint('Erro ao salvar logs: $e');
    }
  }

  /// Limpa todos os logs
  Future<void> clearLogs() async {
    _logs.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logsKey);
      await log('SYSTEM', 'Logs limpos');
    } catch (e) {
      debugPrint('Erro ao limpar logs: $e');
    }
  }

  /// Exporta logs como string
  String exportLogs() {
    final buffer = StringBuffer();
    buffer.writeln('═══ Debug Logs - Grimório de Bolso ═══');
    buffer.writeln('Exportado em: ${DateTime.now()}');
    buffer.writeln('Total de logs: ${_logs.length}');
    buffer.writeln('');

    for (final log in _logs) {
      final time = '${log.timestamp.hour.toString().padLeft(2, '0')}:'
          '${log.timestamp.minute.toString().padLeft(2, '0')}:'
          '${log.timestamp.second.toString().padLeft(2, '0')}.'
          '${log.timestamp.millisecond.toString().padLeft(3, '0')}';
      buffer.writeln('[$time] [${log.tag}] ${log.message}');
    }

    return buffer.toString();
  }
}

/// Entrada de log
class DebugLogEntry {
  final DateTime timestamp;
  final String tag;
  final String message;

  DebugLogEntry({
    required this.timestamp,
    required this.tag,
    required this.message,
  });
}

/// Função helper para logging rápido
Future<void> debugLog(String tag, String message) async {
  await DebugLogService().log(tag, message);
}
