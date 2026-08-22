import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/grimoire_colors.dart';

/// A tipografia das leituras — a mesma em toda tela que mostra texto gerado.
///
/// Existe por causa de um defeito que se repetiu tela a tela: cada uma montava
/// o próprio `MarkdownStyleSheet` do zero, e TUDO o que ela esquecia caía no
/// padrão do flutter_markdown, que é pensado para tema claro. Quando o modelo
/// resolvia destacar uma frase com `> ` — e ele resolve, ninguém precisa
/// pedir —, o destaque saía num retângulo AZUL-CLARO no meio do grimório
/// escuro, com o texto quase apagado dentro.
///
/// A base nasce do tema e veste TODAS as formas que o markdown pode trazer:
/// destaque, listas, títulos, código, régua e tabela. Assim nenhuma leitura
/// depende de a tela ter lembrado de cada uma — o esquecimento volta a ser
/// só um detalhe sem ajuste fino, nunca um bloco ilegível.
///
/// Cada tela ajusta o que é dela por cima, com `copyWith`.
MarkdownStyleSheet readingMarkdownStyle(BuildContext context) {
  final gc = context.gc;
  final lilas = gc.lilac;

  return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
    p: TextStyle(color: gc.softWhite, height: 1.72, fontSize: 16),
    // O negrito é reservado ao que a leitura prova — a posição real do mapa,
    // a data do ciclo — e por isso vem colorido.
    strong: TextStyle(color: lilas, fontWeight: FontWeight.w700),
    em: TextStyle(color: gc.softWhite, fontStyle: FontStyle.italic),
    a: TextStyle(color: lilas, decoration: TextDecoration.underline),
    del: TextStyle(
      color: gc.textSecondary,
      decoration: TextDecoration.lineThrough,
    ),

    // A frase de destaque: o gancho que se lê antes de tudo, num bloco lilás
    // com barra à esquerda.
    blockquote: GoogleFonts.lora(
      color: gc.textPrimary,
      fontSize: 17.5,
      height: 1.5,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
    ),
    blockquotePadding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
    blockquoteDecoration: BoxDecoration(
      color: lilas.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      border: Border(left: BorderSide(color: lilas, width: 3)),
    ),

    listBullet: TextStyle(color: lilas, fontSize: 16, height: 1.72),
    listBulletPadding: const EdgeInsets.only(right: 10),
    listIndent: 18,
    checkbox: TextStyle(color: lilas),

    h1: GoogleFonts.cinzelDecorative(
      color: lilas,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    h2: GoogleFonts.cinzelDecorative(
      color: lilas,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    h3: GoogleFonts.cinzelDecorative(
      color: lilas,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    h4: GoogleFonts.lora(
      color: lilas,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
    h5: GoogleFonts.lora(
      color: lilas,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    h6: GoogleFonts.lora(
      color: lilas,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),

    // Texto gerado quase nunca traz código ou tabela — mas quando traz, o
    // padrão do pacote é cinza-claro sobre fundo claro. Uma vez vestido aqui,
    // nunca mais aparece assim.
    code: TextStyle(
      color: gc.textPrimary,
      backgroundColor: gc.surface,
      fontFamily: 'monospace',
      fontSize: 14,
    ),
    codeblockPadding: const EdgeInsets.all(12),
    codeblockDecoration: BoxDecoration(
      color: gc.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: gc.surfaceBorder),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: gc.surfaceBorder)),
    ),
    tableBorder: TableBorder.all(color: gc.surfaceBorder),
    tableHead: TextStyle(color: lilas, fontWeight: FontWeight.w700),
    tableBody: TextStyle(color: gc.softWhite),
    tableCellsDecoration: BoxDecoration(
      color: gc.surface.withValues(alpha: 0.35),
    ),
  );
}

/// Um trecho de leitura em markdown, já com a tipografia do grimório.
///
/// Use isto no lugar de `MarkdownBody` direto: o que a tela não ajustar sai
/// vestido pela base, e não pelo padrão claro do pacote.
class ReadingMarkdown extends StatelessWidget {
  const ReadingMarkdown(this.data, {super.key, this.refine});

  final String data;

  /// Os ajustes desta leitura sobre a base — densidade, tamanho de título,
  /// o que for próprio da tela.
  final MarkdownStyleSheet Function(MarkdownStyleSheet base)? refine;

  @override
  Widget build(BuildContext context) {
    final base = readingMarkdownStyle(context);
    return MarkdownBody(
      data: data,
      styleSheet: refine == null ? base : refine!(base),
    );
  }
}
