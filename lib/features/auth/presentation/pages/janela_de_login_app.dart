import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/navigation/janela_de_login.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/services/debug_log_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'auth_wrapper.dart';

/// O app MÍNIMO da janela de login — o documento que volta do Google.
///
/// Por que ele existe: o login social abre uma segunda aba NO MESMO endereço
/// (`window.open` + `redirectTo` para a raiz), e essa aba rodava o boot
/// inteiro — inclusive `DatabaseHelper.instance.database`. Na web o banco é
/// um SQLite sobre IndexedDB, cujo sistema de arquivos tem índice ÚNICO no
/// nome: dois documentos da mesma origem, cada um com seu índice em memória,
/// colidem no primeiro arquivo criado e derrubam a transação —
/// `ConstraintError` seguido de `IDB transaction error`, logo depois do
/// login, na aba de verdade.
///
/// A janela não precisa de nada disso. O trabalho dela já terminou quando o
/// `Supabase.initialize` trocou o `?code=` pela sessão (que fica no
/// armazenamento da origem, de onde a aba principal a recolhe). Aqui ela só
/// tenta se fechar e, quando o COOP do Google não deixa, mostra a mesma tela
/// de sempre — sem providers, sem banco, sem sincronização.
class JanelaDeLoginApp extends StatefulWidget {
  const JanelaDeLoginApp({super.key});

  @override
  State<JanelaDeLoginApp> createState() => _JanelaDeLoginAppState();
}

class _JanelaDeLoginAppState extends State<JanelaDeLoginApp> {
  StreamSubscription<AuthState>? _sessaoChegando;

  @override
  void initState() {
    super.initState();
    if (_tentarFechar()) return;

    // A troca do código pode concluir logo DEPOIS do boot; quando a sessão
    // aparece, vale uma segunda tentativa de fechar.
    if (SupabaseConfig.isConfigured) {
      _sessaoChegando =
          Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.session != null) _tentarFechar();
      });
    }
  }

  bool _tentarFechar() {
    final fechou = fecharSeJanelaDeLogin();
    if (fechou) {
      unawaited(debugLog('AUTH', 'Janela de login fechada'));
      unawaited(_sessaoChegando?.cancel());
      _sessaoChegando = null;
    }
    return fechou;
  }

  @override
  void dispose() {
    _sessaoChegando?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: LanguageProvider.supportedLocales,
        localeResolutionCallback: LanguageProvider.resolve,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const JanelaDeLoginConcluida(),
      );
}
