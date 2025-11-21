import 'dart:convert';
import 'enums.dart';

class MagicalProfile {
  final String userId;
  final String birthChartId;

  // Elementos
  final Element dominantElement;
  final Map<Element, int> elementDistribution;

  // Modalidades
  final Modality dominantModality;
  final Map<Modality, int> modalityDistribution;

  // Interpretações dos planetas pessoais
  final String magicalEssence; // Baseado no Sol
  final String intuitiveGifts; // Baseado na Lua
  final String communicationStyle; // Baseado em Mercúrio
  final String loveAndBeauty; // Baseado em Vênus
  final String protectiveEnergy; // Baseado em Marte

  // Casas especiais
  final String houseOfMagic; // Casa 8
  final String houseOfSpirit; // Casa 12

  // Afinidades
  final List<String> magicalStrengths;
  final List<String> recommendedPractices;
  final List<String> favorableTools; // cristais, ervas, cores

  // Desafios
  final List<String> shadowWork;

  // Texto personalizado gerado por IA
  final String? aiGeneratedText;
  final String? chartHash; // Hash dos dados do mapa para verificar se mudou

  final DateTime generatedAt;

  const MagicalProfile({
    required this.userId,
    required this.birthChartId,
    required this.dominantElement,
    required this.elementDistribution,
    required this.dominantModality,
    required this.modalityDistribution,
    required this.magicalEssence,
    required this.intuitiveGifts,
    required this.communicationStyle,
    required this.loveAndBeauty,
    required this.protectiveEnergy,
    required this.houseOfMagic,
    required this.houseOfSpirit,
    required this.magicalStrengths,
    required this.recommendedPractices,
    required this.favorableTools,
    required this.shadowWork,
    required this.generatedAt,
    this.aiGeneratedText,
    this.chartHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'birthChartId': birthChartId,
      'dominantElement': dominantElement.name,
      'elementDistribution': elementDistribution.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'dominantModality': dominantModality.name,
      'modalityDistribution': modalityDistribution.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'magicalEssence': magicalEssence,
      'intuitiveGifts': intuitiveGifts,
      'communicationStyle': communicationStyle,
      'loveAndBeauty': loveAndBeauty,
      'protectiveEnergy': protectiveEnergy,
      'houseOfMagic': houseOfMagic,
      'houseOfSpirit': houseOfSpirit,
      'magicalStrengths': magicalStrengths,
      'recommendedPractices': recommendedPractices,
      'favorableTools': favorableTools,
      'shadowWork': shadowWork,
      'generatedAt': generatedAt.toIso8601String(),
      'aiGeneratedText': aiGeneratedText,
      'chartHash': chartHash,
    };
  }

  MagicalProfile copyWith({
    String? userId,
    String? birthChartId,
    Element? dominantElement,
    Map<Element, int>? elementDistribution,
    Modality? dominantModality,
    Map<Modality, int>? modalityDistribution,
    String? magicalEssence,
    String? intuitiveGifts,
    String? communicationStyle,
    String? loveAndBeauty,
    String? protectiveEnergy,
    String? houseOfMagic,
    String? houseOfSpirit,
    List<String>? magicalStrengths,
    List<String>? recommendedPractices,
    List<String>? favorableTools,
    List<String>? shadowWork,
    DateTime? generatedAt,
    String? aiGeneratedText,
    String? chartHash,
  }) {
    return MagicalProfile(
      userId: userId ?? this.userId,
      birthChartId: birthChartId ?? this.birthChartId,
      dominantElement: dominantElement ?? this.dominantElement,
      elementDistribution: elementDistribution ?? this.elementDistribution,
      dominantModality: dominantModality ?? this.dominantModality,
      modalityDistribution: modalityDistribution ?? this.modalityDistribution,
      magicalEssence: magicalEssence ?? this.magicalEssence,
      intuitiveGifts: intuitiveGifts ?? this.intuitiveGifts,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      loveAndBeauty: loveAndBeauty ?? this.loveAndBeauty,
      protectiveEnergy: protectiveEnergy ?? this.protectiveEnergy,
      houseOfMagic: houseOfMagic ?? this.houseOfMagic,
      houseOfSpirit: houseOfSpirit ?? this.houseOfSpirit,
      magicalStrengths: magicalStrengths ?? this.magicalStrengths,
      recommendedPractices: recommendedPractices ?? this.recommendedPractices,
      favorableTools: favorableTools ?? this.favorableTools,
      shadowWork: shadowWork ?? this.shadowWork,
      generatedAt: generatedAt ?? this.generatedAt,
      aiGeneratedText: aiGeneratedText ?? this.aiGeneratedText,
      chartHash: chartHash ?? this.chartHash,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory MagicalProfile.fromJson(Map<String, dynamic> json) {
    return MagicalProfile(
      userId: json['userId'],
      birthChartId: json['birthChartId'],
      dominantElement: Element.values.firstWhere(
        (e) => e.name == json['dominantElement'],
      ),
      elementDistribution: (json['elementDistribution'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          Element.values.firstWhere((e) => e.name == k),
          v as int,
        ),
      ),
      dominantModality: Modality.values.firstWhere(
        (e) => e.name == json['dominantModality'],
      ),
      modalityDistribution: (json['modalityDistribution'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          Modality.values.firstWhere((e) => e.name == k),
          v as int,
        ),
      ),
      magicalEssence: json['magicalEssence'],
      intuitiveGifts: json['intuitiveGifts'],
      communicationStyle: json['communicationStyle'],
      loveAndBeauty: json['loveAndBeauty'],
      protectiveEnergy: json['protectiveEnergy'],
      houseOfMagic: json['houseOfMagic'],
      houseOfSpirit: json['houseOfSpirit'],
      magicalStrengths: List<String>.from(json['magicalStrengths']),
      recommendedPractices: List<String>.from(json['recommendedPractices']),
      favorableTools: List<String>.from(json['favorableTools']),
      shadowWork: List<String>.from(json['shadowWork']),
      generatedAt: DateTime.parse(json['generatedAt']),
      aiGeneratedText: json['aiGeneratedText'],
      chartHash: json['chartHash'],
    );
  }

  factory MagicalProfile.fromJsonString(String jsonString) {
    return MagicalProfile.fromJson(jsonDecode(jsonString));
  }
}
