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
  final FocusNode _birthPlaceFocusNode = FocusNode();

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _birthPlace;
  bool _unknownBirthTime = false;
  bool _isCalculating = false;

  List<Location> _locationSuggestions = [];
  List<Placemark> _placemarkSuggestions = [];
  bool _isSearchingLocation = false;
  bool _showSuggestions = false;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void dispose() {
    _birthPlaceController.dispose();
    _birthPlaceFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
        _placemarkSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearchingLocation = true;
      _showSuggestions = true;
    });

    try {
      // Adicionar ", Brasil" se não especificar país para resultados mais precisos
      String searchQuery = query;
      if (!query.toLowerCase().contains('brasil') &&
          !query.toLowerCase().contains('brazil') &&
          !query.toLowerCase().contains(',')) {
        searchQuery = '$query, Brasil';
      }

      final locations = await locationFromAddress(searchQuery);

      // Get placemarks for each location to show readable addresses
      final placemarks = <Placemark>[];
      for (final location in locations.take(5)) {
        try {
          final placemark = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          if (placemark.isNotEmpty) {
            placemarks.add(placemark.first);
          }
        } catch (e) {
          // Skip locations that can't be reverse geocoded
        }
      }

      setState(() {
        _locationSuggestions = locations.take(5).toList();
        _placemarkSuggestions = placemarks;
        _isSearchingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationSuggestions = [];
        _placemarkSuggestions = [];
        _isSearchingLocation = false;
      });
    }
  }

  void _selectLocation(int index) {
    final location = _locationSuggestions[index];
    final placemark = _placemarkSuggestions.length > index
        ? _placemarkSuggestions[index]
        : null;

    String displayName;
    if (placemark != null) {
      final parts = <String>[];
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        parts.add(placemark.locality!);
      }
      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        parts.add(placemark.administrativeArea!);
      }
      if (placemark.country != null && placemark.country!.isNotEmpty) {
        parts.add(placemark.country!);
      }
      displayName = parts.join(', ');
    } else {
      displayName = _birthPlaceController.text;
    }

    setState(() {
      _birthPlace = displayName;
      _birthPlaceController.text = displayName;
      _selectedLatitude = location.latitude;
      _selectedLongitude = location.longitude;
      _showSuggestions = false;
      _locationSuggestions = [];
      _placemarkSuggestions = [];
    });

    _birthPlaceFocusNode.unfocus();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      // Use coordenadas já selecionadas ou geocodificar
      double latitude;
      double longitude;

      if (_selectedLatitude != null && _selectedLongitude != null) {
        latitude = _selectedLatitude!;
        longitude = _selectedLongitude!;
      } else {
        // Geocodificar local de nascimento
        final locations = await locationFromAddress(_birthPlace!);

        if (locations.isEmpty) {
          throw Exception('Local não encontrado');
        }

        final location = locations.first;
        latitude = location.latitude;
        longitude = location.longitude;
      }

      // Calcular mapa
      final provider = context.read<AstrologyProvider>();
      final chart = await provider.calculateAndSaveBirthChart(
        birthDate: _birthDate!,
        birthTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
        birthPlace: _birthPlace!,
        latitude: latitude,
        longitude: longitude,
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
                    const SizedBox(height: 8),
                    Text(
                      'Digite o nome da cidade. Serão buscadas cidades no Brasil automaticamente. '
                      'Confira as coordenadas para garantir precisão.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.softWhite.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _birthPlaceController,
                      focusNode: _birthPlaceFocusNode,
                      style: const TextStyle(color: AppColors.softWhite),
                      decoration: InputDecoration(
                        hintText: 'Ex: Campinas, Bueno Brandão, São Paulo...',
                        hintStyle: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.5),
                        ),
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: AppColors.lilac,
                        ),
                        suffixIcon: _isSearchingLocation
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.lilac,
                                    ),
                                  ),
                                ),
                              )
                            : (_selectedLatitude != null && _selectedLongitude != null)
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                  )
                                : null,
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
                          _selectedLatitude = null;
                          _selectedLongitude = null;
                        });
                        _searchLocation(value);
                      },
                    ),
                    if (_showSuggestions && _locationSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.lilac.withOpacity(0.3),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _locationSuggestions.length,
                          separatorBuilder: (context, index) => Divider(
                            color: AppColors.lilac.withOpacity(0.2),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final placemark = _placemarkSuggestions.length > index
                                ? _placemarkSuggestions[index]
                                : null;

                            final loc = _locationSuggestions[index];
                            String displayText;
                            String coordsText = 'Lat: ${loc.latitude.toStringAsFixed(4)}, Lon: ${loc.longitude.toStringAsFixed(4)}';

                            if (placemark != null) {
                              final parts = <String>[];

                              // Adicionar sublocality (bairro/distrito) se disponível
                              if (placemark.subLocality != null &&
                                  placemark.subLocality!.isNotEmpty) {
                                parts.add(placemark.subLocality!);
                              }

                              if (placemark.locality != null &&
                                  placemark.locality!.isNotEmpty) {
                                parts.add(placemark.locality!);
                              }

                              if (placemark.administrativeArea != null &&
                                  placemark.administrativeArea!.isNotEmpty) {
                                parts.add(placemark.administrativeArea!);
                              }

                              if (placemark.country != null &&
                                  placemark.country!.isNotEmpty) {
                                parts.add(placemark.country!);
                              }

                              displayText = parts.join(', ');
                            } else {
                              displayText = coordsText;
                            }

                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.place,
                                color: AppColors.lilac,
                                size: 20,
                              ),
                              title: Text(
                                displayText,
                                style: const TextStyle(
                                  color: AppColors.softWhite,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                coordsText,
                                style: TextStyle(
                                  color: AppColors.softWhite.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () => _selectLocation(index),
                            );
                          },
                        ),
                      ),
                    ],
                    if (_selectedLatitude != null && _selectedLongitude != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Local selecionado: $_birthPlace\n'
                                'Coordenadas: ${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
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
