import 'dart:math' as math;
import 'package:flutter/material.dart';

class SigilWheel {
  // Distribuição das letras nos 3 anéis da roda
  // Baseado na imagem do livro
  static const Map<String, WheelPosition> letterPositions = {
    // Anel Externo (raio = 1.0)
    'N': WheelPosition(ring: 3, angle: 0, index: 0),
    'Z': WheelPosition(ring: 3, angle: 30, index: 1),
    'Y': WheelPosition(ring: 3, angle: 60, index: 2),
    'X': WheelPosition(ring: 3, angle: 90, index: 3),
    'W': WheelPosition(ring: 3, angle: 120, index: 4),
    'V': WheelPosition(ring: 3, angle: 150, index: 5),
    'U': WheelPosition(ring: 3, angle: 180, index: 6),
    'T': WheelPosition(ring: 3, angle: 210, index: 7),
    'S': WheelPosition(ring: 3, angle: 240, index: 8),
    'R': WheelPosition(ring: 3, angle: 270, index: 9),
    'Q': WheelPosition(ring: 3, angle: 300, index: 10),
    'P': WheelPosition(ring: 3, angle: 330, index: 11),
    
    // Anel Médio (raio = 0.66)
    'O': WheelPosition(ring: 2, angle: 15, index: 0),
    'M': WheelPosition(ring: 2, angle: 60, index: 1),
    'L': WheelPosition(ring: 2, angle: 105, index: 2),
    'K': WheelPosition(ring: 2, angle: 150, index: 3),
    'J': WheelPosition(ring: 2, angle: 195, index: 4),
    'I': WheelPosition(ring: 2, angle: 240, index: 5),
    'H': WheelPosition(ring: 2, angle: 285, index: 6),
    'G': WheelPosition(ring: 2, angle: 330, index: 7),
    
    // Anel Interno (raio = 0.33)
    'F': WheelPosition(ring: 1, angle: 0, index: 0),
    'E': WheelPosition(ring: 1, angle: 72, index: 1),
    'D': WheelPosition(ring: 1, angle: 144, index: 2),
    'C': WheelPosition(ring: 1, angle: 216, index: 3),
    'B': WheelPosition(ring: 1, angle: 288, index: 4),
    
    // Centro (para A - início comum)
    'A': WheelPosition(ring: 0, angle: 0, index: 0),
  };
  
  // Converte texto em sequência para sigilo
  static List<String> textToSigilSequence(String text) {
    // Normaliza: maiúsculas e remove acentos
    String normalized = _normalizeText(text.toUpperCase());
    
    // Remove espaços e caracteres não-alfabéticos
    normalized = normalized.replaceAll(RegExp(r'[^A-Z]'), '');
    
    // Remove vogais repetidas consecutivas (mantém a primeira ocorrência)
    String withoutRepeatedVowels = _removeRepeatedVowels(normalized);
    
    // Remove consoantes duplicadas consecutivas
    String withoutDuplicates = _removeDuplicates(withoutRepeatedVowels);
    
    // Converte em lista de caracteres
    return withoutDuplicates.split('');
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
  static Offset getCanvasPosition(
    String letter,
    Size canvasSize,
  ) {
    final position = letterPositions[letter];
    if (position == null) return Offset(canvasSize.width / 2, canvasSize.height / 2);
    
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final maxRadius = math.min(canvasSize.width, canvasSize.height) * 0.4;
    
    // Calcula o raio baseado no anel
    double radius;
    switch (position.ring) {
      case 0: // Centro
        radius = 0;
        break;
      case 1: // Anel interno
        radius = maxRadius * 0.33;
        break;
      case 2: // Anel médio
        radius = maxRadius * 0.66;
        break;
      case 3: // Anel externo
        radius = maxRadius;
        break;
      default:
        radius = maxRadius;
    }
    
    // Converte ângulo para radianos
    final angleRad = position.angle * (math.pi / 180);
    
    // Calcula posição X,Y
    final x = center.dx + radius * math.cos(angleRad - math.pi / 2);
    final y = center.dy + radius * math.sin(angleRad - math.pi / 2);
    
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
