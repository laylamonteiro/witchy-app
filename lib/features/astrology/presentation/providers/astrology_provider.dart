import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../../../core/ai/ai_service.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/magical_profile_report.dart';
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
  int _aiSectionsDone = 0;
  String? _error;
  String _currentUserId = 'local_user';

  BirthChartModel? get birthChart => _birthChart;
  MagicalProfile? get magicalProfile => _magicalProfile;
  bool get isLoading => _isLoading;
  bool get isGeneratingAI => _isGeneratingAI;

  /// Quantas seções da Análise Personalizada já foram tecidas nesta geração.
  /// A tela mostra o progresso porque são dez chamadas: sem número na tela,
  /// meio minuto de spinner parece travamento.
  int get aiSectionsDone => _aiSectionsDone;
  int get aiSectionsTotal => MagicalProfileSections.ordered.length;
  String? get error => _error;
  bool get hasBirthChart => _birthChart != null;
  bool get hasMagicalProfile => _magicalProfile != null;
  bool get hasAIGeneratedProfile => _magicalProfile?.aiGeneratedText != null;

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    await loadBirthChart();
  }

  /// Carrega o mapa natal do usuário (se existir)
  Future<void> loadBirthChart([String? userId]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final effectiveUserId = userId ?? _currentUserId;
      _birthChart = await _repository.getBirthChart(effectiveUserId);

      if (_birthChart != null) {
        // Recalcula silenciosamente se o mapa foi gerado por uma versão antiga
        // do algoritmo (ex.: antes dos novos pontos místicos).
        await _recalculateIfOutdated();
        // Carregar perfil mágico também
        _magicalProfile = await _repository.getMagicalProfile(effectiveUserId);
      }
    } catch (e) {
      _error = 'Erro ao carregar mapa natal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recalcula um mapa salvo cuja versão de cálculo esteja desatualizada,
  /// reaproveitando os dados de nascimento originais. Preserva o id (mesma
  /// linha no banco) e não mexe no perfil mágico/IA. Falha em silêncio,
  /// mantendo o mapa antigo se o recálculo não for possível.
  Future<void> _recalculateIfOutdated() async {
    final chart = _birthChart;
    if (chart == null || chart.calcVersion >= kChartCalcVersion) return;

    try {
      final recalculated = await _calculator.calculateBirthChart(
        userId: chart.userId,
        birthDate: chart.birthDate,
        birthTime: chart.birthTime,
        birthPlace: chart.birthPlace,
        latitude: chart.latitude,
        longitude: chart.longitude,
        unknownBirthTime: chart.unknownBirthTime,
      );
      final updated = recalculated.copyWith(id: chart.id, userId: chart.userId);
      await _repository.updateBirthChart(updated);
      _birthChart = updated;
    } catch (e) {
      debugPrint('Falha ao recalcular mapa desatualizado: $e');
    }
  }

  /// Calcula e salva um novo mapa natal
  ///
  /// [hasFullAccess] decide se a análise personalizada (produto Premium)
  /// entra junto: sem acesso, ela nem é pedida à IA.
  Future<BirthChartModel?> calculateAndSaveBirthChart({
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required bool hasFullAccess,
    bool unknownBirthTime = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calcular mapa natal
      final chart = await _calculator.calculateBirthChart(
        userId: _currentUserId,
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
      generateAIMagicalProfile(hasFullAccess: hasFullAccess);

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
  Future<void> updateBirthChart(
    BirthChartModel chart, {
    required bool hasFullAccess,
  }) async {
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
      generateAIMagicalProfile(hasFullAccess: hasFullAccess);

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
    final data =
        '${chart.birthDate.toIso8601String()}_${chart.birthTime.hour}_${chart.birthTime.minute}_${chart.latitude}_${chart.longitude}';
    return md5.convert(utf8.encode(data)).toString();
  }

  /// Tece a Análise Personalizada, uma seção por chamada.
  ///
  /// O texto salvo continua sendo um markdown só; o que separa as seções é
  /// o marcador de chave (`## [essence]`), que a tela usa para montar os
  /// cards e para rotular cada um pelo l10n — o corpo fica no idioma em que
  /// foi tecido, os títulos acompanham o app.
  ///
  /// Uma seção que falha não derruba o relatório: as outras seguem, e a que
  /// faltou simplesmente não vira card. Só se TODAS falharem é que a tela
  /// mostra erro.
  Future<String?> _tecerAnalise() async {
    final partes = <String>[];
    _aiSectionsDone = 0;

    for (final chave in MagicalProfileSections.ordered) {
      try {
        final corpo = await _aiService.generateMagicalProfileSection(
          birthChart: _birthChart!,
          profile: _magicalProfile!,
          sectionKey: chave,
        );
        if (corpo.trim().isNotEmpty) {
          partes.add('${MagicalProfileSections.header(chave)}\n\n$corpo');
        }
      } catch (e) {
        debugPrint('Perfil mágico: seção $chave falhou — $e');
      }
      _aiSectionsDone++;
      notifyListeners();
    }

    if (partes.isEmpty) return null;
    return partes.join('\n\n');
  }

  /// Gera a Análise Personalizada, se ainda não existir para este mapa.
  Future<void> generateAIMagicalProfile({required bool hasFullAccess}) async {
    if (_birthChart == null || _magicalProfile == null) return;

    // A análise personalizada é produto Premium: sem acesso, não se gera nem
    // se guarda (fail-closed — esconder na tela o que já está no aparelho
    // nunca foi proteção).
    if (!hasFullAccess) return;

    final currentHash = _generateChartHash(_birthChart!);
    if (_magicalProfile!.aiGeneratedText != null &&
        _magicalProfile!.chartHash == currentHash) {
      return;
    }

    await _gerarAnaliseInterna(currentHash, 'Erro ao gerar perfil personalizado');
  }

  /// Força a regeneração (mesmo que já exista texto para este mapa).
  Future<void> regenerateAIMagicalProfile({required bool hasFullAccess}) async {
    if (_birthChart == null || _magicalProfile == null) return;
    if (!hasFullAccess) return;

    await _gerarAnaliseInterna(
      _generateChartHash(_birthChart!),
      'Erro ao regenerar perfil',
    );
  }

  Future<void> _gerarAnaliseInterna(String chartHash, String mensagemDeErro) async {
    _isGeneratingAI = true;
    _error = null;
    notifyListeners();

    try {
      final aiText = await _tecerAnalise();
      if (aiText == null) {
        _error = mensagemDeErro;
        return;
      }

      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: aiText,
        chartHash: chartHash,
      );
      await _repository.saveMagicalProfile(_magicalProfile!);
    } catch (e) {
      _error = '$mensagemDeErro: $e';
    } finally {
      _isGeneratingAI = false;
      notifyListeners();
    }
  }
}
