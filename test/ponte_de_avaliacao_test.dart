// A ponte entre o Dart e o Kotlin do card de avaliação.
//
// Nada nesta esteira liga os dois lados: `flutter analyze` não lê `.kt`,
// `check_hardcoded_pt.sh` varre só `lib/`, não há ktlint, e o único job que
// compila Android roda em branch, com `--debug`, e só quando o ÚLTIMO commit do
// push toca `android/`. Um rename do canal feito de um lado só deixaria tudo
// verde — e a avaliação morta em todo aparelho, em silêncio, porque
// `MissingPluginException` vira um desfecho legítimo lá dentro.
//
// Então o acordo vira teste. O padrão é o de `politica_legal_test.dart`, que já
// lê arquivos-fonte com `File(...).readAsStringSync()`.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/reviews/convite_de_avaliacao.dart';

const _caminhoDaActivity =
    'android/app/src/main/kotlin/com/grimoriodebolso/app/MainActivity.kt';

/// A cópia que existia em outro pacote. O manifest resolve `.MainActivity` para
/// `com.grimoriodebolso.app`, então escrever o canal aqui compilava verde e
/// nunca executava. Foi apagada, e este teste é o que impede a armadilha de
/// voltar.
const _caminhoDaCopiaMorta =
    'android/app/src/main/kotlin/com/grimoriodebolso/grimorio_de_bolso';

void main() {
  const loja = AberturaDaLoja();

  test('o canal do Dart é o canal que o Kotlin registra', () {
    final kotlin = File(_caminhoDaActivity).readAsStringSync();
    expect(kotlin, contains("\"${AberturaDaLoja.canalNativo.name}\""),
        reason: 'o nome do canal precisa ser o MESMO dos dois lados');
    expect(kotlin, contains("\"${AberturaDaLoja.metodoPedirAvaliacao}\""),
        reason: 'o nome do método precisa ser o MESMO dos dois lados');
  });

  test('os códigos de desfecho batem com os do Kotlin', () {
    final kotlin = File(_caminhoDaActivity).readAsStringSync();
    // O Dart traduz número em [DesfechoDoCard]; se um lado mudar o número, a
    // tradução passa a mentir sem ninguém reclamar.
    expect(kotlin, contains('const val LANCADO = 0'));
    expect(kotlin, contains('const val ADIAR = -1000'));
    expect(kotlin, contains('const val ERRO_INTERNO = -100'));
  });

  test('há exatamente uma MainActivity, e é a que o manifest resolve', () {
    expect(File(_caminhoDaActivity).existsSync(), isTrue);
    expect(Directory(_caminhoDaCopiaMorta).existsSync(), isFalse,
        reason: 'a cópia em outro pacote compila verde e nunca executa');

    final manifesto =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifesto, contains('android:name=".MainActivity"'));
    expect(File(_caminhoDaActivity).readAsStringSync(),
        contains('package com.grimoriodebolso.app'));
  });

  test('a dependência do card está declarada no Gradle', () {
    final gradle = File('android/app/build.gradle').readAsStringSync();
    expect(gradle, contains('com.google.android.play:review:'),
        reason: 'sem a dependência, o Kotlin não compila');
    expect(gradle, isNot(contains("com.google.android.play:review:+")),
        reason: 'versão flutuante quebra a reprodutibilidade do build');
  });

  test('as regras do R8 para o card existem', () {
    // O R8 roda em TODO build de release (o plugin do Flutter liga o minify
    // sozinho), e o job Android da branch roda `--debug`, que não o liga. Uma
    // keep rule faltando só apareceria depois do merge, no aparelho.
    final regras = File('android/app/proguard-rules.pro').readAsStringSync();
    expect(regras, contains('com.google.android.play.core.review'));
  });

  test('a ficha da loja aponta para o app que o Gradle publica', () {
    final gradle = File('android/app/build.gradle').readAsStringSync();
    expect(gradle, contains('applicationId "${AberturaDaLoja.idDoApp}"'),
        reason: 'a ficha da loja de outro app é um link para o lugar errado');
    expect(loja.ficha.toString(), contains(AberturaDaLoja.idDoApp));
  });
}
