import 'package:flutter/material.dart';

import '../../../core/theme/grimoire_colors.dart';

/// A escala tipográfica da jornada do Ciclo, num lugar só.
///
/// A página, a folha de registro e "A Lua e você" repetiam os mesmos seis
/// estilos escritos à mão, cada um com um número de diferença — e a jornada
/// ficava sem coerência de fonte, tamanho e posição. Aqui cada papel tem um
/// nome; quem desenha escolhe o papel, não o número.
///
/// Tudo parte do `textTheme` (a Nunito do app) e das cores do tema, para que
/// uma troca de fonte ou de tema chegue aqui sem ninguém precisar lembrar.
abstract final class MenstrualType {
  /// O título de um card: o mesmo tamanho e peso em todos os cards da página.
  static TextStyle cardTitle(BuildContext context) => _from(
        Theme.of(context).textTheme.titleMedium,
        color: context.gc.lilac,
        fontWeight: FontWeight.bold,
      );

  /// O cabeçalho de uma seção dentro de um card ou da folha.
  static TextStyle sectionHead(BuildContext context) => _from(
        Theme.of(context).textTheme.bodySmall,
        color: context.gc.lilac,
        fontWeight: FontWeight.bold,
      );

  /// O corpo: o que ela lê de verdade.
  static TextStyle body(BuildContext context) => _from(
        Theme.of(context).textTheme.bodyMedium,
        color: context.gc.textPrimary,
        height: 1.5,
      );

  /// O texto discreto: o que acompanha o corpo sem disputar com ele.
  static TextStyle quiet(BuildContext context) => _from(
        Theme.of(context).textTheme.bodySmall,
        color: context.gc.textSecondary,
        height: 1.4,
      );

  /// A legenda: a menor voz da página, para notas de rodapé e bênçãos.
  static TextStyle caption(BuildContext context) => _from(
        Theme.of(context).textTheme.bodySmall,
        color: context.gc.textSecondary,
        fontSize: 11,
        height: 1.4,
      );

  /// A linha acima de um título — a data, a fase — que situa sem se impor.
  static TextStyle eyebrow(BuildContext context) => _from(
        Theme.of(context).textTheme.bodySmall,
        color: context.gc.textSecondary,
      );

  /// O `textTheme` do Flutter é todo nulável por contrato, mas o tema do app
  /// preenche cada papel; o fallback existe só para o tipo fechar.
  static TextStyle _from(
    TextStyle? seed, {
    required Color color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) =>
      (seed ?? const TextStyle()).copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      );
}
