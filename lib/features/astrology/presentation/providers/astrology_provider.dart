import 'package:flutter/material.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/magical_profile_model.dart';
import '../../data/repositories/astrology_repository.dart';
import '../../data/services/chart_calculator.dart';
import '../../data/services/magical_interpreter.dart';

class AstrologyProvider with ChangeNotifier {
  final AstrologyRepository _repository = AstrologyRepository();
  final ChartCalculator _calculator = ChartCalculator.instance;
  final MagicalInterpreter _interpreter = MagicalInterpreter.instance;

  BirthChartModel? _birthChart;
  MagicalProfile? _magicalProfile;
  bool _isLoading = false;
  String? _error;

  BirthChartModel? get birthChart => _birthChart;
  MagicalProfile? get magicalProfile => _magicalProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBirthChart => _birthChart != null;
  bool get hasMagicalProfile => _magicalProfile != null;

  /// Carrega o mapa natal do usuário (se existir)
  Future<void> loadBirthChart(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _birthChart = await _repository.getBirthChart(userId);

      if (_birthChart != null) {
        // Carregar perfil mágico também
        _magicalProfile = await _repository.getMagicalProfile(userId);
      }
    } catch (e) {
      _error = 'Erro ao carregar mapa natal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calcula e salva um novo mapa natal
  Future<BirthChartModel?> calculateAndSaveBirthChart({
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    bool unknownBirthTime = false,
    String userId = 'current_user',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calcular mapa natal
      final chart = await _calculator.calculateBirthChart(
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace,
        latitude: latitude,
        longitude: longitude,
        unknownBirthTime: unknownBirthTime,
      );

      // Salvar no banco
      await _repository.saveBirthChart(chart);

      // Gerar perfil mágico
      final profile = _interpreter.interpretChart(chart);
      await _repository.saveMagicalProfile(profile);

      // Atualizar estado
      _birthChart = chart;
      _magicalProfile = profile;

      return chart;
    } catch (e) {
      _error = 'Erro ao calcular mapa natal: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza o mapa natal existente
  Future<void> updateBirthChart(BirthChartModel chart) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateBirthChart(chart);

      // Regenerar perfil mágico
      final profile = _interpreter.interpretChart(chart);
      await _repository.saveMagicalProfile(profile);

      _birthChart = chart;
      _magicalProfile = profile;
    } catch (e) {
      _error = 'Erro ao atualizar mapa natal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deleta o mapa natal
  Future<void> deleteBirthChart() async {
    if (_birthChart == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteBirthChart(_birthChart!.id);
      _birthChart = null;
      _magicalProfile = null;
    } catch (e) {
      _error = 'Erro ao deletar mapa natal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Regenera o perfil mágico
  Future<void> regenerateMagicalProfile() async {
    if (_birthChart == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = _interpreter.interpretChart(_birthChart!);
      await _repository.saveMagicalProfile(profile);
      _magicalProfile = profile;
    } catch (e) {
      _error = 'Erro ao regenerar perfil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
