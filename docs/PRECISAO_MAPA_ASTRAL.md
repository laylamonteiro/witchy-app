# 🌟 Acuracidade do Mapa Astral

## Situação Atual

O app calcula mapas astrais **localmente** usando aproximações astronômicas simplificadas.

### Precisão Atual

| Corpo Celeste | Precisão | Método |
|---------------|----------|--------|
| Sol | ±0.5° | VSOP87 simplificado |
| Lua | ±1-2° | Fórmulas de Meeus |
| Mercúrio | ±3-5° | Aproximação orbital |
| Vênus | ±3-5° | Aproximação orbital |
| Marte | ±2-4° | Aproximação orbital |
| Júpiter-Plutão | ±2-6° | Aproximação orbital |
| Ascendente | ±2° | Sistema de Casas Placidus |
| Casas | ±1-3° | Placidus local |

### Impacto Prático

**Para Bruxaria e Magia:**
- ✅ **Suficiente** para identificar signos solares, lunares e ascendente
- ✅ **Suficiente** para trânsitos planetários gerais
- ✅ **Suficiente** para fases lunares e aspectos principais
- ⚠️ **Limitado** para aspectos precisos (trígonos, sextis, quadraturas)
- ⚠️ **Limitado** para timing exato de eventos

**Para Astrologia Profissional:**
- ❌ **Insuficiente** para leituras profissionais
- ❌ **Insuficiente** para prognósticos precisos
- ❌ **Insuficiente** para análise de trânsitos exatos

## Comparação com Outras Fontes

### Versus astro.com (Swiss Ephemeris)
- **Diferença:** ±2-5° em posições planetárias
- **Causa:** astro.com usa Swiss Ephemeris (precisão de 0.001°)

### Versus TimePassages, Co-Star, etc.
- **Diferença:** Similar (±2-5°)
- **Causa:** Esses apps também usam Swiss Ephemeris

## Soluções para Melhorar Precisão

### Opção 1: Swiss Ephemeris (Flutter Package)

**Package:** `sweph` (https://pub.dev/packages/sweph)

**Vantagens:**
- ✅ Precisão profissional (±0.001°)
- ✅ Offline (não precisa de API)
- ✅ Usado por apps profissionais
- ✅ Inclui todos os planetas, asteroides, nodos

**Desvantagens:**
- ❌ Package grande (~20MB de dados efemeris)
- ❌ Complexo de integrar
- ❌ Requer arquivos de dados adicionais

**Como implementar:**
```dart
// pubspec.yaml
dependencies:
  sweph: ^2.0.0

// chart_calculator.dart
import 'package:sweph/sweph.dart';

double getPlanetPosition(Planet planet, double julianDay) {
  final sweph = Sweph();
  sweph.setEphePath('/path/to/ephemeris/files');

  final result = sweph.calc(
    julianDay,
    planet.id,
    Sweph.FLG_SWIEPH,
  );

  return result.longitude;
}
```

### Opção 2: API Externa (Prokerala)

**Status:** ❌ **NÃO disponível** no plano gratuito

Testamos extensivamente e nenhum endpoint funciona no plano free.

### Opção 3: Manter Implementação Atual

**Quando faz sentido:**
- ✅ App focado em bruxaria/magia (não astrologia profissional)
- ✅ Usuários não precisam de precisão astronômica
- ✅ Simplicidade e leveza são prioridade

**Melhorias possíveis sem bibliotecas:**
1. Implementar VSOP87 completo para todos os planetas
2. Adicionar perturbações planetárias
3. Melhorar cálculo de casas
4. Corrigir para nutação e aberração

## Recomendação

### Para o Grimório de Bolso

**Manter implementação atual** porque:

1. **Foco do app:** Bruxaria e magia prática, não astrologia profissional
2. **Usuários típicos:** Praticantes que querem saber seu signo lunar, ascendente, e trânsitos gerais
3. **Precisão suficiente:** Para identificar em qual signo cada planeta está
4. **Trade-off:** Leveza do app vs precisão astronômica

### Se precisar de mais precisão

Implementar Swiss Ephemeris (`sweph` package) seria a melhor opção:
- Precisão profissional
- Offline
- Não depende de APIs

**Custo:** ~20MB adicionais ao app + integração complexa

## Melhorando a Implementação Atual

### Prioridades

1. **Lua** - Mais importante para bruxaria (fases, signos lunares)
2. **Ascendente** - Muito usado em perfil mágico
3. **Sol** - Já razoavelmente preciso
4. **Planetas pessoais** (Mercúrio, Vênus, Marte)
5. **Planetas sociais** (Júpiter, Saturno)
6. **Planetas geracionais** (Urano, Netuno, Plutão) - menos críticos

### Melhorias Possíveis

**Sem bibliotecas externas:**
- Implementar VSOP87 mais completo (±0.1° para planetas principais)
- Corrigir longitude para equinócio verdadeiro
- Melhorar cálculo de nodos lunares

**Esforço:** Alto (semanas de trabalho)
**Benefício:** Precisão moderada (±0.5-1°)
**Vale a pena?:** Depende do público-alvo

## Conclusão

A implementação atual é **adequada para o propósito do app** (bruxaria e magia prática).

Para melhorar significativamente, seria necessário:
- **Integrar Swiss Ephemeris** (melhor opção)
- **OU** reescrever toda a lógica de cálculo planetário

**Decisão recomendada:** Manter como está e focar em outras features do app.
