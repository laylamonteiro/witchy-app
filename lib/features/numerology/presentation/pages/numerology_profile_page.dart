import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/numerology_meanings_data.dart';
import '../../domain/numerology_calculator.dart';
import 'numerology_page.dart';

/// Perfil pessoal: os 5 números-chave calculados de nome + nascimento.
class NumerologyProfilePage extends StatefulWidget {
  const NumerologyProfilePage({super.key});

  @override
  State<NumerologyProfilePage> createState() => _NumerologyProfilePageState();
}

class _NumerologyProfilePageState extends State<NumerologyProfilePage> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  NumerologyProfile? _profile;

  String? _aiText;
  bool _isExplaining = false;

  // Dados (nome + nascimento) aos quais a explicação salva corresponde.
  // Usados para só reabilitar o botão quando os dados forem alterados.
  String? _explainedName;
  DateTime? _explainedBirthDate;

  late final String _userId;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _userId = user.id;
    // Pré-preenche com os dados do perfil quando existirem.
    _nameController.text = user.displayName ?? '';
    _birthDate = user.birthDate;
    _loadSaved();
  }

  String get _prefsBase => 'num_profile_${_userId}_';

  /// Restaura o último cálculo salvo (nome, data e a explicação do
  /// Conselheiro Místico), para não refazer a leitura a cada visita.
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('${_prefsBase}name');
    final dateMs = prefs.getInt('${_prefsBase}date');
    final aiText = prefs.getString('${_prefsBase}ai');
    if (name == null || name.isEmpty || dateMs == null || !mounted) return;

    final date = DateTime.fromMillisecondsSinceEpoch(dateMs);
    setState(() {
      _nameController.text = name;
      _birthDate = date;
      _profile = NumerologyCalculator.profile(fullName: name, birthDate: date);
      if (aiText != null && aiText.isNotEmpty) {
        _aiText = aiText;
        _explainedName = name;
        _explainedBirthDate = date;
      }
    });
  }

  /// Persiste o último cálculo com a explicação para reabrir igual.
  Future<void> _persist() async {
    if (_aiText == null ||
        _explainedName == null ||
        _explainedBirthDate == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefsBase}name', _explainedName!);
    await prefs.setInt(
        '${_prefsBase}date', _explainedBirthDate!.millisecondsSinceEpoch);
    await prefs.setString('${_prefsBase}ai', _aiText!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
    }
  }

  void _calculate() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.numFillNameAndDate),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }
    // Mantém a explicação apenas se os dados forem exatamente os mesmos já
    // explicados; qualquer alteração de nome/data reabilita o botão.
    final sameAsExplained = _aiText != null &&
        name == _explainedName &&
        _birthDate == _explainedBirthDate;
    setState(() {
      _profile = NumerologyCalculator.profile(
        fullName: name,
        birthDate: _birthDate!,
      );
      if (!sameAsExplained) {
        _aiText = null;
        _explainedName = null;
        _explainedBirthDate = null;
      }
    });
  }

  Future<void> _explainWithAI() async {
    final profile = _profile;
    if (profile == null || _isExplaining) return;

    final authProvider = context.read<AuthProvider>();
    final access =
        authProvider.checkFeatureAccess(AppFeature.numerologyReadings);
    if (!access.hasFullAccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(access.message ??
              AppLocalizations.of(context)!.numDailyLimit),
          backgroundColor: context.gc.alert,
        ),
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
    }

    setState(() => _isExplaining = true);
    try {
      final summary = 'Perfil numerológico calculado pelo app:\n'
          '- Caminho de Vida: ${profile.lifePath}\n'
          '- Expressão: ${profile.expression}\n'
          '- Alma: ${profile.soulUrge}\n'
          '- Personalidade: ${profile.personality}\n'
          '- Ano Pessoal: ${profile.personalYear}';
      final text = await AIService.instance.explainNumerology(summary: summary);
      await authProvider.incrementAiConsultations();
      if (!mounted) return;
      setState(() {
        _aiText = text;
        _explainedName = _nameController.text.trim();
        _explainedBirthDate = _birthDate;
      });
      // Guarda o cálculo + explicação para reabrir sem refazer a leitura.
      await _persist();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'.replaceAll('Exception: ', '')),
          backgroundColor: context.gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExplaining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.numPersonalProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.numYourBirthData,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.numBirthNameHelp,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.numFullName,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: context.gc.lilac),
                          const SizedBox(width: 8),
                          Text(
                            _birthDate == null
                                ? AppLocalizations.of(context)!.numChooseBirthDate
                                : '${AppLocalizations.of(context)!.numBirthPrefix}: '
                                    '${_birthDate!.day.toString().padLeft(2, '0')}/'
                                    '${_birthDate!.month.toString().padLeft(2, '0')}/'
                                    '${_birthDate!.year}',
                            style: TextStyle(color: context.gc.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate_outlined, size: 18),
                      label: Text(AppLocalizations.of(context)!.numCalculate),
                    ),
                  ),
                ],
              ),
            ),
            if (profile != null) ...[
              _buildProfileNumber(
                  context, 'lifePath', profile.lifePath),
              _buildProfileNumber(
                  context, 'expression', profile.expression),
              _buildProfileNumber(context, 'soulUrge', profile.soulUrge),
              _buildProfileNumber(
                  context, 'personality', profile.personality),
              _buildProfileNumber(
                  context, 'personalYear', profile.personalYear),
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_aiText == null) ...[
                      // Ainda sem explicação para estes dados: mostra o botão.
                      Text(
                        AppLocalizations.of(context)!.numSynthesisQuestion,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.gc.textSecondary,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isExplaining ? null : _explainWithAI,
                        icon: _isExplaining
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.gc.onPrimary,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(_isExplaining
                            ? AppLocalizations.of(context)!.numWeavingSynthesis
                            : AppLocalizations.of(context)!
                                .numAdvisorExplanation),
                      ),
                    ] else ...[
                      // Explicação já gerada e persistida: mostra só o texto.
                      // O botão volta ao alterar nome ou data de nascimento.
                      Text(
                        AppLocalizations.of(context)!.numAdvisorExplanation,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _aiText!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNumber(BuildContext context, String key, int number) {
    final info = profileNumberInfos[key]!;
    final meaning = numberMeanings[number];

    return MagicalCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 4),
          leading: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.gc.lilac.withOpacity(0.15),
              border: Border.all(color: context.gc.lilac),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: context.gc.lilac,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            '${info.emoji} ${info.label}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.gc.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: meaning == null
              ? null
              : Text(
                  meaning.title,
                  style: TextStyle(color: context.gc.textSecondary),
                ),
          iconColor: context.gc.lilac,
          collapsedIconColor: context.gc.textSecondary,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                info.explanation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.gc.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
            if (meaning != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  meaning.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  meaning.shadow,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
