import 'package:flutter/material.dart';
import './sigil_wheel_model.dart';

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

  /// Cria um sigilo a partir de uma intenção
  /// Usa a Roda Alfabética das Bruxas com 3 anéis concêntricos
  factory Sigil.fromIntention(String intention) {
    // Usar a lógica do SigilWheel para processar o texto
    final sequence = SigilWheel.textToSigilSequence(intention);
    final processedLetters = sequence.join('');

    // Gerar pontos usando a Roda de 3 anéis
    // Tamanho do canvas usado no desenho (360x360)
    const canvasSize = Size(360, 360);
    final points = SigilWheel.generateSigilPoints(intention, canvasSize);

    return Sigil(
      intention: intention,
      processedLetters: processedLetters,
      points: points,
    );
  }
}
