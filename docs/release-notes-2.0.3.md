# Notas da versão — 2.0.3 (build 104)

Mudanças acumuladas desde o **build 80**: 118 commits, 22 novas
funcionalidades e mais de 55 correções

---

## 📱 Para a Play Store (copiar e colar)

### 🇧🇷 pt-BR

```
✨ A maior atualização do Grimório até hoje

• Nova aba Seu Dia: ritos diários, sequência, nível e atalhos
• Enciclopédia com índice ilustrado, busca global e 5 seções novas
• Salem, o gato guia, apresenta o app
• Rituais guiados passo a passo para sabbats e luas
• Grimório Vivo: trilhas de aprendizado com XP e níveis
• Sonhos interpretados símbolo por símbolo
• Fotografe plantas e pedras e crie páginas na sua enciclopédia
• Correções de navegação e desempenho
```

### 🇺🇸 en-US

```
✨ The biggest Grimoire update yet

• New Your Day tab: daily rites, streak, level and shortcuts
• Encyclopedia with illustrated index, global search and 5 new sections
• Salem, the guiding cat, walks you through the app
• Step-by-step guided rituals for sabbats and moons
• Living Grimoire: learning trails with XP and levels
• Dreams interpreted symbol by symbol
• Photograph plants and stones to create your own pages
• Navigation and performance fixes
```

### 🇪🇸 es

```
✨ La mayor actualización del Grimorio hasta hoy

• Nueva pestaña Tu Día: ritos diarios, racha, nivel y atajos
• Enciclopedia con índice ilustrado, búsqueda global y 5 secciones nuevas
• Salem, el gato guía, te presenta la app
• Rituales guiados paso a paso para sabbats y lunas
• Grimorio Vivo: rutas de aprendizaje con XP y niveles
• Sueños interpretados símbolo por símbolo
• Fotografía plantas y piedras y crea tus páginas
• Correcciones de navegación y rendimiento
```

---

## 🌟 Novidades

### A aba Seu Dia (nova)
Uma tela inicial que reúne o ritual do dia da Bruxa:

- **Saudação com nível e sequência** de dias praticados
- **Ritos de hoje**: gratidão e sonho fixos + um rito exploratório que se
  reveza a cada dia entre tarot, oráculo, quiromancia, runas,
  identificação na natureza e pêndulo — cada ferramenta marca o próprio
  rito só quando a ação acontece de verdade
- **Clima mágico do dia** em cache e **afirmação diária**
- **Contagem regressiva do próximo sabbat**, com urgência progressiva e
  atalho direto para o ritual guiado
- **Carrossel lunar** com a fase de hoje e os próximos dias
- **Continue sua trilha**: retoma a próxima lição do Grimório Vivo
- **Atalhos editáveis** — a pessoa escolhe quais ferramentas ficam à mão
- **Lembrete diário do Salem** por notificação

### Enciclopédia reformulada
- **Índice ilustrado** em papel envelhecido: o livro abre sozinho, folheia
  ao escolher uma seção e fecha ao voltar
- **Busca global** que atravessa todas as seções e as entradas pessoais
- **Novas seções**: Metais, Arquétipos, Símbolos Sagrados, Anjos e Demônios
- **Páginas Lua e Sol** reformuladas, com hero animado (a Lua e o Sol
  "respiram") e conteúdo próprio sobre cada um na bruxaria
- **Enciclopédia pessoal (Premium)**: fotografe uma planta, pedra ou cor,
  o Conselheiro Místico identifica e monta o verbete considerando a foto
  real — com filtro "Minhas/Meus" nas listas e sincronização na nuvem
- Tags **"Veja também"** clicáveis nos verbetes arcanos
- Cards padronizados em todas as listas, com nomes longos que encolhem em
  vez de quebrar

### Grimório Vivo e rituais
- **46 rituais guiados** trilíngues (sabbats, fases lunares e momentos
  mágicos) com player passo a passo que registra a prática
- **Trilha nova: Águas Mágicas** (9 lições)
- **Página de lição reformulada**: cabeçalho com "Lição X de Y", barra de
  progresso da trilha, chip de XP, passos numerados na prática e portão de
  conclusão explicado
- **Momento Mágico**: dias e horas planetárias com card na página lunar

### Progresso unificado
- **XP e níveis** agora somam estudo **e** prática: lições (25), trilhas
  encadernadas (100), rituais guiados (10), criações (5) e tiragens (2)
- Níveis: Aprendiz 🕯️ → Iniciada 🌙 → Praticante ⭐ → Adepta 🔮 →
  Mestra 👑 → Guardiã 📜
- **Estatísticas Mágicas** reformuladas: períodos corrigidos, calendário do
  mês com os dias praticados, sequências de prática e gratidão, card do
  Grimório Vivo e atalho para as Jornadas

### Salem, o gato guia
- Ganhou nome, voz própria em três idiomas e um **tour em coach marks**
  pelo app
- Some em fumaça quando incomoda e volta com o mesmo gesto

### Sonhos e leituras
- **Interpretação de sonhos em duas camadas** por elemento (o símbolo
  tradicional + a leitura aplicada ao seu sonho) e uma síntese final na
  voz de mentor ancião, com destaque de cores para cada camada
- **Quiromancia** com leitura completa, legível e sem truncar
- Salvar uma interpretação agora **leva direto à entrada criada**

### Anúncios e planos
- Intersticiais para o plano gratuito **antes do resultado** (tarot, runas,
  oráculo, pêndulo, feitiço por IA, conselheiro e mapa astral), com
  intervalo mínimo de 3 minutos e teto diário
- Rituais guiados e trilhas além da primeira lição passam a ser Premium

### Bastidores
- **Conselheiro Místico** com provedores parametrizados: Groq para texto,
  Gemini para visão, com fallback automático entre eles
- Suporte a **páginas de 16 KB** (requisito do Google Play) e minSdk 24
  nivelado nos plugins nativos
- Auto-incremento de versão no release (2.0.1 → 2.0.2 → 2.0.3...)

---

## 🐛 Correções

**Navegação**
- O gesto de voltar não fecha mais o app fora do Seu Dia — ele desce pelas
  telas até a aba inicial (predictive back do Android 16)
- Voltar de uma tiragem de tarot volta para o tarot, não para Ferramentas
- Re-toque na barra inferior volta ao topo da Enciclopédia e do Grimório
- Atalhos e ritos de sonho abrem a aba certa dos Diários

**Interface**
- Cards de Astrologia e Ferramentas com cores e altura idênticas
- Heros da Lua e do Sol sempre do mesmo tamanho
- Caixas de busca padronizadas; abas sem filtro usam a largura total
- Rodapé do tour não estoura mais no último passo
- Rolagem do índice contida dentro da moldura do livro

**Conteúdo e idioma**
- Afirmação do dia e balões do Salem respeitam a troca de idioma
- Crash ao trocar de idioma e ao registrar gratidão corrigidos
- Contagem do sabbat por dia de calendário
- Textos do fluxo de adicionar revisados ("página" no lugar de "verbete")

**Estabilidade**
- Ordem dos providers corrigida (AuthProvider antes dos dependentes)
- Colisão de nome do ShortcutRegistry com o Flutter
- Build nativo do sweph no NDK 28

---

## 📊 Números

| | |
|---|---|
| Commits | 118 |
| Builds | 80 → 104 |
| Novas funcionalidades | 22 |
| Correções | 55+ |
| Chaves de interface | 1.400 × 4 idiomas |
| Seções da Enciclopédia | 15 |
| Trilhas · Lições | 9 · 88 |
| Rituais guiados | 46 |
