import 'package:flutter/material.dart';

import '../../diary/presentation/pages/dream_form_page.dart';
import '../../diary/presentation/pages/free_writing_tab.dart';
import '../../divination/presentation/pages/oracle_cards_page.dart';
import '../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../data/data_sources/blood_lore_content.dart';
import '../domain/menstrual_shortcut.dart';
import 'pages/blood_lore_category_page.dart';

/// As portas que o Ciclo abre — e todas elas já existiam.
///
/// Este arquivo é o ÚNICO lugar do módulo menstrual que sabe navegar para
/// fora dele, e existe para deixar evidente o que a funcionalidade promete:
/// nenhum destino aqui é uma cópia. O Diário é o Diário, o sonho vai para o
/// Diário de Sonhos, a tiragem é a do Oráculo e a intenção vira sigilo no
/// criador que o Grimório já tem. O Ciclo é a lente que sugere o momento; a
/// persistência continua sendo a de cada ferramenta.
///
/// Por isso NÃO há aqui: tarô menstrual, diário menstrual, diário de sonhos
/// menstrual nem sistema paralelo de intenções.
abstract final class MenstrualShortcuts {
  /// Abre o destino de um atalho contextual.
  ///
  /// A rota é empilhada no navegador da aba (sem `rootNavigator`), como o
  /// restante da aba Ciclos: voltar devolve a pessoa à página do Ciclo, com
  /// a barra inferior no lugar.
  static Future<void> open(
    BuildContext context,
    MenstrualShortcut shortcut,
  ) {
    final texts = bloodLoreContent.shortcuts[shortcut];
    return _push(
      context,
      switch (shortcut) {
        // O convite entra como convite, nunca como conteúdo: ele aparece
        // acima do campo e some quando ela começa a escrever. O que for
        // escrito vira uma entrada NORMAL da escrita livre.
        MenstrualShortcut.release ||
        MenstrualShortcut.cultivate =>
          FreeWritingTab(prompt: texts?.prompt),
        MenstrualShortcut.oracle => const OracleCardsPage(),
        MenstrualShortcut.dream => const DreamFormPage(),
        MenstrualShortcut.intention => const SigilStep1IntentionPage(),
        MenstrualShortcut.practices => const BloodLoreCategoryPage(
            category: BloodLoreCategory.practices,
          ),
      },
    );
  }

  /// Abre o destino de um convite de verbete que sai desta área.
  ///
  /// [BloodLoreLink.entry] não passa por aqui: ele é resolvido pela própria
  /// tela do verbete, que já sabe abrir um irmão.
  static Future<void> follow(BuildContext context, BloodLoreLink link) {
    final texts = bloodLoreContent.shortcuts;
    return _push(
      context,
      switch (link) {
        BloodLoreLink.sigils => const SigilStep1IntentionPage(),
        BloodLoreLink.diary => FreeWritingTab(
            prompt: texts[MenstrualShortcut.release]?.prompt,
          ),
        BloodLoreLink.dreams => const DreamFormPage(),
        BloodLoreLink.oracle => const OracleCardsPage(),
        // Um convite para outro verbete nunca chega aqui; se chegasse, a
        // área toda é o destino menos errado.
        BloodLoreLink.entry => const BloodLoreCategoryPage(
            category: BloodLoreCategory.practices,
          ),
      },
    );
  }

  static Future<void> _push(BuildContext context, Widget page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
