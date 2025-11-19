import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Modelo para representar um sigilo gerado
class Sigil {
  final String intention;
  final String processedLetters;
  final List<Offset> points;

  Sigil({
    required this.intention,
    required this.processedLetters,
    required this.points,
  });

  /// Processa a intenção para extrair letras únicas
  static String processIntention(String intention) {
    // 1. Remover espaços
    String processed = intention.replaceAll(' ', '');

    // 2. Converter para maiúsculas
    processed = processed.toUpperCase();

    // 3. Remover acentos
    const withAccents = 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const withoutAccents = 'AAAAAEEEEIIIIOOOOOUUUUC';

    for (int i = 0; i < withAccents.length; i++) {
      processed = processed.replaceAll(withAccents[i], withoutAccents[i]);
    }

    // 4. Remover letras repetidas, mantendo apenas a primeira ocorrência
    String uniqueLetters = '';
    for (int i = 0; i < processed.length; i++) {
      if (!uniqueLetters.contains(processed[i])) {
        uniqueLetters += processed[i];
      }
    }

    return uniqueLetters;
  }

  /// Gera pontos para o desenho do sigilo baseado nas letras
  static List<Offset> generatePoints(String letters, double radius) {
    // Alfabeto de 26 letras
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final points = <Offset>[];

    for (int i = 0; i < letters.length; i++) {
      final letter = letters[i];
      final index = alphabet.indexOf(letter);

      if (index >= 0) {
        // Calcular ângulo para esta letra (distribuído ao redor do círculo)
        // Começar do topo (270 graus) e ir no sentido horário
        final angle = (index / 26) * 2 * math.pi - math.pi / 2;

        // Calcular posição x, y no círculo
        final x = radius + radius * math.cos(angle);
        final y = radius + radius * math.sin(angle);

        points.add(Offset(x, y));
      }
    }

    return points;
  }

  /// Cria um sigilo a partir de uma intenção
  factory Sigil.fromIntention(String intention) {
    final processedLetters = processIntention(intention);
    final points = generatePoints(processedLetters, 100.0);

    return Sigil(
      intention: intention,
      processedLetters: processedLetters,
      points: points,
    );
  }
}
