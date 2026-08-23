# Plano unificado — os dois relatórios, cruzados entre si e contra o código

> **Este documento é a verdade operacional.** Os dois relatórios
> (`AUDITORIA_TECNICA_AGO2026.md` e `AUDITORIA_PRODUTO_AGO2026.md`) são a
> fonte; este é o estado. Quando divergirem, vale o que está aqui — porque
> aqui cada item foi conferido contra o código de hoje, e o código andou
> desde que os relatórios foram escritos.

**Atualizado em:** 23/08/2026
**Branch:** `claude/tombstone-sync-qvki0e` (continua a
`claude/artifact-access-aea6wn`, 28 commits) — nenhum PR aberto
**Validação:** a CI da branch. Não há Flutter neste ambiente (o host do SDK
é bloqueado pela política de rede da sessão). Nada aqui foi executado
localmente; o que está marcado como verificado foi verificado pela CI ou
por leitura do código, e a distinção está dita item a item.

---

## 1. Como ler isto

Três regras que valem para quem continuar o trabalho — pessoa ou agente:

1. **Comece por aqui, não pelos relatórios.** Os relatórios têm achados que
   já foram corrigidos, achados que se mostraram falsos e achados que se
   contradizem. Ler qualquer um deles isolado leva a refazer trabalho ou a
   desfazer decisão tomada.
2. **O que está marcado como decidido não reabre.** Isso inclui os "mantém
   como está" do relatório técnico: são decisão explícita, não esquecimento.
3. **Os seis conflitos da seção 3 não são para um agente resolver
   sozinho.** São escolhas de produto com custo em dinheiro e em usuária.
   Estão descritos com o custo de cada lado, prontos para decisão.

---

## 2. O que cada relatório é

| | Técnico (`c7517a52`) | Produto (`4c68fa06`, revisão 2) |
|---|---|---|
| Olha para | Código, segurança, esteira, dívida | Receita, retenção, funil, base de 116 contas |
| Tamanho | ~60 achados em 6 fases | 111 itens cruzados |
| Estado | **executado** — as 6 fases foram implementadas nesta branch | 12 feitos · 75 abertos · 6 em conflito · 4 falsos · 14 travados em painel |
| Confiabilidade | alta; os `arquivo:linha` estavam quase todos certos | média; ver seção 4 — quatro premissas não se sustentam |

O relatório técnico foi escrito para ser executado e foi. O de produto foi
escrito para ser decidido, e é aí que ele está parado.

---

## 3. Os seis conflitos — decisão pendente

Cada um destes tem os dois relatórios dizendo coisas opostas sobre o mesmo
código. Nenhum foi resolvido por conta própria.

### 3.1 Congelar preço vs. publicar preço novo

- **Produto (decisão 12):** congelar os preços atuais até o funil estar
  medido. Mexer em preço sem analytics é apostar no escuro.
- **Técnico:** os valores novos são bloqueio de release — o app mostra um
  preço e a loja cobra outro.
- **Código hoje:** os valores em vigor são R$ 19,90 (mensal), R$ 119,90
  (anual), R$ 249,90 (vitalício), R$ 4,99 (leitura semanal) e R$ 9,99
  (leitura mensal), confirmados por você em 22/08.
- **Onde eles se cruzam:** não é o mesmo assunto. "Congelar" é sobre
  *mudar* o preço; "bloqueio de release" é sobre a tela *mentir* sobre o
  preço que já existe. Dá para fazer os dois: corrigir a exibição para
  bater com a loja **e** não mexer no valor.
- **Recomendação:** fazer os dois. Não é conflito real, é ambiguidade de
  redação — mas precisa da sua confirmação de que "congelar" significa
  congelar o valor, não congelar a correção.

### 3.2 Destravar a degustação da lição

- **Produto:** destravar — a pessoa gratuita nunca vê o que está comprando.
- **Técnico:** *"mantém como está. Não mexer."*
- **Código hoje:** a degustação **existe e é renderizada**
  (`lesson_page.dart:567`, `TeaserReveal`). O que impede de vê-la são dois
  interceptadores antes dela: `trail_page.dart:59` e `lesson_page.dart:86`.
  **O relatório técnico está factualmente errado sobre o estado** — ele
  descreve um teaser que não existe; ele existe e está atrás de porta.
- **Consequência:** o "não mexer" foi dado sobre uma premissa errada.
  Precisa ser reafirmado ou revogado com o estado real na mesa.
- **Custo de destravar:** duas condições nos interceptadores. Baixo.

### 3.3 Rito do dia filtrado por plano

- **Produto:** filtrar por plano — a gratuita vê rito que não pode abrir.
- **Técnico:** o rito do dia é benefício Premium; mantém.
- **Feito:** implementado o caminho técnico — o rito continua aparecendo,
  com selo dourado, como vitrine deliberada em vez de porta fechada.
- **Fica assim** salvo decisão contrária.

### 3.4 Inverter o paywall da enciclopédia

- **Produto:** liberar os detalhes — o conteúdo trancado é justamente o que
  traria busca orgânica, e o Google não indexa o que não pode ler.
- **Técnico:** "Enciclopédia com conteúdos completos" é um dos quatro
  benefícios Premium que sobraram no convite redesenhado.
- **Tensão real:** liberar esvazia um dos quatro pilares do convite que
  acabou de ser redesenhado (commit `6792904`). Não dá para fazer os dois.
- **O que pesa de cada lado:** SEO só vale se houver versão web indexável —
  e o app é Flutter web, que o buscador lê mal de qualquer jeito. Antes de
  trocar receita por SEO, vale medir se a busca orgânica é sequer possível
  na arquitetura atual.
- **Recomendação:** manter trancado até existir página estática de
  conteúdo. Aí a discussão muda de natureza.

### 3.5 Free consegue fechar o dia

- **Produto:** a gratuita precisa conseguir completar um dia inteiro, senão
  não há hábito para converter.
- **Técnico:** os limites do plano gratuito são o que são.
- **Estado:** o convite redesenhado (`convite_do_plano.dart`) já mostra o
  limite antes de a pessoa esbarrar nele, o que ataca o sintoma. Se o
  fechamento do dia é possível hoje dentro dos limites, ninguém mediu.
- **Falta:** contar, com dados, quantas contas gratuitas fecham um dia.
  Depende de analytics (decisão 6), que depende de consentimento (3.6).

### 3.6 Analytics vs. consentimento

- **Produto (decisão 6):** ligar PostHog e tabelas próprias.
- **Produto (decisão 9), no mesmo relatório:** o toggle
  `privacy_analytics` existe na tela e **não controla nada**; as 116 contas
  nasceram sob um checkbox sem versão nem timestamp.
- **Conflito interno ao relatório 2:** ligar processador terceiro sobre um
  toggle que mente é pior do que não ter toggle — ainda mais num app onde
  a pessoa escreve sobre crença e sofrimento.
- **Ordem obrigatória:** honrar o toggle → pedir consentimento versionado →
  só então instrumentar. Nunca na ordem inversa.
- **Preparado:** `supabase/marcar_contas_de_teste.sql` marca as contas de
  equipe para o funil nascer limpo. Não aplicado (é painel).

---

## 4. O que o relatório de produto afirma e o código desmente

Quatro premissas não se sustentam. Quem construir em cima delas constrói no
vazio.

1. **A consulta a `auth.audit_log_entries`.** A errata do próprio relatório
   diz que a tabela está vazia. Toda conclusão de comportamento tirada dali
   é inferência sem dado.
2. **"Dois anos de dados".** O projeto Supabase expirou e foi recriado. A
   coorte mais antiga tem ~5 semanas. Nenhuma série longa existe.
3. **"Liberar significado de cartas e runas".** Já é gratuito. O achado
   descreve uma trava que não está lá.
4. **"Ninguém rodou um SELECT".** A mesma revisão do relatório contém os
   resultados de SELECTs. Contradição interna.

**E uma correção de base que muda a leitura toda:** dos 15 usuários com
dado no servidor, 12 são testadoras recrutadas — a sincronização era
Premium, e o pool Premium são os 20 códigos beta. A frase "o produto
retém" está apoiada numa amostra enviesada por construção. Com 5 contas de
equipe e ~20 testadoras, quase um terço da base não é usuária.

---

## 5. O que já está feito nesta branch

26 commits. Por assunto:

**Segurança e dado**
- `profiles` fechado por coluna (GRANT/REVOKE) e exclusão de conta completa
- função de concessão de Premium vitalício tirada do `anon`
- rastro na falha de upload que morria num `debugPrint`

**Dinheiro**
- três caminhos em que a compra sumia, fechados
- `isPro`, compra avulsa e RevenueCat na web
- preço da leitura corrigido no comentário que explicava o risco

**Sincronização**
- aberta para todo mundo, nas duas pontas (era Premium)
- **tombstone/lápide**: item apagado não ressuscita mais no download. O
  `deleteItem` grava a lápide antes de qualquer guarda de rede; as
  varreduras sincronizam exclusões antes de entidades; edição/recriação
  mais nova que a exclusão vence (regra `mostRecent`). Local na v23 do
  banco; o lado do servidor é `sync_tombstones_migration.sql` (seção 7).
  Teste antes-e-depois: o commit só com o teste ficou vermelho na CI
  reproduzindo a ressurreição, o seguinte ficou verde. Sem dublê do
  método de risco — só a borda de rede virou porta (`ServidorDeSync`)

**Convite ao Premium**
- placar do plano Free trocado por convite que reage ao momento
  (`convite_do_plano.dart`, `cartao_do_convite.dart`,
  `vislumbres_do_premium.dart`, `pagina_de_descoberta.dart`)
- oferta falando a mesma língua do convite

**Web e login**
- o voltar seguro na volta do Google (`guarda_de_voltar_web.dart`,
  `um_de_cada_vez.dart`)
- recusa do Supabase deixou de ser engolida
- origens autorizadas em vez de regex de endereço efêmero
- impressão digital que o login com o Google não reconhece, acusada na CI

**IA**
- intermediário preparado (`supabase/functions/ia/index.ts`, nunca
  executado), chave de provedor fora do cliente atrás de
  `IA_PELO_SERVIDOR`

**Esteira**
- segredo morto (Prokerala) removido da CI — não está em bundle nenhum
- catraca de `use_build_context_synchronously` com teto 26
- guarda de `GOOGLE_WEB_CLIENT_ID` (presença e forma)
- **guarda de `TURNSTILE_SITE_KEY`**: com o Attack Protection ligado no
  painel, publicar sem a site key é publicar um app onde ninguém entra

**Decisões suas, aplicadas**
- sem porta permanente da Leitura do Ciclo
- IA pelo servidor
- sem runner de iOS
- `PRAGMA foreign_keys` fica desligado (ver seção 7)

---

## 6. O que está aberto

**Custa dado se ficar aberto**
- ~~Tombstone / exclusão suave~~ — **feito** (ver seção 5). O que restou
  dele é painel: rodar `sync_tombstones_migration.sql` (seção 7).
- Teste de concorrência do acúmulo por seção.

**Segurança**
- `handle_new_user` com EXECUTE para `anon` — não verificado
- três funções sem `SET search_path`: `create_user_policy`,
  `reset_daily_counters`, `reset_monthly_counters`

**Cobertura**
- `PagedReading`, `PageDots`, `PremiumLockedPreview`, `StaggeredEntrance`:
  zero testes

**Formatação**
- `dart format` em 327 de 576 arquivos. Precisa de Flutter; o passo da CI é
  `continue-on-error`, então o verde dele não diz nada.

**Os 75 itens abertos do relatório de produto** seguem no próprio
documento; a maioria depende das decisões da seção 3 ou de analytics.

---

## 7. O que está travado em painel, credencial ou aparelho

Nada aqui foi contornado. O material está pronto; a execução é sua.

| O quê | Onde | Material pronto |
|---|---|---|
| Rodar os `.sql` | Supabase → SQL Editor | `marcar_contas_de_teste.sql`, `profiles_lockdown_migration.sql`, **`sync_tombstones_migration.sql`** (novo: até rodar, a exclusão não propaga ENTRE aparelhos — no próprio aparelho a ressurreição já está barrada — e as lápides locais ficam pendentes, retentadas a cada varredura) |
| **Ligar "Prevent use of leaked passwords"** | Supabase → Authentication → Attack Protection | está **desligado** no painel (visto em 23/08); é um clique, na mesma tela do captcha |
| Impressão digital do Google | Google Cloud + `google-services.json` | `release.yml:67` espera `54:84:54:75:7F:…`; o arquivo tem só `8BD7BB97…`. Nenhum dos dois é a chave de release |
| Publicar a Edge Function da IA | Supabase → Functions | `supabase/functions/ia/index.ts`, nunca executado |
| RevenueCat, AdMob, App Store, Play | painéis | — |
| Qualquer teste em aparelho | — | — |
| Mesclar PR | — | — |

**Sobre o captcha, agora que o painel foi visto:** são duas peças. O gate
dentro do app (Turnstile → `captchaToken`) não barra robô nenhum — um
crawler chama `POST /auth/v1/signup` direto e nunca vê o app. Quem barra é
a exigência no servidor, e ela **está ligada**. Então foi ela que fechou a
porta das contas fantasma, e as suspeitas que a consulta do `.sql` listar
são de antes disso. A contrapartida é a guarda nova na esteira: com a
exigência ligada, um build sem a site key não cadastra nem entra ninguém.

**Sobre `PRAGMA foreign_keys = ON`** (sua pergunta de 22/08): fica
desligado. `astrology_repository.dart:34` usa `ConflictAlgorithm.replace`,
que no SQLite é DELETE + INSERT. Com as FKs ligadas, esse DELETE cascateia
e apaga o Perfil Mágico — dez chamadas de IA — a cada regravação de mapa. O
`database_helper.dart` tem o comentário longo explicando a ordem exata para
ligar isso algum dia, se um dia valer a pena.

---

## 8. Ordem sugerida

1. ~~Tombstone~~ — feito (seção 5); o `.sql` dele entrou na lista do
   painel.
2. **Decidir os seis conflitos** (seção 3). Metade do relatório de produto
   está parada atrás deles.
3. **Painel**: ligar leaked passwords, rodar os `.sql` (agora três),
   resolver a impressão digital do Google.
4. **Consentimento → analytics**, nesta ordem.
5. Segurança restante (`search_path`, `handle_new_user`).
6. Cobertura e `dart format`.

---

## 9. O que este documento não sabe

- Nada foi rodado localmente. Sem Flutter no ambiente, a CI é o validador,
  e ela roda `analyze`, `test`, `check_arb_sync.sh` e
  `check_hardcoded_pt.sh`. O passo de formatação é `continue-on-error`.
- Os números de negócio do relatório de produto vêm de uma base com quase
  um terço de contas que não são usuárias. Enquanto o `.sql` da seção 7 não
  rodar, toda taxa calculada sobre eles está torta para cima.

---

## 10. Armadilhas deste ambiente

Cada uma destas custou tempo para ser descoberta. Estão aqui para não serem
descobertas de novo.

- **Não há Flutter instalado, e não dá para instalar.** O host do SDK
  (`storage.googleapis.com`) é recusado pela política de rede da sessão;
  `pub.dev` e os espelhos também. Clonar o SDK do GitHub não resolve — o
  primeiro `flutter` baixa o Dart SDK do host bloqueado. **O validador é a
  CI**: empurre para a branch e leia o resultado. Nada de chamar de testado
  o que só foi lido.
- **O passo de formatação da CI é `continue-on-error`.** O verde dele não
  quer dizer nada. São 327 de 576 arquivos fora do `dart format`.
- **A catraca de `use_build_context_synchronously` está exatamente no
  teto** (`TETO=26`, em `branch-validate.yml`). Qualquer `context` novo
  depois de um `await` derruba a CI. É de propósito: o número só desce.
- **`AppLocalizationsPtBr extends AppLocalizationsPt`** — é herança, não
  sobrescrita. Chave que existe só em `app_pt.arb` aparece em pt-BR sem
  erro nenhum, e o `check_arb_sync.sh` é quem pega.
- **`@visibleForTesting` não vale em parâmetro.** Quebra o `analyze`. Para
  abrir um caminho só para teste, documente em prosa (foi o que
  `guarda_de_voltar_web.dart` fez com o campo `naWeb`).
- **`Navigator.maybePop()` devolve `true` quando o `PopScope` recusa.**
  Teste de guarda que asseverar `isFalse` passa a impressão errada — teste
  qual tela ficou na frente.
- **`ConflictAlgorithm.replace` é DELETE + INSERT** no SQLite, e
  `PRAGMA foreign_keys` nasce desligado e vale por conexão. As duas coisas
  juntas são o motivo de as FKs seguirem desligadas (seção 7).
- **Listar runs da CI pela API traz o corpo de todos os commits** e estoura
  o limite de resposta. Filtre por branch e status, ou vá direto no id da
  run.

---

## 11. Perguntas em aberto para a dona do produto

1. **Os seis conflitos da seção 3.** Metade do relatório de produto está
   parada atrás deles.
2. **"Congelar preço" (decisão 12) significa congelar o valor, não congelar
   a correção da exibição** — confirmar. Ver 3.1.
3. **Os e-mails pessoais em `marcar_contas_de_teste.sql` e os números de
   negócio em `AUDITORIA_PRODUTO_AGO2026.md` devem seguir versionados?** O
   `.sql` não funciona sem os e-mails, mas dá para editar a lista antes de
   rodar e reverter o arquivo depois.
