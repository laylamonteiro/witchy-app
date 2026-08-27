import 'package:flutter/widgets.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import 'gender.dart';

/// O tratamento da pessoa, lido da árvore — o caminho normal para as telas.
///
/// Existe porque a escolha vive no `AuthProvider` e quase toda tela precisaria
/// repetir `context.watch<AuthProvider>().currentUser.gender` só para pedir a
/// variante certa de uma frase. Com `watch`, a tela ainda REDESENHA quando a
/// escolha muda em Configurações — que é o que o [TratamentoAtual] (espelho
/// sem contexto, para os títulos de nível) não tem como fazer.
///
/// O `AuthProvider` fica acima do `MaterialApp` no `MultiProvider` do
/// `main.dart`, então isto vale inclusive dentro de diálogos e folhas.
///
/// SÓ DENTRO DE `build`: `watch` fora dele é exceção em tempo de execução.
/// Quem não está num build (tratador assíncrono, getter estático) usa o
/// [TratamentoAtual] — é para isso que ele existe.
extension TratamentoDoContexto on BuildContext {
  Gender get tratamento => watch<AuthProvider>().currentUser.gender;

  /// Escolhe entre as três variantes de uma mesma frase do ARB.
  ///
  /// As três SEMPRE vêm do `AppLocalizations`: conjugar no Dart quebraria os
  /// outros idiomas, que marcam gênero em lugares diferentes (ou em nenhum,
  /// como o inglês).
  String porTratamento({
    required String feminine,
    required String masculine,
    required String neutral,
  }) =>
      GenderText.select(
        preference: tratamento,
        feminine: feminine,
        masculine: masculine,
        neutral: neutral,
      );

  /// O chamamento — "Bruxa" / "Bruxo", e "Bruxa" também no neutro: é a
  /// palavra da casa, e serve de nome para quem ainda não escreveu o seu.
  ///
  /// Para as frases em que o ÚNICO trecho marcado é o vocativo: elas ficam
  /// inteiras numa chave só, com um `{tratamento}` no meio, em vez de
  /// triplicarem um parágrafo por causa de uma palavra.
  String get vocativo => vocativoDe(AppLocalizations.of(this), tratamento);
}

/// O mesmo chamamento para quem NÃO está num `build`: um tratador assíncrono,
/// um getter estático. Ver [TratamentoAtual] para de onde vem a preferência
/// nesses casos.
String vocativoDe(AppLocalizations l10n, Gender tratamento) => GenderText.select(
      preference: tratamento,
      feminine: l10n.witchTreatmentFeminine,
      masculine: l10n.witchTreatmentMasculine,
      neutral: l10n.witchTreatmentNeutral,
    );
