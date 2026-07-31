# Relatório de Entrega — Revisão Ampla do Projeto (Jul/2026)

Entrega final da revisão em 3 etapas: internacionalização completa
(pt-BR/EN/ES), revisão do conteúdo de Tarot com base nos PDFs
Rider-Waite-Smith e auditoria técnica. Branch:
`claude/project-review-i18n-tarot-audit-ahmwn9`.

## 1. Inventário de tradução

- **1.195 chaves ARB** em paridade nos 4 arquivos (`app_pt.arb` template,
  `app_pt_BR.arb`, `app_en.arb`, `app_es.arb`), cobrindo todo o chrome de
  interface: títulos, botões, diálogos, snackbars, validações, estados
  vazios/erro/carregamento, tooltips, plurais ICU e placeholders.
- **Conteúdo estático (~10 mil linhas)** em arquivos por locale
  (`*_pt.dart` / `*_en.dart` / `*_es.dart`) selecionados em runtime por
  `ContentLocale`: Tarot (78 cartas), Oráculo (44), Runas, Enciclopédia
  (cristais, ervas, metais, cores, deusas, anjos, demônios, arquétipos,
  símbolos, elementos, altar), trilhas do Grimório Vivo (8 trilhas),
  temas de sonhos, interpretações astrológicas (signos, casas, aspectos,
  trânsitos, mapa natal, sugestões personalizadas), clima mágico diário,
  sigilos, numerologia, sabbats, jornadas, feitiços e afirmações.
- **Serviços e modelos sem BuildContext** usam
  `lookupAppLocalizations(ContentLocale.instance.locale)` (notificações,
  pagamentos, sync, auth, enums de exibição).
- **Prova de completude**: `scripts/check_hardcoded_pt.sh` (baseline
  inicial: 4.952 linhas) está **limpo e bloqueante no CI**;
  `scripts/check_arb_sync.sh` garante paridade dos ARBs.

## 2. Idioma do dispositivo, seletor e fallback

- Primeiro uso sem preferência salva: idioma do dispositivo
  (`PlatformDispatcher`), com fallback pt-BR.
- Escolha manual persistida (`SharedPreferences`); trocar idioma reagenda
  as notificações no novo idioma (agendamento idempotente).
- **Seletor reativado** nas Configurações (pt-BR / EN / ES).

## 3. IA no idioma da pessoa usuária

- 10 personas/prompts extraídos para `lib/core/ai/prompts/`
  (`ai_prompts_{pt,en,es}.dart`), com helpers de gênero por idioma.
- Marcadores de parsing preservados nas 3 línguas: ◈/✦ (sonhos e
  quiromancia), títulos `##` do clima diário casando com `looksComplete`
  por idioma, JSON de feitiços com chaves/enums invariantes.
- Conteúdo escrito pela pessoa usuária NUNCA é traduzido.

## 4. Identidades persistidas protegidas

- Seeds de feitiços (65) e afirmações (38) congeladas em PT no SQLite;
  tradução apenas na exibição (SpellLocalizer/AffirmationLocalizer).
- Ids/enums/slug de assets invariantes entre idiomas; histórico de
  leituras preserva o idioma da época (dado da pessoa usuária).

## 5. Revisão do Tarot (Etapa 2)

- 78 cartas comparadas com os significados divinatórios de Waite e o LWB:
  **1 correção conceitual** (Torre: keyword "reconstrução" → "mudança
  súbita"); estrutura, tamanho, tom e divisão Free/Premium mantidos.
- 10 lições (`ta_01`–`ta_10`) verificadas: 0 erros conceituais.
- Quiz conceitual: 12/12 corretas.
- Nomes das cartas nas convenções de cada idioma (The Fool / El Loco /
  O Louco); cartas da corte localizadas (Ás/Ace/As etc.).

## 6. Bugs cross-idioma corrigidos (além do escopo original)

- Imagens dos verbetes arcanos quebravam em EN/ES (slug derivado do nome
  traduzido) → identidade estável via `ArcaneCategory` + nome PT por
  índice, com teste de invariância.
- Ícones de metais caíam no genérico fora do PT → match sem acento nos 3
  idiomas.
- Quiz de arquétipos: correspondência por emoji (independente de idioma).
- Cache do clima diário reconhecido por idioma (`looksComplete`
  trilingue) — sem regeneração indevida ao trocar idioma.

## 7. Novos pedidos implementados

- **Deep links de notificação**: lua cheia/nova → Enciclopédia/Lua;
  sabbat → Enciclopédia/Sabbats; arquitetura extensível (`AppDeepLink` +
  `DeepLinkService`) para futuras notificações; funciona com app aberto,
  em segundo plano e app iniciado pelo toque na notificação.
- **Tela inicial fixa**: o app abre SEMPRE na Enciclopédia Mágica da Lua,
  inclusive no "refresh" de sessão (≥30 min).

## 8. Auditoria técnica (Etapa 3) — `docs/AUDITORIA_TECNICA.md`

- Segurança (classificada): chave Firebase versionada (ALTA — requer
  restrição no console), segredo Prokerala no histórico (ALTA — confirmar
  rotação), testes non-blocking no release (MÉDIA), e-mail em logs
  (BAIXA — **corrigido**: mascaramento).
- Correções seguras aplicadas: `flutter_secure_storage` removido (0 usos),
  e-mails mascarados nos logs, documentação de dev retirada do bundle do
  APK, método morto `_detectBrazilianTimezone` removido.
- Binários da raiz (mapas astrais pessoais, capturas) **aguardam sua
  confirmação** para remoção.

## 9. Testes e CI

- Gate bloqueante no CI de branch: `flutter analyze` (erros/warnings),
  17 arquivos de teste de i18n/conteúdo/paridade + smoke dos 3 idiomas,
  paridade dos ARBs, scanner de PT hardcoded, build do APK debug.
- Suíte completa roda como informativa e **passou integralmente no run
  final**; a dívida pré-existente documentada (gender fallback = decisão
  de produto; FeatureAccess; paywall; free_writing) segue anotada no §5
  do relatório de auditoria para acompanhamento.

## 10. Documentação

- README: diretrizes de i18n atualizadas + guia "como adicionar um novo
  idioma".
- `docs/AUDITORIA_TECNICA.md` novo; e-mails de suporte atualizados para
  suporte.grimoriodebolso@gmail.com em app, docs e páginas legais.

## 11. Limitações conhecidas

- Documentos legais (`assets/legal/*.md`) permanecem em PT (canônicos) —
  versões EN/ES exigem revisão jurídica, não tradução automática.
- Rótulos internos do payload de dados enviado à IA permanecem em PT
  (não são UI; idioma da resposta é imposto pelos prompts).
- Leituras/textos já persistidos permanecem no idioma em que foram
  gerados (por design — são dados da pessoa usuária).

## 12. Ações manuais pendentes (mantenedora)

1. Restringir a chave Firebase no Google Cloud Console.
2. Confirmar rotação do segredo Prokerala.
3. Autorizar remoção dos binários da raiz.
4. Decidir fallback de gênero (feminino atual vs. neutro do teste).
5. Decidir sobre versões EN/ES dos documentos legais.

## 13. Riscos de regressão

- Textos EN/ES podem ser mais longos que PT em botões/paywall — os testes
  de layout existentes cobrem parte; recomenda-se passada visual nos 3
  idiomas antes do release.
- Qualquer conteúdo novo deve seguir o fluxo do README (ARB + 3 variantes
  de conteúdo); o scanner bloqueante impede regressões de PT hardcoded.

## 14. Validação final

- CI (branch-validate): analyze + testes bloqueantes + ARB sync + scanner
  + build APK debug — verde no commit `507d0cc` (run `https://github.com/laylamonteiro/witchy-app/actions/runs/30625380919`).

## 15. Estatísticas da entrega

- ~60 commits na branch; ~250 arquivos Dart tocados; 1.195 chaves ARB ×4;
  ~110 arquivos de conteúdo por locale; 17 arquivos de teste no gate.
