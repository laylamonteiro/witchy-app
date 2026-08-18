import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/debug_log_service.dart';

/// App mínimo exibido quando a inicialização (antes do runApp normal) falha.
///
/// Substitui a tela branca por um diagnóstico legível — exceção, stack trace
/// e os últimos logs de boot — e permite copiar o relatório completo. Fica em
/// produção de propósito: sem ele, qualquer erro de boot na web vira uma tela
/// branca impossível de diagnosticar (o build release minifica os símbolos).
class BootErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  /// Reexecuta a inicialização do zero (erros transitórios: rede, storage).
  final Future<void> Function()? onRetry;

  const BootErrorApp({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  static const _background = Color(0xFF0B0A16);
  static const _surface = Color(0xFF1A1830);
  static const _accent = Color(0xFFB39DDB);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grimório de Bolso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.dark(
          primary: _accent,
          surface: _surface,
        ),
      ),
      home: _BootErrorScreen(
        error: error,
        stackTrace: stackTrace,
        onRetry: onRetry,
      ),
    );
  }
}

class _BootErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final Future<void> Function()? onRetry;

  const _BootErrorScreen({
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  String _buildReport() {
    final buffer = StringBuffer()
      ..writeln('═══ Grimório de Bolso — erro na inicialização ═══')
      ..writeln('Momento: ${DateTime.now().toIso8601String()}')
      ..writeln()
      ..writeln('── Exceção ──')
      ..writeln(error.toString())
      ..writeln()
      ..writeln('── Stack trace ──')
      ..writeln(stackTrace?.toString() ?? '(indisponível)')
      ..writeln()
      ..writeln(DebugLogService().exportLogs());
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bootLogs = DebugLogService().logs;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.auto_fix_off,
                    size: 48, color: BootErrorApp._accent),
                const SizedBox(height: 16),
                const Text(
                  'O grimório não conseguiu abrir',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Algo falhou durante a inicialização do app. '
                  'Os detalhes abaixo ajudam a identificar a causa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (onRetry != null)
                      FilledButton.icon(
                        onPressed: () => onRetry!(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(
                          ClipboardData(text: _buildReport()),
                        );
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Relatório copiado')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar relatório'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DiagnosticSection(
                  title: 'Exceção',
                  content: error.toString(),
                ),
                if (stackTrace != null)
                  _DiagnosticSection(
                    title: 'Stack trace',
                    content: stackTrace.toString(),
                  ),
                if (bootLogs.isNotEmpty)
                  _DiagnosticSection(
                    title: 'Últimos logs de boot',
                    // Os mais recentes primeiro: o último log antes da
                    // exceção aponta o passo do boot que estourou.
                    content: bootLogs.reversed
                        .take(30)
                        .map((l) => '[${l.tag}] ${l.message}')
                        .join('\n'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosticSection extends StatelessWidget {
  final String title;
  final String content;

  const _DiagnosticSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BootErrorApp._accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BootErrorApp._surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.5,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
