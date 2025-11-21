import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../../../core/ai/ai_service.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/magical_profile_model.dart';
import '../../data/repositories/astrology_repository.dart';
import '../../data/services/chart_calculator.dart';
import '../../data/services/magical_interpreter.dart';

class AstrologyProvider with ChangeNotifier {
  final AstrologyRepository _repository = AstrologyRepository();
  final ChartCalculator _calculator = ChartCalculator.instance;
  final MagicalInterpreter _interpreter = MagicalInterpreter.instance;
  final AIService _aiService = AIService.instance;

  BirthChartModel? _birthChart;
  MagicalProfile? _magicalProfile;
  bool _isLoading = false;
  bool _isGeneratingAI = false;
  String? _error;

  BirthChartModel? get birthChart => _birthChart;
  MagicalProfile? get magicalProfile => _magicalProfile;
  bool get isLoading => _isLoading;
  bool get isGeneratingAI => _isGeneratingAI;
  String? get error => _error;
  bool get hasBirthChart => _birthChart != null;
  bool get hasMagicalProfile => _magicalProfile != null;
  bool get hasAIGeneratedProfile => _magicalProfile?.aiGeneratedText != null;

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

      // Gerar texto personalizado com Conselheiro Místico automaticamente
      _isLoading = false;
      notifyListeners();

      // Iniciar geração do texto IA em background
      generateAIMagicalProfile();

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

      // Regenerar texto personalizado com Conselheiro Místico
      _isLoading = false;
      notifyListeners();

      // Iniciar geração do texto em background
      generateAIMagicalProfile();

      return;
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

  /// Gera hash único do mapa astral para comparação
  String _generateChartHash(BirthChartModel chart) {
    final data = '${chart.birthDate.toIso8601String()}_${chart.birthTime.hour}_${chart.birthTime.minute}_${chart.latitude}_${chart.longitude}';
    return md5.convert(utf8.encode(data)).toString();
  }

  /// Gera texto personalizado do perfil mágico com IA
  Future<void> generateAIMagicalProfile() async {
    if (_birthChart == null || _magicalProfile == null) return;

    // Verificar se já existe texto gerado para o mesmo mapa
    final currentHash = _generateChartHash(_birthChart!);
    if (_magicalProfile!.aiGeneratedText != null &&
        _magicalProfile!.chartHash == currentHash) {
      print('✅ Texto IA já existe para este mapa, usando cache');
      return;
    }

    _isGeneratingAI = true;
    _error = null;
    notifyListeners();

    try {
      print('🔮 Gerando texto personalizado com IA...');

      final aiText = await _aiService.generateMagicalProfileText(
        birthChart: _birthChart!,
        profile: _magicalProfile!,
      );

      // Atualizar perfil com texto IA
      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: aiText,
        chartHash: currentHash,
      );

      // Salvar perfil atualizado
      await _repository.saveMagicalProfile(_magicalProfile!);

      print('✅ Perfil mágico com IA salvo');
    } catch (e) {
      print('❌ Erro ao gerar perfil com IA: $e');
      _error = 'Erro ao gerar perfil personalizado: $e';
    } finally {
      _isGeneratingAI = false;
      notifyListeners();
    }
  }

  /// Força regeneração do texto IA (mesmo que já exista)
  Future<void> regenerateAIMagicalProfile() async {
    if (_birthChart == null || _magicalProfile == null) return;

    _isGeneratingAI = true;
    _error = null;
    notifyListeners();

    try {
      final aiText = await _aiService.generateMagicalProfileText(
        birthChart: _birthChart!,
        profile: _magicalProfile!,
      );

      final currentHash = _generateChartHash(_birthChart!);

      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: aiText,
        chartHash: currentHash,
      );

      await _repository.saveMagicalProfile(_magicalProfile!);
    } catch (e) {
      _error = 'Erro ao regenerar perfil: $e';
    } finally {
      _isGeneratingAI = false;
      notifyListeners();
    }
  }
}
