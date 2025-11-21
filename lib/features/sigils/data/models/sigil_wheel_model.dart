import 'dart:math' as math;
import 'package:flutter/material.dart';

class SigilWheel {
  // Distribuição das letras nos 3 anéis da roda
  // Baseado no livro: Roda Alfabética das Bruxas
  // ESTRUTURA CORRETA - 3 CAMADAS CONCÊNTRICAS

  // Letras por anel (para embaralhamento - "Sigilo Nada")
  static const List<String> innerRingLetters = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const List<String> middleRingLetters = ['G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'];
  static const List<String> outerRingLetters = ['O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  // Ângulos padrão para cada anel
  static List<double> get innerRingAngles => [0, 60, 120, 180, 240, 300];
  static List<double> get middleRingAngles => [0, 45, 90, 135, 180, 225, 270, 315];
  static List<double> get outerRingAngles => [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330];

  static const Map<String, WheelPosition> letterPositions = {
    // Anel Interno (raio = 0.33) - 6 letras (A-F)
    // 60° entre cada letra (360° / 6 = 60°)
    'A': WheelPosition(ring: 1, angle: 0, index: 0),
    'B': WheelPosition(ring: 1, angle: 60, index: 1),
    'C': WheelPosition(ring: 1, angle: 120, index: 2),
    'D': WheelPosition(ring: 1, angle: 180, index: 3),
    'E': WheelPosition(ring: 1, angle: 240, index: 4),
    'F': WheelPosition(ring: 1, angle: 300, index: 5),

    // Anel Médio (raio = 0.66) - 8 letras (G-N)
    // 45° entre cada letra (360° / 8 = 45°)
    'G': WheelPosition(ring: 2, angle: 0, index: 0),
    'H': WheelPosition(ring: 2, angle: 45, index: 1),
    'I': WheelPosition(ring: 2, angle: 90, index: 2),
    'J': WheelPosition(ring: 2, angle: 135, index: 3),
    'K': WheelPosition(ring: 2, angle: 180, index: 4),
    'L': WheelPosition(ring: 2, angle: 225, index: 5),
    'M': WheelPosition(ring: 2, angle: 270, index: 6),
    'N': WheelPosition(ring: 2, angle: 315, index: 7),

    // Anel Externo (raio = 1.0) - 12 letras (O-Z)
    // 30° entre cada letra (360° / 12 = 30°)
    'O': WheelPosition(ring: 3, angle: 0, index: 0),
    'P': WheelPosition(ring: 3, angle: 30, index: 1),
    'Q': WheelPosition(ring: 3, angle: 60, index: 2),
    'R': WheelPosition(ring: 3, angle: 90, index: 3),
    'S': WheelPosition(ring: 3, angle: 120, index: 4),
    'T': WheelPosition(ring: 3, angle: 150, index: 5),
    'U': WheelPosition(ring: 3, angle: 180, index: 6),
    'V': WheelPosition(ring: 3, angle: 210, index: 7),
    'W': WheelPosition(ring: 3, angle: 240, index: 8),
    'X': WheelPosition(ring: 3, angle: 270, index: 9),
    'Y': WheelPosition(ring: 3, angle: 300, index: 10),
    'Z': WheelPosition(ring: 3, angle: 330, index: 11),
  };

  /// Gera posições embaralhadas para as letras (como no "Sigilo Nada" do livro)
  /// Mantém cada letra em seu anel original, mas em posição aleatória
  static Map<String, WheelPosition> generateShuffledPositions() {
    final random = math.Random();
    final shuffledPositions = <String, WheelPosition>{};

    // Embaralhar anel interno (A-F)
    final shuffledInner = List<String>.from(innerRingLetters)..shuffle(random);
    for (int i = 0; i < shuffledInner.length; i++) {
      shuffledPositions[shuffledInner[i]] = WheelPosition(
        ring: 1,
        angle: innerRingAngles[i],
        index: i,
      );
    }

    // Embaralhar anel médio (G-N)
    final shuffledMiddle = List<String>.from(middleRingLetters)..shuffle(random);
    for (int i = 0; i < shuffledMiddle.length; i++) {
      shuffledPositions[shuffledMiddle[i]] = WheelPosition(
        ring: 2,
        angle: middleRingAngles[i],
        index: i,
      );
    }

    // Embaralhar anel externo (O-Z)
    final shuffledOuter = List<String>.from(outerRingLetters)..shuffle(random);
    for (int i = 0; i < shuffledOuter.length; i++) {
      shuffledPositions[shuffledOuter[i]] = WheelPosition(
        ring: 3,
        angle: outerRingAngles[i],
        index: i,
      );
    }

    return shuffledPositions;
  }

  /// Calcula posição no canvas com posições customizadas (para embaralhamento)
  static Offset getCanvasPositionWithCustom(
    String letter,
    Size canvasSize,
    Map<String, WheelPosition>? customPositions,
  ) {
    final positions = customPositions ?? letterPositions;
    final position = positions[letter];
    if (position == null) return Offset(canvasSize.width / 2, canvasSize.height / 2);

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    // Usar exatamente 140.0 para canvas 360x360 (mesmo valor do painter)
    final maxRadius = 140.0;

    // Calcula o raio baseado no anel (centro da faixa, igual ao painter)
    double radius;
    switch (position.ring) {
      case 1: // Anel interno (A-F)
        radius = maxRadius * 0.22;
        break;
      case 2: // Anel médio (G-N)
        radius = maxRadius * 0.50;
        break;
      case 3: // Anel externo (O-Z)
        radius = maxRadius * 0.80;
        break;
      default:
        radius = maxRadius * 0.80;
    }

    // Converte ângulo para radianos (subtrai 90° para começar do topo)
    final angleRad = (position.angle - 90) * (math.pi / 180);

    // Calcula posição X,Y
    final x = center.dx + radius * math.cos(angleRad);
    final y = center.dy + radius * math.sin(angleRad);

    return Offset(x, y);
  }

  /// Gera pontos do sigilo com posições customizadas
  static List<Offset> generateSigilPointsWithCustom(
    String text,
    Size canvasSize,
    Map<String, WheelPosition>? customPositions,
  ) {
    final sequence = textToSigilSequence(text);
    final points = <Offset>[];

    for (String letter in sequence) {
      final position = getCanvasPositionWithCustom(letter, canvasSize, customPositions);
      points.add(position);
    }

    return points;
  }

  // Converte texto em sequência para sigilo
  // Remove TODAS as letras duplicadas (método tradicional da Roda das Bruxas)
  static List<String> textToSigilSequence(String text) {
    // Normaliza: maiúsculas e remove acentos
    String normalized = _normalizeText(text.toUpperCase());

    // Remove espaços e caracteres não-alfabéticos
    normalized = normalized.replaceAll(RegExp(r'[^A-Z]'), '');

    // Remove TODAS as letras duplicadas, mantendo apenas primeira ocorrência
    String uniqueLetters = '';
    for (int i = 0; i < normalized.length; i++) {
      if (!uniqueLetters.contains(normalized[i])) {
        uniqueLetters += normalized[i];
      }
    }

    // Converte em lista de caracteres
    return uniqueLetters.split('');
  }
  
  // Remove acentos e normaliza texto
  static String _normalizeText(String text) {
    const Map<String, String> accents = {
      'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Ç': 'C', 'Ñ': 'N',
    };
    
    String result = text;
    accents.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }
  
  // Remove vogais repetidas mantendo apenas a primeira
  static String _removeRepeatedVowels(String text) {
    const vowels = ['A', 'E', 'I', 'O', 'U'];
    StringBuffer result = StringBuffer();
    String? lastVowel;
    
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (vowels.contains(char)) {
        if (char != lastVowel) {
          result.write(char);
          lastVowel = char;
        }
      } else {
        result.write(char);
        lastVowel = null;
      }
    }
    
    return result.toString();
  }
  
  // Remove letras duplicadas consecutivas
  static String _removeDuplicates(String text) {
    if (text.isEmpty) return text;
    
    StringBuffer result = StringBuffer();
    String lastChar = '';
    
    for (int i = 0; i < text.length; i++) {
      if (text[i] != lastChar) {
        result.write(text[i]);
        lastChar = text[i];
      }
    }
    
    return result.toString();
  }
  
  // Calcula posição no canvas baseado na posição da roda
  // IMPORTANTE: Os raios devem ser iguais aos do WitchWheelPainter!
  static Offset getCanvasPosition(
    String letter,
    Size canvasSize,
  ) {
    final position = letterPositions[letter];
    if (position == null) return Offset(canvasSize.width / 2, canvasSize.height / 2);

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    // Usar exatamente 140.0 para canvas 360x360 (mesmo valor do painter)
    final maxRadius = 140.0;

    // Calcula o raio baseado no anel (DEVE ser igual ao painter!)
    double radius;
    switch (position.ring) {
      case 1: // Anel interno (A-F)
        radius = maxRadius * 0.22;
        break;
      case 2: // Anel médio (G-N)
        radius = maxRadius * 0.50;
        break;
      case 3: // Anel externo (O-Z)
        radius = maxRadius * 0.80;
        break;
      default:
        radius = maxRadius * 0.80;
    }

    // Converte ângulo para radianos (subtrai 90° para começar do topo)
    final angleRad = (position.angle - 90) * (math.pi / 180);

    // Calcula posição X,Y
    final x = center.dx + radius * math.cos(angleRad);
    final y = center.dy + radius * math.sin(angleRad);

    return Offset(x, y);
  }
  
  // Gera os pontos do sigilo para desenho
  static List<Offset> generateSigilPoints(String text, Size canvasSize) {
    final sequence = textToSigilSequence(text);
    final points = <Offset>[];
    
    for (String letter in sequence) {
      final position = getCanvasPosition(letter, canvasSize);
      points.add(position);
    }
    
    return points;
  }
}

// Classe para armazenar posição na roda
class WheelPosition {
  final int ring; // 0 = centro, 1 = interno, 2 = médio, 3 = externo
  final double angle; // Ângulo em graus
  final int index; // Índice dentro do anel
  
  const WheelPosition({
    required this.ring,
    required this.angle,
    required this.index,
  });
}

// Dados do sigilo criado
class SigilData {
  final String originalText;
  final String processedText;
  final List<String> sequence;
  final List<Offset> points;
  final DateTime createdAt;
  final String? intention;
  
  SigilData({
    required this.originalText,
    required this.processedText,
    required this.sequence,
    required this.points,
    required this.createdAt,
    this.intention,
  });
  
  // Cria sigilo a partir do texto
  factory SigilData.fromText(String text, Size canvasSize, {String? intention}) {
    final sequence = SigilWheel.textToSigilSequence(text);
    final processedText = sequence.join('');
    final points = SigilWheel.generateSigilPoints(text, canvasSize);
    
    return SigilData(
      originalText: text,
      processedText: processedText,
      sequence: sequence,
      points: points,
      createdAt: DateTime.now(),
      intention: intention,
    );
  }
}
