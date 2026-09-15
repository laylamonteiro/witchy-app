import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/captcha_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/debug_log_service.dart';
import '../../data/repositories/auth_repository.dart';
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

  /// A chave em que o supabase_flutter persiste a sessão — nas
  /// SharedPreferences no celular, no localStorage cru na web:
  /// `sb-<primeiro rótulo do host da URL>-auth-token`
  /// (ex.: https://abcdefg.supabase.co → `sb-abcdefg-auth-token`).
  ///
  /// Espelha o `persistSessionKey` de
  /// packages/supabase_flutter/lib/src/supabase.dart (2.17). É um contrato
  /// do pacote, não uma API: se ele mudar a chave, esta conferência passa a
  /// dizer "sem sessão no disco" e o diálogo volta a aparecer offline — o
  /// teste tranca o formato para a troca de versão não passar em silêncio.
  @visibleForTesting
  static String chaveDaSessaoPersistida(String supabaseUrl) =>
      'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token';

  /// Pedir a senha só quando NÃO há sessão em memória NEM no disco.
  @visibleForTesting
  static bool deveReconectar({
    required bool sessaoViva,
    required bool sessaoPersistida,
  }) =>
      !sessaoViva && !sessaoPersistida;

  static Future<void> maybeShow(BuildContext context) async {
    if (_jaPerguntou) return;
    if (!SupabaseConfig.isConfigured) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    // Só contas Supabase (id UUID): usuários do modo local não têm sessão
    // por definição e não devem ser incomodados.
    if (!user.isAuthenticated || !_uuidRegExp.hasMatch(user.id)) return;

    // Sessão viva em memória — ou, pelo menos, gravada no disco. Sem rede a
    // sessão pode estar expirada e sem renovar, mas ela EXISTE no disco, e o
    // supabase_flutter a renova quando a rede voltar. Pedir a senha aqui,
    // offline, é trancar a pessoa fora do próprio grimório. O caso do limbo
    // (20-27/08) não tem token nenhum no disco, e continua coberto.
    final sessaoViva = Supabase.instance.client.auth.currentSession != null;
    // Pelo armazenamento DO PACOTE, e não por `SharedPreferences` direto: no
    // celular a sessão vive nas SharedPreferences, mas na web o
    // supabase_flutter grava direto no localStorage (sem o prefixo `flutter.`
    // que o shared_preferences usa) — conferir na mão aqui daria sempre
    // "sem sessão" no navegador, que é o único caminho no iPhone.
    final armazenamento = SharedPreferencesLocalStorage(
      persistSessionKey: chaveDaSessaoPersistida(SupabaseConfig.url),
    );
    await armazenamento.initialize();
    final sessaoPersistida = await armazenamento.hasAccessToken();
    if (!deveReconectar(
      sessaoViva: sessaoViva,
      sessaoPersistida: sessaoPersistida,
    )) {
      return;
    }

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

  /// Login barrado por e-mail não confirmado (a exigência de confirmação
  /// está ligada e esta conta é do limbo): a senha certa não basta, e o
  /// caminho é reenviar o link — o botão só aparece neste estado.
  bool _naoConfirmado = false;

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
      _naoConfirmado = result.errorCode == AuthErrorCode.emailNotConfirmed;
      _error = result.errorMessage ??
          AppLocalizations.of(context).authErrLogin;
    });
  }

  Future<void> _reenviarConfirmacao() async {
    final captchaToken = await CaptchaGate.resolve(context);
    if (!mounted) return;
    if (CaptchaConfig.isConfigured && captchaToken == null) {
      setState(
          () => _error = AppLocalizations.of(context).authCaptchaFailed);
      return;
    }
    final result = await SupabaseAuthRepository()
        .resendConfirmationEmail(widget.email, captchaToken: captchaToken);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    showAuthSnack(
      context,
      result.success
          ? l10n.forgotResendSuccess
          : (result.errorMessage ?? l10n.forgotResendError),
      type: result.success ? AuthSnackType.success : AuthSnackType.error,
    );
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
          if (_naoConfirmado)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _reenviarConfirmacao,
                child: Text(l10n.authResendConfirmAction),
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
