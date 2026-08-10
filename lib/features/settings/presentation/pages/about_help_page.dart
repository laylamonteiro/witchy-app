import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/legal/legal_document_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'faq_page.dart';

/// "Sobre & Ajuda": funde os antigos diálogos "Sobre o App" e
/// "Ajuda & Suporte" numa página só — ambos eram informativos, e duas
/// entradas no menu eram uma a mais.
class AboutHelpPage extends StatelessWidget {
  const AboutHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(
          l10n.settingsAboutHelp,
          style: TextStyle(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.gc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(context, l10n.profileAboutApp),
            _card(context, [_AboutCard()]),
            const SizedBox(height: 24),
            _sectionHeader(context, l10n.profileHelpSupport),
            _card(context, [
              _item(
                context,
                icon: Icons.email_outlined,
                title: l10n.profileSupportEmail,
                subtitle: 'suporte.grimoriodebolso@gmail.com',
                onTap: () => _launchEmail(context),
              ),
              _divider(context),
              _item(
                context,
                icon: Icons.question_answer_outlined,
                title: 'FAQ',
                subtitle: l10n.profileFaq,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FaqPage()),
                ),
              ),
              _divider(context),
              _item(
                context,
                icon: Icons.policy_outlined,
                title: l10n.authPrivacyPolicy,
                subtitle: l10n.profilePrivacySafe,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LegalDocumentPage.privacy),
                ),
              ),
              _divider(context),
              _item(
                context,
                icon: Icons.gavel_outlined,
                title: l10n.authTermsOfUse,
                subtitle: l10n.settingsTermsSubtitle,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LegalDocumentPage.terms),
                ),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.gc.lilac,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _card(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gc.textPrimary10),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: context.gc.textPrimary.withValues(alpha: 0.1),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.gc.lilac.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: context.gc.lilac, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.gc.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: context.gc.textSecondary),
      onTap: onTap,
    );
  }

  /// Abre o app de e-mail; sem app compatível, copia o endereço e avisa.
  Future<void> _launchEmail(BuildContext context) async {
    const supportEmail = 'suporte.grimoriodebolso@gmail.com';
    final uri = Uri(scheme: 'mailto', path: supportEmail);
    var opened = false;
    try {
      opened = await launchUrl(uri);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      await Clipboard.setData(const ClipboardData(text: supportEmail));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).supportEmailCopied(supportEmail),
          ),
        ),
      );
    }
  }
}

/// Bloco "Sobre": nome, versão, descrição e créditos — o conteúdo do
/// antigo diálogo, agora residente.
class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Grimório de Bolso',
                style: TextStyle(
                  color: context.gc.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              if (info == null) return const SizedBox(height: 16);
              return Text(
                l10n.aboutVersion(info.version, info.buildNumber),
                style: TextStyle(color: context.gc.textSecondary),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            l10n.aboutDescription,
            style: TextStyle(color: context.gc.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.aboutMadeWith,
            style: TextStyle(color: context.gc.lilac),
          ),
          const SizedBox(height: 6),
          Text(
            '© 2024 Grimório de Bolso',
            style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
