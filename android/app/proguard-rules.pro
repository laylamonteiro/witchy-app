# Regras do R8 para o build de release.
#
# O projeto nunca escreveu `minifyEnabled`, e mesmo assim o R8 RODA em todo
# `flutter build apk/appbundle --release`: o plugin Gradle do Flutter liga o
# minify sozinho quando a propriedade `shrink` não existe — veja
# FlutterPluginUtils.shouldShrinkResources (devolve true por padrão) e o bloco
# que faz `isMinifyEnabled = true` em FlutterPlugin. O mesmo bloco adota ESTE
# arquivo automaticamente, só por ele existir: não há nada a declarar no
# build.gradle.
#
# Por que o arquivo nasce junto com o canal de avaliação: uma `keep rule`
# faltando não quebra build nenhum. Ela aparece como ClassNotFound em tempo de
# execução, num artefato assinado — e o único job Android de uma branch roda
# `--debug`, que nunca liga o R8. Ou seja: o erro só apareceria depois do
# merge, no aparelho.

# Play In-App Review. A biblioteca resolve o serviço por reflexão e entrega o
# resultado por listener, então o R8 não enxerga quem chama o quê.
-keep class com.google.android.play.core.review.** { *; }
-keep interface com.google.android.play.core.review.** { *; }

# As Task do Play Services que o fluxo de avaliação devolve.
-keep class com.google.android.gms.tasks.** { *; }
