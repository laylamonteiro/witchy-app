import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/astrology_provider.dart';
import 'birth_chart_view_page.dart';

class BirthChartInputPage extends StatefulWidget {
  const BirthChartInputPage({super.key});

  @override
  State<BirthChartInputPage> createState() => _BirthChartInputPageState();
}

class _BirthChartInputPageState extends State<BirthChartInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _birthPlaceController = TextEditingController();

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _birthPlace;
  bool _unknownBirthTime = false;
  bool _isCalculating = false;

  @override
  void dispose() {
    _birthPlaceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lilac,
              surface: AppColors.darkBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      helpText: 'Selecione a hora',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lilac,
              surface: AppColors.darkBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthTime) {
      setState(() {
        _birthTime = picked;
      });
    }
  }

  bool _canCalculate() {
    return _birthDate != null &&
        _birthPlace != null &&
        _birthPlace!.trim().isNotEmpty &&
        (_unknownBirthTime || _birthTime != null);
  }

  Future<void> _calculateChart() async {
    if (!_canCalculate()) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      // Geocodificar local de nascimento
      final locations = await locationFromAddress(_birthPlace!);

      if (locations.isEmpty) {
        throw Exception('Local não encontrado');
      }

      final location = locations.first;

      // Calcular mapa
      final provider = context.read<AstrologyProvider>();
      final chart = await provider.calculateAndSaveBirthChart(
        birthDate: _birthDate!,
        birthTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
        birthPlace: _birthPlace!,
        latitude: location.latitude,
        longitude: location.longitude,
        unknownBirthTime: _unknownBirthTime,
      );

      if (!mounted) return;

      if (chart != null) {
        // Navegar para visualização
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const BirthChartViewPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erro ao calcular mapa'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: AppColors.alert,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Mapa Astral'),
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
              // Introdução
              MagicalCard(
                child: Column(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Seu Mapa Astral',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.softWhite,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Para calcular seu mapa natal preciso, precisamos de sua data, '
                      'hora e local de nascimento. Quanto mais preciso, melhor!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.softWhite,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Data de nascimento
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data de Nascimento',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _birthDate == null
                            ? 'Selecionar data'
                            : DateFormat('dd/MM/yyyy').format(_birthDate!),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardBackground,
                        foregroundColor: AppColors.softWhite,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Hora de nascimento
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hora de Nascimento',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A hora exata é importante para calcular o Ascendente e as Casas.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softWhite.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _unknownBirthTime ? null : () => _selectTime(context),
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _birthTime == null
                            ? 'Selecionar hora'
                            : _birthTime!.format(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cardBackground,
                        foregroundColor: AppColors.softWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _unknownBirthTime,
                      onChanged: (value) {
                        setState(() {
                          _unknownBirthTime = value ?? false;
                          if (_unknownBirthTime) _birthTime = null;
                        });
                      },
                      title: const Text(
                        'Não sei a hora exata',
                        style: TextStyle(color: AppColors.softWhite),
                      ),
                      activeColor: AppColors.lilac,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Local de nascimento
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local de Nascimento',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _birthPlaceController,
                      style: const TextStyle(color: AppColors.softWhite),
                      decoration: InputDecoration(
                        hintText: 'Ex: São Paulo, Brasil',
                        hintStyle: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: AppColors.lilac,
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _birthPlace = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botão calcular
              ElevatedButton(
                onPressed: _isCalculating || !_canCalculate() ? null : _calculateChart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: AppColors.lilac.withOpacity(0.3),
                ),
                child: _isCalculating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.darkBackground,
                          ),
                        ),
                      )
                    : const Text(
                        'Calcular Mapa Astral ✨',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              if (_unknownBirthTime) ...[
                const SizedBox(height: 16),
                MagicalCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.starYellow,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sem a hora exata, usaremos meio-dia (12:00) e o sistema de casas iguais.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.softWhite.withOpacity(0.8),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
