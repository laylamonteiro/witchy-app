import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/config/captcha_config.dart';
import '../../../../core/theme/grimoire_colors.dart';

/// Verificação anti-robô do Cloudflare Turnstile.
///
/// Sobe como folha por cima do formulário, resolve o desafio (na maioria
/// das vezes sem pedir nada à pessoa) e devolve o token que o Supabase
/// exige. Devolve null quando a pessoa desiste ou o desafio falha.
///
/// Sem a site key compilada ([CaptchaConfig.isConfigured] falso) o gate
/// nem aparece e devolve null — que é exatamente o que os repositórios
/// enviam hoje, então o app segue funcionando como antes.
class CaptchaGate {
  const CaptchaGate._();

  static Future<String?> resolve(BuildContext context) async {
    if (!CaptchaConfig.isConfigured) return null;

    return showModalBottomSheet<String>(
      context: context,
      isDismissible: true,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CaptchaSheet(),
    );
  }
}

class _CaptchaSheet extends StatelessWidget {
  const _CaptchaSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.gc.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.authCaptchaTitle,
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
              siteKey: CaptchaConfig.siteKey,
              options: TurnstileOptions(
                theme: TurnstileTheme.dark,
                refreshExpired: TurnstileRefreshExpired.auto,
              ),
              onTokenReceived: (token) {
                if (context.mounted) Navigator.of(context).pop(token);
              },
              onError: (_) {
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
