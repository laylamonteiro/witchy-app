import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/captcha_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/debug_log_service.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../pages/forgot_password_page.dart';
import '../providers/auth_provider.dart';
import 'auth_feedback.dart';
import 'captcha_gate.dart';

/// Reconecta contas que o estado local considera logadas mas estão SEM
/// sessão Supabase neste aparelho.
///
/// O estado existe em quantidade: entre ~20 e 27/08/2026 o cadastro por
/// e-mail exigia confirmação e não emitia sessão, mas o app tratava o
/// signUp como login — essas pessoas usam o app "logadas" enquanto toda
/// chamada à nuvem sai como `anon` e a sincronização fica muda. Sessão
/// não nasce retroativamente (não há refresh token guardado, e o app não
/// guarda senha): o único caminho é um login de verdade, e este diálogo o
/// pede na cara, com o e-mail já resolvido — sobra digitar a senha.
///
/// Por que um diálogo e não mandar para /login: o [GuestOnly] devolve à
/// Home quem o estado local diz estar logado, e um signOut antes de ir
/// destruiria dados locais ainda não sincronizados. Aqui nada é deslogado:
/// a sessão entra por baixo e o [AuthProvider.syncAuthenticatedUser] faz o
/// resto (inclusive o upload do que foi criado no limbo — os dados locais
/// já estão gravados com o id certo da conta).
class ReloginDialog {
  /// Pergunta no máximo uma vez por execução do app; a próxima abertura
  /// pergunta de novo se a pessoa adiou.
  static bool _jaPerguntou = false;

  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static Future<void> maybeShow(BuildContext context) async {
    if (_jaPerguntou) return;
    if (!SupabaseConfig.isConfigured) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    // Só contas Supabase (id UUID): usuários do modo local não têm sessão
    // por definição e não devem ser incomodados.
    if (!user.isAuthenticated || !_uuidRegExp.hasMatch(user.id)) return;
    if (Supabase.instance.client.auth.currentSession != null) return;

    _jaPerguntou = true;
    final email = user.email;
    if (email == null || email.isEmpty) return;

    await debugLog(
        'AUTH', 'Conta sem sessão Supabase detectada — pedindo re-login');

    // Deixa o splash da Home (2,5s) terminar antes de subir o diálogo; e
    // reconfere a sessão depois da espera — um retorno OAuth pode tê-la
    // entregue nesse meio tempo.
    await Future.delayed(const Duration(seconds: 3));
    if (!context.mounted) return;
    if (Supabase.instance.client.auth.currentSession != null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _ReloginDialogBody(email: email),
    );
  }
}

class _ReloginDialogBody extends StatefulWidget {
  final String email;

  const _ReloginDialogBody({required this.email});

  @override
  State<_ReloginDialogBody> createState() => _ReloginDialogBodyState();
}

class _ReloginDialogBodyState extends State<_ReloginDialogBody> {
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final password = _passwordController.text;
    if (password.isEmpty || _isLoading) return;

    // Mesmo portão anti-robô do login normal (no-op sem site key no build).
    final captchaToken = await CaptchaGate.resolve(context);
    if (!mounted) return;
    if (CaptchaConfig.isConfigured && captchaToken == null) {
      setState(
          () => _error = AppLocalizations.of(context).authCaptchaFailed);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final result = await SupabaseAuthRepository()
        .signInWithEmail(widget.email, password, captchaToken: captchaToken);

    if (!mounted) return;
    if (result.success && result.user != null) {
      await auth.syncAuthenticatedUser(result.user!);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAuthSnack(
        context,
        AppLocalizations.of(context).authReloginDone,
        type: AuthSnackType.success,
      );
      return;
    }

    setState(() {
      _isLoading = false;
      _error = result.errorMessage ??
          AppLocalizations.of(context).authErrLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.authReloginTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.authReloginBody(widget.email)),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            autofocus: true,
            onSubmitted: (_) => _entrar(),
            decoration: InputDecoration(
              labelText: l10n.authPasswordLabel,
              errorText: _error,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
              child: Text(l10n.authForgotPassword),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.authReloginLater),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _entrar,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.authReloginAction),
        ),
      ],
    );
  }
}
