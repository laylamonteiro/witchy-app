import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';
import '../../../../core/i18n/tratamento_do_contexto.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/config/captcha_config.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/folha_com_saida.dart';

/// Verificação anti-robô do Cloudflare Turnstile.
///
/// Sobe como folha por cima do formulário, resolve o desafio (na maioria
/// das vezes sem pedir nada à pessoa) e devolve o token que o Supabase
/// exige. Devolve null quando a pessoa desiste ou o desafio falha.
///
/// A saída tem BOTÃO, e não só o gesto: este é o portão de Entrar, Cadastrar,
/// Esqueci minha senha e do re-login, e não há tela por baixo para onde
/// escapar. Arrastar e tocar fora já fechavam a folha, mas nenhum dos dois se
/// anuncia no navegador do celular — então quem não conseguisse resolver o
/// desafio (WebView que não carrega, desafio que se repete) não via saída
/// nenhuma. Agora vê duas: o X no alto e o "Cancelar" embaixo.
///
/// Sem a site key compilada ([CaptchaConfig.isConfigured] falso) o gate
/// nem aparece e devolve null — que é exatamente o que os repositórios
/// enviam hoje, então o app segue funcionando como antes.
class CaptchaGate {
  const CaptchaGate._();

  static Future<String?> resolve(BuildContext context) async {
    if (!CaptchaConfig.isConfigured) return null;

    return mostrarFolhaComSaida<String>(
      context: context,
      // Sem teto de altura: a folha padrão para em 9/16 da tela, e com a alça
      // do Material (48px) somada ao X, ao desafio e ao "Cancelar" o conteúdo
      // passou disso. No navegador do celular — onde a barra do navegador já
      // come altura — isso estourava a Column. Aqui a folha cresce só o que
      // precisa, e a rolagem lá dentro cobre o resto (fonte ampliada, telas
      // curtas).
      isScrollControlled: true,
      builder: (_) => const _CaptchaSheet(),
    );
  }
}

class _CaptchaSheet extends StatefulWidget {
  const _CaptchaSheet();

  @override
  State<_CaptchaSheet> createState() => _CaptchaSheetState();
}

class _CaptchaSheetState extends State<_CaptchaSheet> {
  /// Quantas vezes recriar o widget antes de desistir.
  static const int _maxAttempts = 3;

  int _attempt = 0;

  /// O Turnstile roda numa WebView; quando ela está "fria" (app recém
  /// instalado, dados limpos, rede lenta) o primeiro carregamento costuma
  /// falhar. Antes, esse erro fechava a folha devolvendo null, e a tela de
  /// login mostrava "não deu para concluir a verificação" sem nem abrir o
  /// Google — quebrando a PRIMEIRA tentativa de quem acabou de instalar.
  /// Agora recria o widget algumas vezes antes de desistir.
  Future<void> _onError() async {
    if (!mounted) return;
    if (_attempt + 1 >= _maxAttempts) {
      Navigator.of(context).pop();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _attempt++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // O X fica no alto à direita para não empurrar o título do centro,
            // e o "Cancelar" repete a saída embaixo, onde o olho já está
            // depois de o desafio falhar.
            const Align(
              alignment: Alignment.centerRight,
              child: BotaoFecharFolha(key: ValueKey('captcha-close')),
            ),
            Text(
              l10n.authCaptchaTitle(context.vocativo),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.authCaptchaSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 90,
              child: CloudflareTurnstile(
                // A key muda a cada tentativa para forçar a recriação do
                // widget (e uma nova carga da WebView) em vez de reusar a
                // que falhou.
                key: ValueKey(_attempt),
                siteKey: CaptchaConfig.siteKey,
                options: TurnstileOptions(
                  theme: TurnstileTheme.dark,
                  refreshExpired: TurnstileRefreshExpired.auto,
                ),
                onTokenReceived: (token) {
                  if (mounted) Navigator.of(context).pop(token);
                },
                onError: (_) => _onError(),
              ),
            ),
            const SizedBox(height: 4),
            // Desistir devolve null, que é o mesmo que o gate já devolvia
            // quando a pessoa tocava fora — aqui só ganha nome e alvo.
            TextButton(
              key: const ValueKey('captcha-cancel'),
              onPressed: () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(
                foregroundColor: context.gc.textSecondary,
              ),
              child: Text(l10n.commonCancel),
            ),
          ],
        ),
      ),
    );
  }
}
