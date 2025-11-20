import 'package:flutter/material.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';

class AIConfigPage extends StatefulWidget {
  const AIConfigPage({super.key});

  @override
  State<AIConfigPage> createState() => _AIConfigPageState();
}

class _AIConfigPageState extends State<AIConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  AIProvider _selectedProvider = AIProvider.openai;
  bool _hasApiKey = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkApiKey() async {
    final aiService = AIService.instance;
    final hasKey = await aiService.hasApiKey();
    final provider = await aiService.getProvider();

    setState(() {
      _hasApiKey = hasKey;
      if (provider != null) {
        _selectedProvider = provider;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final aiService = AIService.instance;
      await aiService.saveApiKey(
        _apiKeyController.text.trim(),
        _selectedProvider,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chave arcana salva com sucesso! ✨'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  Future<void> _removeApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Remover chave arcana?',
          style: TextStyle(color: AppColors.softWhite),
        ),
        content: const Text(
          'Você precisará configurar novamente para invocar o conselheiro místico.',
          style: TextStyle(color: AppColors.softWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.lilac)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: AppColors.alert)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AIService.instance.removeApiKey();
      setState(() {
        _hasApiKey = false;
        _apiKeyController.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chave arcana removida'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configurar Conselheiro'),
          backgroundColor: AppColors.darkBackground,
        ),
        backgroundColor: AppColors.darkBackground,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lilac),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Conselheiro Místico'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MagicalCard(
                child: Column(
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Conselheiro Místico',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure sua chave arcana para invocar o conselheiro místico e manifestar feitiços personalizados.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.softWhite.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_hasApiKey)
                MagicalCard(
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Chave arcana configurada ✅',
                          style: TextStyle(color: AppColors.softWhite),
                        ),
                      ),
                      TextButton(
                        onPressed: _removeApiKey,
                        child: const Text(
                          'Remover',
                          style: TextStyle(color: AppColors.alert),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Provedor
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fonte de Sabedoria',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<AIProvider>(
                      value: AIProvider.openai,
                      groupValue: _selectedProvider,
                      onChanged: (value) {
                        setState(() {
                          _selectedProvider = value!;
                        });
                      },
                      title: const Text(
                        'Oráculo Primordial',
                        style: TextStyle(color: AppColors.softWhite),
                      ),
                      subtitle: const Text(
                        'Mais preciso, pequeno custo por consulta',
                        style: TextStyle(color: AppColors.softWhite),
                      ),
                      activeColor: AppColors.lilac,
                    ),
                    RadioListTile<AIProvider>(
                      value: AIProvider.gemini,
                      groupValue: _selectedProvider,
                      onChanged: (value) {
                        setState(() {
                          _selectedProvider = value!;
                        });
                      },
                      title: const Text(
                        'Espírito Estelar',
                        style: TextStyle(color: AppColors.softWhite),
                      ),
                      subtitle: const Text(
                        'Generoso e abundante em suas ofertas',
                        style: TextStyle(color: AppColors.softWhite),
                      ),
                      activeColor: AppColors.lilac,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // API Key
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chave Arcana',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedProvider == AIProvider.openai
                          ? 'Obtenha sua chave em: platform.openai.com'
                          : 'Obtenha sua chave em: makersuite.google.com/app/apikey',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softWhite.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apiKeyController,
                      style: const TextStyle(color: AppColors.softWhite),
                      decoration: InputDecoration(
                        hintText: _selectedProvider == AIProvider.openai
                            ? 'sk-...'
                            : 'AI...',
                        hintStyle: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.5),
                        ),
                        prefixIcon: const Icon(Icons.key, color: AppColors.lilac),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a chave arcana';
                        }
                        if (_selectedProvider == AIProvider.openai &&
                            !value.startsWith('sk-')) {
                          return 'A chave do Oráculo Primordial deve começar com "sk-"';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Salvar Configuração',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppColors.lilac,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informações importantes',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.lilac,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Sua chave arcana é armazenada apenas no seu dispositivo\n'
                      '• Há custos mínimos para consultar o Oráculo Primordial\n'
                      '• O Espírito Estelar oferece consultas generosas sem custo\n'
                      '• Você controla totalmente sua conexão mística\n'
                      '• Pode remover a chave arcana a qualquer momento',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softWhite.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
