# Implementação da Fase: Astrologia + IA + Expansão de Divinação (Local-First)

## 📌 Contexto do Projeto

Você está trabalhando no **Grimório de Bolso**, um app Flutter de bruxaria e espiritualidade para bruxas iniciantes. A **Fase 1 (MVP)** está completa e sem bugs, com todas as funcionalidades básicas implementadas.

**Repositório:** `laylamonteiro/witchy-app`
**Branch atual:** `main`
**Linguagem:** Dart/Flutter 3.x
**Armazenamento:** SQLite local (sem backend ainda)
**Estado:** Provider

**Status atual:**
- ✅ 70 feitiços pré-carregados
- ✅ Enciclopédia completa (cristais, ervas, metais, cores, elementos)
- ✅ Calendário Lunar funcional
- ✅ Diários (Sonhos, Desejos, Gratidão, Afirmações)
- ✅ Sigilos (criação em 3 etapas)
- ✅ Runas básicas (Futhark)
- ✅ Roda do Ano

---

## 🎯 Objetivo da Fase

Adicionar funcionalidades avançadas de astrologia e divinação, mantendo tudo **local-first** (sem backend):

1. **Mapa Astral Completo** - Cálculo preciso baseado em data, hora e local de nascimento
2. **Perfil Mágico Personalizado** - Análise astrológica adaptada para bruxaria
3. **Sugestões Personalizadas** - Rituais/feitiços recomendados baseados no mapa + trânsitos atuais
4. **Clima Mágico Diário** - Previsões astrológicas diárias personalizadas
5. **Assistente de IA** - Geração de feitiços personalizados (com API key opcional do usuário)
6. **Expansão de Divinação** - Novos sistemas além de runas

---

## 🏗️ Stack Tecnológico

### Astrologia
- **sweph** ou **swiss_ephemeris** (cálculos astronômicos precisos)
  - Biblioteca oficial do Swiss Ephemeris
  - Cálculo de posições planetárias, casas, aspectos
  - Offline-first (usa efemérides embarcadas)

- **geocoding** + **geolocator** (obter coordenadas de local de nascimento)
  - Converter cidade → lat/long
  - Obter timezone correto

### IA (Opcional/Configurável)
- **OpenAI API** ou **Gemini API** (usuário fornece própria API key)
- **http** ou **dio** para chamadas HTTP
- Armazenamento local da API key (secure_storage)

### Divinação
- Implementação custom de sistemas divinatórios
- Algoritmos de embaralhamento seguro (crypto)

### Persistência
- **SQLite** (sqflite) - dados do usuário
- **SharedPreferences** - configurações e API keys
- **flutter_secure_storage** - armazenamento seguro de API keys

---

## 📐 Arquitetura da Fase 4

```
lib/
├── core/
│   ├── ai/                          # [NOVO] Assistente IA
│   │   ├── ai_service.dart
│   │   ├── spell_generator.dart
│   │   └── ai_config_provider.dart
│   │
│   └── database/
│       └── database_helper.dart     # [MODIFICAR] adicionar tabelas de astrologia
│
└── features/
    ├── astrology/                   # [NOVO] Módulo de Astrologia
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── birth_chart_model.dart
    │   │   │   ├── planet_position_model.dart
    │   │   │   ├── house_model.dart
    │   │   │   ├── aspect_model.dart
    │   │   │   └── magical_profile_model.dart
    │   │   ├── repositories/
    │   │   │   ├── astrology_repository.dart
    │   │   │   └── ephemeris_repository.dart
    │   │   └── services/
    │   │       ├── chart_calculator.dart
    │   │       ├── transit_calculator.dart
    │   │       └── magical_interpreter.dart
    │   │
    │   └── presentation/
    │       ├── providers/
    │       │   ├── astrology_provider.dart
    │       │   └── daily_weather_provider.dart
    │       ├── pages/
    │       │   ├── birth_chart_input_page.dart
    │       │   ├── birth_chart_view_page.dart
    │       │   ├── magical_profile_page.dart
    │       │   ├── daily_magical_weather_page.dart
    │       │   └── personalized_suggestions_page.dart
    │       └── widgets/
    │           ├── chart_wheel_widget.dart
    │           ├── planet_card_widget.dart
    │           └── aspect_line_widget.dart
    │
    ├── grimoire/
    │   └── presentation/
    │       └── pages/
    │           └── ai_spell_creation_page.dart  # [NOVO]
    │
    ├── runes/                       # [EXPANDIR]
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── rune_spread_model.dart   # [NOVO]
    │   │   └── data_sources/
    │   │       └── rune_spreads_data.dart   # [NOVO]
    │   └── presentation/
    │       └── pages/
    │           ├── rune_reading_page.dart   # [NOVO]
    │           └── rune_spread_page.dart    # [NOVO]
    │
    └── divination/                  # [NOVO] Novos sistemas
        ├── data/
        │   ├── models/
        │   │   ├── pendulum_model.dart
        │   │   └── oracle_card_model.dart
        │   └── data_sources/
        │       └── oracle_cards_data.dart
        └── presentation/
            └── pages/
                ├── pendulum_page.dart
                └── oracle_cards_page.dart
```

---

## 🌟 Tarefa 1: Cálculo do Mapa Astral Completo

### Requisitos

**Input do usuário:**
- Data de nascimento (dia/mês/ano)
- Hora de nascimento (hora:minuto) - crucial para casas
- Local de nascimento (cidade/país) → converter para lat/long

**Cálculos necessários:**
- Posições dos 10 planetas principais:
  - Sol ☉, Lua ☽, Mercúrio ☿, Vênus ♀, Marte ♂
  - Júpiter ♃, Saturno ♄, Urano ♅, Netuno ♆, Plutão ♇
- Nodo Norte e Nodo Sul (Rahu/Ketu)
- Cúspides das 12 casas (sistema Placidus ou Koch)
- Ascendente, Meio do Céu (MC), Descendente, Fundo do Céu (IC)
- Aspectos maiores entre planetas:
  - Conjunção (0°), Oposição (180°), Trígono (120°)
  - Quadratura (90°), Sextil (60°)
  - Orbe: ±8° para aspectos maiores

**Modelo de dados:**
```dart
class BirthChartModel {
  final String userId;
  final DateTime birthDate;
  final TimeOfDay birthTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  final String timezone;

  // Planetas
  final List<PlanetPosition> planets;

  // Casas
  final List<House> houses;

  // Pontos importantes
  final PlanetPosition ascendant;
  final PlanetPosition midheaven;

  // Aspectos
  final List<Aspect> aspects;

  final DateTime calculatedAt;
}

class PlanetPosition {
  final Planet planet;        // enum: sun, moon, mercury, etc.
  final ZodiacSign sign;       // enum: aries, taurus, gemini, etc.
  final int degree;            // 0-29
  final int minute;            // 0-59
  final House house;           // qual casa o planeta está
  final bool isRetrograde;
}

class House {
  final int number;            // 1-12
  final ZodiacSign sign;       // signo na cúspide
  final int degree;
  final String meaning;        // área da vida
}

class Aspect {
  final Planet planet1;
  final Planet planet2;
  final AspectType type;       // conjunction, opposition, trine, etc.
  final double angle;          // graus exatos
  final double orb;            // orbe (diferença do exato)
  final bool isApplying;       // aspecto se aproximando ou se afastando
}
```

### Implementação sugerida

1. **Adicionar dependências ao pubspec.yaml:**
```yaml
dependencies:
  sweph: ^1.0.0  # Swiss Ephemeris
  geocoding: ^3.0.0
  geolocator: ^13.0.0
  timezone: ^0.9.0
```

2. **Criar ChartCalculator:**
```dart
class ChartCalculator {
  // Inicializar Swiss Ephemeris
  Future<void> initialize() async {
    // Carregar efemérides do assets
    await Sweph.init(epheFilesPath: 'assets/ephe');
  }

  // Calcular mapa natal
  Future<BirthChartModel> calculateBirthChart({
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required double latitude,
    required double longitude,
  }) async {
    // 1. Converter data/hora local para Julian Day
    final julianDay = _dateTimeToJulianDay(birthDate, birthTime);

    // 2. Calcular posições planetárias
    final planets = await _calculatePlanets(julianDay);

    // 3. Calcular casas (sistema Placidus)
    final houses = await _calculateHouses(julianDay, latitude, longitude);

    // 4. Calcular aspectos
    final aspects = _calculateAspects(planets);

    return BirthChartModel(...);
  }

  Future<List<PlanetPosition>> _calculatePlanets(double julianDay) async {
    final planets = <PlanetPosition>[];

    // Para cada planeta
    for (final planetId in Planet.values) {
      // Calcular posição usando Swiss Ephemeris
      final position = await Sweph.calc(
        julianDay,
        planetId.swephId,
        SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_SPEED,
      );

      // Converter longitude eclíptica para signo + grau
      final longitude = position[0]; // longitude em graus (0-360)
      final sign = ZodiacSign.fromLongitude(longitude);
      final degree = (longitude % 30).floor();
      final minute = ((longitude % 1) * 60).floor();
      final isRetrograde = position[3] < 0; // velocidade negativa

      planets.add(PlanetPosition(
        planet: planetId,
        sign: sign,
        degree: degree,
        minute: minute,
        isRetrograde: isRetrograde,
      ));
    }

    return planets;
  }

  Future<List<House>> _calculateHouses(
    double julianDay,
    double latitude,
    double longitude,
  ) async {
    // Calcular cúspides das casas (sistema Placidus)
    final houses = await Sweph.houses(
      julianDay,
      latitude,
      longitude,
      'P', // 'P' = Placidus, 'K' = Koch, 'W' = Whole Sign
    );

    final List<House> houseList = [];

    for (int i = 0; i < 12; i++) {
      final cuspLongitude = houses.cusps[i];
      final sign = ZodiacSign.fromLongitude(cuspLongitude);
      final degree = (cuspLongitude % 30).floor();

      houseList.add(House(
        number: i + 1,
        sign: sign,
        degree: degree,
        meaning: _getHouseMeaning(i + 1),
      ));
    }

    return houseList;
  }

  List<Aspect> _calculateAspects(List<PlanetPosition> planets) {
    final aspects = <Aspect>[];

    // Para cada par de planetas
    for (int i = 0; i < planets.length; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        final planet1 = planets[i];
        final planet2 = planets[j];

        // Calcular ângulo entre os planetas
        final angle = _calculateAngleBetween(planet1, planet2);

        // Verificar se forma aspecto
        final aspectType = _findAspect(angle);

        if (aspectType != null) {
          aspects.add(Aspect(
            planet1: planet1.planet,
            planet2: planet2.planet,
            type: aspectType,
            angle: angle,
            orb: _calculateOrb(angle, aspectType),
          ));
        }
      }
    }

    return aspects;
  }

  AspectType? _findAspect(double angle) {
    const aspects = {
      0: AspectType.conjunction,    // Conjunção
      60: AspectType.sextile,        // Sextil
      90: AspectType.square,         // Quadratura
      120: AspectType.trine,         // Trígono
      180: AspectType.opposition,    // Oposição
    };

    for (final entry in aspects.entries) {
      if ((angle - entry.key).abs() <= 8) { // orbe de 8°
        return entry.value;
      }
    }

    return null;
  }
}
```

3. **Criar página de input do mapa natal:**
```dart
class BirthChartInputPage extends StatefulWidget {
  const BirthChartInputPage({super.key});

  @override
  State<BirthChartInputPage> createState() => _BirthChartInputPageState();
}

class _BirthChartInputPageState extends State<BirthChartInputPage> {
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _birthPlace;
  bool _unknownBirthTime = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Mapa Astral')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              child: Column(
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Seu Mapa Astral',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para calcular seu mapa natal preciso, precisamos de sua data, '
                    'hora e local de nascimento. Quanto mais preciso, melhor!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Data de nascimento
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data de Nascimento',
                    style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_birthDate == null
                      ? 'Selecionar data'
                      : DateFormat('dd/MM/yyyy').format(_birthDate!)),
                  ),
                ],
              ),
            ),

            // Hora de nascimento
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hora de Nascimento',
                    style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'A hora exata é importante para calcular o Ascendente e as Casas.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _unknownBirthTime ? null : () => _selectTime(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(_birthTime == null
                      ? 'Selecionar hora'
                      : _birthTime!.format(context)),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _unknownBirthTime,
                    onChanged: (value) {
                      setState(() {
                        _unknownBirthTime = value ?? false;
                        if (_unknownBirthTime) _birthTime = null;
                      });
                    },
                    title: const Text('Não sei a hora exata'),
                  ),
                ],
              ),
            ),

            // Local de nascimento
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Local de Nascimento',
                    style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Ex: São Paulo, Brasil',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _birthPlace = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Botão calcular
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _canCalculate() ? _calculateChart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lilac,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Calcular Mapa Astral ✨',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canCalculate() {
    return _birthDate != null && _birthPlace != null;
  }

  Future<void> _calculateChart() async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Geocodificar local
      final locations = await locationFromAddress(_birthPlace!);
      final location = locations.first;

      // 2. Calcular mapa
      final calculator = ChartCalculator();
      await calculator.initialize();

      final chart = await calculator.calculateBirthChart(
        birthDate: _birthDate!,
        birthTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0), // Meio-dia se desconhecido
        latitude: location.latitude,
        longitude: location.longitude,
      );

      // 3. Salvar no banco
      final provider = context.read<AstrologyProvider>();
      await provider.saveBirthChart(chart);

      // 4. Navegar para visualização
      Navigator.of(context).pop(); // Fechar loading
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BirthChartViewPage(chart: chart),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fechar loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao calcular: $e')),
      );
    }
  }
}
```

4. **Criar visualização do mapa astral:**
   - Widget de roda astrológica (chart wheel)
   - Lista de posições planetárias
   - Lista de aspectos
   - Interpretações básicas

---

## 🔮 Tarefa 2: Perfil Mágico Personalizado

### Requisitos

**Interpretação astrológica adaptada para bruxaria:**

Analisar o mapa e gerar um perfil mágico incluindo:

**1. Elemento Dominante:**
- Contar planetas por elemento (Fogo, Terra, Ar, Água)
- Elemento mais presente define energia principal
- Fogo: Ação, paixão, transformação
- Terra: Manifestação, aterramento, prosperidade
- Ar: Comunicação, intelecto, adivinhação
- Água: Intuição, emoção, magia lunar

**2. Modalidade Dominante:**
- Cardinal (iniciação), Fixo (estabilidade), Mutável (adaptação)
- Define como a pessoa pratica magia

**3. Planetas Pessoais (Sol, Lua, Mercúrio, Vênus, Marte):**
- **Sol**: Essência mágica, propósito espiritual
- **Lua**: Intuição, conexão com ciclos, magia emocional
- **Mercúrio**: Comunicação com espíritos, feitiços, runas
- **Vênus**: Magia de amor, beleza, atração
- **Marte**: Proteção, banimento, coragem

**4. Casa 8 (magia e ocultismo):**
- Signo na cúspide
- Planetas na casa 8
- Afinidade natural com magia

**5. Casa 12 (espiritualidade e inconsciente):**
- Conexão com o divino
- Sonhos proféticos
- Mediunidade

**6. Aspectos importantes:**
- Sol-Lua (integração masculino/feminino)
- Lua-Netuno (intuição psíquica)
- Mercúrio-Netuno (canalização)

**Modelo de dados:**
```dart
class MagicalProfile {
  final String userId;
  final BirthChartModel birthChart;

  // Elementos
  final Element dominantElement;
  final Map<Element, int> elementDistribution;

  // Modalidades
  final Modality dominantModality;

  // Interpretações
  final String magicalEssence;       // Baseado no Sol
  final String intuitiveGifts;       // Baseado na Lua
  final String communicationStyle;   // Baseado em Mercúrio
  final String loveAndBeauty;        // Baseado em Vênus
  final String protectiveEnergy;     // Baseado em Marte

  // Casas especiais
  final String houseOfMagic;         // Casa 8
  final String houseOfSpirit;        // Casa 12

  // Afinidades
  final List<String> magicalStrengths;
  final List<String> recommendedPractices;
  final List<String> favorableTools;    // cristais, ervas, cores

  // Desafios
  final List<String> shadowWork;
}
```

### Implementação sugerida

```dart
class MagicalInterpreter {
  MagicalProfile interpretChart(BirthChartModel chart) {
    // 1. Analisar elementos
    final elementDist = _analyzeElements(chart.planets);
    final dominantElement = _getDominantElement(elementDist);

    // 2. Analisar modalidades
    final modalityDist = _analyzeModalities(chart.planets);
    final dominantModality = _getDominantModality(modalityDist);

    // 3. Interpretar planetas pessoais
    final sun = chart.planets.firstWhere((p) => p.planet == Planet.sun);
    final moon = chart.planets.firstWhere((p) => p.planet == Planet.moon);
    final mercury = chart.planets.firstWhere((p) => p.planet == Planet.mercury);

    return MagicalProfile(
      userId: chart.userId,
      birthChart: chart,
      dominantElement: dominantElement,
      elementDistribution: elementDist,
      dominantModality: dominantModality,
      magicalEssence: _interpretSun(sun),
      intuitiveGifts: _interpretMoon(moon),
      communicationStyle: _interpretMercury(mercury),
      magicalStrengths: _calculateStrengths(chart),
      recommendedPractices: _recommendPractices(chart),
      favorableTools: _recommendTools(chart),
      shadowWork: _identifyShadowWork(chart),
    );
  }

  String _interpretSun(PlanetPosition sun) {
    // Interpretação do Sol por signo
    switch (sun.sign) {
      case ZodiacSign.aries:
        return 'Sua essência mágica é de pioneirismo e coragem. '
               'Você é uma bruxa guerreira, que age com rapidez e decisão. '
               'Seus feitiços mais poderosos envolvem iniciar novos ciclos e quebrar barreiras.';

      case ZodiacSign.taurus:
        return 'Sua essência mágica está enraizada na terra e na manifestação. '
               'Você é uma bruxa que traz o mundo espiritual para o físico. '
               'Seus feitiços mais poderosos envolvem prosperidade, sensualidade e beleza.';

      case ZodiacSign.cancer:
        return 'Sua essência mágica flui com as marés lunares. '
               'Você é uma bruxa intuitiva, profundamente conectada às emoções. '
               'Seus feitiços mais poderosos envolvem proteção do lar, cura emocional e magia lunar.';

      // ... continuar para todos os signos
    }
  }

  List<String> _recommendPractices(BirthChartModel chart) {
    final practices = <String>[];

    // Baseado no elemento dominante
    switch (_getDominantElement(_analyzeElements(chart.planets))) {
      case Element.fire:
        practices.addAll([
          'Magia de velas',
          'Rituais sob o sol',
          'Trabalho com fogo sagrado',
          'Feitiços de ação rápida',
        ]);
        break;

      case Element.earth:
        practices.addAll([
          'Bruxaria verde (ervas e plantas)',
          'Magia de cristais',
          'Rituais de manifestação',
          'Trabalho com altar',
        ]);
        break;

      case Element.air:
        practices.addAll([
          'Magia de palavras e encantamentos',
          'Leitura de runas',
          'Trabalho com incensos',
          'Comunicação com espíritos',
        ]);
        break;

      case Element.water:
        practices.addAll([
          'Magia lunar',
          'Banhos rituais',
          'Leitura de tarô',
          'Trabalho com sonhos',
        ]);
        break;
    }

    // Baseado em planetas em casas específicas
    final house8Planet = _getPlanetsInHouse(chart, 8);
    if (house8Planet.isNotEmpty) {
      practices.add('Magia sexual e transformação profunda');
      practices.add('Trabalho com sombras');
    }

    return practices;
  }
}
```

---

## 📅 Tarefa 3: Sugestões Personalizadas Baseadas em Trânsitos

### Requisitos

**Sistema de recomendações dinâmicas:**

Analisar trânsitos planetários atuais + mapa natal → sugerir rituais/feitiços

**Trânsitos importantes a monitorar:**
- Mercúrio Retrógrado (3x por ano)
- Lua Nova e Lua Cheia (mensal)
- Eclipses (solar/lunar)
- Retrogradações de planetas externos
- Trânsitos sobre planetas natais
- Trânsitos sobre Ascendente/Meio do Céu

**Tipos de sugestões:**
```dart
class PersonalizedSuggestion {
  final String title;
  final String description;
  final SuggestionType type;        // ritual, spell, bath, meditation
  final AstrologicalReason reason;  // por que está sendo sugerido
  final List<String> ingredients;
  final List<String> steps;
  final DateTime validFrom;
  final DateTime validUntil;
  final Priority priority;          // high, medium, low

  // Link para feitiço existente (se houver)
  final String? relatedSpellId;
}

enum SuggestionType {
  protection,     // durante Mercúrio retrógrado
  manifestation,  // durante Lua Nova
  release,        // durante Lua Cheia
  grounding,      // durante planetas retrógrados
  communication,  // quando Mercúrio está favorável
  love,           // quando Vênus está favorável
}
```

### Implementação sugerida

```dart
class TransitCalculator {
  List<PersonalizedSuggestion> generateSuggestions(
    BirthChartModel natalChart,
    DateTime date,
  ) {
    final suggestions = <PersonalizedSuggestion>[];

    // 1. Verificar Mercúrio Retrógrado
    if (await _isMercuryRetrograde(date)) {
      suggestions.add(PersonalizedSuggestion(
        title: '🔄 Mercúrio Retrógrado está ativo',
        description: 'Período ideal para revisão, não para início de novos projetos. '
                    'Foque em proteção e clareza na comunicação.',
        type: SuggestionType.protection,
        reason: AstrologicalReason(
          transit: 'Mercúrio Retrógrado',
          explanation: 'Durante Mercúrio retrógrado, a comunicação pode falhar '
                      'e equipamentos eletrônicos apresentam problemas.',
        ),
        ingredients: ['Alecrim', 'Quartzo transparente', 'Sal grosso'],
        steps: [
          'Acenda uma vela azul',
          'Segure o quartzo e visualize proteção',
          'Faça o Banho de Proteção (do grimório)',
        ],
        validFrom: date,
        validUntil: date.add(Duration(days: 21)), // ~3 semanas
        priority: Priority.high,
        relatedSpellId: 'protection_bath_001', // Link para feitiço existente
      ));
    }

    // 2. Verificar fase lunar
    final moonPhase = await _getCurrentMoonPhase(date);
    if (moonPhase == MoonPhase.newMoon) {
      // Lua Nova: manifestação
      suggestions.add(_suggestNewMoonRitual(natalChart, date));
    } else if (moonPhase == MoonPhase.fullMoon) {
      // Lua Cheia: liberação
      suggestions.add(_suggestFullMoonRitual(natalChart, date));
    }

    // 3. Verificar trânsitos sobre planetas natais
    final transits = await _calculateTransits(natalChart, date);

    for (final transit in transits) {
      if (transit.isSignificant) {
        suggestions.add(_interpretTransit(transit, natalChart));
      }
    }

    // 4. Sugestões baseadas no elemento dominante
    suggestions.addAll(_suggestByElement(natalChart, date));

    return suggestions..sort((a, b) =>
      b.priority.value.compareTo(a.priority.value));
  }

  PersonalizedSuggestion _suggestNewMoonRitual(
    BirthChartModel chart,
    DateTime date,
  ) {
    // Verificar qual signo a Lua Nova está acontecendo
    final newMoonSign = _getZodiacSignAtDate(date);

    return PersonalizedSuggestion(
      title: '🌑 Lua Nova em ${newMoonSign.displayName}',
      description: _getNewMoonMessage(newMoonSign),
      type: SuggestionType.manifestation,
      reason: AstrologicalReason(
        transit: 'Lua Nova em ${newMoonSign.displayName}',
        explanation: 'Lua Nova é o momento perfeito para plantar sementes '
                    'de intenções e manifestar novos começos.',
      ),
      ingredients: _getNewMoonIngredients(newMoonSign),
      steps: [
        'Escreva suas intenções para este ciclo lunar',
        'Acenda uma vela branca',
        'Leia suas intenções em voz alta',
        'Queime o papel ou guarde-o em local especial',
        'Agradeça à Lua Nova',
      ],
      validFrom: date,
      validUntil: date.add(Duration(days: 3)),
      priority: Priority.high,
    );
  }
}
```

**Página de sugestões:**
```dart
class PersonalizedSuggestionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AstrologyProvider>(
      builder: (context, provider, _) {
        final suggestions = provider.currentSuggestions;

        return Scaffold(
          appBar: AppBar(title: const Text('Sugestões Para Você')),
          body: ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return SuggestionCard(suggestion: suggestion);
            },
          ),
        );
      },
    );
  }
}
```

---

## 🌤️ Tarefa 4: Clima Mágico Diário

### Requisitos

**Previsão astrológica diária personalizada** combinando:
- Fase lunar do dia
- Aspectos planetários do dia
- Trânsitos sobre mapa natal
- Recomendações práticas

**Estrutura:**
```dart
class DailyMagicalWeather {
  final DateTime date;
  final String userId;

  // Resumo
  final String summary;              // "Dia favorável para comunicação e estudos"
  final EnergyLevel energyLevel;     // high, medium, low
  final List<String> favorableFor;   // ["comunicação", "estudos", "criatividade"]
  final List<String> challengesIn;   // ["paciência", "organização"]

  // Astrologia do dia
  final MoonPhase moonPhase;
  final ZodiacSign moonSign;
  final List<Aspect> dailyAspects;

  // Recomendações
  final String recommendedColor;
  final List<String> recommendedCrystals;
  final List<String> recommendedHerbs;
  final String ritualSuggestion;

  // Horários favoráveis
  final List<TimeRange> favorableHours;

  // Mensagem personalizada
  final String personalMessage;      // Baseada no mapa natal
}
```

### Implementação sugerida

```dart
class DailyWeatherProvider extends ChangeNotifier {
  DailyMagicalWeather? _today;

  Future<void> calculateDailyWeather(
    BirthChartModel natalChart,
    DateTime date,
  ) async {
    // 1. Calcular posições planetárias do dia
    final dailyPlanets = await _calculateDailyPlanets(date);

    // 2. Analisar aspectos do dia
    final aspects = _calculateDailyAspects(dailyPlanets);

    // 3. Verificar Lua
    final moonPhase = await _getCurrentMoonPhase(date);
    final moonSign = dailyPlanets.firstWhere((p) => p.planet == Planet.moon).sign;

    // 4. Gerar interpretação
    final interpretation = _interpretDaily(
      aspects: aspects,
      moonPhase: moonPhase,
      moonSign: moonSign,
      natalChart: natalChart,
    );

    _today = interpretation;
    notifyListeners();
  }

  DailyMagicalWeather _interpretDaily({
    required List<Aspect> aspects,
    required MoonPhase moonPhase,
    required ZodiacSign moonSign,
    required BirthChartModel natalChart,
  }) {
    final favorableFor = <String>[];
    final challengesIn = <String>[];
    var energyLevel = EnergyLevel.medium;

    // Analisar aspectos
    for (final aspect in aspects) {
      if (aspect.type == AspectType.trine || aspect.type == AspectType.sextile) {
        // Aspectos harmoniosos
        favorableFor.add(_getAspectMeaning(aspect));
        energyLevel = EnergyLevel.high;
      } else if (aspect.type == AspectType.square || aspect.type == AspectType.opposition) {
        // Aspectos desafiadores
        challengesIn.add(_getAspectChallenge(aspect));
      }
    }

    // Analisar Lua
    final moonElement = moonSign.element;
    favorableFor.addAll(_getMoonRecommendations(moonElement));

    // Sugerir cristais baseado no dia
    final crystals = _suggestCrystals(aspects, moonSign);

    return DailyMagicalWeather(
      date: DateTime.now(),
      userId: natalChart.userId,
      summary: _generateSummary(favorableFor, challengesIn),
      energyLevel: energyLevel,
      favorableFor: favorableFor,
      challengesIn: challengesIn,
      moonPhase: moonPhase,
      moonSign: moonSign,
      dailyAspects: aspects,
      recommendedColor: _suggestColor(moonSign),
      recommendedCrystals: crystals,
      recommendedHerbs: _suggestHerbs(moonSign),
      ritualSuggestion: _suggestRitual(aspects, moonPhase),
      favorableHours: _calculateFavorableHours(aspects),
      personalMessage: _generatePersonalMessage(natalChart, aspects),
    );
  }
}
```

**UI do Clima Mágico:**
```dart
class DailyMagicalWeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DailyWeatherProvider>(
      builder: (context, provider, _) {
        final weather = provider.todayWeather;

        if (weather == null) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header com data e energia
              _buildHeader(weather),

              // Resumo do dia
              _buildSummaryCard(weather),

              // Lua do dia
              _buildMoonCard(weather),

              // Aspectos planetários
              _buildAspectsCard(weather),

              // Recomendações
              _buildRecommendationsCard(weather),

              // Horários favoráveis
              _buildFavorableHoursCard(weather),

              // Mensagem personalizada
              _buildPersonalMessageCard(weather),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🤖 Tarefa 5: Assistente de IA para Criação de Feitiços (Local-First)

### Requisitos

**Implementação sem backend** - usuário fornece própria API key:

1. Usuário configura API key do OpenAI ou Gemini nas configurações
2. API key armazenada localmente de forma segura
3. Chamadas HTTP diretas para API de IA
4. Limite de uso controlado localmente (contador)
5. Sugestões offline baseadas em templates (sem IA)

### Implementação sugerida

```dart
class AIService {
  static const _keyStorageKey = 'openai_api_key';
  static const _providerKey = 'ai_provider';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final Dio _dio = Dio();

  // Salvar API key
  Future<void> saveApiKey(String apiKey, AIProvider provider) async {
    await _secureStorage.write(key: _keyStorageKey, value: apiKey);
    await _secureStorage.write(key: _providerKey, value: provider.name);
  }

  // Verificar se tem API key
  Future<bool> hasApiKey() async {
    final key = await _secureStorage.read(key: _keyStorageKey);
    return key != null && key.isNotEmpty;
  }

  // Gerar feitiço com IA
  Future<SpellModel?> generateSpell(String userIntention) async {
    final apiKey = await _secureStorage.read(key: _keyStorageKey);
    final provider = await _secureStorage.read(key: _providerKey);

    if (apiKey == null) {
      throw Exception('API key não configurada');
    }

    if (provider == 'openai') {
      return _generateWithOpenAI(apiKey, userIntention);
    } else {
      return _generateWithGemini(apiKey, userIntention);
    }
  }

  Future<SpellModel?> _generateWithOpenAI(
    String apiKey,
    String intention,
  ) async {
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': _buildSystemPrompt(),
          },
          {
            'role': 'user',
            'content': intention,
          },
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.8,
      },
    );

    final content = response.data['choices'][0]['message']['content'];
    final spellData = jsonDecode(content);

    return SpellModel(
      id: Uuid().v4(),
      name: spellData['name'],
      purpose: spellData['purpose'],
      type: _parseSpellType(spellData['type']),
      category: _parseSpellCategory(spellData['category']),
      moonPhase: _parseMoonPhase(spellData['moonPhase']),
      ingredients: List<String>.from(spellData['ingredients']),
      steps: spellData['steps'],
      duration: spellData['duration'] ?? 1,
      observations: spellData['observations'],
      isPreloaded: false,
      userId: 'current_user', // Pegar do auth quando tiver
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String _buildSystemPrompt() {
    return '''Você é um assistente especializado em bruxaria moderna e práticas esotéricas.

Crie um feitiço baseado na intenção do usuário.

IMPORTANTE: Retorne APENAS um objeto JSON válido, sem markdown ou explicações adicionais.

Formato do JSON:
{
  "name": "Nome do feitiço",
  "purpose": "Propósito específico",
  "type": "attraction" ou "banishment",
  "category": "love/protection/prosperity/healing/cleansing/luck/creativity/communication/dreams/divination/energy/home/wisdom/study/courage/friendship/work/banishing",
  "moonPhase": "newMoon/waxingCrescent/firstQuarter/waxingGibbous/fullMoon/waningGibbous/lastQuarter/waningCrescent",
  "ingredients": ["item 1", "item 2", "item 3"],
  "steps": "Passo 1\nPasso 2\nPasso 3\n...",
  "duration": 1,
  "observations": "Observações e dicas importantes"
}

Diretrizes:
- Use APENAS ingredientes acessíveis e seguros
- Ingredientes comuns: velas (cores variadas), ervas (alecrim, lavanda, manjericão, canela), cristais (quartzo, ametista), sal, água
- NUNCA sugira ingredientes perigosos ou difíceis de encontrar
- Inclua avisos de segurança se necessário nas observações
- Seja específico nos passos (enumere de 1 a X)
- Recomende fase lunar apropriada
- Tom: acolhedor, místico mas prático
- Feitiços devem ser éticos (não manipulação, não prejudicar terceiros)
- Se for feitiço de amor, SEMPRE adicionar "com respeito ao livre arbítrio"''';
  }
}
```

**Página de configuração de IA:**
```dart
class AIConfigPage extends StatefulWidget {
  @override
  State<AIConfigPage> createState() => _AIConfigPageState();
}

class _AIConfigPageState extends State<AIConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  AIProvider _selectedProvider = AIProvider.openai;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final aiService = context.read<AIService>();
    final hasKey = await aiService.hasApiKey();
    setState(() {
      _hasApiKey = hasKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Assistente IA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MagicalCard(
                child: Column(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Assistente de IA',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure sua própria API key para usar o assistente de IA '
                      'na criação de feitiços personalizados.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              if (_hasApiKey)
                MagicalCard(
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('API key configurada ✅'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Remover API key?'),
                              content: const Text('Você precisará configurar novamente para usar o assistente de IA.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Remover'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await context.read<AIService>().removeApiKey();
                            setState(() {
                              _hasApiKey = false;
                            });
                          }
                        },
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                ),

              // Provedor
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Provedor de IA',
                      style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),

                    RadioListTile<AIProvider>(
                      value: AIProvider.openai,
                      groupValue: _selectedProvider,
                      onChanged: (value) {
                        setState(() {
                          _selectedProvider = value!;
                        });
                      },
                      title: const Text('OpenAI (GPT-4)'),
                      subtitle: const Text('Mais preciso, ~\$0.0003 por feitiço'),
                    ),

                    RadioListTile<AIProvider>(
                      value: AIProvider.gemini,
                      groupValue: _selectedProvider,
                      onChanged: (value) {
                        setState(() {
                          _selectedProvider = value!;
                        });
                      },
                      title: const Text('Google Gemini'),
                      subtitle: const Text('Mais econômico, gratuito até certo limite'),
                    ),
                  ],
                ),
              ),

              // API Key
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('API Key',
                      style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      _selectedProvider == AIProvider.openai
                        ? 'Obtenha sua API key em: platform.openai.com'
                        : 'Obtenha sua API key em: makersuite.google.com/app/apikey',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(
                        hintText: _selectedProvider == AIProvider.openai
                          ? 'sk-...'
                          : 'AI...',
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () => _showApiKeyHelp(),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a API key';
                        }
                        if (_selectedProvider == AIProvider.openai &&
                            !value.startsWith('sk-')) {
                          return 'API key da OpenAI deve começar com "sk-"';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveApiKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar Configuração'),
              ),

              const SizedBox(height: 16),

              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Text('Informações importantes',
                          style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Sua API key é armazenada apenas localmente no seu dispositivo\n'
                      '• Você será cobrado diretamente pelo provedor (OpenAI/Google)\n'
                      '• Estimativa de custo: ~\$0.0003 por feitiço gerado (OpenAI)\n'
                      '• Gemini oferece quota gratuita generosa\n'
                      '• Você pode remover a API key a qualquer momento',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveApiKey() async {
    if (_formKey.currentState!.validate()) {
      try {
        final aiService = context.read<AIService>();
        await aiService.saveApiKey(
          _apiKeyController.text.trim(),
          _selectedProvider,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key salva com sucesso! ✨'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    }
  }
}
```

**Página de criação com IA:**
```dart
class AISpellCreationPage extends StatefulWidget {
  @override
  State<AISpellCreationPage> createState() => _AISpellCreationPageState();
}

class _AISpellCreationPageState extends State<AISpellCreationPage> {
  final _intentionController = TextEditingController();
  SpellModel? _generatedSpell;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Feitiço com IA')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Descreva sua Intenção',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conte ao assistente de IA o que você deseja manifestar. '
                    'Quanto mais detalhes, melhor!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            MagicalCard(
              child: TextField(
                controller: _intentionController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Quero atrair prosperidade financeira para '
                           'pagar minhas contas e ter mais tranquilidade',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ),

            if (_generatedSpell == null)
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateSpell,
                icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Gerando...' : 'Gerar Feitiço ✨'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),

            if (_generatedSpell != null) ...[
              const SizedBox(height: 24),
              SpellDetailCard(spell: _generatedSpell!),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _generatedSpell = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Gerar Outro'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveSpell(),
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateSpell() async {
    if (_intentionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descreva sua intenção primeiro')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final aiService = context.read<AIService>();

      // Verificar se tem API key
      final hasKey = await aiService.hasApiKey();
      if (!hasKey) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AIConfigPage()),
        );
        return;
      }

      final spell = await aiService.generateSpell(
        _intentionController.text.trim(),
      );

      setState(() {
        _generatedSpell = spell;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar: $e'),
          backgroundColor: AppColors.alert,
        ),
      );
    }
  }

  Future<void> _saveSpell() async {
    final provider = context.read<SpellProvider>();
    await provider.addSpell(_generatedSpell!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feitiço salvo no seu grimório! ✨'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }
}
```

---

## 🔮 Tarefa 6: Expansão de Runas e Sistemas de Divinação

### Requisitos

**Expandir runas existentes:**
- ✅ Já temos: Lista básica de runas Futhark
- ➕ **ADICIONAR:**
  - Sistema de tiragem/leitura de runas
  - Spreads (layouts): 1 runa, 3 runas, cruz nórdica
  - Interpretação combinada de runas
  - Histórico de leituras

**Adicionar novos sistemas:**

1. **Pêndulo:**
   - Simulação de pêndulo interativo
   - Perguntas sim/não
   - Calibração do pêndulo
   - Histórico de consultas

2. **Oracle Cards (Cartas do Oráculo):**
   - Deck próprio com temática de bruxaria
   - 44 cartas com mensagens inspiradoras
   - Tiragem diária (1 carta)
   - Spread de 3 cartas (passado/presente/futuro)

### Implementação sugerida - Runas

```dart
// Modelo de tiragem
class RuneReading {
  final String id;
  final DateTime date;
  final String question;
  final RuneSpread spread;
  final List<RunePosition> positions;
  final String interpretation;
}

class RunePosition {
  final int position;       // 1, 2, 3...
  final RuneModel rune;
  final bool isReversed;
  final String positionMeaning;  // Ex: "Passado", "Presente", "Futuro"
}

enum RuneSpread {
  single,          // 1 runa
  threeCast,       // 3 runas (passado/presente/futuro)
  nordicCross,     // 5 runas (cruz nórdica)
  nineWorlds,      // 9 runas (completo)
}

// Página de leitura
class RuneReadingPage extends StatefulWidget {
  @override
  State<RuneReadingPage> createState() => _RuneReadingPageState();
}

class _RuneReadingPageState extends State<RuneReadingPage>
    with SingleTickerProviderStateMixin {

  RuneSpread _selectedSpread = RuneSpread.single;
  String _question = '';
  List<RunePosition>? _drawnRunes;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _drawRunes() async {
    // 1. Embaralhar runas
    final allRunes = List<RuneModel>.from(runesData)..shuffle();

    // 2. Tirar número de runas baseado no spread
    final count = _getRuneCount(_selectedSpread);
    final drawn = <RunePosition>[];

    for (int i = 0; i < count; i++) {
      final rune = allRunes[i];
      final isReversed = Random().nextBool(); // 50% chance de invertida

      drawn.add(RunePosition(
        position: i + 1,
        rune: rune,
        isReversed: isReversed,
        positionMeaning: _getPositionMeaning(_selectedSpread, i),
      ));
    }

    setState(() {
      _drawnRunes = drawn;
    });

    _animController.forward();

    // Salvar leitura
    await _saveReading(drawn);
  }

  String _getPositionMeaning(RuneSpread spread, int position) {
    switch (spread) {
      case RuneSpread.single:
        return 'Mensagem';
      case RuneSpread.threeCast:
        return ['Passado', 'Presente', 'Futuro'][position];
      case RuneSpread.nordicCross:
        return ['Situação', 'Desafio', 'Passado', 'Futuro', 'Resultado'][position];
      case RuneSpread.nineWorlds:
        return [
          'Eu Interior', 'Mente', 'Espírito',
          'Recursos', 'Obstáculos', 'Oportunidades',
          'Passado', 'Presente', 'Futuro'
        ][position];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leitura de Runas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Escolha do spread
            if (_drawnRunes == null) ...[
              MagicalCard(
                child: Column(
                  children: [
                    const Text('ᚱᚢᚾᚨ', style: TextStyle(fontSize: 48)),
                    Text('Escolha um Layout',
                      style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),

              _buildSpreadOption(
                RuneSpread.single,
                'Runa Única',
                'Mensagem direta e rápida',
                Icons.crop_square,
              ),

              _buildSpreadOption(
                RuneSpread.threeCast,
                'Três Runas',
                'Passado, Presente e Futuro',
                Icons.view_column,
              ),

              _buildSpreadOption(
                RuneSpread.nordicCross,
                'Cruz Nórdica',
                'Análise completa da situação',
                Icons.add,
              ),

              // Campo de pergunta
              MagicalCard(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Sua Pergunta (opcional)',
                    hintText: 'O que as runas devem revelar?',
                  ),
                  maxLines: 2,
                  onChanged: (value) => _question = value,
                ),
              ),

              ElevatedButton.icon(
                onPressed: _drawRunes,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Tirar Runas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],

            // Resultado
            if (_drawnRunes != null) ...[
              _buildRuneSpreadResult(_drawnRunes!),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _drawnRunes = null;
                    _animController.reset();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Nova Leitura'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Implementação sugerida - Pêndulo

```dart
class PendulumPage extends StatefulWidget {
  @override
  State<PendulumPage> createState() => _PendulumPageState();
}

class _PendulumPageState extends State<PendulumPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _swingController;
  PendulumAnswer? _answer;
  String _question = '';
  bool _isSwinging = false;

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _swingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _showAnswer();
      }
    });
  }

  Future<void> _askPendulum() async {
    if (_question.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça uma pergunta primeiro')),
      );
      return;
    }

    setState(() {
      _isSwinging = true;
      _answer = null;
    });

    _swingController.repeat(reverse: true);

    // Esperar 3 segundos
    await Future.delayed(const Duration(seconds: 3));

    _swingController.stop();
  }

  void _showAnswer() {
    // Gerar resposta aleatória
    final answers = [
      PendulumAnswer.yes,
      PendulumAnswer.no,
      PendulumAnswer.maybe,
      PendulumAnswer.unclear,
    ];

    setState(() {
      _answer = answers[Random().nextInt(answers.length)];
      _isSwinging = false;
    });

    // Salvar histórico
    _saveConsultation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pêndulo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Text('⟟', style: TextStyle(fontSize: 48)),
                  Text('Consultar o Pêndulo',
                    style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Faça perguntas de sim ou não. '
                    'Concentre-se e confie na resposta.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Visualização do pêndulo
            SizedBox(
              height: 300,
              child: AnimatedBuilder(
                animation: _swingController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: PendulumPainter(
                      swingAngle: _isSwinging
                        ? _swingController.value * 0.5 - 0.25
                        : 0,
                      answer: _answer,
                    ),
                    child: Container(),
                  );
                },
              ),
            ),

            // Campo de pergunta
            MagicalCard(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Sua Pergunta',
                  hintText: 'Ex: Devo aceitar aquele emprego?',
                ),
                maxLines: 2,
                onChanged: (value) => _question = value,
              ),
            ),

            if (_answer == null)
              ElevatedButton.icon(
                onPressed: _isSwinging ? null : _askPendulum,
                icon: _isSwinging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.help),
                label: Text(_isSwinging ? 'Consultando...' : 'Perguntar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),

            if (_answer != null) ...[
              MagicalCard(
                child: Column(
                  children: [
                    Icon(
                      _answer!.icon,
                      size: 64,
                      color: _answer!.color,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _answer!.displayName,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _answer!.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _answer = null;
                    _question = '';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Nova Consulta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum PendulumAnswer {
  yes,
  no,
  maybe,
  unclear;

  String get displayName {
    switch (this) {
      case yes: return 'SIM';
      case no: return 'NÃO';
      case maybe: return 'TALVEZ';
      case unclear: return 'INCERTO';
    }
  }

  String get message {
    switch (this) {
      case yes: return 'A energia indica uma resposta positiva';
      case no: return 'A energia indica uma resposta negativa';
      case maybe: return 'A resposta não é clara. Reformule sua pergunta.';
      case unclear: return 'A energia está confusa. Tente mais tarde.';
    }
  }

  IconData get icon {
    switch (this) {
      case yes: return Icons.check_circle;
      case no: return Icons.cancel;
      case maybe: return Icons.help;
      case unclear: return Icons.blur_on;
    }
  }

  Color get color {
    switch (this) {
      case yes: return AppColors.success;
      case no: return AppColors.alert;
      case maybe: return AppColors.starYellow;
      case unclear: return AppColors.lilac;
    }
  }
}
```

---

## 📝 Checklist de Implementação

### Astrologia
- [ ] Adicionar dependências (sweph, geocoding, geolocator)
- [ ] Baixar e embedir efemérides Swiss Ephemeris
- [ ] Criar modelos de dados (BirthChart, Planet, House, Aspect)
- [ ] Implementar ChartCalculator
- [ ] Implementar TransitCalculator
- [ ] Criar página de input do mapa natal
- [ ] Criar visualização do mapa (chart wheel)
- [ ] Implementar MagicalInterpreter
- [ ] Criar página de perfil mágico
- [ ] Testar cálculos com mapas conhecidos

### Sugestões Personalizadas
- [ ] Implementar sistema de sugestões
- [ ] Detectar Mercúrio retrógrado
- [ ] Detectar Lua Nova/Cheia
- [ ] Calcular trânsitos sobre mapa natal
- [ ] Criar página de sugestões
- [ ] Integrar com feitiços existentes

### Clima Mágico Diário
- [ ] Implementar DailyWeatherProvider
- [ ] Calcular aspectos do dia
- [ ] Gerar interpretação diária
- [ ] Criar página de clima mágico
- [ ] Adicionar widget de resumo na home

### IA
- [ ] Implementar AIService
- [ ] Criar página de configuração de API key
- [ ] Armazenamento seguro com flutter_secure_storage
- [ ] Criar página de geração de feitiços
- [ ] Testar com OpenAI
- [ ] Testar com Gemini
- [ ] Tratamento de erros
- [ ] Fallback sem IA (templates)

### Divinação
- [ ] Expandir sistema de runas
- [ ] Implementar spreads de runas
- [ ] Criar página de leitura de runas
- [ ] Implementar pêndulo interativo
- [ ] Criar Oracle Cards (44 cartas)
- [ ] Página de tiragem de cartas
- [ ] Histórico de leituras

### Final
- [ ] Atualizar database schema
- [ ] Testes de integração
- [ ] Documentação
- [ ] Atualizar README

---

## 🚀 Priorização

**Ordem recomendada**

1. **Astrologia Base**
   - Cálculo do mapa natal
   - Visualização básica
   - Perfil mágico

2. **Clima Mágico Diário**
   - Aspectos do dia
   - Interpretação diária
   - UI

3. **Sugestões Personalizadas**
   - Trânsitos
   - Recomendações
   - Integração com feitiços

4. **IA**
   - Configuração de API key
   - Geração de feitiços
   - UI

5. **Expansão de Divinação**
   - Runas (spreads)
   - Pêndulo
   - Oracle Cards

---

## 📚 Recursos

**Astrologia:**
- [Swiss Ephemeris](https://www.astro.com/swisseph/)
- [sweph package](https://pub.dev/packages/sweph)

**IA:**
- [OpenAI API Docs](https://platform.openai.com/docs)
- [Gemini API Docs](https://ai.google.dev/docs)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

---

## 🎯 Resultado Esperado

Ao final da Fase, o app deve:

✅ Calcular mapa astral completo e preciso
✅ Gerar perfil mágico personalizado
✅ Oferecer clima mágico diário
✅ Sugerir rituais baseados em astrologia
✅ Gerar feitiços personalizados com IA (opcional)
✅ Sistema completo de leitura de runas
✅ Pêndulo interativo
✅ Oracle Cards

---

**Boa implementação! 🌙✨**

Este é um projeto ambicioso e muito completo. Priorize as features core (astrologia) e depois expanda para as outras.
