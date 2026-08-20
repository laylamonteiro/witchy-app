# Auditoria Técnica — Grimório de Bolso (Jul/2026)

Relatório da Etapa 3 da revisão ampla do projeto (após a conclusão da
internacionalização pt-BR/EN/ES e da revisão de conteúdo do Tarot).
**Este documento lista achados e propostas; remoções e correções são
aplicadas em commits separados, apenas nos itens marcados como seguros.**

> **Status (31/Jul/2026):** todas as ações propostas foram aplicadas,
> **exceto a seção 1 (Segurança)**, adiada por decisão da mantenedora —
> permanece como pendência para uma próxima rodada.

## 1. Segurança

### 1.1 ALTA — Chave de API do Firebase commitada
`android/google-services.json` e `android/app/google-services.json` contêm
uma chave real (`AIza…`) versionada no repositório.

- Risco: a chave identifica o projeto Firebase; embora chaves de app Android
  não sejam segredos absolutos, a exposição pública facilita abuso de cota e
  phishing de configuração.
- Proposta: injetar o arquivo via secret no CI (mesmo padrão já usado para
  `groq_credentials.dart`/`prokerala_credentials.dart` no release) e
  **restringir a chave no Google Cloud Console** (por pacote Android +
  SHA-1). Requer ação externa da mantenedora.
- Observação: remover o arquivo do repositório sem reescrever histórico não
  elimina a exposição passada — a restrição da chave no console é o
  controle efetivo.

### 1.2 ALTA — Segredo Prokerala no histórico do git
Já documentado em `docs/SECURITY.md`. O segredo foi trocado por stub, mas o
histórico o preserva.

- Proposta: confirmar a **rotação** da credencial no painel Prokerala (ação
  externa). Não reescrever histórico sem decisão explícita da mantenedora.

### 1.3 ✅ RESOLVIDO — Testes non-blocking no release
`release-parallel.yml` rodava `flutter test … || echo` — falhas de teste não
bloqueavam o release. **Aplicado**: o workflow foi substituído por
`release.yml` (gatilho por tag, publicação atrás do environment `production`),
cujo job `validar` roda `flutter test` completo SEM escape, além de analyze,
paridade de ARBs e scanner de PT — no commit exato da tag.

### 1.4 BAIXA — E-mail do usuário em logs de debug
`auth_wrapper.dart:41` e `supabase_auth_repository.dart:142` registram o
e-mail do usuário via `debugLog`. Os logs são locais (SQLite, tela dev-only),
mas podem ser copiados/exportados pela tela de debug.

- Proposta: mascarar o e-mail nos logs (`a***@dominio`) — correção simples e
  segura; aplicada junto com a auditoria se aprovada.

## 2. Dependências

| Pacote | Situação | Proposta |
| --- | --- | --- |
| `flutter_secure_storage` | **0 usos** em `lib/`/`test/` | ✅ Removido do pubspec |
| `crypto` | 2 usos reais | Manter |
| `image_cropper` | 1 uso | Manter |
| `gal` | 1 uso | Manter |
| demais | usados | Manter |

## 3. Arquivos e assets

### 3.1 Binários soltos na raiz (dados pessoais + bloat) — ✅ APLICADO
- `astro_1.pdf`, `astro_2.pdf`, `astro_3.pdf` — mapas astrais **pessoais**
  (de terceiros), irrelevantes ao código.
- `mapa_astral_layla.png` — dado pessoal da mantenedora.
- `diagnostico_api.jpg` (1,3 MB), `Logs Diagnóstico.docx` — capturas de
  depuração antigas.
- `recurso grafico gplay.png` — arte da loja; se ainda for a arte vigente,
  mover para `docs/` ou armazenar fora do repositório.

Aplicado com autorização da mantenedora (31/Jul/2026): `astro_1/2/3.pdf`,
`mapa_astral_layla.png`, `diagnostico_api.jpg` e `Logs Diagnóstico.docx`
removidos da árvore atual (histórico preservado);
`recurso grafico gplay.png` movido para `docs/assets/` (arte da loja).

### 3.2 Assets empacotados no APK sem necessidade
`pubspec.yaml` inclui `assets/icons/` inteiro, que contém documentação e
ferramentas de desenvolvimento: `INTEGRACAO_ASSETS.md`, `README_ASSETS.md`,
`assets_guide.md`, `preview_assets.html`, `app_assets_config.dart` — tudo
isso vai para dentro do APK.

- `assets/icons/old_cat/` (36 KB): usado apenas como fallback dinâmico em
  `draggable_cat_mascot.dart:623`; `new_cat/` (916 KB) é o conjunto ativo.
- Proposta: mover os arquivos de documentação para `docs/assets/` (fora do
  bundle). Ganho pequeno mas gratuito. `old_cat/` permanece enquanto o
  fallback existir.

### 3.3 Código morto pontual
- `chart_calculator.dart`: `_detectBrazilianTimezone` **já removido** nesta
  branch (substituído pelo `TimezoneResolver` com DST histórico IANA).
- Não foram encontrados órfãos grandes adicionais em `lib/` durante a
  varredura de i18n (que tocou ~200 arquivos).

## 4. Performance

- Sem problemas mensuráveis novos identificados. Os maiores assets de imagem
  estão < 1 MB (total de `assets/` = 15 MB, dominado por `new_cat/` e
  imagens da enciclopédia em WebP).
- Dívida de lint (~500 infos `withOpacity` depreciado, `prefer_const…`)
  não afeta usuários; pode ser reduzida gradualmente. O gate de branch já
  bloqueia **erros e warnings** novos.

## 5. Dívida de testes (pré-existente, fora do gate bloqueante)

Estado atual: **263 passam, 0 falham** — a dívida foi zerada.

As 17 falhas do levantamento anterior tinham causas distintas, mas quase
todas do mesmo tipo: testes cobrando contratos que o app já havia mudado de
propósito. Em ordem de quantidade:

| Causa | Casos |
| --- | --- |
| Contrato antigo da escrita livre ("sair descarta" × "sair salva") | 4 |
| `pumpAndSettle` em página com animação em laço (`BlinkStar`) | 4 |
| Regra de acesso desatualizada (`aiPalmistry`, `numerologyReadings`) | 2 |
| Ponto final que os textos nunca tiveram, em nenhum idioma | 2 |
| `ListTile` com respingo de toque atrás do fundo opaco (correção no app) | 2 |
| Delegates de localização ausentes no harness | 1 |
| `LanguageProvider` ausente no harness | 1 |
| Item que mudou de tela ("Seja Premium", commit `0054d28`) | 1 |
| Fallback de gênero (o app trata no feminino, e diz isso no código) | 1 |
| Layout de paywall abandonado (chave `premium_paywall_fitted_content`) | 1 |

Duas viraram **correção de código**, não de teste: os `ListTile` das telas de
Privacidade e Configurações ficavam dentro de um `Container` opaco, e o
respingo do toque era pintado atrás dele — o toque não dava retorno visual.
Os dois cartões passaram a ser `Material` com `shape`.

Uma observação que sobrou do lote: medido em 390×844, o paywall pede ~444px
de rolagem. Não é regressão (a chave que marcava o layout "cabe numa tela só"
foi removida do app junto com aquele design), mas é um número a considerar se
o objetivo voltar a ser caber sem rolar.

A suíte completa é **bloqueante** nos dois workflows (`branch-validate.yml`
e `release.yml`) desde que a dívida foi zerada. A contrapartida assumida: um
teste instável barra a publicação — se acontecer, o conserto é do teste,
nunca do gate.

## 6. Arquitetura (anotações, sem refatoração em massa)

- `lib/core/diagnostic/diagnostic_page.dart` (96 KB) — console dev-only
  monolítico; candidato a split por abas se voltar a ser tocado.
- `lib/features/settings/presentation/pages/settings_page.dart` (47 KB) —
  acumula seções; candidato a extração de widgets por seção.
- `lib/core/ai/ai_service.dart` (28 KB após extração dos prompts) — os
  prompts agora vivem em `lib/core/ai/prompts/` por idioma.
- Documentos legais em `assets/legal/*.md` permanecem **apenas em PT**
  (canônicos). Se a distribuição internacional avançar, produzir versões
  EN/ES revisadas juridicamente (não é tradução automática).

## 7. Internacionalização — estado final (referência)

- 1.195 chaves ARB em paridade nos 4 arquivos (`app_pt`, `app_pt_BR`,
  `app_en`, `app_es`).
- Conteúdo estático (~10 mil linhas) em arquivos por locale
  (`*_pt/_en/_es.dart`) selecionados por `ContentLocale` — paridade coberta
  por testes bloqueantes no CI.
- `scripts/check_hardcoded_pt.sh` **limpo e bloqueante** (baseline inicial:
  4.952 linhas).
- Idioma inicial = idioma do dispositivo (fallback pt-BR); seleção manual
  persistida; seletor reativado nas Configurações.
- Prompts de IA por idioma; resposta no idioma do app; conteúdo escrito
  pelo usuário nunca é traduzido; seeds persistidas (feitiços/afirmações)
  congeladas em PT com overlay de exibição.

## 8. Ações que dependem da mantenedora

1. Restringir a chave Firebase no console (§1.1) e, se desejar, migrar o
   `google-services.json` para secret de CI.
2. Confirmar rotação do segredo Prokerala (§1.2).
3. Autorizar a remoção dos binários da raiz (§3.1).
4. Decidir o padrão de gênero (feminino vs. neutro) para o fallback (§5).
5. Decidir sobre versões EN/ES dos documentos legais (§6).
