import 'dart:convert';

import 'package:flutter/material.dart' show Color;

import 'color_model.dart';
import 'crystal_model.dart';
import 'herb_model.dart';

/// Categorias que aceitam entradas criadas pela usuária (foto + IA).
/// As chaves (`crystal`/`herb`/`color`) são invariantes: viajam nos prompts
/// de IA e na coluna `category` de `user_encyclopedia_entries`.
enum UserEntryCategory {
  crystal,
  herb,
  color;

  String get key => name;

  /// Só a erva tem identificação por foto. Cristal: a identificação visual
  /// errava demais — a pessoa dá o nome e a foto vai junto do verbete. Cor:
  /// não tem mais verbete pessoal (ver [aceitaEntradaPessoal]).
  bool get identificavelPorFoto => this == UserEntryCategory.herb;

  /// Cores saíram da criação pessoal: o catálogo fixo da aba Cores basta. O
  /// valor continua no enum só para LER linhas antigas do banco.
  bool get aceitaEntradaPessoal => this != UserEntryCategory.color;

  /// Pasta da foto no Storage: `{uid}/{pasta}/{id}.jpg`.
  String get pastaNoStorage => switch (this) {
        UserEntryCategory.crystal => 'crystals',
        UserEntryCategory.herb => 'herbs',
        UserEntryCategory.color => 'colors',
      };

  static UserEntryCategory? fromKey(String? key) {
    for (final category in values) {
      if (category.key == key) return category;
    }
    return null;
  }
}

/// Uma entrada pessoal da enciclopédia: página gerada por IA a partir da
/// foto tirada pela Bruxa, no formato exato da categoria correspondente.
/// `data` guarda o JSON com os campos do modelo (chaves em inglês, textos
/// no idioma em que a entrada foi gerada).
class UserEncyclopediaEntry {
  final String id;
  final String userId;
  final UserEntryCategory category;
  final String name;
  final String? imagePath;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEncyclopediaEntry({
    required this.id,
    required this.userId,
    required this.category,
    required this.name,
    this.imagePath,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'category': category.key,
        'name': name,
        'image_path': imagePath,
        'data': jsonEncode(data),
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'synced': 0,
      };

  static UserEncyclopediaEntry? fromMap(Map<String, dynamic> map) {
    final category = UserEntryCategory.fromKey(map['category'] as String?);
    if (category == null) return null;
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(jsonDecode(map['data'] as String));
    } catch (_) {
      return null;
    }
    return UserEncyclopediaEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'local_user',
      category: category,
      name: map['name'] as String? ?? '',
      imagePath: map['image_path'] as String?,
      data: data,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int? ?? 0),
    );
  }

  // ---- Conversões para os modelos das páginas existentes ----

  static List<String> _stringList(dynamic value) =>
      value is List ? value.map((e) => '$e').toList() : const [];

  static List<CrystalMethod> _methods(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((m) {
      return CrystalMethod(
        method: '${m['method'] ?? ''}',
        isSafe: m['isSafe'] == true,
        warning: m['warning'] == null ? null : '${m['warning']}',
      );
    }).toList();
  }

  Element _element() {
    final raw = '${data['element'] ?? ''}';
    return Element.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => Element.earth,
    );
  }

  CrystalModel toCrystalModel() => CrystalModel(
        name: name,
        description: '${data['description'] ?? ''}',
        element: _element(),
        intentions: _stringList(data['intentions']),
        usageTips: _stringList(data['usageTips']),
        cleaningMethods: _methods(data['cleaningMethods']),
        chargingMethods: _methods(data['chargingMethods']),
        safetyWarnings: _stringList(data['safetyWarnings']),
        imageUrl: imagePath,
      );

  HerbModel toHerbModel() {
    final elementRaw = '${data['element'] ?? ''}';
    final planetRaw = '${data['planet'] ?? ''}';
    return HerbModel(
      name: name,
      scientificName: '${data['scientificName'] ?? ''}',
      description: '${data['description'] ?? ''}',
      element: HerbElement.values.firstWhere(
        (e) => e.name == elementRaw,
        orElse: () => HerbElement.earth,
      ),
      planet: Planet.values.firstWhere(
        (p) => p.name == planetRaw,
        orElse: () => Planet.moon,
      ),
      magicalProperties: _stringList(data['magicalProperties']),
      ritualUses: _stringList(data['ritualUses']),
      safetyWarnings: _stringList(data['safetyWarnings']),
      edible: data['edible'] == true,
      toxic: data['toxic'] == true,
      folkNames: data['folkNames'] == null ? null : '${data['folkNames']}',
      imageUrl: imagePath,
    );
  }

  ColorModel toColorModel() => ColorModel(
        name: name,
        color: _parseHex('${data['hex'] ?? ''}'),
        meaning: '${data['meaning'] ?? ''}',
        intentions: _stringList(data['intentions']),
        usageTips: _stringList(data['usageTips']),
      );

  static Color _parseHex(String hex) {
    final cleaned = hex.replaceAll('#', '').trim();
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null || cleaned.length != 6) {
      return const Color(0xFF9C89B8); // lilás padrão em caso de hex inválido
    }
    return Color(0xFF000000 | value);
  }
}
