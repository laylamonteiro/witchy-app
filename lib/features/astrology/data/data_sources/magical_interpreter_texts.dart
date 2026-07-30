import '../../../../core/content/content_locale.dart';
import '../models/enums.dart';
import 'magical_interpreter_texts_en.dart';
import 'magical_interpreter_texts_es.dart';
import 'magical_interpreter_texts_pt.dart';

/// Frases-template do `MagicalInterpreter` (perfil mágico do mapa natal).
///
/// O conteúdo por idioma vive em `magical_interpreter_texts_pt/en/es.dart` —
/// as três instâncias DEVEM preencher as mesmas estruturas (mesmas chaves nos
/// mapas, mesmos tamanhos de lista); a paridade é verificada em
/// `test/astrology_interpreters_parity_test.dart`. Nomes de planeta, signo e
/// elemento chegam já localizados via os getters `displayName` dos enums.
class MagicalInterpreterTexts {
  const MagicalInterpreterTexts({
    required this.sunEssence,
    required this.moonIntro,
    required this.moonBySign,
    required this.moonByElement,
    required this.mercuryByElement,
    required this.venus,
    required this.mars,
    required this.house8Intro,
    required this.house8NoPlanets,
    required this.house8WithPlanets,
    required this.house8Moon,
    required this.house8Pluto,
    required this.house12Intro,
    required this.house12NoPlanets,
    required this.house12WithPlanets,
    required this.house12Neptune,
    required this.house12Moon,
    required this.strengthPsychicIntuition,
    required this.strengthSunMoonBalance,
    required this.strengthMagicAffinity,
    required this.strengthSpiritualConnection,
    required this.strengthDominantElement,
    required this.practicesByElement,
    required this.practicesHouse8,
    required this.practicesHouse12,
    required this.toolsByElement,
    required this.sunCrystal,
    required this.moonHerb,
    required this.shadowSunMoon,
    required this.shadowSaturn,
    required this.shadowHouse12,
  });

  /// Essência mágica (Sol) por signo — texto completo.
  final Map<ZodiacSign, String> sunEssence;

  /// Abertura de "Sua Lua em X na Casa N " (termina com espaço).
  final String Function(String signName, int houseNumber) moonIntro;

  /// Complemento da Lua para os signos com texto próprio.
  final Map<ZodiacSign, String> moonBySign;

  /// Complemento genérico da Lua, baseado no elemento do signo.
  final String Function(String elementName) moonByElement;

  /// Estilo de comunicação (Mercúrio) por elemento.
  final Map<Element, String> mercuryByElement;

  /// Amor e beleza (Vênus).
  final String Function(String signName, String elementName) venus;

  /// Energia protetora (Marte).
  final String Function(String signName, String elementName) mars;

  // Casa 8 — magia e ocultismo.
  final String Function(String signName) house8Intro;
  final String house8NoPlanets;
  final String Function(int count, String planetNames) house8WithPlanets;
  final String house8Moon;
  final String house8Pluto;

  // Casa 12 — espiritualidade.
  final String Function(String signName) house12Intro;
  final String house12NoPlanets;
  final String Function(int count, String planetNames) house12WithPlanets;
  final String house12Neptune;
  final String house12Moon;

  // Forças mágicas.
  final String strengthPsychicIntuition;
  final String strengthSunMoonBalance;
  final String strengthMagicAffinity;
  final String strengthSpiritualConnection;
  final String Function(String elementName) strengthDominantElement;

  // Práticas recomendadas.
  final Map<Element, List<String>> practicesByElement;
  final List<String> practicesHouse8;
  final List<String> practicesHouse12;

  // Ferramentas favoráveis.
  final Map<Element, List<String>> toolsByElement;
  final String Function(String signName) sunCrystal;
  final String Function(String signName) moonHerb;

  // Trabalho de sombra.
  final String shadowSunMoon;
  final String shadowSaturn;
  final String shadowHouse12;
}

/// Textos do interpretador mágico no idioma atual (fallback: português).
MagicalInterpreterTexts get magicalInterpreterTexts =>
    ContentLocale.instance.select(
      pt: magicalInterpreterTextsPt,
      en: magicalInterpreterTextsEn,
      es: magicalInterpreterTextsEs,
    );
