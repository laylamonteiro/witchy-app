import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/enums.dart';

/// A cor de cada planeta retrógrado, tirada da paleta do tema em uso.
///
/// POR QUE ISTO EXISTE: na lista de retrógrados o glifo astrológico
/// (`Planet.symbol`) é o que separa uma linha da outra, e ele nem sempre
/// desenha — os oito símbolos não existem em toda fonte de sistema, e no
/// aparelho antigo a lista abria com quadradinhos iguais. A cor entra como
/// o segundo canal: mesmo virando quadradinho, a linha de Marte continua
/// vermelha e a de Júpiter dourada.
///
/// POR QUE ESTES SLOTS, E NÃO OUTROS: a paleta tem DEZ cores de frente
/// (lilás, rosa, menta, estrela, ouro, sucesso, alerta, info e os dois
/// níveis de texto) e duas precisam sair porque colapsam dependendo do
/// tema. `starYellow` e `gold` são a MESMA cor no tema claro (ΔE 0), então
/// só uma das duas pode virar planeta. E `lilac`, que é o acento e troca
/// de matiz a cada preset, mede ΔE 4,7 contra `info` no Azul Celeste —
/// perto demais para ser outra linha. (No Esmeralda Jade o lilás vira
/// verde e fica a ΔE 17 de `mint`: ali passaria; é o Azul Celeste sozinho
/// que o desclassifica.)
///
/// Não é a ÚNICA escolha possível — trocar `info` por `lilac` e `gold` por
/// `starYellow` dá exatamente o mesmo resultado —, e sim uma das que
/// chegam ao teto. Medido em test/: nos seis temas as oito ficam distintas
/// entre si (ΔE mínimo 13,4, que é o máximo que oito slots desta paleta
/// alcançam) e bem distantes do cartão (ΔE mínimo 52).
///
/// As escolhas seguem o planeta onde dá: alerta para Marte (o vermelho),
/// ouro para Júpiter (a expansão), o cinza do texto secundário para
/// Saturno (o chumbo), menta para Netuno (a maré) e o tom de maior
/// contraste para Plutão (o subterrâneo — quase preto no tema claro,
/// quase branco nos escuros).
///
/// Os planetas que não retrogradam caem no acento do tema: só chegam aqui
/// por engano de chamada, e o acento é a cor que sempre passa no contraste.
Color retrogradePlanetColor(GrimoireColors gc, Planet planet) =>
    switch (planet) {
      Planet.mercury => gc.info,
      Planet.venus => gc.pink,
      Planet.mars => gc.alert,
      Planet.jupiter => gc.gold,
      Planet.saturn => gc.textSecondary,
      Planet.uranus => gc.success,
      Planet.neptune => gc.mint,
      Planet.pluto => gc.textPrimary,
      _ => gc.lilac,
    };

/// Os oito planetas que a lista de retrógrados sabe desenhar — a mesma
/// chave que `personalizedSuggestionsContent.retrogradeInfo` usa.
const List<Planet> kRetrogradePlanets = [
  Planet.mercury,
  Planet.venus,
  Planet.mars,
  Planet.jupiter,
  Planet.saturn,
  Planet.uranus,
  Planet.neptune,
  Planet.pluto,
];
