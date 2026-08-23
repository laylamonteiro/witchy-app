# Auditoria técnica — agosto de 2026 (artefato c7517a52)

> Texto extraído do artefato publicado em
> `claude.ai/code/artifact/c7517a52-a18d-4d44-9ad3-ef343cc571bb`.
>
> Guardado aqui porque o artefato vive fora do repositório e este é o
> documento de onde saíram as sete fases implementadas na branch
> `claude/artifact-access-aea6wn`. O estado de cada achado está em
> `docs/PLANO_UNIFICADO.md`.
>
> A formatação é do extrator (o original é HTML) — o conteúdo é integral.

---

Auditoria do Grimório

• 

• 

• 

Grimório de Bolso · 22 de agosto de 2026

########## O que foi pedido, o que foi entregue

Auditoria da sequência de trabalho que vai do card do Vitalício até a entrada com o
Google sem sair da aba. Quase tudo o que você pediu está no app. O que sobrou não é
pedido inacabado — é dinheiro, dado e acesso que podem se perder por caminhos que
ninguém percorre em teste.

Escopo

16 commits, já mesclados na main pelo PR #245

Método

29 agentes em duas frentes, cada achado passado por um verificador adversarial — 1.844 buscas no código

Em produção

Nada. O PR #246 (v2.0.31) está aberto e é ele que publica

Confiança

Tudo verificado. Os itens graves eu também conferi à mão; dois achados caíram na verificação

8custam dinheiro, dado ou acesso

13pedidos entregues pela metade

14dívida com consequência real

14pedidos entregues inteiros

Os agentes levantaram cerca de 230 achados. Aqui estão os 49 que mudam alguma decisão
sua; o resto é ruído de lint, nome de variável e sobra cosmética. Dois achados foram
derrubados na verificação e saíram daqui.

===== Por onde começar

• Qualquer conta pode se promover a admin com uma requisição — uma política de banco sem trava de coluna

• As chaves da Groq e da Gemini publicadas no site — qualquer pessoa extrai do JavaScript

• A compra avulsa que cobra e não entrega — uma linha de catch

• Na web, a compra não é ligada à conta — o SDK nunca é inicializado ali

• O grimório do Free que o iOS apaga em 7 dias — resolvido por ligar o sync no Free

• O isPro sem o guarda que o isLifetime tem — é a sua pergunta do RevenueCat, com consequência

• A isca das Eras está travada, e sem cadeado

• O perfil tecido antes do login não vai junto para a conta

• As origens do Google no painel — é o que ainda falta para o login novo funcionar

• Os preços novos nas lojas — o código só carrega os valores de reserva

===== Decisões tomadas — não reabrir

Estas foram decididas pela dona do produto. Quem implementar executa como está escrito:
não são sugestões, não precisam de nova confirmação, e o silêncio de um item aqui
significa "mantenha como está hoje".

Decidido

--- Sincronização na nuvem para todos, sem paywall

Sync deixa de ser Premium. Todas as portas isPremium abrem — subida e
descida —, e o paywall sai da tela de Configurações (o switch bloqueado, o diálogo de
upgrade, o cartão de upsell e o bloco dourado). Detalhes e inventário completo na
seção de decisões abaixo.

Decidido

--- No paywall, a linha de sincronização apenas sai

Sem substituto na lista. Os benefícios passam de cinco itens para quatro
(Conselheiro, Enciclopédia, Clima do Dia, leituras sem limite), mais os dois extras do
Vitalício. Nada de inventar um benefício novo para preencher a linha — o substituto de
verdade é o redesenho do convite ao Premium, decidido depois.

Decidido

--- O convite ao Premium é redesenhado

O card "Uso do Plano Gratuito" deixa de ser placar de limites e passa a reagir ao
estado da pessoa; o toque abre uma página de descoberta do que o Premium entrega; e a
página de Assinatura passa a falar a mesma língua. Direção, princípio e o que não fazer
na seção do convite.

Decidido

--- O resgate de Código Premium continua — muda de lugar, não de existência

É o que dá autonomia de criar e distribuir cupons pelo app. Vira função
SECURITY DEFINER no banco; a criação de cupons não é tocada.

Decidido

--- Os contadores diários são trancados no mesmo lote

Vão junto com o REVOKE da profiles: os campos
*_today, spells_count e
diary_entries_this_month saem do alcance de escrita do cliente e passam a
ser atualizados por função SECURITY DEFINER, como o resgate. Fecha o
buraco de zerar os próprios limites por requisição.

Decidido

--- Rituais Guiados passa a seguir o fluxo livre

Era o último que barrava na entrada — o padrão que já foi abolido na Quiromancia e no
Guia da Natureza. O conteúdo fica visível, com o bloqueio aparecendo como cadeado no
lugar certo, e não como porta fechada.

Mantém como está

--- Ritos do Dia e a degustação da lição ficam como estão

Decisão explícita, não esquecimento: os dois ritos premium-only continuam premium-only
(o Free segue sem conseguir completar os seis ritos do dia), e o "O começo desta
lição" continua entregando o primeiro parágrafo real da lição paga. Não mexer nesses
dois — se algum dia mudarem, é decisão nova.

Default aplicável

--- Os itens sem decisão explícita seguem estes defaults

Autorizado decidir por estes caminhos, sem perguntar de novo:

Preço do Vitalício
Acrescentar R$ 249,90 como valor de reserva, ao lado dos que já
existem para mensal e anual — lembrando que o preço real vem sempre da loja, e o de
reserva só aparece quando a loja não respondeu.

Selo de economia
Deixar de ser texto fixo: calcular a partir dos preços reais que a
loja devolveu. Se não der para calcular (loja muda, moeda estrangeira, catálogo não
carregou), esconder o selo em vez de mostrar um número que pode
mentir.

Porta da Leitura do Ciclo na página de assinatura
Manter. O comentário no código a justifica como aviso de que a
leitura é compra avulsa e não entra no Premium — é informação de preço, não descoberta.
Encerra o "aguardando decisão" que vinha do plano original.

Limite diário do Guia da Natureza
Manter o valor 5, mas movê-lo do meio da página para onde moram os
outros limites.

Perfis antigos da Análise Personalizada
Dar saída: oferecer refazer no formato novo. Sem migração automática silenciosa —
gerar dez seções custa chamadas de IA, então quem decide é a pessoa.

===== Dinheiro, dado e acesso que podem se perder

Nenhum destes nasceu nesta sequência — são anteriores. Estão aqui porque a auditoria
os encontrou e porque, ao contrário de tudo o mais, custam algo irrecuperável quando
acontecem.

Crítico
Conferido por mim
Anterior a esta sequência

--- Qualquer conta autenticada pode se promover a admin — confirmado em produção

Onde
pg_policies: profiles (banco em produção)
supabase_auth_repository.dart:578-585
feature_access.dart:337

A consulta ao banco em produção confirmou: a política de escrita da tabela
profiles é cmd = UPDATE · qual = (auth.uid() = id) · with_check =
null — sem WITH CHECK e sem restrição de coluna. Quem passa no
USING (o dono da linha) reescreve qualquer coluna. E os
grants de coluna mostram role e plan abertos para escrita.

Resultado: qualquer pessoa logada faz um PATCH em
profiles?id=eq.<seu uid> com
{"role":"admin","plan":"lifetime"}. No login seguinte o app lê
role direto do servidor, isAdmin vira verdadeiro, e
feature_access.dart:337 devolve AccessResult.full(): app
inteiro liberado, limites diários zerados, e o cartão Admin das Configurações aberto —
com a tela de Diagnóstico e a de códigos beta dentro.

Não é teoria: o próprio app faz essa escrita a partir do cliente. O resgate de Código
Premium grava 'role': 'premium', 'plan': 'lifetime' em
beta_code_repository.dart:251-252 — é a prova de que o caminho está
aberto, e o mesmo caminho aceita admin.

A mesma consulta expôs um segundo problema: o papel anon
(não autenticado) tem grants amplos na profiles — SELECT,
INSERT e UPDATE em email, birth_date,
role, plan e tudo o mais. Hoje só o RLS segura isso (para o
anônimo, auth.uid() é nulo e não casa nenhuma linha), mas é uma rede única:
qualquer política permissiva adicionada no futuro abriria a tabela ao mundo. Anon não
deveria ter grant nenhum aqui.

O que fazer — passo 1
Tirar as colunas de poder do alcance do cliente e fechar o anon:

-- anon não deve tocar em profiles
REVOKE ALL ON public.profiles FROM anon;

-- authenticated só edita as colunas do próprio perfil
REVOKE UPDATE ON public.profiles FROM authenticated;
GRANT UPDATE (display_name, photo_url, birth_date,
birth_time, birth_place, updated_at)
ON public.profiles TO authenticated;

-- mesmo corte no INSERT, para não nascer já como admin
REVOKE INSERT ON public.profiles FROM authenticated;
GRANT INSERT (id, email, display_name, signup_platform, updated_at)
ON public.profiles TO authenticated;

Passo 2 — o resgate continua, só muda de lugar
O REVOKE acima quebraria o resgate de Código Premium, que hoje grava
role/plan a partir do cliente
(beta_code_repository.dart:250-258). A decisão de produto é manter o
resgate — é o que dá autonomia de criar e distribuir cupons pelo próprio app. Então
ele não some: passa para uma função SECURITY DEFINER, que roda como dona
do banco (acima do REVOKE), valida e consome o código e concede o premium
na linha de quem chamou — tudo numa transação. De brinde, o resgate fica
atômico: hoje o código é consumido numa escrita e o premium concedido
noutra, então uma queda no meio queima o cupom sem entregar nada.

create or replace function public.redeem_beta_code(p_code text)
returns jsonb language plpgsql security definer
set search_path = public as $$
declare v_uid uuid := auth.uid(); v_ok boolean;
begin
if v_uid is null then
return jsonb_build_object('success', false, 'message', 'not_authenticated');
end if;

-- consumo condicional: só casa se o código ainda estiver válido
update beta_codes
set current_uses = current_uses + 1,
is_used = (current_uses + 1) >= max_uses,
used_by = v_uid, used_at = now()
where code = p_code and is_used = false and current_uses 

No app, o resgate deixa de fazer os dois update e passa a uma chamada só:
supabase.rpc('redeem_beta_code', {'p_code': cleanCode}). A
criação de cupons (o INSERT em beta_codes)
não é tocada por nada disto — o REVOKE foi só em profiles, então
a autonomia de gerar códigos pelo app continua igual.

Fica de fora, de propósito
Os contadores diários (*_today, spells_count,
diary_entries_this_month) continuam graváveis pela usuária — dá para zerar
os próprios limites por PATCH. É bem menos grave que virar admin, e não
entra no corte acima porque hoje o app escreve esses contadores do cliente; movê-los
para o servidor é um item à parte para o plano.

Crítico
Conferido por mim
Anterior a esta sequência

--- A compra avulsa pode cobrar e não entregar nada — e não há como recuperar

Onde
cycle_reading_intro_page.dart:346-381
payment_service.dart:652-669

O _buy() é try { … } finally { … }, sem
catch. Depois de o pagamento ser aprovado vêm duas operações
de banco: buscar o crédito e gravá-lo. Se qualquer uma estourar — banco cheio, web
com armazenamento bloqueado, aparelho sem espaço —, a exceção escapa de um
onPressed: que ninguém aguarda, vira uma linha de log e a tela apenas
para de girar.

E não há segunda chance: consumível não gera entitlement (decisão correta), o
restorePurchases só devolve sucesso if (_isPro), e
nonSubscription — onde o RevenueCat guarda as compras avulsas — não
aparece em nenhum lugar do app. Ela pagou, e o app não sabe.

O que fazer
Envolver do _creditoPara ao insert num catch
que mostre o erro e registre a compra pendente; e consultar
customerInfo.nonSubscriptionTransactions na restauração, para que uma
compra confirmada na loja possa virar crédito de novo.

Crítico
Conferido por mim
Anterior a esta sequência

--- As chaves da Groq, da Gemini e da Prokerala vão compiladas dentro do site

Onde
.github/actions/credenciais-app/action.yml
ai_service.dart:763, 799, 971, 1025

A action de CI escreve as chaves reais dentro de arquivos .dart
(GroqCredentials.apiKey, GeminiCredentials.apiKey,
ProkeralaCredentials.clientSecret) e o app as manda direto no cabeçalho
Authorization. No aparelho isso já é frágil; na web é público: o
JavaScript publicado em grimoriodebolso.app carrega as chaves em texto,
e qualquer pessoa que abra o DevTools as copia.

Quem copiar consome a sua cota — e a sua fatura — sem passar pelo app. É a única
coisa nesta lista que um estranho pode explorar sozinho.

O que fazer
As chamadas de IA na web precisam passar por um intermediário seu (uma Edge Function
do Supabase, que o projeto já usa) em vez de sair do navegador. Enquanto isso não
existe, gire as chaves depois de qualquer publicação web e ponha um teto de gasto
nos dois provedores.

Crítico
Conferido por mim
Anterior a esta sequência

--- O grimório de quem não é Premium só existe naquele aparelho — e o iOS o apaga sozinho em 7 dias

Onde
data_sync_service.dart:233, 1013, 1071
main.dart:113-115

A sincronização é Premium: o syncItem começa com
if (!PremiumAccess.instance.isPremium) return; e o
resolveCloudSyncPreference devolve false duro para Free. Logo,
no Free nada sobe para a nuvem — inclusive a Leitura do Ciclo, que é vendida justamente
a quem não é Premium. O crédito e o texto pago ficam só no banco local.

E o "banco local" na web é frágil de um jeito específico. Ele é sqlite gravado no
IndexedDB (databaseFactoryFfiWebNoWebWorker). No iOS todos
os navegadores usam o motor da Apple, e a política de privacidade dele
apaga o armazenamento gravável por script depois de 7 dias sem a pessoa abrir o
site. Sem cópia na nuvem, uma semana sem abrir = grimório inteiro perdido:
feitiços, diário, mapa astral, e o produto pago junto. Não é a pessoa limpando dados —
é o sistema apagando sozinho. (Instalar o PWA na tela inicial escapa disso: o iOS dá um
armazenamento separado, mais durável — por isso o convite de instalação importa.)

Some-se ao item da compra sem catch: para o comprador Free, as duas redes
que existiriam — a nuvem e a restauração de compra — estão as duas fechadas.

Decisão tomada
Ligar a sincronização no Free (ver a seção de decisões abaixo). Resolve este item na
raiz — não só a leitura paga, mas todo o grimório passa a ter cópia na nuvem.

Crítico
Conferido por mim
Anterior a esta sequência

--- O isPro não tem o guarda que o isLifetime tem

Onde
payment_service.dart:212-220
payment_service.dart:898-916
auth_provider.dart:286-293

Você perguntou se produto avulso pode estar no entitlement. A resposta continua
sendo não — e aqui está o motivo com nome e sobrenome. O isLifetime
documenta o cenário com todas as letras ("uma leitura de R$ 4,90 viraria Premium
vitalício") e se defende. Já o _updateProStatus é só
entitlements.active.containsKey(proEntitlementId), sem checagem
nenhuma.

Se a leitura de ciclo entrar no entitlement por engano no painel, o
isLifetime diz não e o isPro diz sim. E o
isPro é quem alimenta o app inteiro: o auth_provider grava
role: premium no usuário e persiste. Uma compra de R$ 4,90 vira Premium
permanente, com sincronização.

O que fazer
Mover o guarda do getter estreito para o largo: o _updateProStatus
precisa rejeitar entitlement cujo produto ativo seja um dos consumíveis. E manter o
painel como está — leitura de ciclo fora de qualquer entitlement.

Crítico
Verificado
Só na web

--- Na web, o RevenueCat nunca é associado à conta

Onde
main.dart:154-156
payment_service.dart:698-706
auth_provider.dart:659

O boot pula a inicialização na web — if (!kIsWeb) { await
PaymentService().initialize(); }. Depois, ao entrar na conta, o
logIn confere só RevenueCatConfig.isConfigured, que testa se
a chave existe (e existe, é a rcb_ da web), não se o
Purchases.configure rodou. O Purchases.logIn então lança, e o
catch engole num debugPrint.

Resultado: na web a compra fica num usuário anônimo do RevenueCat, sem ligação com a
conta do Supabase. É o mesmo sintoma dos itens acima — "paguei e o app não sabe" — só
que por outro caminho, e é o único que atinge todo mundo que compra pelo navegador.
O logIn é o único ponto de associação no app inteiro.

O que fazer
Inicializar o SDK também na web antes do logIn, ou fazer o
logIn checar inicialização de verdade (e não apenas a presença da chave)
e chamar o initialize quando faltar.

Atenção
Verificado

--- O plano nunca é gravado no servidor por uma compra

Onde
supabase_auth_repository.dart:582-584
beta_code_repository.dart:251-252

Um achado que a verificação corrigiu, e o que sobrou é mais fundo do que o original: o
medo de "Vitalício reinstalado paga de novo" não se confirma no celular
— o logIn atualiza o customerInfo, o callback dispara e o
plano volta a ser lifetime. Mas o campo plan da tabela
profiles é lido no login e nunca escrito por compra
nenhuma: o único write vem do resgate de Código Premium.

Ou seja: o servidor não sabe quem comprou. Quem depende disso é justamente a web, onde
o RevenueCat não está associado (item acima), e qualquer relatório ou suporte que você
queira fazer por consulta ao banco.

Crítico
Verificado

--- O que foi tecido antes do login fica órfão — e some da tela

Onde
astrology_provider.dart:24, 72-76, 145
astrology_repository.dart:45-46, 126, 146-147

O provider de astrologia nasce anônimo: _currentUserId = 'local_user'. É
esse valor que vai gravado no mapa astral e no perfil. E o acesso Premium não exige
conta (Código Premium e admin valem localmente), então dá para tecer as dez seções sem
nunca ter logado.

Quando o login acontece, o setUserId troca o identificador e recarrega —
com where: 'user_id = ?', sem nenhum fallback para
'local_user'. O mapa e a Análise Personalizada desaparecem da tela, e
nunca sobem para a nuvem: ficam numa linha órfã do banco local, apontando para um
usuário que não existe.

O que fazer
Uma migração no login, no mesmo lugar onde o
DatabaseHelper.claimLegacyData(user.id) já roda: reatribuir as linhas de
'local_user' para o uid real e marcá-las como não sincronizadas.

===== Pedidos entregues pela metade

Tudo aqui é desta sequência. São coisas que funcionam no caminho feliz e falham no
caminho que a usuária de verdade percorre.

Crítico
Conferido por mim

--- A isca das Eras está travada — e é a única sem cadeado

Onde
feature_access.dart:49, 377
era_reading_page.dart:52
life_eras_page.dart:170, 236

O plano dizia: Era e Fase atuais abertas, passado e futuro no paywall. O
AppFeature.lifeErasNow foi criado e posto em freeFeatures
com o comentário "a isca da feature" — e nunca é lido por ninguém. O
era_reading_page.dart:52 exige lifeErasFull para qualquer
leitura, inclusive a atual.

O resultado na tela é o pior arranjo possível: os dois cartões de "Agora" não têm
cadeado e parecem abertos, então a pessoa toca na isca e bate numa tela travada — e
as listas de passado e futuro, essas sim, têm cadeado. A única coisa que ela podia
ver de graça é a que parece proibida, e vice-versa.

O que fazer
Fazer o EraReadingPage escolher a feature pelo que está sendo aberto:
lifeErasNow para a Era e a Fase correntes,
lifeErasFull para o resto.

Atenção
Conferido por mim

--- "Cancele a qualquer momento" aparece com o Vitalício selecionado

Onde
subscription_offer_widgets.dart:491, 866-878

A lista de benefícios passou a responder ao plano escolhido, como você pediu — mas o
rodapé não. O SubscriptionGuarantees é const e mostra
sempre premiumCancelAnytime. Com o Vitalício em foco, a mesma dobra da
tela diz "sem renovação, para sempre" e, duas linhas abaixo, "cancele a qualquer
momento".

O que fazer
Passar o plano selecionado para o widget e trocar a frase por uma de compra única.
Mesma linha do que já foi feito com os benefícios.

Atenção
Verificado por agente

--- Um ## solto vindo da IA some com os dez cards da Análise

Onde
magical_profile_report.dart (parseMagicalProfile)
magical_profile_page.dart:491-495

O parser distingue perfil novo de perfil antigo pela presença de
## [chave]. Se a IA escrever um ## por conta própria dentro
de uma seção, a tela inteira desvia para o modo "perfil antigo" e a grade de dez
cards desaparece — junto com todo botão de tecer de novo. O prompt pede o formato,
mas nada garante, e não há teste para isso.

O que fazer
Escapar ou rebaixar qualquer ## que não seja um cabeçalho de chave, na
hora de acumular o texto — e um teste com uma resposta rebelde.

Atenção
Medido no banco real

--- Quinze dos dezesseis perfis em produção nunca verão os dez cards

Onde
magical_profiles.profile_data → aiGeneratedText

A auditoria consultou o banco: das 16 linhas de magical_profiles, apenas
1 está no formato novo (com 9 seções gravadas na ordem em que os cards foram abertos
— prova de que a geração sob demanda funciona de ponta a ponta). As outras 15 estão
no formato antigo, e o código as desvia para a leitura corrida: nunca alcançam a
grade nova, e não têm botão para regerar.

O que fazer
Dar saída a esses perfis: um "tecer de novo no formato novo" na tela da Análise, ou
migrar o texto antigo para a primeira seção e deixar as outras nove disponíveis.

Atenção
Verificado por agente

--- "Tecer de novo" que falha volta ao texto antigo sem dizer nada

E o erro e o aviso de limite do provedor (_error,
lastFailureWasRateLimit) continuam globais no provider, embora a trava
de geração tenha virado por seção: uma seção que falha marca erro para todas as
outras que estiverem abertas.

Atenção
Verificado por agente

--- Na Leitura do Ciclo, o "destaque" virou cor sem peso

Onde
cycle_reading_report_page.dart

A mesma reclamação sua rendeu, no Perfil Mágico, negrito de verdade, frase de
abertura em evidência e respiro entre blocos. No relatório do Ciclo ficou mais tímido:
cada seção não tem gancho de abertura, e o único bloco em destaque do documento é a
afirmação — que é escrita pelo app, não pela IA. Vale repetir ali o que funcionou aqui.

Atenção
Verificado por agente

--- As pílulas de lua e ingredientes do ritual são apagadas antes de alguém poder lê-las

A anotação que alimenta os cartõezinhos do relatório é removida do texto antes de o
cartão ter chance de consultá-la — então eles nunca aparecem. É código que existe,
roda e não produz nada na tela.

Atenção
Verificado por agente

--- A seção de rituais é localizada pelo título no idioma atual

Quem trocar o idioma do app deixa de ver os cartões de rituais nas leituras antigas:
a busca é feita pelo texto do título traduzido, não por uma chave estável.

Atenção
Verificado por agente

--- Sobrou uma degustação: "O começo desta lição"

Onde
lesson_page.dart:567
core/offers/teaser_reveal.dart

Todas as prévias que gastavam chamada de IA saíram, como você pediu. Ficou uma, na
trilha de aprendizado, e é justamente a que entrega texto real de graça: o primeiro
parágrafo da lição paga. Pode ser decisão de produto — só não estava no lote que foi
removido.

Atenção
Verificado por agente

--- A Quiromancia mostra "3 leituras restantes hoje" para quem não pode fazer nenhuma

E o Guia da Natureza engole qualquer erro que não seja limite de uso, enquanto a
Quiromancia mostra todos. Os dois fluxos que você pediu para igualar ficaram parecidos
na aparência e diferentes no comportamento.

Atenção
Verificado por agente

--- Um Text('') de 28pt abre o cabeçalho de "Seus Planetas nos Signos"

Sobra da remoção do emoji do signo: o texto saiu, o espaço reservado para ele não.
É cosmético, mas é exatamente no lugar que você mandou limpar.

Crítico
Verificado

--- Corrigir os dados de nascimento faz a Análise Personalizada sumir sem aviso

Onde
astrology_repository.dart (chave por birth_chart_id)

O perfil é carimbado pelo id do mapa. Ao corrigir a data ou a hora de nascimento,
nasce um mapa novo com id novo — e o perfil antigo fica pendurado no id velho. A
pessoa não é avisada: as dez seções que ela mandou tecer simplesmente não estão mais
lá, e nada oferece trazê-las de volta ou refazê-las.

O que fazer
Avisar antes ("corrigir o nascimento vai refazer o seu perfil") e, no mínimo, apagar o
registro órfão em vez de deixá-lo ocupando espaço e confundindo consulta.

Atenção
Verificado

--- Sem rede, o card do Perfil Mágico mostra o dump cru da exceção

Aparece o texto da DioException na tela, com a URL do provedor de IA
dentro. O teste que deveria pegar isso usa um duplo que devolve uma frase amigável —
o provider real devolve o dump. É a mesma tela que você já viu nascer em erro, agora
no caminho de falta de rede.

Atenção
Verificado

--- Um boot com rede ruim deixa "planos indisponíveis" pela sessão inteira

Onde
payment_service.dart:110, 232, 297-306

O catálogo é carregado uma vez, no boot, e a falha é engolida num
debugPrint. O refreshOfferings, que existiria para tentar de
novo, não tem nenhum chamador. E as três telas que acham que estão
garantindo o catálogo (subscription_page,
premium_blur_widget, cycle_reading_intro_page) chamam
initialize(), que sai na primeira linha porque
_isInitialized vira true até nos caminhos de erro.

Efeito: se o catálogo não veio no boot — rede ruim, offering ainda propagando no
painel —, o botão de compra fica desligado e a tela diz "planos indisponíveis" até a
pessoa fechar e reabrir o app. Não há retry em lugar nenhum.

Atenção
Verificado

--- Na aba Ciclos, um erro de banco deixa o botão desabilitado para sempre

Onde
cycles_tab.dart:402-448, 565

O _carregar() do cartão da Leitura do Ciclo faz três idas ao banco sem
try/catch, disparado de um Future que ninguém
aguarda. Qualquer exceção vira erro assíncrono não capturado, o setState
nunca roda, _carregando fica true — e
onPressed: _carregando ? null : _abrir deixa o CTA morto, com a barra de
progresso em zero.

===== O voltar na web e o login com o Google

O assunto mais longo da conversa, e o único onde o pedido original ainda não está
atendido por inteiro.

Atenção
Verificado por agente

--- "Voltar nunca sai do app": ainda não vale para todo mundo

O GuestOnly resolveu o caso de reabrir #/login com sessão
viva. Mas a entrada com o Google na própria página — que é o que impede o
accounts.google.com de entrar no histórico — só roda quando tudo dá
certo. Sete condições devolvem nulo e recolocam a pessoa no redirecionamento de
sempre: cookies de terceiros bloqueados, script não carregado, origem não autorizada,
endereço efêmero, tempo esgotado, One Tap em cooldown, navegador sem FedCM.

O que fazer
Assumir que o redirecionamento continua existindo e cuidar do retorno dele: hoje há
uma janela de até 15 segundos, depois de voltar do Google, sem nenhum
PopScope montado — e é justamente quando o Google é a entrada anterior
do histórico.

Atenção
Verificado por agente

--- A causa raiz da travada foi contornada, não corrigida

Onde
home_page.dart (_handleSystemBack)

O WebBackKeeper foi revertido porque entrou em recursão com o
if (rootNavigator.canPop()) do _handleSystemBack. Esse
código continua exatamente como estava, e o comentário dele ainda descreve errado o
que ele faz. Qualquer tentativa futura de segurar o voltar vai tropeçar no mesmo
lugar — e não há teste nenhum cobrindo esse caminho.

Bloqueante
Fora do código

--- As origens JavaScript no Google Cloud continuam vazias

É o que falta para o login novo funcionar. No seu último print o campo
Authorized JavaScript origins estava vazio. Precisam entrar:

https://staging.grimorio-de-bolso.pages.dev

https://claude-ciclos-de-vida-featur.grimorio-de-bolso.pages.dev

https://grimoriodebolso.app

A staging já está com o código novo (a branch foi mesclada na main), então
dá para testar por lá assim que as origens propagarem — o Google avisa que leva de 5
minutos a algumas horas. E isso não está documentado em lugar nenhum do repositório:
é a quarta lista de permissões externa do projeto e a única que não aparece no
documento de ambientes.

Atenção
Verificado por agente

--- Se a chave do Google faltar no release, a produção volta ao defeito em silêncio

O release.yml passa GOOGLE_WEB_CLIENT_ID sem verificar se
ele veio — e o mesmo arquivo já tem o padrão de trava que faltou aqui (ele reprova o
build se a chave do RevenueCat for de sandbox). Sem o segredo, o app publica
normalmente e ninguém percebe que a feature nova não existe.

Atenção
Conferido por mim

--- A documentação manda desligar a checagem de nonce no Supabase

Onde
docs/GOOGLE_SIGNIN_SETUP.md:155, 192

"Skip nonce checks — ative se a opção existir". Se essa opção estiver ligada no painel,
toda a proteção de nonce que o login novo implementa vira enfeite: o Supabase deixa
de comparar o valor. Foi escrito para o fluxo nativo do Android, que nem sempre manda
nonce — mas vale para o projeto inteiro.

O que fazer
Conferir se está ligada. Se estiver, avaliar desligar agora que o caminho web manda
nonce corretamente, e ajustar o documento.

Dívida
Verificado por agente

--- Seis segundos parados antes de desistir, e o erro do Supabase é engolido

Quando o Google não responde, o app espera o tempo cheio antes de cair no
redirecionamento — porque não escuta o aviso de "não vou aparecer" que a API oferece.
E se o Supabase recusar o token, a pessoa não vê erro nenhum: escolhe a conta duas
vezes e o defeito fica invisível para sempre, inclusive para você.

Dívida
Conferido por mim

--- O guarda de endereço efêmero cobre só uma das formas de URL de prévia

Onde
google_one_tap_web.dart:73-74

RegExp(r'^[0-9a-f]{8}\.') pega
47a8ec37.grimorio-de-bolso.pages.dev. Não pega prévias com nome de
branch, e pegaria por engano um domínio legítimo que começasse com oito
hexadecimais. Funciona para o caso que te atrapalhou; não é uma regra sobre o que
realmente importa, que é "esta origem está autorizada?".

===== Dívida com consequência real

Nada aqui aparece para a usuária hoje. Tudo aqui aumenta a chance de o próximo defeito
passar batido.

Atenção
Conferido por mim

--- O dart format do CI é decorativo

Onde
.github/workflows/branch-validate.yml:83-85

O passo roda com continue-on-error: true, então falha e é reportado como
sucesso. Segundo a auditoria, 319 dos 556 arquivos estão fora de formato. Ou o passo
vira bloqueante depois de uma formatação geral, ou sai — do jeito que está, ele só
ensina a ignorar um check verde.

Atenção
Verificado por agente

--- Os 186 infos do analyze escondem 26 use_build_context_synchronously

A política é razoável — não bloquear em dívida de lint antiga — mas o efeito é que
ninguém olha a lista. E dentro dela estão 26 usos de context depois de
await, que é a família de bug que derruba tela em produção.

Atenção
Verificado por agente

--- O que esta sequência entregou não tem teste

Sem cobertura: a geração por seção do Perfil Mágico (o teste de widget substitui
justamente o método que concentra o risco), a persistência no Supabase, a composição
da Leitura do Ciclo com o perfil, o PagedReading e o
PageDots — usados em quatro telas —, a quebra do relatório em seções e o
seu fallback, a feature Ciclos inteira do lado da interface, e o comportamento do
voltar na web.

O que fazer
Os dois que pagam mais rápido: um teste da acumulação de seções (que é onde mora o
risco de perder texto) e um da quebra do relatório com um markdown fora do formato.

Dívida
Verificado

--- 54 chaves órfãs nos ARBs, e o check de paridade não vê órfã

Duas são desta sequência (premiumLifetimeOnce,
cycleReadingBuyFor) e três nasceram mortas dentro dela
(cyclesEraLabel, cyclesPhaseLabel,
cyclesOpenTimeline). O resto é acervo. São 216 strings traduzidas em
quatro idiomas que nenhuma tela consome.

Dívida
Verificado

--- O scanner de português cravado só enxerga acento

O check_hardcoded_pt.sh detecta português pela acentuação — então
"Compra cancelada", "Nenhuma compra encontrada para restaurar" e companhia passam
direto e chegam à tela em inglês e espanhol. O restorePurchases tem uma
dessas, e ela ainda é comparada como string literal em dois widgets: traduzir a
mensagem faria o app mostrar erro num cancelamento normal.

Atenção
Verificado

--- Dois google-services.json comitados, divergentes — e nenhum tem a SHA-1 do release

Onde
android/app/google-services.json
android/google-services.json
release.yml:67

Só o de android/app/ é lido pelo Gradle. Os dois não são o mesmo arquivo:
o efetivo tem um cliente OAuth, o ignorado tem três. E a impressão digital que o
release.yml declara esperar
(54:84:54:75:7F:…) não aparece em nenhum dos dois.

O login com o Google no Android só funciona se a SHA-1 da chave que assinou o APK
estiver registrada no cliente OAuth. Vale conferir com um build assinado na mão —
porque nenhum teste cobre isso, e o CI só compila Android quando o commit toca código
nativo (o que não aconteceu nesta sequência).

Dívida
Verificado

--- O iOS não é compilado por nenhum job de CI

E o detector de "mudou código nativo" nem olha para ios/. Junto com isso,
duas coisas concretas: não há configuração de Google Sign-In nativo no iOS (sem
GIDClientID, sem GoogleService-Info.plist), e o
identificador do AdMob no Info.plist ainda é o de teste do Google
(ca-app-pub-3940256099942544~1458002511) enquanto o do Android é o real.
Anúncio no iOS não rende nada hoje.

Dívida
Verificado por agente

--- Erros que somem sem deixar rastro

O LifeErasError guarda a causa num campo que ninguém lê e mostra um
cartão mudo, sem motivo e sem botão de tentar de novo. As falhas de upload do perfil
morrem num debugPrint. A identificação do Guia da Natureza engole tudo
que não for limite de uso. Quando alguém reclamar, não haverá o que olhar.

Dívida
Verificado

--- Duas seções tecidas ao mesmo tempo podem deixar a nuvem com uma a menos

A corrida foi corrigida na memória — o texto acumulado é lido depois da chamada, e o
comentário no código descreve isso corretamente. O que ficou de fora é o upload: dois
upsert em voo, sem alvo de conflito e sem guarda por
updated_at, e o que chega por último vence. No aparelho o texto fica
certo; na nuvem pode faltar uma seção.

Dívida
Verificado

--- O app_pt.arb que todo mundo edita primeiro nunca chega à tela

Onde
language_provider.dart:11-16
generated/app_localizations_pt.dart:2618

Os locales suportados são pt_BR, es e en — não
existe pt avulso, e a classe AppLocalizationsPtBr
sobrescreve todos os 796 membros da AppLocalizationsPt. Ou seja: o
app_pt.arb é o template (é ele que tem os 145 blocos de metadados, e é o
primeiro que qualquer pessoa abre), mas os valores dele nunca aparecem para
ninguém — só os nomes de chave e os placeholders importam ali.

O que fazer
Escrever isso no topo do arquivo. Hoje um texto corrigido só no
app_pt.arb parece feito e não muda nada no app.

Dívida
Verificado

--- O ON DELETE CASCADE do banco local é decorativo

Falta o PRAGMA foreign_keys = ON: no SQLite as chaves estrangeiras vêm
desligadas por padrão, então apagar um mapa astral não apaga o perfil ligado a ele. É
a mesma família do registro órfão que faz a Análise sumir ao corrigir o nascimento —
os dois deixam lixo apontando para nada.

Dívida
Verificado

--- O cache das Eras sobrevive ao logout

O LifeErasRepository.clear() existe, tem teste — e nenhum chamador. As
chaves em SharedPreferences ficam depois que a pessoa sai da conta.
Some-se a isso que o algoVersion invalida o cache, mas nada obriga
ninguém a subi-lo quando o cálculo mudar, e o cache não expira sozinho.

Dívida
Verificado

--- Nenhum documento acompanhou 16 commits

Preços velhos continuam em quatro arquivos de docs/, a trava de SDK do
pubspec diz 3.3 quando o código exige 3.6, o README fala em Flutter
3.24+, e os arquivos gerados de l10n estão 859 chaves atrasados no git sem que essa
convenção esteja escrita em lugar nenhum.

===== O convite ao Premium — redesenho

Pedido novo, com direção dada: "deve ser irresistível, deixá-lo curioso, com vontade de
ter o Premium, sentir que algo falta por não ter — chamativo, grandioso". Vale junto com
a decisão de tirar a linha de sincronização do paywall: o que substitui aquele item não
é outra linha de lista, é este redesenho.

Defeito
Conferido por mim

--- O card "Uso do Plano Gratuito" mostra o contador errado

Onde
settings_page.dart:486-493
feature_access.dart:308-315
user_model.dart:158, 177

A linha "Conselheiro Místico" lê user.aiConsultationsToday contra
freeAiConsultationsLimit. Mas o Conselheiro é limitado por
advisorConsultationsToday contra
freeAdvisorConsultationsLimit — outro contador. Os dois limites valem
1, então o denominador bate por coincidência e ninguém percebeu.

O efeito é uma barra que erra nos dois sentidos: consultar o Conselheiro não
move a barra do Conselheiro, e analisar um sonho (ou pedir sugestão de
feitiço, ou o clima mágico) move a barra rotulada "Conselheiro
Místico". A pessoa acha que tem consulta sobrando quando não tem, ou o contrário.

Defasado
Conferido por mim

--- O card mostra três limites; o app tem sete

Ficaram de fora, todos com limite diário real: Runas (1),
Pêndulo (3), Oráculo (1) e Tarô.
E há uma regra invisível que merece ser dita: Tarô e Oráculo dividem a mesma
cota — os dois leem oracleReadingsToday, então uma tiragem de
tarô consome a leitura do oráculo do dia. Hoje isso não aparece em lugar nenhum, e a
pessoa descobre batendo a cabeça.

Recomendação

--- Vale mostrar os limites — mas não como placar

Resposta direta à pergunta: sim, vale, porque esconder gera a sensação pior de todas
(bater num muro sem aviso). O problema do card atual não é mostrar, é quando e
como. Ele exibe "0/10 · 0/30 · 0/1" para quem acabou de chegar — e zero usado é
exatamente o momento em que o limite parece generoso e distante. O
card gasta o melhor espaço da tela para dizer "você tem muito ainda", que é o oposto de
despertar desejo. E, quando a pessoa realmente esbarra no limite, ele mostra a mesma
coisa, do mesmo tamanho.

O princípio: o card deve reagir ao estado da pessoa, não repetir uma
tabela. Três estados, um só componente:

Estado 1 — longe do limite
Números somem. No lugar deles, o que ela ainda não viu: um vislumbre rotativo
do que o Premium abre, no idioma que já funcionou no Perfil Mágico. Aqui a emoção certa
é curiosidade, não contagem.

Estado 2 — perto do limite
Aí sim o número aparece, e só o que está perto: "resta 1 consulta hoje". Um item, não
sete. É informação útil no momento em que ela é útil.

Estado 3 — no limite
O card cresce e vira o convite mais forte da tela, dizendo o que teria acontecido:
não "você atingiu o limite", e sim o que estava do outro lado daquela consulta.

Recomendação

--- O toque no card abre "o que você ainda não viu", não a tabela de preços

A ideia da dona do produto está certa e o app já tem as peças. O destino do toque deve
ser uma página de descoberta, e a linguagem para isso já existe e já
foi aprovada nesta mesma sequência: os cards com páginas que deslizam
do Perfil Mágico (PagedReading + PageDots). Uma peça por
feature premium, cada uma com um vislumbre real do que ela entrega — o
PremiumLockedPreview, que já mostra a forma do conteúdo sem entregar o
conteúdo, é o material certo.

A ordem importa: desejo primeiro, preço por último. A página termina
no plano, não começa nele. Quem já quer, rola até o fim; quem só espiou, saiu sabendo o
que existe — e é isso que faz voltar.

Coerência com o que já foi pedido
Isto é a mesma instrução de antes, agora do lado positivo: "é pra ele sentir que está
perdendo algo", e nada de tom de venda. Vale repetir a regra que valeu para as
degustações — mostrar a forma, nunca o conteúdo. Nada de gerar por IA
para exibir de graça: as prévias que custavam chamada foram removidas de propósito, e
não devem voltar por esta porta.

Recomendação

--- A página de Assinatura passa a falar a mesma língua

Hoje ela é uma lista de benefícios com ícone e uma frase cada — correta e esquecível.
Com a linha de sincronização saindo, ela encolhe para quatro itens, o que torna o
redesenho não só desejável como oportuno.

O que muda
Cada benefício deixa de ser uma linha e vira uma peça com imagem e vislumbre — o mesmo
vocabulário da página de descoberta, para as duas telas parecerem a mesma ideia vista
de dois ângulos. Os três planos lado a lado (que já ficaram bons) descem para o fim,
depois do desejo. As entradas de animação que o app já usa
(StaggeredEntrance) dão o senso de "grandioso" sem precisar de efeito
novo.

O que NÃO fazer
Nada de escassez inventada (contagem regressiva falsa, "últimas vagas"), nada de
número inflado, nada de esconder o preço ou dificultar o fechamento. O app vende
introspecção — um paywall com truque de urgência quebra o tom da Salem e destrói mais
confiança do que converte. "Grandioso" aqui é produção caprichada, não pressão.

Dependência

--- Este redesenho depende de dois itens já decididos

(1) Os contadores vão ser trancados no servidor (função
SECURITY DEFINER). Como o card passa a exibi-los, a leitura precisa
continuar disponível ao cliente depois do REVOKE — trancar a escrita, não
a leitura. Fazer as duas coisas no mesmo lote evita um card que nasce quebrado.

(2) A linha de sincronização sai do paywall. Não substituir por outra
linha: o substituto é esta página de descoberta.

E um alerta de coerência: por decisão explícita, dois dos seis Ritos do Dia continuam
premium-only, ou seja, quem é Free nunca completa o dia. Isso é uma boa isca se
for apresentado como convite; vira frustração se aparecer como tarefa falhada. Vale
conferir como esses dois ritos se mostram na tela, agora que o assunto é justamente o
tom do convite.

===== O que depende de você, fora do código

Nenhum destes um agente faz sozinho: exigem painel, credencial ou aparelho na mão. Quem
implementar deve tratá-los como pré-requisito ou como entrega sua, nunca como tarefa
própria — e deve dizer quando estiver bloqueado por um deles, em vez de contornar.

Bloqueante

--- Os preços novos ainda não existem nas lojas

O código só carrega valores de reserva, e nem esses estão completos: R$ 19,90 e
R$ 119,90 estão lá, o R$ 249,90 do Vitalício não existe em nenhum lugar do
repositório — nem no código, nem em commit, nem em documento. E o selo
"Economize 50%" é texto fixo no ARB, não uma conta: se a loja devolver outro preço,
ou se a pessoa estiver fora do Brasil, o selo mente.

Ordem
App Store Connect e Google Play primeiro (preço novo em cada produto), depois
conferir no RevenueCat que os produtos continuam nos pacotes certos, e só então
checar o app — que lê o preço da loja, não do código.

Confirmar

--- RevenueCat: o Vitalício dentro do entitlement, as leituras fora

Vitalício é non-consumable e precisa estar no entitlement
Grimorio de Bolso Pro. As leituras de ciclo
(leitura_ciclo_mes, leitura_ciclo_semana) são consumables e
não podem estar em entitlement nenhum. Vale a pena reconferir o
painel agora que você sabe o preço de errar: veja o item do isPro.

Decisão tomada
Trabalho de código

--- Sincronização na nuvem para todos, e o paywall sai das Configurações

Decisão de produto: sincronização deixa de ser exclusiva do Premium e passa a valer
para qualquer pessoa com conta. O motivo é o item crítico dos 7 dias — sem cópia na
nuvem, o grimório do Free se apaga sozinho no iOS — e o custo é desprezível: os dados
são texto, o RLS já é por dono nas 20 entidades sincronizáveis, e o mapa de sync já
está completo e travado por teste. É destravar, não construir.

Inventário — todas as portas a abrir
Levantado no código; nenhuma pode ficar para trás, porque cada uma sozinha reintroduz
a perda:

data_sync_service.dart
:233 resolveCloudSyncPreference → `if (!isPremium) return false;` (a raiz)
:294 syncAll → erro syncPremiumOnly
:1013 syncItem → return silencioso (a porta mais quente)
:1034 upload por entidade
:1053 upload por entidade
:1071 fullDownload ← A DESCIDA. sem ela o dado sobe e não volta
:1131 download por entidade ← idem

sync_provider.dart
:75 isReady → `&& PremiumAccess.instance.isPremium`
:76 isPremium (getter que a UI consulta)
:107 :136 :158 → três guardas que devolvem syncPremiumOnly

sync_settings_page.dart (a tela de Configurações → Sincronização)
:38 ensureCloudSyncPreference(isPremium: ...)
:84-100 o switch: subtitle "Recurso exclusivo Premium", `value: isPremium && ...`,
e `if (!isPremium) { _showUpgradeDialog(); return; }` — o toque vira paywall
:185-247 o cartão de upsell inteiro, que SUBSTITUI o status de sincronização
:338 privacySyncEnablePrompt
:430-439 o bloco dourado com editSyncPremiumPitch

edit_profile_page.dart (o MESMO toggle, duplicado nesta tela)
:50 :53 :250-262 :1002 — mesma lógica, mesmo paywall

Regra de ouro
Abrir as duas pontas. Se só a subida abrir, o dado sobe mas não volta
depois que o iOS apaga o local — a pessoa reabre o app e vê um grimório vazio, com
tudo intacto no servidor. O fullDownload é tão essencial quanto o
syncItem.

Inferência — o estrago dos 7 dias é maior do que só o banco
A regra do WebKit apaga todo armazenamento gravável por script, não só o
IndexedDB: o localStorage cai junto. E é nele que moram o
SharedPreferences na web (preferência de sync, contadores, cache das Eras)
e a sessão do Supabase. Ou seja, na sétima noite ociosa a pessoa perde
o banco e é deslogada — e, deslogada, nem o download de recuperação acontece.
Isso conversa diretamente com a queixa original de "voltar e cair no login": parte
daqueles episódios pode ter sido expiração de armazenamento, não navegação.
A verificar no aparelho, mas se confirmar, muda a prioridade do
convite de PWA de cosmético para proteção de primeira ordem.

Depende de dois outros itens do relatório
(1) Sync exige conta (auth.uid()). Quem usa sem logar continua exposto —
então o conserto do perfil órfão (local_user) anda junto, e cabe um
empurrão honesto: "crie uma conta para proteger o seu grimório".
(2) No iOS web, o convite de instalação do PWA passa a ser proteção real: o
armazenamento do app instalado não cai na regra dos 7 dias.

Discurso de venda — decidido
Sincronização é vendida como benefício Premium em três lugares
(subscription_offer_widgets.dart:304,
subscription_page.dart:274 e :369, todos com
premiumBenefitCloudSync). A decisão é apenas remover a linha,
sem substituto: a lista passa de cinco benefícios para quatro. Sete chaves de l10n
ficam órfãs ou mudam de sentido nos 4 ARBs e precisam sair ou ser reescritas:
premiumBenefitCloudSync, editSyncPremiumPitch,
editSyncPremiumOnly, syncPremiumOnly,
privacyCloudSyncUpsellTitle, privacyCloudSyncUpsellBody,
privacySyncEnablePrompt.

O paywall sai das Configurações
Na sync_settings_page.dart: o switch deixa de ser bloqueado (:84-100
— cai o subtítulo "Recurso exclusivo Premium", o value: isPremium && … e o
_showUpgradeDialog() no toque), o cartão de upsell (:185-247)
dá lugar ao status de sincronização de verdade, e o bloco dourado do pitch
(:430-439) sai. A edit_profile_page.dart tem o
mesmo toggle duplicado (:250-262, :1002) e
precisa da mesma mudança — dois lugares, não um.

Inferência — dois riscos que crescem junto
(a) Conflito. A auditoria achou que o _hasChanges nunca
detecta igualdade nas tabelas de blob JSON: toda linha suja vira "conflito" e o empate
de milissegundo resolve a favor do servidor. Com sync ligado para todo mundo, o alcance
desse defeito multiplica — vale consertá-lo antes ou no mesmo lote.
(b) Volume. Passa a guardar o grimório de toda a base, não só o dos
assinantes. É texto, então é barato, mas convém confirmar o plano do Supabase e o teto
de armazenamento antes de abrir a torneira.

Bloqueante — a exclusão de conta não apaga tudo
Conferido agora, e é pré-requisito para abrir o sync: o
_deleteUserData (supabase_auth_repository.dart:490-517) apaga
15 tabelas, mas o app sincroniza 20. Ficam no servidor depois de a
pessoa excluir a conta: freeWritings (a escrita livre — o dado mais
íntimo do app), cycleReadings, tarotReadings,
dailyCheckins, learningProgress e
userEncyclopediaEntries.

E há um segundo defeito na mesma função: a linha de profiles é apagada com
.eq('user_id', userId), mas essa tabela não tem coluna
user_id — a chave é id (confirmado nos grants do banco). A
chamada falha, o catch a engole ("Ignorar erros — tabela pode não
existir") e o perfil sobrevive à exclusão da conta, com e-mail e data
de nascimento dentro.

Hoje isso atinge só quem é Premium (o único que tem dado na nuvem). Abrir o sync para
todos transforma um vazamento pequeno num vazamento de base inteira — por isso o
conserto entra antes ou no mesmo lote, nunca depois. O caminho robusto é
derivar a lista de tabelas da própria SyncEntity, para nenhuma entidade
nova nascer fora da exclusão, e trocar a chave de profiles para
id.

Decisão

--- A porta da Leitura do Ciclo na página de assinatura fica ou sai?

Onde
subscription_page.dart:114-118, 543-587

O plano mandava remover, e ela continua lá — de propósito: o comentário no código diz
que ela existe para avisar que a leitura é compra avulsa e não entra no Premium. É
aviso de preço, não descoberta. A porta de Configurações, essa, saiu. Ficou
registrado como "aguardando decisão" desde o plano original, e a decisão é sua.

Pendente

--- O teste no aparelho, que nenhuma auditoria fecha

Em lista curta: a compra e a restauração de verdade em cada loja; o Vitalício
reinstalado; o anel do ícone maskable num launcher Android real (a margem contra a
zona segura ficou em zero); o One Tap no Safari e no Firefox; o botão voltar do
Android com a HomePage montada; e um mapa astral antigo, para ver o recálculo
acontecer.

Pronto para publicar

--- Nada disso está em produção

O PR #246 — "Publicar v2.0.31", 16 commits — está aberto e é ele que
publica: site, AAB na faixa de teste da Play e GitHub Release, depois da sua aprovação
no environment production. A main só faz ensaio. Se algum
item desta lista deve entrar antes da publicação, é agora.

===== O que ficou pronto

Conferido no código, não na lembrança.

• ✓ Três planos lado a lado, com o card do Vitalício antigo removido inteiro

• ✓ A lista de benefícios muda ao escolher o Vitalício — e as duas promessas novas são verdade no código

• ✓ Prévias que gastavam IA: todas fora (menos a da lição)

• ✓ Avisos de venda tipo "O Conselheiro teceria assim": fora

• ✓ Mapa Astral sem dado premium e sem paywall

• ✓ Emoji do signo removido de "Seus Planetas nos Signos"

• ✓ Blur restrito à Análise Personalizada

• ✓ Análise Personalizada em dez cards, com páginas que deslizam

• ✓ Geração só ao abrir o card, com trava por seção e retry de limite

• ✓ Texto gravado no Supabase de verdade — comprovado no banco de produção

• ✓ Perfil alimentando a Leitura do Ciclo pelo composer

• ✓ Nenhum "ainda não tecida" na tela

• ✓ A seção não nasce mais dizendo que falhou

• ✓ Ícone do PWA com o anel lilás, e o apple-touch-icon próprio

===== Pontos cegos — o que ninguém perguntou

Isto não são achados de código: são lacunas de contexto que mudam a prioridade de tudo o
que está acima. A primeira delas invalida parcialmente o resto, e por isso vem antes.

Pré-requisito
Conferido por mim

--- Não existe nenhum relato de erro — nada disto é observável

Onde
nenhum Sentry/Crashlytics no pubspec
feature_access.dart (_analyticsHook sem consumidor)
debug_log_service.dart:7-8

Sem serviço de relato de erro, sem analytics de produto. O _analyticsHook
do feature_access, que emite BlockedAccessEvent toda vez que
alguém bate num muro, não tem nenhum consumidor. O
OfferEngine.recordConversion grava local. E o debugLog escreve
em SharedPreferences no próprio aparelho, com teto de 200 linhas — que na
web é localStorage, apagado pela mesma regra dos 7 dias do iOS.

Consequência direta sobre esta auditoria: ela encontrou cerca de quinze defeitos do
tipo "erro engolido". Não há como saber se algum deles está acontecendo com
gente real, nem se os consertos funcionaram. O plano inteiro seria executado
e avaliado por sensação.

Recomendação
Ligar um serviço de relato de erro antes das fases de conserto — é trabalho de
meia hora e transforma todo o resto em mensurável. E ligar o
_analyticsHook a algum destino, porque ele já emite exatamente o evento
que responde "onde as pessoas batem no muro".

Pergunta aberta

--- Quantas pessoas usam o app hoje?

O único número que esta auditoria viu foi 16 perfis mágicos no banco de
produção. Se a base é dessa ordem, a prioridade muda: as chaves de IA no bundle seguem
em primeiro (robô de varredura encontra chave sozinho, sem atacante interessado), mas a
escalada de privilégio vira risco teórico por ora — e o redesenho do convite ao Premium
passa a importar mais do que qualquer dívida técnica, porque o problema real pode não
ser a tela de venda, e sim quase ninguém chegar até ela. Hoje não dá para responder:
ver o item anterior.

Pergunta aberta

--- Publicar o que já está pronto antes de empilhar o plano?

O PR #246 tem 16 commits esperando. Empilhar por cima correção de segurança, sync para
todos e redesenho de paywall produz um release grande, difícil de diagnosticar se algo
quebrar. Soltar a v2.0.31 primeiro e depois ir por fases isola os riscos.

Pergunta aberta

--- Como desligar se der errado?

Não existe feature flag no projeto. O sync para todos mexe em armazenamento, custo e no
defeito de conflito. Se azedar, o desfazer é um build novo passando pela revisão da
Apple — dias, não minutos. Vale avaliar um interruptor remoto simples para as mudanças
de maior alcance.

Pergunta aberta

--- Quanto custa um usuário gratuito por mês?

Custo de IA nunca entrou na conversa. O Perfil Mágico saiu de uma chamada para dez ou
mais, e o plano Free tem IA com limite diário. Sincronizar texto é barato; gerar texto
não é. O plano gratuito está ficando mais atraente sem que a margem seja conhecida.

Pergunta aberta

--- O banco tem backup?

Com o sync aberto para todos, o servidor passa a guardar o grimório da base inteira — e,
para quem está no iOS web, a nuvem vira a cópia, não uma cópia
adicional. Vale confirmar a política de backup do projeto no Supabase antes de abrir a
torneira.

Pergunta aberta

--- Quem revisa, e como coordenar sessões paralelas?

O plano será executado por agentes, incluindo mudanças de pagamento e de segurança.
Vale decidir se algo passa por olho humano antes da main. E há trabalho
concorrente: o PR #248 foi aberto por outra sessão enquanto esta auditoria rodava —
duas sessões editando o mesmo repositório colidem.

Pergunta aberta

--- O iOS está publicado?

Sem CI, sem configuração de Google Sign-In nativo, AdMob com identificador de teste. Se
o app está na App Store, o iOS está bem menos cuidado que o Android e esses itens sobem
de prioridade. Se ainda não está, vários achados são teóricos e podem descer na fila.

Auditoria feita por 29 agentes em duas frentes: cada dimensão foi auditada por um agente
e depois entregue a um verificador adversarial, cuja tarefa era derrubar os achados indo
ao código. Os itens graves eu também conferi à mão, um a um.

Dois achados caíram na verificação e não estão neste documento: a tela de Diagnóstico
está protegida por isOriginalAdmin, e o Vitalício reinstalado
não cobra de novo no celular. A escalada de privilégio pela tabela
profiles foi confirmada no banco em produção por consulta a
pg_policies e aos grants de coluna — não é mais uma suspeita de esquema.
