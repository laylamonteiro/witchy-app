# Varredura de completude — auditoria técnica

> Gerada por 28 agentes: um por seção do relatório técnico, e um verificador
> **adversarial** para cada achado marcado como não coberto — cuja tarefa era
> provar o contrário indo ao código.
>
> Total: **94 achados** — 62 cobertos, 18 abertos, 11 bloqueados em painel,
> 2 mantidos por decisão explícita, 1 falso.
>
> Vários dos "abertos" abaixo já foram fechados DEPOIS desta varredura (o dump
> cru da exceção, o "tecer de novo" mudo, a catraca do
> `use_build_context_synchronously`, o rastro da falha de upload, as chaves de
> IA). O estado atual de cada um está em `docs/PLANO_UNIFICADO.md` — este
> documento é o registro da varredura, não o placar.


## Abertos na varredura

Cada um passou por um verificador que tentou provar que já estava feito, e não conseguiu.

### --- Não existe nenhum relato de erro — nada disto é observável
*seção `cegos` · estado `NAO_COBERTO`*

**Onde:** lib/features/auth/data/models/feature_access.dart:245-249 — `_analyticsHook` continua sem consumidor de produção; o único `setBlockedAccessAnalyticsHook` fora da própria classe é test/widget_test.dart:350

O achado se mantém inteiro, e é o mais grave dos pontos cegos porque nenhum commit desta
branch o tocou. (a) Sem serviço de relato de erro: grep case-insensitive por
sentry|crashlytics em pubspec.yaml = 0 ocorrências. (b) O hook segue emitindo
BlockedAccessEvent em feature_access.dart:347-353 e :360-364 para lugar nenhum. (c)
debug_log_service.dart:7-8 confirma o teto (`_logsKey = 'debug_logs'`, `_maxLogs = 200`)
e :24-25 confirma o destino (SharedPreferences). (d) offer_engine.dart:191-198
(`recordConversion`) e :204-210 (`_bumpEvent`) gravam só em SharedPreferences local. A
recomendação de "ligar um serviço de relato de erro antes das fases de conserto" não foi
executada — as 15 correções desta branch continuam avaliáveis só por sensação.

> **Verificador adversarial não conseguiu refutar.** Não encontrei nenhuma evidência de conserto, nem sob nome em português, nem por
outro caminho, nem como decisão explícita registrada. Cinco frentes independentes
confirmam o achado. (1) Nenhum serviço de relato de erro: grep case-insensitive por 
sentry|crashlytics|firebase_analytics|posthog|amplitude|mixpanel|bugsnag|glitchtip|r
ollbar em *.yaml/*.dart/*.json/*.md retorna zero ocorrências reais — os únicos hits
são a palavra "Amplitude" num comentário de animação em
lib/core/widgets/living_emblem.dart:381 e "amplitude do pensamento" num texto de
quiromancia. O bloco dependencies: de pubspec.yaml não tem nenhum pacote de
observabilidade. (2) O _analyticsHook continua órfão em produção: o singleton é
criado sem hook em lib/features/auth/data/models/feature_access.dart:243 (static
final FeatureAccessService instance = FeatureAccessService();), o construtor com
analyticsHook (linha 240) não é

### --- Como desligar se der errado?
*seção `cegos` · estado `NAO_COBERTO`*

**Onde:** lib/core/config/test_build_config.dart:3-6 — as únicas "flags" do projeto são `bool.fromEnvironment`, constantes de COMPILAÇÃO; grep por feature_flag|remote_config|kill_switch|killSwitch em lib/ = 0 ocorrências

Confirmado e agravado. lib/core/config/ tem seis arquivos (admin_config, captcha_config,
google_signin_config, revenuecat_config, supabase_config, test_build_config) e nenhum é
interruptor remoto — o próprio comentário de test_build_config.dart:4-6 explica que sem
o `--dart-define` o compilador arranca o caminho da árvore. Desfazer o sync para todos
ou o redesenho do paywall continua exigindo build novo + revisão da Apple. Nenhum commit
desta branch adicionou controle remoto.

> **Verificador adversarial não conseguiu refutar.** Não achei nenhuma evidência de conserto. O achado é uma pergunta aberta de operação
("como desligar sem build novo?") e continua sem resposta no código: todas as flags
do projeto são constantes de compilação
(`bool.fromEnvironment`/`String.fromEnvironment`), não existe tabela de configuração
no Supabase nem edge function que sirva um flag, e nenhum commit da branch adicionou
controle remoto. Procurei ativamente por identificadores em português (interruptor,
desligar, torneira, válvula, freio, manutenção, habilitarSync, syncLiberado) e o
único acerto relevante — `sync_settings_page.dart:77` / `edit_profile_page.dart:244`
— é o interruptor do próprio usuário sobre o sync dele, com comentário dizendo isso
em letra clara; não é um kill switch de operador e não desfaz o rollout para a base.
O mais próximo de uma "decisão registrada" é docs/ROADMAP.md:87, que lista
"OPCIONAL: Toggle remoto (Fi

### --- Quanto custa um usuário gratuito por mês?
*seção `cegos` · estado `NAO_COBERTO`*

**Onde:** lib/features/auth/data/models/user_model.dart:158 (`freeAiConsultationsLimit = 1`) com lib/features/auth/data/models/feature_access.dart:259-262 (`LimitWindow.daily`) — o plano Free tem IA todo dia; nenhum arquivo em docs/ analisa custo ou margem

A pergunta continua sem resposta no repositório. O número que ela precisa está no código
e cresceu: lib/features/astrology/presentation/providers/astrology_provider.dart:361-364
registra que a Análise Personalizada seriam "dez chamadas de IA" se tecidas de uma vez,
e magical_profile_report.dart:35-46 confirma as dez seções. A geração sob demanda mitiga
(só a seção aberta gasta), mas o teto por pessoa subiu de 1 para 10 chamadas e não há
nenhuma estimativa de margem escrita. Grep por "custo|margem" em docs/ROADMAP.md e
docs/ORIGEM_E_PAGAMENTO.md não retorna nada sobre custo de IA.

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhuma resposta a pergunta "quanto custa um usuario gratuito por mes"
— nem em docs/, nem em comentario de codigo, nem em mensagem de commit. Varri o
repositorio inteiro (todas as extensoes, fora .git/build) por
"custo|margem|cost|margin|unit econom|CAC|LTV|quanto custa|custo mensal|custo do
plano|teto de gasto|orcamento de IA|US$|R$ 0,|$0.0|centavos|tokens por", e tambem
`git log -S"custo"` nos commits recentes e `git log` de docs/. O unico material de
custo escrito e sobre PRODUTO PAGO, nao sobre o plano Free:
docs/prompt_leitura_ciclo_motor_ofertas.md:202-206 estima "~87 chamadas de IA por
pessoa por ano" para o Vitalicio (e ~295/ano se incluisse a semanal), e as duas
linhas de preco logo abaixo comparam R$ 123/ano de valor contra a anual de R$ 89,90.
Nada disso e o plano gratuito. Alem disso,
docs/prompt_leitura_ciclo_motor_ofertas.md:141-144 e a prova NEGATIVA mais di

### --- Quem revisa, e como coordenar sessões paralelas?
*seção `cegos` · estado `NAO_COBERTO`*

**Onde:** não existe .github/CODEOWNERS (o diretório .github/ tem só `actions/` e `workflows/`); o único olho obrigatório é o gate de ambiente em .github/workflows/release.yml:7 e :689

Nenhuma regra de revisão foi adicionada. O gate do environment `production` impede
publicação sem aprovação humana, mas não obriga ninguém a LER o diff antes do merge na
main — inclusive nas mudanças de pagamento (lib/core/services/payment_service.dart) e de
segurança (supabase/profiles_lockdown_migration.sql). A coordenação de sessões paralelas
(PR #248) é assunto de GitHub/humano, fora do repositório.

> **Verificador adversarial não conseguiu refutar.** Não achei nenhuma prova de cobertura. Não existe CODEOWNERS, template de PR, regra
de required reviewers na main, nem documento registrando a decisão sobre "quem
revisa" ou sobre coordenar sessões paralelas — em português ou em qualquer outro
vocabulário. O único olho humano obrigatório continua sendo o environment
`production` (release.yml:7-8, :690), que é depois da main e só bloqueia publicação.
O merge manual documentado (.github/workflows/README.md:20-45, branch-
validate.yml:724-728) é um clique, não obriga leitura do diff, não distingue mudança
de pagamento/segurança, e é anterior à auditoria (commit 42276d8 de 2026-08-20 vs.
consertos de 2026-08-22). A parte de coordenar sessões paralelas não tem nenhum
artefato no repo. O achado permanece NÃO_COBERTO.

### As chaves da Groq e da Gemini publicadas no site — qualquer pessoa extrai do JavaScript
*seção `decisoes` · estado `NAO_COBERTO`*

**Onde:** .github/actions/credenciais-app/action.yml:29-45 (o CI ainda escreve as chaves reais dentro de groq_credentials.dart / gemini_credentials.dart) e lib/core/ai/ai_service.dart:874, 910, 1082, 1136 (Authorization: Bearer ${GroqCredentials.apiKey} e x-goog-api-key direto do cliente)

Nenhuma mudança. Não há Edge Function em supabase/ (só arquivos .sql), não há guarda
kIsWeb no ai_service, e nada em docs/ orienta rotação de chave ou teto de gasto. As
linhas do relatório (763, 799, 971, 1025) mudaram de lugar — o código andou —, mas o
defeito é o mesmo, agora em 874/910/1082/1136.

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhuma evidencia de conserto — nem sob nome em portugues, nem por
outro caminho, nem como decisao registrada. (1) Nao existe intermediario: `find` por
diretorios `functions`/`edge*`/`*proxy*` retorna zero, e /home/user/witchy-
app/supabase/ so tem 10 arquivos .sql; o unico `functions.invoke` em lib/ esta
COMENTADO em supabase_auth_repository.dart:534. (2) O cliente continua mandando a
chave crua: ai_service.dart:874, 910, 1082, 1136 sao `_dio.post` diretos para
api.groq.com e generativelanguage.googleapis.com, e `grep kIsWeb` em lib/core/ai/
retorna ZERO — nao ha guarda de web sob nenhum nome. (3) O CI ainda escreve as
chaves reais (action.yml:29-45) e as passa justamente para os jobs de web:
release.yml:539-544 (job `build-web`) e branch-validate.yml:305-310 (publicacao
Cloudflare Pages). Agravante: release.yml:552 traz o comentario `# ADMIN_* NAO
entra: o bundle web e pub

### As chaves da Groq, da Gemini e da Prokerala vão compiladas dentro do site
*seção `dinheiro` · estado `NAO_COBERTO`*

**Onde:** .github/actions/credenciais-app/action.yml:29-45 (cat > lib/core/ai/groq_credentials.dart e gemini_credentials.dart com as chaves) e :47-58 (prokerala_credentials.dart com clientSecret); lib/core/ai/ai_service.dart:874 e :1136 ('Authorization': 'Bearer ${GroqCredentials.apiKey}'), :910 e :1082 ('x-goog-api-key': GeminiCredentials.apiKey)

Nada mudou aqui. Nao existe nenhuma Edge Function no repo: supabase/ tem apenas arquivos
.sql, e grep por functions.invoke em lib nao devolve nenhuma chamada. Duas divergencias
em relacao ao relatorio: (a) as linhas citadas (ai_service.dart:763, 799, 971, 1025)
andaram — as chamadas com chave estao hoje em 874, 910, 1082 e 1136; (b) o arquivo esta
em lib/core/ai/ai_service.dart, nao em lib/core/services/. Prokerala nao aparece em
nenhum .dart versionado (o credencial e gerado pela CI e ignorado pelo git), mas o
action.yml prova que o clientSecret entra no bundle igual. Tambem nao ha material
preparado para a parte de painel — nenhum doc no repo fala em girar chaves apos
publicacao web nem em teto de gasto (docs/SECURITY.md so trata do vazamento antigo da
Prokerala, docs/SECURITY.md:9-36).

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhuma evidencia de conserto, nem sob outro nome/caminho, nem como
decisao registrada. (1) Nao existe intermediario: supabase/ tem apenas 10 arquivos
.sql e nao ha nenhum .ts no repo (fora node_modules); o unico functions.invoke em
lib/ esta comentado e e de outro assunto (supabase_auth_repository.dart:534, //
await _supabase.functions.invoke('delete-user')). (2) As chaves continuam saindo do
cliente: ai_service.dart:874 e :1136 mandam 'Authorization': 'Bearer
${GroqCredentials.apiKey}', e :910 e :1082 mandam 'x-goog-api-key':
GeminiCredentials.apiKey; nao ha nenhuma ocorrencia de kIsWeb em ai_service.dart,
entao nao existe guarda que tire esse caminho da web. (3) A CI continua compilando
as chaves no bundle web: credenciais-app/action.yml:29-45 e :47-58 escrevem os .dart
com as chaves e o clientSecret, e os jobs de WEB passam os secrets reais em branch-
validate.yml:305-31

### O plano nunca é gravado no servidor por uma compra
*seção `dinheiro` · estado `NAO_COBERTO`*

**Onde:** lib/features/auth/presentation/providers/auth_provider.dart:286-311 (_onPaymentStatusChanged so faz _currentUser.copyWith(role/plan) e :312 await _saveUser(), que grava em SharedPreferences — auth_provider.dart:317-321); lib/features/auth/data/repositories/beta_code_repository.dart:258-260 (unica escrita de role/plan em profiles em todo o lib)

Continua verdadeiro no codigo atual: grep por "'plan'" em lib/ devolve so o resgate de
Codigo Premium (beta_code_repository.dart:260), o toJson do UserModel
(user_model.dart:327) e a LEITURA no login (supabase_auth_repository.dart:680). Nenhuma
compra escreve plan/role em profiles — nem a assinatura, nem o avulso. Divergencia de
linha: o supabase_auth_repository.dart:582-584 citado pelo relatorio hoje e outra coisa
(o laco de exclusao de conta, :573-585); a leitura do plan mudou para :680. O item foi
etiquetado 'Atencao' e nao entrou em nenhum dos commits da branch — os tres commits de
dinheiro (668776a) e sync (db80c6e) nao tocam nisso.

> **Verificador adversarial não conseguiu refutar.** Nao consegui refutar — o achado continua valido no codigo atual da branch
claude/artifact-access-aea6wn.  Procurei ativamente por um conserto em qualquer
forma (nome em portugues, RPC, edge function, webhook, SQL, decisao registrada em
comentario/commit) e ele nao existe:  1) Escritas em `profiles` no lib inteiro sao
apenas quatro, e nenhuma vem de compra: beta_code_repository.dart:258 (resgate de
Codigo Premium, unico write de role/plan), supabase_auth_repository.dart:151 (upsert
de criacao de perfil), :165 (signup_platform) e :473 (updateProfile, cujo updateData
em :460-469 so aceita display_name, photo_url, birth_date, birth_time, birth_place e
updated_at — plan/role nao entram).  2) Grep por "'plan'" em lib/ devolve exatamente
os quatro pontos que o outro agente citou: beta_code_repository.dart:260 (resgate),
user_model.dart:327 e :363 (toJson/fromJson locais) e supabase_auth_reposit

### O dart format do CI é decorativo
*seção `divida` · estado `PARCIAL`*

**Onde:** .github/workflows/branch-validate.yml:118 (`continue-on-error: true`), passo em :93-118

O `continue-on-error: true` continua exatamente onde o relatório disse. Nenhuma das duas
saídas exigidas (virar bloqueante ou sair) aconteceu. O que mudou: o passo agora lista
os arquivos (`dart format --output=none --show=changed lib test | tee /tmp/fmt.txt`,
linha 115) e emite `::warning::arquivos fora de formato: N` (linha 116), e o comentário
96-113 escreve o plano em duas etapas (commit isolado de `dart format` com o Flutter
3.47.0 pinado em .github/actions/setup-flutter, depois apagar o continue-on-error). Ou
seja: deixou de ser mudo, mas segue verde por construção.

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhum conserto alternativo. O `continue-on-error: true` continua vivo
em .github/workflows/branch-validate.yml:118, logo abaixo do `dart format
--output=none --set-exit-if-changed lib test` da linha 117, entao o passo segue
incapaz de derrubar o job. Procurei por caminho alternativo em portugues e em
ingles: release.yml nao roda `dart format` (so tem a matriz `formato: [apk, aab]`);
.github/workflows/README.md nao cita formatacao; nenhum dos scripts
(check_arb_orfas.sh, check_arb_sync.sh, check_hardcoded_pt.sh, release.sh,
deploy_web.sh, scripts/ci/) tem gate de formato; nao existe .githooks, .husky,
lefthook.yml nem .pre-commit-config.yaml. Um grep repo-wide por "dart format" em
*.md/*.sh/*.yml/*.yaml devolve UM unico arquivo: branch-validate.yml. E `git log
--all --grep=format -i` nao mostra o commit isolado de formatacao que o proprio
comentario descreve como pre-requis

### Os 186 infos do analyze escondem 26 use_build_context_synchronously
*seção `divida` · estado `NAO_COBERTO`*

**Onde:** .github/workflows/branch-validate.yml:124 (`flutter analyze --no-fatal-infos`); analysis_options.yaml:1-9

Nada mudou. O analyze segue com `--no-fatal-infos` e o analysis_options.yaml não escala
nem isola `use_build_context_synchronously` (só tem prefer_const_constructors,
prefer_const_literals_to_create_immutables, avoid_print: false, prefer_single_quotes).
Não existe gate separado nem allowlist para essa regra. As únicas cinco menções no repo
são comentários antigos em
lib/features/settings/presentation/pages/privacy_settings_page.dart:370 e :530,
lib/features/sigils/presentation/pages/sigil_step3_drawing_page.dart:103 e :185,
lib/features/subscription/presentation/pages/subscription_page.dart:689. Não consegui
recontar os 26 porque não há Flutter/Dart instalado neste ambiente (`which flutter dart`
vazio), mas nenhuma peça do repo endereça o achado.

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhuma prova de conserto, nem sob nomes em portugues. O
`analysis_options.yaml` continua com 9 linhas e sem bloco `errors:` — nao ha
escalonamento nem isolamento de `use_build_context_synchronously`. Os dois workflows
seguem rodando `flutter analyze --no-fatal-infos` (branch-validate.yml:124 e
release.yml:287), e o comentario que justifica isso (branch-validate.yml:121-123)
fala so de `withOpacity`/`prefer_const`, sem citar a regra — ou seja, nem como
decisao explicita registrada o achado foi endereçado. Nenhum script de `scripts/`
(check_arb_sync, check_arb_orfas, check_hardcoded_pt, assemble_site, deploy_web,
release, ci/conferir_faixa_play.py) trata contexto-depois-de-await, e nenhum dos 16
arquivos novos da branch (`git diff --diff-filter=A e275bba..HEAD`) e um gate de
lint. O `git log -- analysis_options.yaml` mostra que o arquivo nao e tocado desde
f083db3, muito ant

### O que esta sequência entregou não tem teste
*seção `divida` · estado `PARCIAL`*

**Onde:** test/magical_profile_report_test.dart:10,37,55; test/magical_profile_section_page_test.dart:33-48; lib/core/widgets/paged_reading.dart

Metade da lista foi paga. Cobertos agora: a quebra do relatório em seções E o fallback
com markdown fora do formato — que era a segunda recomendação de 'paga mais rápido' — em
test/magical_profile_report_test.dart:10 ('um ## solto da IA não derruba a grade de dez
cards'), :37 e :55; o voltar na web em test/voltar_na_web_test.dart:18 e :100; a feature
Ciclos do lado da interface, parcialmente, em test/isca_das_eras_test.dart:28-129; a
persistência no Supabase, parcialmente, em test/sync_para_todos_test.dart:23-229 e a
ordem das FKs em test/sync_coverage_test.dart:24. NÃO cobertos: (a) a primeira
recomendação, o teste da acumulação de seções —
test/magical_profile_section_page_test.dart continua substituindo justamente o método
que concentra o risco (o `_AstroFake` sobrescreve `erroDaSecao`, `falhaDeLimiteNaSecao`
e `isWeavingSection` nas linhas 33-48; os dois testes novos em :207-234 são sobre
contaminação de erro entre seções, não sobre acúmulo de texto); (b) PagedReading e
PageDots seguem sem nenhum teste — `grep -rln 'paged_reading|page_dots' test/` não
retorna nada, apesar de lib/core/widgets/paged_reading.dart e
lib/core/widgets/page_dots.dart serem usados em cinco telas; (c)
test/cycle_reading_composer_test.dart não menciona MagicalProfile/perfil em lugar
nenhum, então a composição da Leitura do Ciclo com o perfil segue descoberta.

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhuma prova de cobertura para os tres itens que o outro agente
aponta como faltantes; ao contrario, a busca ativa (inclusive por identificadores em
portugues) confirma cada um deles. (a) A acumulacao de secoes continua sem teste: a
logica real esta em
lib/features/astrology/presentation/providers/astrology_provider.dart:375-445 e o
unico teste que toca AstrologyProvider sobrescreve justamente generateProfileSection
em test/magical_profile_section_page_test.dart:57-66, com corpo que so incrementa um
contador e alterna _tecendo — nenhum texto e acumulado. Os testes de :207-234 tratam
de contaminacao de erro/limite entre secoes, nao de acumulo. Apenas a peca isolada
removeMagicalProfileSection e testada
(test/magical_profile_report_test.dart:148,168). (b) PagedReading e PageDots: zero
ocorrencias em test/ para PagedReading, PageDots, paged_reading, page_dots,
PageView, ponti

### Dois google-services.json comitados, divergentes — e nenhum tem a SHA-1 do release
*seção `divida` · estado `PARCIAL`*

**Onde:** android/app/google-services.json; android/google-services.json; .github/workflows/release.yml:459-495

O fato relatado continua verdadeiro, verificado por mim: os dois arquivos existem e
divergem — android/app/google-services.json tem UM oauth_client android com
certificate_hash 8bd7bb97b95c8d5e549d5584a01fe27aec85da98, e android/google-
services.json tem DOIS (c83b65515240e2bf07b9f281701728de74dc6f72 + 8bd7bb...). O
SHA1_ESPERADO de release.yml:67 (54:84:54:75:7F:...) não aparece em nenhum dos dois. O
que a sequência entregou é o ACUSADOR, não o conserto: release.yml:475-495 agora lê os
certificate_hash do android/app/ com jq e FALHA o build de APK quando a digital
assinante não está registrada (com a mensagem de conserto apontando o Google Cloud), e
apenas AVISA no AAB por causa do Play App Signing. O passo a passo do conserto está em
docs/GOOGLE_SIGNIN_SETUP.md (bloco '⚠️ Hoje as duas constantes do repositório se
contradizem' e a tabela '📄 Existem DOIS google-services.json, e eles divergem'). O que
falta é panel: registrar 54:84:... no client OAuth Android no Google Cloud Console e
rebaixar o arquivo. Apagar o android/google-services.json redundante — que é trabalho
puro de repositório — não foi feito.

> **Verificador adversarial não conseguiu refutar.** Nao consegui refutar: o achado permanece inteiramente valido. Procurei ativamente o
conserto sob outro nome, caminho ou como decisao registrada (grep repo-wide por
"android/google-services", varredura de scripts/, .gitignore, workflows, gradle,
mensagens de commit) e nao existe. Os tres fatos do achado se sustentam por
verificacao direta: (a) os dois arquivos continuam rastreados no git e divergem no
conjunto de certificate_hash; (b) a SHA-1 declarada em release.yml:67 (54:84:…) nao
aparece em nenhum dos dois (grep retorna 0 ocorrencias em ambos); (c) o unico
trabalho novo e o acusador em release.yml:462-495 mais a documentacao — e a propria
documentacao (GOOGLE_SIGNIN_SETUP.md:235-236) manda apagar o arquivo redundante
"depois de conferir", deixando explicito que a remocao nao foi feita, e a mensagem
do commit 46b4677 diz textualmente "BLOQUEADO, precisa de painel: ... decidir qual
goog

### O iOS não é compilado por nenhum job de CI
*seção `divida` · estado `PARCIAL`*

**Onde:** ios/Runner/Info.plist:15-17; .github/workflows/branch-validate.yml:63-76

Substancialmente inalterado; o que mudou foi só a honestidade do detector. Confirmei as
três partes: (a) nenhum job roda em macOS — todos os `runs-on` de branch-validate.yml
são ubuntu-latest (linhas 50, 218, 282, 548, 670, 736); (b) ios/Runner/ tem só
AppDelegate.swift, Assets.xcassets, Base.lproj, Info.plist e Runner-Bridging-Header.h —
não há GoogleService-Info.plist, e `grep -rn GIDClientID ios/` não retorna nada; (c)
ios/Runner/Info.plist:17 segue com ca-app-pub-3940256099942544~1458002511 e o próprio
comentário na linha 16 diz 'ID DE TESTE do Google. Troque pelo ID real'. O ganho é que o
passo antes chamado 'mudou código nativo' foi renomeado para '🔎 Mudou o ANDROID?' e o
comentário em branch-validate.yml:63-76 escreve o buraco por extenso, inclusive as duas
pendências do iOS. Fechar de fato exige runner macOS (decisão de custo) + painel do
AdMob (ID real) + Google Cloud/Firebase (GoogleService-Info.plist).

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhuma prova de conserto — nem sob outro nome, nem por outro caminho.
Busquei ativamente por: (1) runners macOS e passos de build iOS — `grep -rni
"macos|xcodebuild|build ios|build ipa|xcode" .github/` retorna UMA unica linha, e
ela e um COMENTARIO (branch-validate.yml:71) dizendo que fechar o buraco "exige um
runner macOS, que e decisao de custo". Os 12 `runs-on` dos dois workflows sao todos
`ubuntu-latest` (branch-validate.yml:50,218,282,548,670,736 e
release.yml:77,272,334,530,710,845). (2) Outra esteira de CI fora do GitHub Actions
— nao existe codemagic.yaml, fastlane/, bitrise.yml, .circleci/, .gitlab-ci.yml nem
azure-pipelines em lugar nenhum do repo. (3) Scripts de verificacao em portugues —
scripts/ tem apenas assemble_site.sh, check_arb_orfas.sh, check_arb_sync.sh,
check_hardcoded_pt.sh, deploy_web.sh, release.sh e
scripts/ci/conferir_faixa_play.py; nenhum toca i

### Erros que somem sem deixar rastro
*seção `divida` · estado `PARCIAL`*

**Onde:** lib/features/cycles/data/repositories/life_eras_repository.dart:71-76; lib/features/cycles/presentation/pages/cycles_tab.dart:352-371; lib/core/services/data_sync_service.dart:1091-1093

Dois dos três itens foram atendidos. (1) Eras: a causa agora vai para o log em
life_eras_repository.dart:74 e o cartão deixou de ser mudo — cycles_tab.dart:357-368 tem
TextButton.icon 'tentar de novo' chamando `LifeErasProvider.recarregar`, que ignora o
carimbo (sem isso o `sync` sairia na primeira linha). Ressalva: o campo `erro` de
LifeErasError (lib/features/cycles/data/models/life_eras_state.dart:38) continua sem
leitor — o próprio comentário em life_eras_repository.dart:72-74 assume isso. (2) Guia
da Natureza: parou de engolir —
lib/features/encyclopedia/presentation/pages/add_entry_page.dart:177-179 agora faz
`_error = e is AiRateLimitException ? aiVisionRateLimit : errorsGeneric`, ou seja, TODA
falha aparece, não só o 429. (3) NÃO atendido: as falhas de upload continuam morrendo
num debugPrint — lib/core/services/data_sync_service.dart:1091-1093 (`catch (e) {
debugPrint('Erro ao sincronizar item: \$e'); }`) é o caminho por onde o perfil sobe
(saveMagicalProfile chama `_syncService.syncItem`,
lib/features/astrology/data/repositories/astrology_repository.dart:137), e o mesmo
padrão está em :1112.

> **Verificador adversarial não conseguiu refutar.** Não consegui refutar. Os itens (1) Eras e (2) Guia da Natureza estão de fato
consertados, como o outro agente reconhece, mas o item (3) — falhas de upload
morrendo num debugPrint — continua literalmente igual no HEAD. Procurei ativamente
por conserto sob outro nome/caminho: (a) nenhum logger, telemetria ou canal de erro
foi introduzido em lugar nenhum do repo; (b) syncItem não repassa nem registra a
exceção — o catch está dentro dele, então nem saveMagicalProfile
(astrology_repository.dart:137) nem a fila _gravarPerfil
(astrology_provider.dart:70-77, que promete "o erro continua indo para quem chamou")
jamais enxergam a falha de nuvem; (c) nenhum comentário no código, nenhum doc em
docs/ e nenhuma mensagem de commit registra isso como decisão explícita de "engolir
de propósito" (o único mitigante real — o item fica com synced=0 e é reenviado na
próxima varredura — não está escrito em lug

### Duas seções tecidas ao mesmo tempo podem deixar a nuvem com uma a menos
*seção `divida` · estado `PARCIAL`*

**Onde:** lib/features/astrology/presentation/providers/astrology_provider.dart:68-77 (`_filaDePerfil`/`_gravarPerfil`); supabase/perfil_magico_upsert.sql

A metade que dava para fazer no código foi feita: `_filaDePerfil` serializa as gravações
(`_filaDePerfil.then((_) => _repository.saveMagicalProfile(perfil))`, com `catchError`
para a fila não morrer numa falha), e todos os seis pontos de gravação passam por
`_gravarPerfil` (linhas 209, 265, 290, 339, 431). A doc na própria linha 65-67 admite
que a fila só ordena DENTRO de um processo. A guarda de servidor continua NÃO aplicada:
lib/core/services/data_sync_service.dart:752-800 só usa `onConflict` para as tabelas de
uma-linha-por-dia (`user_id,date`) — magical_profiles cai no upsert por PK, sem alvo de
conflito e sem comparação de `updated_at`. O material está preparado e versionado em
supabase/perfil_magico_upsert.sql (trigger BEFORE UPDATE `descartar_escrita_obsoleta`
com `RETURN OLD`, idempotente), mas o cabeçalho do arquivo manda rodar no SQL Editor do
Supabase — é painel, e não foi aplicado.

> **Verificador adversarial não conseguiu refutar.** Nao encontrei nenhuma guarda de servidor (nem equivalente no cliente) aplicada. O
upload do perfil magico segue por astrology_repository.dart:120-137
(saveMagicalProfile) -> data_sync_service.dart:1081-1094 (syncItem) ->
data_sync_service.dart:751-785 (_uploadItem), e nessa ultima o `onConflict` so vale
para _oneRowPerDayTables (daily_magical_weather, daily_checkins); magical_profiles
cai na linha 784 `await _supabase!.from(table).upsert(remoteItem);` sem alvo de
conflito e sem comparacao de updated_at. Nao ha leitura previa do updated_at remoto
nem uniao de conteudo — em contraste com a uniao deliberada de `rites` nas linhas
763-778, que mostra que o padrao estava disponivel e nao foi usado aqui. Nao existe
caminho por RPC (unico `.rpc(` em lib/ e beta_code_repository.dart:127,
`redeem_beta_code`). A busca por `escrita_obsoleta`/`descartar_escrita` no repo
inteiro so casa em supabase/pe

### O ON DELETE CASCADE do banco local é decorativo
*seção `divida` · estado `PARCIAL`*

**Onde:** lib/core/database/database_helper.dart:32-37 (openDatabase sem onConfigure); lib/features/astrology/data/repositories/astrology_repository.dart:143-146

O PRAGMA continua faltando — é o achado literal e ele NÃO foi fechado. `openDatabase` em
database_helper.dart:32-37 passa só path, version, onCreate e onUpgrade; `grep -rn
onConfigure lib/ test/` não retorna nada. Os dois ON DELETE CASCADE seguem declarados e
inertes (database_helper.dart:119 ritual_logs→daily_rituals e :225
magical_profiles→birth_charts, repetidos nas migrações :498 e :616). O que houve foi o
contorno de um caso: astrology_repository.dart:143-146 documenta o defeito por extenso e
expõe `deleteMagicalProfile(birthChartId)`, chamado em
lib/features/astrology/presentation/providers/astrology_provider.dart:221 ao trocar o
mapa — então o perfil órfão daquele fluxo não acontece mais. A FK
ritual_logs→daily_rituals continua sem rede.

> **Verificador adversarial não conseguiu refutar.** Nao consegui refutar. O achado literal — falta o PRAGMA foreign_keys = ON, logo os
ON DELETE CASCADE do SQLite local sao decorativos — continua aberto, e nao ha
conserto por outro caminho nem por outro nome. A unica mencao ao PRAGMA em todo o
repositorio e o comentario em astrology_repository.dart:144, que descreve o defeito
por extenso; e o oposto de prova de conserto. O que existe e o contorno de um caso:
deleteMagicalProfile(birthChartId) (astrology_repository.dart:146), chamado ao
trocar o mapa, resolve o perfil orfao daquele fluxo. A FK ritual_logs ->
daily_rituals segue sem rede (embora hoje nao haja caminho de exclusao de
daily_rituals no app fora da limpeza de conta, o que e acidente, nao decisao
registrada). Procurei tambem por identificadores em portugues (estrangeira, orfa,
cascade, apagarRitual/removerRitual) e por decisao explicita em comentario ou
commit: nada. Estado PARCI

### "Tecer de novo" que falha volta ao texto antigo sem dizer nada
*seção `metade` · estado `PARCIAL`*

**Onde:** lib/features/astrology/presentation/pages/magical_profile_section_page.dart:161-165 (ainda mostra o texto antigo) vs. astrology_provider.dart:38, 80-87, 389-402, 433-442 (falha por seção, feita)

A metade do erro global FOI feita: `_error`/`lastFailureWasRateLimit` deixaram de
governar as seções — existe `Map<String,_FalhaDaSecao> _falhas`, com erroDaSecao(key) e
falhaDeLimiteNaSecao(key), e a resposta vazia também marca falha (:402).
`lastFailureWasRateLimit` não existe mais no provider. A metade do TÍTULO continua em
pé: em `switch ((tecendo, secao))` o ramo `(false, ProfileSection s)` vem ANTES do ramo
de falha, e num 'tecer de novo' que falha a seção antiga continua gravada (o texto velho
só é removido depois do sucesso, provider :414-418) — então a tela volta a exibir o
texto antigo e o ramo _Falhou nunca é alcançado. `_tecer()` (:120-131) não mostra
SnackBar nenhum. A falha segue silenciosa nesse caminho.

> **Verificador adversarial não conseguiu refutar.** Nao encontrei o conserto, com nenhum nome/caminho alternativo. A metade "falha por
secao" realmente foi feita (Map<String,_FalhaDaSecao> _falhas, erroDaSecao,
falhaDeLimiteNaSecao, resposta vazia marcando falha), mas a metade do titulo
continua em pe: num "tecer de novo" que falha a secao antiga permanece gravada de
proposito (astrology_provider.dart:409-418, comentario "a antiga so sai depois que a
nova chega"), e o switch da tela testa `(false, final ProfileSection s)` ANTES do
ramo de falha, entao _Falhou nunca e alcancado e a tela volta ao texto velho.
_tecer()/_tecerDeNovo() nao leem erroDaSecao apos o await nem mostram SnackBar —
grep por SnackBar/ScaffoldMessenger em lib/features/astrology/ nao tem nenhuma
ocorrencia neste arquivo, e erroDaSecao/falhaDeLimiteNaSecao tem um unico consumidor
em lib/ (o ramo inalcancavel). Nenhum commit posterior toca o arquivo e nenhum
comentario/co

### Sem rede, o card do Perfil Mágico mostra o dump cru da exceção
*seção `metade` · estado `PARCIAL`*

**Onde:** lib/core/ai/ai_service.dart:37-40 (_falhaDeConexao, feito) vs. :297-298 (rethrow do DioException não-429 em generateMagicalProfileSection)

O saneamento existe e foi aplicado amplamente: `_falhaDeConexao` loga o detalhe do Dio e
devolve aiPrompts.errorConnection, usado em :192, :672, :1210, :1415, :1459, :1579 etc.
Mas o caminho DESTE card não passa por ele: em generateMagicalProfileSection o `on
DioException catch (e) { if (e.response?.statusCode != 429) rethrow; }` deixa a exceção
de rede escapar crua (nem _textRequest nem _textCall a embrulham — _textRequest:714-716
só faz rethrow), e AstrologyProvider.generateProfileSection (:438-442) põe
`'$e'.replaceAll('Exception: ','')` na tela — ou seja, o toString do DioException (com
host/URI do provedor dentro) volta a aparecer no card, exatamente no caminho de falta de
rede. Também não achei teste novo cobrindo isso;
test/ai_prompts_parity_test.dart:155-157 só verifica que a STRING errorConnection não
tem payload.

> **Verificador adversarial não conseguiu refutar.** Nao consegui refutar: o caminho do card do Perfil Magico continua sem saneamento no
HEAD (46b4677, working tree limpo). Verifiquei todas as rotas possiveis de conserto
e nenhuma existe:  1) O saneador existe e e real, mas nao cobre esta chamada.
`_falhaDeConexao` (lib/core/ai/ai_service.dart:37-40) e aplicado via `throw
Exception(_falhaDeConexao(e))` em exatamente 11 pontos (linhas 192, 672, 1210, 1415,
1459, 1579, 1641, 1668, 1703, 1752 — grep completo de `_falhaDeConexao`). NENHUM
deles esta dentro de `generateMagicalProfileSection` (ai_service.dart:263-318). Ali
o unico catch e `on DioException catch (e) { if (e.response?.statusCode != 429)
rethrow; ... }` (ai_service.dart:297-298) — numa falta de rede `e.response` e null,
logo `null != 429` e a DioException sai crua.  2) As camadas intermediarias nao
embrulham. `_textRequest` (ai_service.dart:683-748) so faz `catch (e) { if (fallback

### A documentação manda desligar a checagem de nonce no Supabase
*seção `voltar` · estado `PARCIAL`*

**Onde:** docs/GOOGLE_SIGNIN_SETUP.md:155, :157-179, :249; lib/features/auth/data/repositories/supabase_auth_repository.dart:195-199, :225-230

Metade em código/doc: FEITA. As referências do relatório (155, 192) foram conferidas
contra a versão antiga via `git show 2bfb83e:docs/GOOGLE_SIGNIN_SETUP.md` — a linha 155
realmente dizia "Ative se a opção existir" e a linha ~192 da tabela de troubleshooting
dizia "Skip nonce checks ligado". Hoje a 155 diz **"Deixe DESLIGADO"**, e o bloco
157-179 explica que a opção não é por provedor nem por plataforma, que ela vale para o
projeto inteiro, e que se o fluxo nativo Android passar a recusar o certo é fazê-lo
mandar nonce, não desligar a conferência do projeto todo. A linha da tabela de
troubleshooting migrou para 249 e agora diz "**Não** ligue 'Skip nonce checks' para
resolver isto" — a referência :192 do relatório está desatualizada, ali hoje há texto
sobre Callback URL. O nonce do caminho web está de fato implementado como o doc afirma:
cru para o Supabase e sha256 para o Google (supabase_auth_repository.dart:198-199,
:225-230). Metade em painel: NÃO FEITA e não fazível daqui — "conferir se está ligada"
exige o painel do Supabase, e o próprio doc reconhece isso em :177-178.

> **Verificador adversarial não conseguiu refutar.** Procurei ativamente por um conserto alternativo (outro arquivo, nome em português,
guarda de CI, config declarativa, verificação local do nonce, decisão registrada em
commit) e NÃO achei nada que cubra a metade que o outro agente diz faltar. O que
existe confirma o diagnóstico PARCIAL dele:  1) Metade doc/código: FEITA, como ele
disse. docs/GOOGLE_SIGNIN_SETUP.md:155 hoje diz "Deixe DESLIGADO", o bloco :157-179
explica que a opção vale para o projeto inteiro e que o certo é fazer o fluxo nativo
mandar nonce, e a linha de troubleshooting migrou para :249 ("Não ligue 'Skip nonce
checks' para resolver isto"). O nonce do caminho web está implementado (cru para o
Supabase, sha256 para o Google) em
lib/features/auth/data/repositories/supabase_auth_repository.dart:195-199 e
:225-230, e lib/features/auth/data/services/google_one_tap_web.dart:24-31,:68.  2)
Metade painel: NÃO coberta em lugar nen


## Achados que se mostraram FALSOS

A premissa do relatório não bateu com o código.

### O que foi tecido antes do login fica órfão — e some da tela
*seção `dinheiro` · estado `FALSO`*

**Onde:** git show e275bba:lib/core/database/database_helper.dart:1251-1275 (claimLegacyData JA existia antes da branch, com 'birth_charts' e 'magical_profiles' na lista) e :1295-1338 (JA reescrevia o userId DENTRO dos blobs chart_data e profile_data); lib/features/auth/presentation/providers/auth_provider.dart:641 (claimLegacyData roda antes de _currentUser = user e antes do notifyListeners de :670)

A premissa nao se sustenta para astrologia. E verdade que astrology_provider nasce com
_currentUserId = 'local_user'
(lib/features/astrology/presentation/providers/astrology_provider.dart:41) e que
setUserId (:118) consulta por user_id sem fallback — mas quando o setUserId roda
(main.dart:354-424, via ChangeNotifierProxyProvider sobre o AuthProvider) as linhas ja
foram reatribuidas: syncAuthenticatedUser chama claimLegacyData(user.id) na PRIMEIRA
linha (auth_provider.dart:641), antes de publicar o usuario novo. O mapa astral e o
Perfil Magico ja estavam cobertos, blob incluso. O buraco real era outro e foi fechado:
a lista era escrita a mao e tinha perdido tarot_readings — agora e derivada do enum
(database_helper.dart:1261-1266, `for (final entity in SyncEntity.values)
DataSyncService.localTableFor(entity)`), e SyncEntity.tarotReadings existe em
data_sync_service.dart:42/716. Ou seja: o defeito descrito nao existia; um vizinho dele
existia e foi corrigido.


## Bloqueados em painel

Exigem painel externo, credencial ou aparelho. Nenhum é trabalho de código.

### --- Quantas pessoas usam o app hoje?
*seção `cegos` · estado `BLOQUEADO_PAINEL`*

**Onde:** pubspec.yaml:22-100 — bloco `dependencies` sem nenhum pacote de analytics/telemetria; a única contagem possível vem de `public.profiles`, definido em supabase/restore_database.sql

Responder exige o painel do Supabase (SQL Editor / Table Editor). Não há material no
repositório que dê o número, e — pela consequência do item anterior — não há como o app
reportar. Nada foi preparado nesta branch nesse sentido.

### --- O banco tem backup?
*seção `cegos` · estado `BLOQUEADO_PAINEL`*

**Onde:** docs/SUPABASE_RESTORE.md:1-6 — é guia de RECRIAÇÃO de esquema ("recria o ambiente do zero em ~15 minutos"), apoiado em supabase/restore_database.sql; a premissa escrita ali é "o app usa SQLite local como fonte primária"

Existe material preparado, mas ele responde outra pergunta: docs/SUPABASE_RESTORE.md +
supabase/restore_database.sql restauram ESTRUTURA, não DADOS. Política de backup/PITR é
configuração do painel do Supabase (Settings → Database → Backups) e não dá para
conferir daqui. O ponto cego do relatório também segue de pé no código: a premissa
"SQLite local é a fonte primária" enfraqueceu agora que o sync foi aberto para todo
mundo (commit db80c6e, "Abrir a sincronizacao para todo mundo, e as duas pontas"), e no
iOS web o localStorage cai pela regra dos 7 dias.

### --- O iOS está publicado?
*seção `cegos` · estado `BLOQUEADO_PAINEL`*

**Onde:** ios/Runner/Info.plist:17 — `ca-app-pub-3940256099942544~1458002511`, que é o app ID de TESTE do Google, ainda no lugar

Saber se está publicado exige App Store Connect. As três premissas do relatório, porém,
eu confirmei no código, com uma correção: (a) "sem CI" é impreciso como frase geral —
existem .github/workflows/branch-validate.yml e release.yml —, mas é exato para iOS:
branch-validate.yml:66-76 diz, por escrito, "**o iOS não é compilado por job nenhum
desta esteira**" e explica que fechar isso exige runner macOS, que é decisão de custo.
(b) Sem Google Sign-In nativo: `ls ios/Runner/` traz só AppDelegate.swift,
Assets.xcassets, Base.lproj, Info.plist e Runner-Bridging-Header.h — não há
GoogleService-Info.plist, e não há GIDClientID no Info.plist. (c) AdMob de teste
confirmado acima; o Android tem identificador real
(android/app/src/main/AndroidManifest.xml:61). O mesmo comentário de branch-
validate.yml:72-76 já registra as três pendências no repositório — é o material
preparado que existe para este item.

### Este redesenho depende de dois itens já decididos
*seção `convite` · estado `BLOQUEADO_PAINEL`*

**Onde:** supabase/profiles_lockdown_migration.sql:54-101 (REVOKE de escrita, SELECT preservado) e :103-125 (por que nao ha funcao de contador a criar); lib/features/subscription/presentation/widgets/subscription_offer_widgets.dart:313-317 (a sincronizacao saiu sem substituto)

Item (2) esta feito no codigo: a linha de sincronizacao saiu da lista de beneficios e
nao foi trocada por outra linha — grep por premiumBenefitSync em lib/ nao acha nenhum
uso, e o substituto e a propria pagina de descoberta. Item (1) depende do SQL Editor do
Supabase: o material esta versionado em supabase/profiles_lockdown_migration.sql, que
faz exatamente o que o relatorio pediu — tranca a ESCRITA (REVOKE INSERT, UPDATE ...
FROM authenticated na linha 71, com GRANT por coluna sem nenhuma coluna de contador) e
preserva a LEITURA, com o motivo escrito no arquivo (linhas 60-62: "o card de Uso do
Plano Gratuito exibe os contadores, entao a LEITURA precisa sobreviver ao corte"). A
parte "funcao SECURITY DEFINER" do achado esta contestada no proprio arquivo (linhas
105-118): o repo nao tem NENHUMA escrita de contador vinda do cliente (as colunas
*_today so sao lidas em supabase_auth_repository.dart:688 e vizinhas; quem guarda o uso
do dia e o SharedPreferences via auth_provider), entao criar a funcao abriria um caminho
de escrita que hoje nao existe. Rodar o arquivo continua sendo acao de painel. ALERTA DE
COERENCIA — coberto pela metade, e aqui o codigo contradiz a mensagem de commit: o selo
dourado de Premium foi ligado apenas para a Quiromancia (daily_rites_card.dart:97,
featuredId == DailyRites.palmistry) sob a alegacao de que so ela e exclusiva. Nao e: o
rito natureIdentify so e marcado apos uma identificacao real
(add_entry_page.dart:156-161), e essa identificacao exige
AppFeature.encyclopediaPersonalEntries (add_entry_page.dart:88-93), que nao esta em
freeFeatures nem no mapa de limites (feature_access.dart:369-408), caindo em
AccessResult.preview — hasFullAccess falso. Ou seja, nos dias de Guia da Natureza o Free
tambem nao fecha o dia, e ali o rito aparece com a setinha comum, exatamente como
"tarefa falhada" — que era o risco que o relatorio mandou conferir. A contagem do dia
(total = 3, daily_rites_card.dart:101) tambem nao foi mexida, o que e decisao declarada,
nao esquecimento.

### Qualquer conta pode se promover a admin com uma requisição — uma política de banco sem trava de coluna
*seção `decisoes` · estado `BLOQUEADO_PAINEL`*

**Onde:** supabase/profiles_lockdown_migration.sql:53 (REVOKE ALL ... FROM anon), :72 (REVOKE INSERT, UPDATE ... FROM authenticated), :75-101 (GRANT por coluna, sem role/plan/contadores), :136-141 (WITH CHECK), :150-155 (política de DELETE)

O material está inteiro e versionado, mas o efeito só existe depois de alguém rodar o
arquivo no SQL Editor do Supabase — nada no repo aplica DDL. O arquivo também endurece
as duas funções SECURITY DEFINER que escrevem em profiles (redeem_beta_code e
handle_new_user) com SET search_path = public, e a redeem_beta_code passa a ignorar
p_user_id quando há sessão. Confere com a descrição do relatório.

### As origens do Google no painel — é o que ainda falta para o login novo funcionar
*seção `decisoes` · estado `BLOQUEADO_PAINEL`*

**Onde:** docs/AMBIENTES_WEB.md:100-120 (seção "4. Google Cloud — Authorized JavaScript origins", com o sintoma origin_mismatch e o passo a passo das origens a cadastrar)

Ação no Google Cloud Console; o repo tem o passo a passo preparado, mas nada no código
pode substituí-la.

### Os preços novos nas lojas — o código só carrega os valores de reserva
*seção `decisoes` · estado `BLOQUEADO_PAINEL`*

**Onde:** lib/features/auth/presentation/widgets/premium_blur_widget.dart:462-467 (fallbacks 'R$ 19,90', 'R$ 119,90', 'R$ 249,90', com o comentário "Só aparecem enquanto a loja não respondeu")

Depende de App Store Connect / Google Play / RevenueCat. Não encontrei nenhum documento
em docs/ com o passo a passo dos preços novos — só o valor de reserva no código.

### O resgate de Código Premium continua — muda de lugar, não de existência
*seção `decisoes` · estado `BLOQUEADO_PAINEL`*

**Onde:** supabase/profiles_lockdown_migration.sql:171-233 (CREATE OR REPLACE FUNCTION public.redeem_beta_code ... SECURITY DEFINER SET search_path = public) e supabase/restore_database.sql:460-515; o lado do app já chama a RPC em lib/features/auth/data/repositories/beta_code_repository.dart:127

O app está pronto: a RPC é o caminho preferido e o UPDATE direto em role/plan virou
fallback documentado como condenado (beta_code_repository.dart:236-265). A criação de
cupons não foi tocada — continua INSERT do cliente em beta_codes. O que falta é rodar o
SQL no painel do Supabase; enquanto não rodar, o fallback consome o cupom e não entrega
o premium (dito com todas as letras no comentário de :241-246).

### Os contadores diários são trancados no mesmo lote
*seção `decisoes` · estado `BLOQUEADO_PAINEL`*

**Onde:** supabase/profiles_lockdown_migration.sql:75-101 (as colunas *_today, spells_count e diary_entries_this_month ficam FORA do GRANT de INSERT/UPDATE) e :104-127 (seção 2b, que documenta por que não houve função SECURITY DEFINER de contador)

Meia decisão executada, meia recusada com razão. O REVOKE por coluna fecha o buraco de
zerar os próprios limites — mas só depois de rodar no painel. A outra metade ("passam a
ser atualizados por função SECURITY DEFINER") NÃO foi feita, de propósito: conferi e a
premissa é falsa — em
lib/features/auth/data/repositories/supabase_auth_repository.dart:686-692 há sete
LEITURAS dessas colunas e nenhuma escrita no repositório inteiro; quem guarda o uso do
dia é o SharedPreferences. Criar a função abriria um caminho de escrita que hoje não
existe.

### Qualquer conta autenticada pode se promover a admin — confirmado em produção
*seção `dinheiro` · estado `BLOQUEADO_PAINEL`*

**Onde:** supabase/profiles_lockdown_migration.sql:55 (REVOKE ALL ... FROM anon), :72 (REVOKE INSERT, UPDATE ... FROM authenticated), :75-101 (GRANT por coluna, sem role/plan/contadores), :133-149 (WITH CHECK no UPDATE + policy de DELETE), :173-177 (redeem_beta_code SECURITY DEFINER SET search_path); lib/features/auth/data/repositories/beta_code_repository.dart:127

Material preparado e completo no repo, mas o SQL precisa ser rodado no SQL Editor do
Supabase — nada disso vale enquanto o painel nao for tocado. O lado do app ja mudou: o
resgate chama primeiro a RPC atomica (beta_code_repository.dart:127
supabase.rpc('redeem_beta_code')), e a escrita cliente de role/plan sobrou so como
fallback para projeto sem a RPC (beta_code_repository.dart:258-260), documentado como
'sera NEGADA pelo banco depois da migracao' (:240-246). O passo 1 do relatorio foi
seguido com uma diferenca deliberada: SELECT continua inteiro para authenticated
(migration:61-64, o card de uso do plano le os contadores) e a assinatura da RPC ficou
redeem_beta_code(p_code, p_user_id) para suportar resgate sem login, com auth.uid()
prevalecendo sobre o parametro (migration:180). O 'fica de fora de proposito' dos
contadores diarios foi invertido com justificativa verificavel na propria migracao
(:104-118): a auditoria supos escrita cliente dos contadores, e nao ha nenhuma — as
colunas ficaram fora do GRANT, que fecha o buraco sem codigo novo. Confirmei: grep de
'plan'/profiles em lib nao acha escrita de contador.

### As origens JavaScript no Google Cloud continuam vazias
*seção `voltar` · estado `BLOQUEADO_PAINEL`*

**Onde:** docs/AMBIENTES_WEB.md:100-134 (seção "4. Google Cloud — Authorized JavaScript origins"); lib/core/config/google_signin_config.dart:50-53; docs/AMBIENTES_WEB.md:149-151

Preencher o painel do Google Cloud é fora do código — continua pendente. O que o repo
podia preparar foi preparado: a queixa "não está documentado em lugar nenhum do
repositório: é a quarta lista de permissões externa e a única que não aparece no
documento de ambientes" deixou de valer. docs/AMBIENTES_WEB.md ganhou a seção 4 com o
caminho no painel (APIs & Services → Credentials → client OAuth Web), os valores a
colar, o aviso de que o Google não aceita curinga, a propagação de 5min-a-horas e uma
tabela dizendo o que acontece se faltar em cada uma das duas listas. DIVERGÊNCIA
DELIBERADA do relatório: o relatório pedia TRÊS origens, incluindo a prévia de branch
`https://claude-ciclos-de-vida-featur.grimorio-de-bolso.pages.dev`. O repo documenta e
autoriza só DUAS (produção e staging) — google_signin_config.dart:50-53 — e
google_signin_config.dart:45-49 explica a exclusão: o endereço de prévia nasce a cada
branch, autorizá-lo exigiria mexer no painel e recompilar, e a recompilação muda o
endereço de novo. Prévias caem no redirecionamento de propósito.


## Mantidos como estão, por decisão explícita

O relatório os marca como decisão, não esquecimento.

### Ritos do Dia e a degustação da lição ficam como estão
*seção `decisoes` · estado `MANTEM_COMO_ESTA`*

**Onde:** lib/features/auth/data/models/feature_access.dart:316-320 e :441 (aiPalmistry segue exclusiva Premium) e lib/features/learning/presentation/pages/lesson_page.dart:91-97 (_teachingSample devolve o primeiro parágrafo REAL de lesson.teaching), renderizado em :551-576

Decisão respeitada: nenhum gate foi afrouxado. O que mudou em
lib/features/your_day/presentation/widgets/daily_rites_card.dart:89-98, :162 e :369-376
é só a APARÊNCIA — o rito premium do revezamento ganha selo dourado em vez de parecer
tarefa falhada; a contagem do dia e o acesso continuam iguais. Registro a correção de
premissa que o commit 165480b levanta e eu confirmei: no revezamento de seis ferramentas
só a Quiromancia é premium-only (uma, não duas), e o dia tem três ritos, não seis.

### Porta da Leitura do Ciclo na página de assinatura
*seção `decisoes` · estado `MANTEM_COMO_ESTA`*

**Onde:** lib/features/subscription/presentation/pages/subscription_page.dart:117-122 — _buildCycleReadingCard() renderizado nos dois ramos, com o comentário explicando que é aviso de compra avulsa, não descoberta

Mantida, como a decisão determinou. O relatório apontava :114-118 e :543-587; o card
hoje é chamado em :122.


## Cobertos e verificados

- "Cancele a qualquer momento" aparece com o Vitalício selecionado
- "Voltar nunca sai do app": ainda não vale para todo mundo
- --- Publicar o que já está pronto antes de empilhar o plano?
- 54 chaves órfãs nos ARBs, e o check de paridade não vê órfã
- A Quiromancia mostra "3 leituras restantes hoje" para quem não pode fazer nenhuma
- A causa raiz da travada foi contornada, não corrigida
- A compra avulsa pode cobrar e não entregar nada — e não há como recuperar
- A compra avulsa que cobra e não entrega — uma linha de catch
- A isca das Eras está travada — e é a única sem cadeado
- A isca das Eras está travada, e sem cadeado
- A página de Assinatura passa a falar a mesma língua
- A seção de rituais é localizada pelo título no idioma atual
- As pílulas de lua e ingredientes do ritual são apagadas antes de alguém poder lê-las
- Corrigir os dados de nascimento faz a Análise Personalizada sumir sem aviso
- Limite diário do Guia da Natureza
- Na Leitura do Ciclo, o "destaque" virou cor sem peso
- Na aba Ciclos, um erro de banco deixa o botão desabilitado para sempre
- Na web, a compra não é ligada à conta — o SDK nunca é inicializado ali
- Na web, o RevenueCat nunca é associado à conta
- Nenhum documento acompanhou 16 commits
- No paywall, a linha de sincronização apenas sai
- O app_pt.arb que todo mundo edita primeiro nunca chega à tela
- O cache das Eras sobrevive ao logout
- O card "Uso do Plano Gratuito" mostra o contador errado
- O card mostra três limites; o app tem sete
- O convite ao Premium é redesenhado
- O grimório de quem não é Premium só existe naquele aparelho — e o iOS o apaga sozinho em 7 dias
- O grimório do Free que o iOS apaga em 7 dias — resolvido por ligar o sync no Free
- O guarda de endereço efêmero cobre só uma das formas de URL de prévia
- O isPro não tem o guarda que o isLifetime tem
- O isPro sem o guarda que o isLifetime tem
- O perfil tecido antes do login não vai junto para a conta
- O scanner de português cravado só enxerga acento
- O toque no card abre "o que você ainda não viu", não a tabela de preços
- Os itens sem decisão explícita seguem estes defaults
- Perfis antigos da Análise Personalizada
- Preço do Vitalício
- Quinze dos dezesseis perfis em produção nunca verão os dez cards
- Rituais Guiados passa a seguir o fluxo livre
- Se a chave do Google faltar no release, a produção volta ao defeito em silêncio
- Seis segundos parados antes de desistir, e o erro do Supabase é engolido
- Selo de economia
- Sincronização na nuvem para todos, sem paywall
- Sobrou uma degustação: "O começo desta lição"
- Um ## solto vindo da IA some com os dez cards da Análise
- Um Text('') de 28pt abre o cabeçalho de "Seus Planetas nos Signos"
- Um boot com rede ruim deixa "planos indisponíveis" pela sessão inteira
- Vale mostrar os limites — mas não como placar
- ✓ A lista de benefícios muda ao escolher o Vitalício — e as duas promessas novas são verdade no código
- ✓ A seção não nasce mais dizendo que falhou
- ✓ Análise Personalizada em dez cards, com páginas que deslizam
- ✓ Avisos de venda tipo "O Conselheiro teceria assim": fora
- ✓ Blur restrito à Análise Personalizada
- ✓ Emoji do signo removido de "Seus Planetas nos Signos"
- ✓ Geração só ao abrir o card, com trava por seção e retry de limite
- ✓ Mapa Astral sem dado premium e sem paywall
- ✓ Nenhum "ainda não tecida" na tela
- ✓ Perfil alimentando a Leitura do Ciclo pelo composer
- ✓ Prévias que gastavam IA: todas fora (menos a da lição)
- ✓ Texto gravado no Supabase de verdade — comprovado no banco de produção
- ✓ Três planos lado a lado, com o card do Vitalício antigo removido inteiro
- ✓ Ícone do PWA com o anel lilás, e o apple-touch-icon próprio
