import 'package:flutter/material.dart';

import '../../../../core/content/content_locale.dart';
import 'journey_texts_en.dart';
import 'journey_texts_es.dart';
import 'journey_texts_pt.dart';

/// Título+descrição localizados de jornadas/etapas, indexados por id.
typedef JourneyText = ({String title, String description});

/// Representa uma jornada mágica gamificada
class JourneyModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<JourneyStep> steps;
  final JourneyCategory category;
  final int xpReward;
  final String? badgeAsset;

  const JourneyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.steps,
    required this.category,
    this.xpReward = 100,
    this.badgeAsset,
  });

  int get totalSteps => steps.length;

  /// Título no idioma atual (fallback: campo PT gravado no modelo).
  String get localizedTitle => ContentLocale.instance
          .select(pt: journeyTextsPt, en: journeyTextsEn, es: journeyTextsEs)[id]
          ?.title ??
      title;

  /// Descrição no idioma atual (fallback: campo PT do modelo).
  String get localizedDescription => ContentLocale.instance
          .select(pt: journeyTextsPt, en: journeyTextsEn, es: journeyTextsEs)[id]
          ?.description ??
      description;
}

/// Etapa de uma jornada
class JourneyStep {
  final String id;
  final String title;
  final String description;
  final StepType type;
  final int requiredCount;
  final String? targetEntity;
  final int xpReward;

  const JourneyStep({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.requiredCount = 1,
    this.targetEntity,
    this.xpReward = 20,
  });

  /// Título no idioma atual (fallback: campo PT gravado no modelo).
  String get localizedTitle => ContentLocale.instance
          .select(
              pt: journeyStepTextsPt,
              en: journeyStepTextsEn,
              es: journeyStepTextsEs)[id]
          ?.title ??
      title;

  /// Descrição no idioma atual (fallback: campo PT do modelo).
  String get localizedDescription => ContentLocale.instance
          .select(
              pt: journeyStepTextsPt,
              en: journeyStepTextsEn,
              es: journeyStepTextsEs)[id]
          ?.description ??
      description;
}

/// Tipo de etapa
enum StepType {
  /// Criar algo (feitiço, entrada de diário, etc)
  create,

  /// Completar uma leitura (runas, oráculo, etc)
  complete,

  /// Fazer algo por X dias seguidos
  streak,

  /// Visualizar algo
  view,

  /// Customizar algo
  customize,
}

/// Categoria da jornada
enum JourneyCategory {
  iniciante,
  grimorio,
  diario,
  divinacao,
  astrologia,
  comunidade,
}

/// Progresso do usuário em uma jornada
class JourneyProgress {
  final String journeyId;
  final String odUserId;
  final Map<String, int> stepProgress;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime startedAt;

  JourneyProgress({
    required this.journeyId,
    required this.odUserId,
    required this.stepProgress,
    this.isCompleted = false,
    this.completedAt,
    required this.startedAt,
  });

  int getStepProgress(String stepId) => stepProgress[stepId] ?? 0;

  bool isStepCompleted(JourneyStep step) {
    return getStepProgress(step.id) >= step.requiredCount;
  }

  int get completedStepsCount {
    // Precisa das steps para calcular, mas retorna count baseado em progresso
    return stepProgress.values.where((v) => v > 0).length;
  }
}

/// Jornadas disponíveis no app
class AvailableJourneys {
  static const List<JourneyModel> all = [
    // Jornada Iniciante
    JourneyModel(
      id: 'iniciante_01',
      title: 'Primeiros Passos',
      description: 'Comece sua jornada magica aprendendo o basico',
      icon: Icons.stars,
      color: Color(0xFF9C27B0),
      category: JourneyCategory.iniciante,
      xpReward: 150,
      steps: [
        JourneyStep(
          id: 'ini_01_01',
          title: 'Crie seu primeiro feitico',
          description: 'Registre seu primeiro feitico no grimorio',
          type: StepType.create,
          targetEntity: 'spells',
          xpReward: 30,
        ),
        JourneyStep(
          id: 'ini_01_02',
          title: 'Escreva no diario de sonhos',
          description: 'Registre um sonho no seu diario',
          type: StepType.create,
          targetEntity: 'dreams',
          xpReward: 30,
        ),
        JourneyStep(
          id: 'ini_01_03',
          title: 'Pratique gratidão',
          description: 'Escreva sua primeira entrada de gratidão',
          type: StepType.create,
          targetEntity: 'gratitudes',
          xpReward: 30,
        ),
        JourneyStep(
          id: 'ini_01_04',
          title: 'Consulte as runas',
          description: 'Faca sua primeira leitura de runas',
          type: StepType.complete,
          targetEntity: 'rune_readings',
          xpReward: 30,
        ),
        JourneyStep(
          id: 'ini_01_05',
          title: 'Descubra seu mapa astral',
          description: 'Gere seu mapa astral completo',
          type: StepType.complete,
          targetEntity: 'birth_charts',
          xpReward: 30,
        ),
      ],
    ),

    // Jornada do Grimório
    JourneyModel(
      id: 'grimorio_01',
      title: 'Mestre do Grimorio',
      description: 'Construa um grimorio poderoso com seus feitiços',
      icon: Icons.auto_fix_high,
      color: Color(0xFF673AB7),
      category: JourneyCategory.grimorio,
      xpReward: 200,
      steps: [
        JourneyStep(
          id: 'grim_01_01',
          title: 'Aprendiz',
          description: 'Crie 5 feitiços',
          type: StepType.create,
          targetEntity: 'spells',
          requiredCount: 5,
          xpReward: 40,
        ),
        JourneyStep(
          id: 'grim_01_02',
          title: 'Praticante',
          description: 'Crie 10 feitiços',
          type: StepType.create,
          targetEntity: 'spells',
          requiredCount: 10,
          xpReward: 50,
        ),
        JourneyStep(
          id: 'grim_01_03',
          title: 'Mestre',
          description: 'Crie 25 feitiços',
          type: StepType.create,
          targetEntity: 'spells',
          requiredCount: 25,
          xpReward: 60,
        ),
        JourneyStep(
          id: 'grim_01_04',
          title: 'Arquimago',
          description: 'Crie 50 feitiços',
          type: StepType.create,
          targetEntity: 'spells',
          requiredCount: 50,
          xpReward: 50,
        ),
      ],
    ),

    // Jornada da Gratidão
    JourneyModel(
      id: 'gratidao_01',
      title: 'Coracao Grato',
      description: 'Cultive a gratidão em sua vida diaria',
      icon: Icons.favorite,
      color: Color(0xFFE91E63),
      category: JourneyCategory.diario,
      xpReward: 300,
      steps: [
        JourneyStep(
          id: 'grat_01_01',
          title: 'Despertar',
          description: 'Pratique gratidão por 3 dias seguidos',
          type: StepType.streak,
          targetEntity: 'gratitudes',
          requiredCount: 3,
          xpReward: 40,
        ),
        JourneyStep(
          id: 'grat_01_02',
          title: 'Habito',
          description: 'Pratique gratidão por 7 dias seguidos',
          type: StepType.streak,
          targetEntity: 'gratitudes',
          requiredCount: 7,
          xpReward: 60,
        ),
        JourneyStep(
          id: 'grat_01_03',
          title: 'Devocao',
          description: 'Pratique gratidão por 21 dias seguidos',
          type: StepType.streak,
          targetEntity: 'gratitudes',
          requiredCount: 21,
          xpReward: 100,
        ),
        JourneyStep(
          id: 'grat_01_04',
          title: 'Iluminacao',
          description: 'Pratique gratidão por 30 dias seguidos',
          type: StepType.streak,
          targetEntity: 'gratitudes',
          requiredCount: 30,
          xpReward: 100,
        ),
      ],
    ),

    // Jornada dos Sonhos
    JourneyModel(
      id: 'sonhos_01',
      title: 'Viajante Onirico',
      description: 'Explore o mundo dos sonhos',
      icon: Icons.nights_stay,
      color: Color(0xFF3F51B5),
      category: JourneyCategory.diario,
      xpReward: 200,
      steps: [
        JourneyStep(
          id: 'son_01_01',
          title: 'Primeiro Registro',
          description: 'Registre seu primeiro sonho',
          type: StepType.create,
          targetEntity: 'dreams',
          xpReward: 30,
        ),
        JourneyStep(
          id: 'son_01_02',
          title: 'Sonhador Dedicado',
          description: 'Registre 10 sonhos',
          type: StepType.create,
          targetEntity: 'dreams',
          requiredCount: 10,
          xpReward: 50,
        ),
        JourneyStep(
          id: 'son_01_03',
          title: 'Mestre dos Sonhos',
          description: 'Registre 30 sonhos',
          type: StepType.create,
          targetEntity: 'dreams',
          requiredCount: 30,
          xpReward: 70,
        ),
        JourneyStep(
          id: 'son_01_04',
          title: 'Oráculo Onírico',
          description: 'Registre 50 sonhos',
          type: StepType.create,
          targetEntity: 'dreams',
          requiredCount: 50,
          xpReward: 50,
        ),
      ],
    ),

    // Jornada da Divinação
    JourneyModel(
      id: 'divinacao_01',
      title: 'Vidente',
      description: 'Domine as artes divinatórias',
      icon: Icons.visibility,
      color: Color(0xFF00BCD4),
      category: JourneyCategory.divinacao,
      xpReward: 250,
      steps: [
        JourneyStep(
          id: 'div_01_01',
          title: 'Iniciacao nas Runas',
          description: 'Faca 5 leituras de runas',
          type: StepType.complete,
          targetEntity: 'rune_readings',
          requiredCount: 5,
          xpReward: 40,
        ),
        JourneyStep(
          id: 'div_01_02',
          title: 'Leitor de Oráculo',
          description: 'Faca 5 leituras do oráculo',
          type: StepType.complete,
          targetEntity: 'oracle_readings',
          requiredCount: 5,
          xpReward: 40,
        ),
        JourneyStep(
          id: 'div_01_03',
          title: 'Mestre do Pêndulo',
          description: 'Faca 10 consultas ao pêndulo',
          type: StepType.complete,
          targetEntity: 'pendulum_consultations',
          requiredCount: 10,
          xpReward: 50,
        ),
        JourneyStep(
          id: 'div_01_04',
          title: 'Oráculo Completo',
          description: 'Faca 25 leituras no total',
          type: StepType.complete,
          targetEntity: 'all_readings',
          requiredCount: 25,
          xpReward: 70,
        ),
      ],
    ),

    // Jornada dos Desejos
    JourneyModel(
      id: 'desejos_01',
      title: 'Manifestador',
      description: 'Aprenda a manifestar seus desejos',
      icon: Icons.star,
      color: Color(0xFFFF9800),
      category: JourneyCategory.diario,
      xpReward: 250,
      steps: [
        JourneyStep(
          id: 'des_01_01',
          title: 'Primeiro Desejo',
          description: 'Registre seu primeiro desejo',
          type: StepType.create,
          targetEntity: 'desires',
          xpReward: 30,
        ),
        JourneyStep(
          id: 'des_01_02',
          title: 'Lista de Desejos',
          description: 'Registre 10 desejos',
          type: StepType.create,
          targetEntity: 'desires',
          requiredCount: 10,
          xpReward: 50,
        ),
        JourneyStep(
          id: 'des_01_03',
          title: 'Primeira Manifestacao',
          description: 'Manifeste seu primeiro desejo',
          type: StepType.complete,
          targetEntity: 'desires_manifested',
          xpReward: 70,
        ),
        JourneyStep(
          id: 'des_01_04',
          title: 'Mestre Manifestador',
          description: 'Manifeste 5 desejos',
          type: StepType.complete,
          targetEntity: 'desires_manifested',
          requiredCount: 5,
          xpReward: 100,
        ),
      ],
    ),
  ];

  static List<JourneyModel> byCategory(JourneyCategory category) {
    return all.where((j) => j.category == category).toList();
  }

  static JourneyModel? byId(String id) {
    try {
      return all.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }
}
