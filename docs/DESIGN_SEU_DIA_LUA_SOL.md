# Design — Aba "Seu Dia" + páginas da Lua e do Sol

> Proposta refinada para validação (ainda não implementada).
> Contexto: a primeira aba da Enciclopédia (Lua) acumulou elementos que não
> conversam entre si (carrossel, momento mágico, rituais, fases, recomendações).
> A ideia é separar em: um **hub diário curado** ("Seu Dia") + duas páginas
> temáticas profundas (**Lua** e **Sol**), cada uma com seu ritual de água.

## Nova ordem de abas da Enciclopédia

```
Seu Dia | Lua | Sol | Sabbats | Cristais | Ervas | Metais | Cores | ...
```

- "Seu Dia" é a landing do app (a HomePage já abre na Enciclopédia, aba 0).
- As notificações passam a apontar: lua cheia/nova → página **Lua**;
  água solar → página **Sol**; sabbat → **Sabbats** (como hoje).
- Deep links novos: `encyclopedia/today`, `encyclopedia/sun` (payloads
  antigos continuam funcionando — `encyclopedia/moon` abre a aba Lua).

---

## 1. Aba "Seu Dia" (100% free, exceto onde indicado)

Wireframe textual, na ordem de rolagem:

```
┌─────────────────────────────────────────┐
│ 🐈‍⬛  "Boa noite, Bruxa 🌙"              │  1. Saudação do Salem
│     sexta-feira, 31 de julho            │     (por período do dia + data)
├─────────────────────────────────────────┤
│ 🌕 Lua Cheia · "auge do poder..."    →  │  2. Lua de hoje (compacto)
├─────────────────────────────────────────┤
│ ♀ MOMENTO MÁGICO                     →  │  3. Card existente
│ "Hoje é sexta, dia de Vênus..."         │     (MagicalMomentCard)
├─────────────────────────────────────────┤
│ 🔮 CLIMA MÁGICO DO DIA               →  │  4. Resumo de 2 linhas do clima
│ "Energia de encerramentos..."           │     gerado por IA (cache diário)
├─────────────────────────────────────────┤
│ ✨ AFIRMAÇÃO DO DIA                     │  5. Rotativa por data
│ "Eu floresço no meu próprio tempo."     │     (determinística, como as
│                     [salvar 💜]         │     mensagens do Salem)
├─────────────────────────────────────────┤
│ 🕯️ É HOJE: LUA CHEIA                    │  6. Ritual do momento
│ [Fazer o ritual guiado]                 │     (se hoje é sabbat/lua) OU
│ — ou —                                  │     contagem regressiva:
│ "Faltam 3 dias para Imbolc 🕯️"       →  │     próximo evento mágico
├─────────────────────────────────────────┤
│ ⚡ ATALHOS                              │  7. Grade 2×3
│ [Tarot] [Runas] [Feitiço IA]            │     (rotas full-screen já
│ [Oráculo] [Diário] [Sigilos]            │     existentes do Grimório)
└─────────────────────────────────────────┘
```

Detalhes por bloco:
1. **Saudação**: `salemGreetingMorning/Afternoon/Evening/Night` (ARB ×3
   idiomas), usa `MagicDayPeriod.fromHour`. Toque no Salem = burst de
   partículas (reusa o mascote? não — é um avatar estático aqui).
2. **Lua de hoje**: `LunarProvider.getCurrentMoonPhase()` → emoji + nome +
   `description` truncada. Toque → aba Lua (via TabController).
3. **Momento Mágico**: componente pronto (`MagicalMomentCard`), sai da
   página da Lua e vem para cá.
4. **Clima Mágico**: reusa o cache de `daily_magical_weather` (tabela).
   Free: 1ª frase + CTA "ver completo" (gate atual `aiMagicalWeather`
   1/dia). Premium: resumo maior.
5. **Afirmação do dia**: `affirmations` pré-carregadas — índice
   `dayOfYear % length` (mesmo padrão de `CatBubbleMessages.messageForDate`).
   Botão "salvar" marca como favorita (campo `is_favorite` já existe).
6. **Ritual do momento**: `WheelOfYearProvider.isTodaySabbat()` /
   `LunarProvider` fase de hoje → botão direto para `GuidedRitualPage`;
   senão, o evento mais próximo entre próximo sabbat/lua cheia/lua nova
   com contagem regressiva ("Faltam N dias...").
7. **Atalhos**: 6 ícones fixos na v1 (Tarot, Runas, Feitiço IA, Oráculo,
   Diário de Sonhos, Sigilos). Evolução futura: ordenar por uso real
   (contagens que as Jornadas já calculam).

## 2. Página "Lua" (evolução da LunarCalendarPage)

Ordem de rolagem:
1. **Herói**: carrossel Ontem/Hoje/Amanhã (existente).
2. **A Lua na bruxaria** *(conteúdo novo, `_pt/_en/_es`)*: intro + o que
   cada uma das 8 fases favorece (accordion `ExpansionMagicalCard`, uma
   entrada por fase, com "bom para" em tags clicáveis).
3. **Água de Lua**: card destacado → `GuidedRitualPage('moon_water')`.
4. **Esbats** *(conteúdo novo, curto)*: o que é um esbat, como celebrar.
5. **Correspondências lunares**: cristais/ervas/cores da Lua em
   `LinkableChip` (pedra da lua, selenita, jasmim, artemísia, prata...).
6. **Próximas fases** (existente).
7. **Recomendações de feitiço** (existente, `isGoodTimeForSpell`).
8. *(sai)* Momento Mágico → migra para "Seu Dia".

Free/premium: 1–3 e 5–7 free; bloco 4 (esbats) + accordion completo das
8 fases podem ser `lunarCalendarDetails` (preview → paywall), a decidir.

## 3. Página "Sol" (aba nova)

1. **Herói**: período solar de AGORA (nascer/dia/meio-dia/pôr/noite) com
   emoji grande + "bom para" — reusa `MagicDayPeriod`.
2. **O Sol na bruxaria** *(conteúdo novo)*: intro; magia solar vs lunar.
3. **Água Solar**: card destacado → `GuidedRitualPage('sun_water')`.
4. **As horas do Sol**: os 6 períodos do dia em cards (conteúdo do
   Momento Mágico, visão completa).
5. **Sabbats solares**: solstícios/equinócios (Yule, Litha, Ostara,
   Mabon) com link para a Roda do Ano.
6. **Correspondências solares**: `LinkableChip` (citrino, olho de tigre,
   âmbar, girassol, calêndula, alecrim, ouro, dourado...).
7. **Divindades solares** *(conteúdo novo curto ou link para Deusas)*.

Free/premium: espelho da página Lua.

## Impacto técnico (estimativa)

- `EncyclopediaPage`: TabController 14 → 16 abas; novos deep links
  `encyclopedia/today` e `encyclopedia/sun` (+ testes de payload).
- Novos arquivos: `your_day_page.dart` + widgets dos blocos 1/2/4/5/6/7;
  `sun_page.dart`; conteúdo trilíngue novo (`moon_content_*`,
  `sun_content_*`, ~2–3k palavras no total) + teste de paridade.
- `LunarCalendarPage`: remove MagicalMomentCard, adiciona blocos 2–5.
- Notificações: payload de lua cheia/nova continua `encyclopedia/moon`
  (job feito); água solar → `encyclopedia/sun` como destino do card.
- ARB: ~25 chaves novas ×4 arquivos.

## Perguntas em aberto (para a próxima rodada)

1. O resumo do Clima Mágico no "Seu Dia" pode DISPARAR a geração de IA do
   dia automaticamente (consome o 1/dia do free sem toque) ou só mostra o
   cache se já foi gerado + CTA? (Sugestão: só cache + CTA.)
2. Esbats/8 fases: free ou premium (`lunarCalendarDetails`)?
3. Atalhos fixos ou personalizáveis já na v1?
4. A saudação usa o nome/apelido do perfil ("Boa noite, Layla") ou o
   tratamento "Bruxa" universal (respeitando o gênero configurado)?
