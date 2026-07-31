import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../data/services/geocoding_service.dart';
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
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final FocusNode _birthPlaceFocusNode = FocusNode();

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _birthPlace;
  bool _unknownBirthTime = false;
  bool _isCalculating = false;
  String? _dateError;
  String? _timeError;

  List<GeoPlace> _suggestions = [];
  bool _isSearchingLocation = false;
  bool _showSuggestions = false;
  bool _searchFailed = false; // falha de rede/serviço na última busca
  double? _selectedLatitude;
  double? _selectedLongitude;
  Timer? _searchDebounce;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadPreviousData();
  }

  Future<void> _loadPreviousData() async {
    final provider = context.read<AstrologyProvider>();
    await provider.loadBirthChart();

    if (provider.birthChart != null && mounted) {
      final chart = provider.birthChart!;
      setState(() {
        _birthDate = chart.birthDate;
        _birthTime = chart.birthTime;
        _birthPlace = chart.birthPlace;
        _birthPlaceController.text = chart.birthPlace;
        _dateController.text = formatDate(chart.birthDate);
        if (!chart.unknownBirthTime) {
          _timeController.text = formatTime(chart.birthTime);
        }
        _selectedLatitude = chart.latitude;
        _selectedLongitude = chart.longitude;
        _unknownBirthTime = chart.unknownBirthTime;
      });
    }
  }

  void _onDateChanged(String value) {
    setState(() {
      if (value.length == 10) {
        final date = parseDate(value);
        if (date != null) {
          _birthDate = date;
          _dateError = null;
        } else {
          _birthDate = null;
          _dateError = AppLocalizations.of(context).chartInvalidDate;
        }
      } else {
        _birthDate = null;
        _dateError = null;
      }
    });
  }

  void _onTimeChanged(String value) {
    setState(() {
      if (value.length == 5) {
        final time = parseTime(value);
        if (time != null) {
          _birthTime = time;
          _timeError = null;
        } else {
          _birthTime = null;
          _timeError = AppLocalizations.of(context).chartInvalidTime;
        }
      } else {
        _birthTime = null;
        _timeError = null;
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _birthPlaceController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _birthPlaceFocusNode.dispose();
    super.dispose();
  }

  /// Busca com debounce (respeita a política do Nominatim de ≤1 req/s).
  void _searchLocation(String query) {
    _searchDebounce?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearchingLocation = false;
      });
      return;
    }
    setState(() {
      _isSearchingLocation = true;
      _showSuggestions = true;
      _searchFailed = false;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _runSearch(query.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    final requestId = ++_searchRequestId;
    try {
      final results = await GeocodingService.instance.search(query);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _suggestions = results.take(6).toList();
        _isSearchingLocation = false;
        _searchFailed = false;
      });
    } catch (e) {
      // Falha de rede/serviço (timeout, 403/429 do Nominatim, sem internet).
      // Sinaliza para a UI distinguir "sem resultados" de "erro de conexão".
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _suggestions = [];
        _isSearchingLocation = false;
        _searchFailed = true;
      });
    }
  }

  void _selectLocation(GeoPlace place) {
    setState(() {
      _birthPlace = place.displayName;
      _birthPlaceController.text = place.displayName;
      _selectedLatitude = place.latitude;
      _selectedLongitude = place.longitude;
      _showSuggestions = false;
      _suggestions = [];
    });
    _birthPlaceFocusNode.unfocus();
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
        // Nenhuma sugestão selecionada: resolve pelo Nominatim.
        final place =
            await GeocodingService.instance.resolveFirst(_birthPlace!);
        if (place == null) {
          throw Exception(AppLocalizations.of(context).chartPlaceNotFound);
        }
        latitude = place.latitude;
        longitude = place.longitude;
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
        // Navegar para visualização (o fuso/horário de verão é mostrado no mapa).
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const BirthChartViewPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? AppLocalizations.of(context).chartCalcError),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).editErrorPrefix}: $e'),
          backgroundColor: context.gc.alert,
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
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).chartCreateTitle),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
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
                      AppLocalizations.of(context).chartYourChart,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: context.gc.softWhite,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).chartIntro,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.softWhite,
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
                      AppLocalizations.of(context).chartBirthDate,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).chartDateFormat,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.softWhite.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dateController,
                      style: TextStyle(color: context.gc.softWhite),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DateInputFormatter(),
                      ],
                      onChanged: _onDateChanged,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).chartDateHint,
                        hintStyle: TextStyle(
                          color: context.gc.softWhite.withOpacity(0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: context.gc.lilac,
                        ),
                        suffixIcon: _birthDate != null
                            ? Icon(
                                Icons.check_circle,
                                color: context.gc.success,
                              )
                            : null,
                        errorText: _dateError,
                        filled: true,
                        fillColor: context.gc.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.gc.lilac,
                            width: 1,
                          ),
                        ),
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
                      AppLocalizations.of(context).chartBirthTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).chartTimeImportant,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.softWhite.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _timeController,
                      enabled: !_unknownBirthTime,
                      style: TextStyle(
                        color: _unknownBirthTime
                            ? context.gc.softWhite.withOpacity(0.3)
                            : context.gc.softWhite,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TimeInputFormatter(),
                      ],
                      onChanged: _onTimeChanged,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        hintStyle: TextStyle(
                          color: context.gc.softWhite.withOpacity(0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: _unknownBirthTime
                              ? context.gc.lilac.withOpacity(0.3)
                              : context.gc.lilac,
                        ),
                        suffixIcon: _birthTime != null && !_unknownBirthTime
                            ? Icon(
                                Icons.check_circle,
                                color: context.gc.success,
                              )
                            : null,
                        errorText: _timeError,
                        filled: true,
                        fillColor: context.gc.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.gc.lilac,
                            width: 1,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _unknownBirthTime,
                      onChanged: (value) {
                        setState(() {
                          _unknownBirthTime = value ?? false;
                          if (_unknownBirthTime) {
                            _birthTime = null;
                            _timeController.clear();
                            _timeError = null;
                          }
                        });
                      },
                      title: Text(
                        AppLocalizations.of(context).chartDontKnowTime,
                        style: TextStyle(color: context.gc.softWhite),
                      ),
                      activeColor: context.gc.lilac,
                      contentPadding: EdgeInsets.zero,
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
                      AppLocalizations.of(context).chartBirthPlace,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).chartTypeToSearch,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.softWhite.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _birthPlaceController,
                      focusNode: _birthPlaceFocusNode,
                      style: TextStyle(color: context.gc.softWhite),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).chartPlaceHint,
                        hintStyle: TextStyle(
                          color: context.gc.softWhite.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: context.gc.lilac,
                        ),
                        suffixIcon: _isSearchingLocation
                            ? Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      context.gc.lilac,
                                    ),
                                  ),
                                ),
                              )
                            : (_selectedLatitude != null &&
                                    _selectedLongitude != null)
                                ? Icon(
                                    Icons.check_circle,
                                    color: context.gc.success,
                                  )
                                : null,
                        filled: true,
                        fillColor: context.gc.cardBackground,
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
                    if (_showSuggestions && _suggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: context.gc.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.gc.lilac.withOpacity(0.3),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _suggestions.length,
                          separatorBuilder: (context, index) => Divider(
                            color: context.gc.lilac.withOpacity(0.2),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final place = _suggestions[index];
                            final coordsText =
                                'Lat: ${place.latitude.toStringAsFixed(4)}, Lon: ${place.longitude.toStringAsFixed(4)}';
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.place,
                                color: context.gc.lilac,
                                size: 20,
                              ),
                              title: Text(
                                place.displayName,
                                style: TextStyle(
                                  color: context.gc.softWhite,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                coordsText,
                                style: TextStyle(
                                  color: context.gc.softWhite.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () => _selectLocation(place),
                            );
                          },
                        ),
                      ),
                    ],
                    // Falha de conexão/serviço: distingue de "cidade inexistente".
                    if (_showSuggestions &&
                        !_isSearchingLocation &&
                        _suggestions.isEmpty &&
                        _searchFailed) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.gc.alert.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.gc.alert.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wifi_off,
                                color: context.gc.alert, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).birthChartSearchFailed,
                                style: TextStyle(
                                  color: context.gc.softWhite,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Busca ok, porém sem resultados para o texto digitado.
                    if (_showSuggestions &&
                        !_isSearchingLocation &&
                        _suggestions.isEmpty &&
                        !_searchFailed &&
                        (_birthPlace?.trim().length ?? 0) >= 3) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.gc.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.gc.lilac.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).birthChartNoCityFound,
                          style: TextStyle(
                            color: context.gc.softWhite.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    if (_selectedLatitude != null &&
                        _selectedLongitude != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.gc.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.gc.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: context.gc.success,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '✓ $_birthPlace\n'
                                'Lat: ${_selectedLatitude!.toStringAsFixed(4)}, Lon: ${_selectedLongitude!.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: context.gc.success,
                                  fontSize: 12,
                                  height: 1.4,
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
                onPressed:
                    _isCalculating || !_canCalculate() ? null : _calculateChart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: context.gc.lilac.withOpacity(0.3),
                ),
                child: _isCalculating
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.gc.darkBackground,
                          ),
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context).chartCalculate,
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
                      Icon(
                        Icons.info_outline,
                        color: context.gc.starYellow,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).chartNoonNote,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.softWhite.withOpacity(0.8),
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
