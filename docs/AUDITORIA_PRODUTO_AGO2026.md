# Auditoria de produto — agosto de 2026, revisão 2 (artefato 4c68fa06)

> Texto extraído do artefato publicado em
> `claude.ai/code/artifact/4c68fa06-2fee-40c8-b710-cf277e720283`.
>
> **O próprio relatório pede para morar aqui** — a última linha dele diz
> "O relatório completo está em docs/AUDITORIA_PRODUTO_AGO2026.md". Estava
> só no artefato até agora.
>
> É um documento DIFERENTE do técnico: traz os números reais da base de
> produção, doze decisões de produto que são contrato, e um plano de cinco
> ondas. Onde ele e o técnico se contradizem, veja
> `docs/PLANO_UNIFICADO.md`.
>
> ⚠️ Contém números de negócio (contas, pagantes, receita). O repositório é
> privado; se preferir que não fiquem versionados, é só dizer.
>
> A formatação é do extrator (o original é HTML) — o conteúdo é integral.

---

Auditoria do Grimório de Bolso
Auditoria de produto · agosto de 2026 · revisão 2
O que está escrito e não está ligado
Oito auditorias de código e cinco frentes de pesquisa de mercado no Grimório de Bolso, com verificação factual hostil de ambas — sob duas restrições de produto já decididas.
Versão auditada 2.0.25+126
Superfície 503 arquivos · 148k linhas
Canais Play + web
Leituras de arquivo 1.128
Lacunas mapeadas 112
O login é obrigatório Não haverá modo convidado. A confirmação de e-mail não barra o uso — confirmado, não existe gate de confirmação no código.
Não haverá iOS nativo A aposta é o app web/PWA.
As restrições não invalidaram o diagnóstico. Elas o reordenaram — e uma delas revelou a peça que faltava para o plano fechar.
Contrato
As doze decisões
Tudo abaixo já foi decidido. Esta seção é o contrato do plano de implementação — nada aqui está em aberto .
Decisão Consequência de implementação
1 · Sincronização gratuita para todos Remover o if (!isPremium) return false; de data_sync_service.dart:233 . É o item de maior efeito de toda a lista: devolve visibilidade sobre 83% da base e conserta o iPhone em aba, que hoje perde o diário em 7 dias pelo ITP
2 · Persistir o estado da assinatura no servidor Hoje payment_service.dart não tem uma única referência a profiles : os 4 pagantes da Play existem só no RevenueCat, e no banco os quatro são role='free' . Webhook do RevenueCat → Edge Function → profiles / entitlements
3 · Fim de plano com aviso e carência Ler billingIssueDetectedAt e willRenew . Falha de cobrança → banner antes de tirar acesso. Cancelamento → mantém até o fim do período pago
4 · Liberar cartas e runas ⚠️ Não há o que liberar. AppFeature.runesBasic tem zero call sites e o texto das 78 cartas não é barrado — já são gratuitos. O trabalho é só publicar. Já lunarCalendarDetails é aplicado em 5 pontos, então a lua entra só na camada básica
5 · Publicar ~330 URLs estáticas 78 cartas + 24 runas + fases lunares (básico) + 8 sabbats, nos 3 idiomas, com hreflang e JSON-LD. Piloto de 3 páginas e teste de roteamento antes — as rotas não podem ser engolidas pelo fallback SPA do Flutter
6 · PostHog + tabelas próprias PostHog para funil e para quem desiste antes de criar conta, que o banco nunca vê. Tabelas próprias para ritos, lições e tiragens, que já chegarão de graça com a decisão 1
7 · Trial de 7 dias no anual Oferta base no Play ligada ao offering default , lida via storeProduct.introductoryPrice
8 · Anúncio contido 2-3/dia, cooldown de 15 min, e bloqueio total durante ritual, tiragem, leitura e Conselheiro. Hoje: _dailyCap = 10 e 3 min
9 · Cadastro enxuto + consentimento separado Sai “confirmar senha” e o checkbox de termos (aceite implícito com log). Entra uma caixa própria e destacada só para o dado sensível de crença — art. 5º II e art. 11 da LGPD
10 · Apple Sign-In adiada SMTP próprio agora (vale por si e é pré-requisito). Reavaliar em 60 dias com critério escrito
11 · Não trocar o motor de cobrança Zero assinantes web: nada a migrar
12 · Congelar preço Sem tráfego, é chute
A tese revisada
Sob essas restrições, o produto não é “um app com um site”. É um site de conteúdo com um app acoplado .
Essa inversão resolve a tensão que o login obrigatório parecia criar: o site estático, sem login e indexável, é o modo convidado que o app está proibido de ter . A parede de conta continua dura dentro do app — a restrição fica intacta — e o valor demonstrável, compartilhável e rastreável pelo Google passa a morar fora dele, onde não precisa de conta, não precisa de instalação, não sofre a poda de storage do Safari e funciona idêntico no iPhone.
E o corte do que publicar não é gosto, é commodity vs. autoral . O significado das 78 cartas está em dez mil sites — publicar o seu não perde nada e ganha a única fonte de descoberta que existe. As 88 lições não existem em lugar nenhum: publicá-las seria entregar o produto.
Os números reais
O relatório ganha denominador
Todas as revisões anteriores foram escritas sem base de comparação. Consultei o Postgres de produção e a conta Stripe. O diagnóstico muda de ordem.
Contas totais — a primeira em 14/07/2026 116
Criadas nos últimos 30 dias 88
Com login nos últimos 30 dias / 7 dias 42 / 11
E-mail confirmado 60 de 116
signup_platform 111 android · 0 web · 5 nulo
plan — nenhum mensal, nenhum anual 96 free · 20 lifetime · 1 admin
Assinaturas no Stripe (web) zero
Cobranças no Stripe — ambas da própria conta da dona 2 × R$ 9,90
A aposta do web tem zero usuárias. Não é “o web converte pouco” — é que nenhuma conta jamais nasceu no web . Toda a estratégia de PWA como substituto do iOS, todo o cálculo de Web Billing, Pix e Apple Sign-In está sendo discutida sobre um canal que ainda não produziu uma única pessoa. Não significa que a decisão esteja errada: significa que ela ainda não foi testada, e que otimizar o checkout desse canal antes de alguém chegar nele é resolver o problema errado.
Os 20 “premium” são códigos beta , todos lifetime . E há 4 pagantes reais na Play — 2 anuais e 2 mensais, informados pela dona. Eles não aparecem na consulta porque o isPro do RevenueCat não é persistido em profiles : no banco, os quatro são role='free' . É exatamente o buraco que a decisão 2 fecha.
O auth.audit_log_entries está vazio. corrigido A recomendação de consultá-lo para saber se algum iPhone entrou não funciona neste projeto.
O achado mais grave de toda a auditoria só aparece com o número na mão
A sincronização é Premium — data_sync_service.dart:233 , if (!isPremium) return false; . Os dados das 96 contas gratuitas nunca saem do aparelho . Só 15 pessoas têm qualquer dado no servidor, e 12 delas são premium.
Ou seja: ela é cega para 83% da própria base por decisão de arquitetura, não por falta de SDK. Nenhuma consulta SQL resolve isso.
Resolvido pelas decisões 1 e 6: a sincronização passa a ser gratuita para todos e entra PostHog ao lado das tabelas próprias. As duas fecham o buraco pelos dois lados — o dado de domínio passa a chegar ao servidor, e o funil de quem desiste antes de criar conta passa a ser visível.
E o que o mesmo dado mostra de bom
Entre as 15 pessoas cujos dados chegam ao servidor: média de 6,4 dias de check-in, máximo de 24 dias, e 13 das 15 ativas nos últimos 7 dias . Só 2 registraram um único dia.
O produto segura quem entra. O funil de cadastro para cá é que está vazando — e a aquisição é o gargalo, não a retenção.
116 contas · 4 pagantes · 0 vindos do web. Isso é ~3,4% de conversão sobre a base total — que não é ruim para a categoria. O problema não é o funil de compra: é que só 116 pessoas passaram por ele.
O gargalo é aquisição , e o SEO é tudo. Foi essa leitura que sustentou três das decisões: adiar Apple Sign-In , não trocar o motor de cobrança e congelar preço .
O padrão que se repete
Quase tudo que falta já está meio construído — e desligado
Não é código que falta escrever. É código escrito, testado, localizado em três idiomas, sem um fio ligando a ponta.
OfferEngine grava exposição, clique, dispensa e conversão por oferta
Morre no SharedPreferences ; eventCount não tem um único chamador
BlockedAccessEvent.toAnalyticsParameters() monta o evento de bloqueio completo
setBlockedAccessAnalyticsHook nunca é chamado de lugar nenhum
Degustação da lição: escrita, localizada em 3 idiomas, instrumentada
Interceptada antes de renderizar — nenhuma usuária jamais viu
bestStreak calculado a partir de 11 tabelas de evidência
Nunca exibido em nenhuma tela
JourneyProgress existe como modelo de domínio
Não é persistido: as 7 jornadas não dão XP, badge nem celebração
Notificação com deep link, agendamento e canais, tudo testado
notification_service.dart:37 — if (kIsWeb) return false; e o mesmo nas linhas 351, 359 e 364
daily_checkins já sobe para o Supabase com data por usuária
Nenhuma edge function lê isso — win-back nunca foi tentado
Dois anos de dados reais no Postgres, com signup_platform já migrado
Ninguém rodou um SELECT
O último item é o mais caro de todos, e é o mais barato de corrigir.
Placar
Oito dimensões contra a régua da categoria
Conteúdo editorial e IA 6 /10
O maior ativo do produto, e o mais subvendido
Design e identidade visual 6 /10
Identidade forte, sistema incompleto — só cor virou token
UX e arquitetura da informação 5 /10
Navegação bem resolvida, mas o vocabulário colide e há perda de dado
Monetização e conversão 5 /10
Encanamento sólido, e o paywall cobra pela coisa errada
Ativação 4 /10
Porta única, com um captcha que admite falhar
Retenção 4 /10
O canal de volta existe — e-mail — e nunca foi usado
Infraestrutura de produto 4 /10
CI/CD acima da média, observabilidade zero
Plataforma e distribuição 3 /10
Sem App Store, a descoberta é tudo — e o domínio tem 642 palavras
Plataforma caiu de 4 para 3 nesta revisão. Não porque o iOS foi cortado, mas porque cortá-lo transfere todo o peso da descoberta para o canal web — e é lá que o buraco é maior.
Diagnóstico
Os seis gargalos, em ordem de dependência
1
O produto é cego — mas a base já sabe responder
Nenhum SDK de analytics, crash reporting ou remote config. Como runZonedGuarded impede o processo de morrer, nem o Play Vitals enxerga. São 285 blocos catch , 23 terminando em debugPrint e 10 vazios.
A prova do custo: o onboarding inteiro — 474 linhas, 5 slides — foi apagado no commit d4fa073 sem um único número que dissesse se ele ajudava.
O que faltava na primeira versão desta auditoria: existe um app em produção há dois anos e ninguém olhou o que a base já diz. Não é preciso SDK nenhum para responder quantas contas, quantas ativas, quantas pagando, retenção por coorte, quanto é web — isso é SQL no Postgres que já existe, e signup_platform_migration.sql foi escrita exatamente para essa pergunta.
Com 2.000 contas e 40 assinantes, o problema é aquisição e o SEO é tudo. Com 40.000 contas e 300 assinantes, o problema é conversão e o paywall é tudo. São planos diferentes, e a resposta cabe numa tarde.
2
Ninguém acha o app
O Flutter removeu o renderer HTML na versão 3.29 — não existe mais a saída de buildar para o Google indexar. CanvasKit desenha tudo dentro de um <canvas> , e o Googlebot não extrai texto de canvas WebGL. O próprio repositório reconhece isso num comentário em site/sitemap.xml : “a raiz é o app: uma tela só, desenhada em canvas, sem conteúdo indexável” .
Palavras indexáveis em todo o domínio 642, numa página só
URLs no sitemap 3 — duas jurídicas
Lições, cartas, runas, rituais, verbetes indexáveis zero
E o teste que fecha o diagnóstico: buscar o nome exato do produto não retorna o domínio dele . Retorna um item do Genshin Impact, um jogo de tabuleiro e — pior — um concorrente direto chamado Grimorio , que está na App Store e na Play, funciona offline e suporta sete idiomas incluindo português, com posicionamento quase idêntico.
Isso desmonta uma defesa que parecia sólida. O trilinguismo protege contra Co-Star, CHANI e The Pattern — que operam só em inglês — mas não contra o concorrente posicionalmente idêntico, que já fala português e já está na loja onde você decidiu não estar . A defesa contra esse é profundidade pedagógica e curadoria autoral, não idioma.
3
A porta de entrada é única, e pode estar trancada
Com login obrigatório, 100% do público atravessa um ponto só. Esse ponto tem seis obstáculos — nome, e-mail, senha, confirmar senha , checkbox de termos e captcha — e um componente que admite falhar.
login_page.dart:616 → CaptchaGate.resolve · login_page.dart:630 → signInWithGoogle
O Turnstile roda antes do caminho de menor atrito. E o comentário do próprio captcha diz: “quando ela [a WebView] está fria (app recém instalado, dados limpos, rede lenta) o primeiro carregamento costuma falhar (…) quebrando a PRIMEIRA tentativa de quem acabou de instalar” . Já existe mitigação de 3 tentativas, o que significa que quebrou em produção antes. E “WebView fria em app recém-instalado” é o cenário de 100% dos novos usuários .
O risco específico do iPhone: login com Google dentro de PWA standalone no iOS é reconhecidamente frágil. O código tenta o caminho seguro via signInWithIdToken , mas cai para signInWithOAuth com redirect completo quando o Google Identity Services falha — e o GIS falha rotineiramente no Safari por bloqueio de cookie de terceiros. No standalone, o redirect abre navegador embutido, o verificador PKCE fica noutro contexto de storage, e a troca de código falha.
Com login obrigatório e zero crash reporting, se isso estiver quebrado a porta de 100% do público iOS está trancada e ninguém descobriria. É meia hora de teste num iPhone real.
4
As chaves de IA estão publicadas — e o Free na web não paga nada
A action que escreve as credenciais roda dentro do job de build web . O Dart compila para JavaScript: as duas chaves viram literais no main.dart.js público. Não existe supabase/functions/ — não há proxy.
release.yml:503 · ai_service.dart:854, 890, 1062, 1116
Há também um buraco que cresce com o sucesso: em user_model.dart , canUseAi => isPremium || … — o plano pago é ilimitado . Um assinante intenso a R$ 19,90 (líquidos de ~R$ 16,90) consumindo centenas de chamadas fica negativo sozinho.
E o achado que a aposta do web torna urgente: ad_service.dart:54 é !kIsWeb && (Android || iOS) . A usuária gratuita da web não gera receita de anúncio nenhuma . Cada pessoa de iPhone que chega pelo PWA — exatamente o público que a estratégia quer atrair — é 100% custo de Groq e Gemini com zero receita. Se a aposta funcionar, ela piora a economia do Free antes de melhorar a da assinatura.
5
A venda é no escuro, e o paywall está invertido
Não existe trial — nenhuma leitura de introductoryPrice nas 961 linhas do serviço de pagamento. Um paywall genérico atende ~20 contextos, com 16 call sites construindo const PremiumUpgradeSheet() direto. E os cinco benefícios vendem “leituras ilimitadas” sem citar as 88 lições nem os 46 rituais.
Mas o achado mais consequente desta revisão é outro: o paywall cobra pela coisa errada. Detalhes de cristais, ervas, cores e metais são Premium — informação commodity que qualquer pessoa acha grátis em três segundos. Enquanto isso, o que é insubstituível — o diário, o registro, a prática acumulada, o grimório que é seu — é o que sustentaria a assinatura.
Isso quebra três coisas ao mesmo tempo: faz o preço parecer ganancioso, torna o plano de SEO impossível sem canibalizar, e desalinha a história que o app conta. Inverter — referência de graça, prática e registro pagos — conserta as três numa decisão só.
nota de implementação: a regra de lição gratuita NÃO está no FeatureAccess, apesar do comentário em trails_data.dart:33 — está duplicada em trail_page.dart:59 e lesson_page.dart:86
6
Não há canal de volta — e o e-mail está ali, ignorado
Toda notificação é local. No web está desligada por decisão de código , não por limitação de plataforma. E o lembrete diário é uma frase única: quem fica seis meses recebe “🐈‍⬛ O Salem te chama” 180 vezes .
Mas o login obrigatório entrega um ativo que a primeira versão subestimou: o app tem o e-mail de 100% da base. E o valor não é a cadência lunar — são três coisas:
É o único caminho legal de vender o anual pelo checkout web a uma usuária Android sem violar a política anti-steering da Play
É o antídoto ao ITP do Safari , que apaga IndexedDB, localStorage e o service worker após 7 dias sem interação — um link mágico devolve a pessoa ao grimório depois que o Safari apagou tudo
É a apólice contra suspensão de loja , o risco existencial real de um app de bruxaria na Play brasileira
Correção da primeira versão corrigido : a sequência tem uma graça. currentStreak() verifica hoje e recua para ontem antes de zerar. O que não existe é congelamento, reparo ou aviso — um dia efetivamente perdido zera em silêncio.
A aposta
O que precisa ser verdade para o web substituir o iOS
A decisão está tomada. O que segue é o que precisa dar certo para ela render — e o que é ilusão.
O que a decisão não custa: margem. A Apple nunca cobrou nada e nunca vai cobrar, porque não há app na App Store. Todo o noticiário de Epic v. Apple é irrelevante aqui. corrigido De passagem: ele foi mal relatado em toda parte — o 9º Circuito afirmou a condenação em dezembro de 2025 e manteve a injunção; a Apple protocolou certiorari em maio de 2026, ainda pendente, sem decisão antes de 2027.
O que a decisão custa: descoberta. Não é economia de 30% — é abrir mão da vitrine que traz gente até o produto. Por isso o gargalo 2 é o gargalo 2.
O que é ilusão: Web Push no iPhone
Em 2026 a Push API no iOS continua exclusiva de web apps adicionados à Tela de Início. Não há brecha: ela não existe numa aba do Safari. O Declarative Web Push (Safari 18.4/18.5) simplificou o envio, mas não removeu o requisito de instalação.
O funil é multiplicativo e cada portão é estreito: chegar ao site → descobrir “Adicionar à Tela de Início” sem prompt do sistema (o iOS não tem beforeinstallprompt ) → aceitar a permissão. Sobre uma base que já é ~18% dos aparelhos brasileiros.
A estimativa de “10-15× menor que push nativo” que circula entre fornecedores é heurística de vendor, não medição. confiança média Trate como ordem de grandeza — a direção se sustenta e já basta para decidir.
Recomendação: não construir Web Push em 2026. É o pior retorno por esforço de toda a pesquisa e exige backend que não existe. O canal de retorno é e-mail, que já existe para 100% da base e funciona idêntico nas três plataformas.
O que é binário e barato: o login funcionar
Se o login com Google quebra em PWA standalone no iOS ou dentro do navegador embutido do Instagram, a aposta inteira vale zero — e sem crash reporting ninguém descobre. Se quebrar, o caminho é código OTP de 6 dígitos por e-mail como opção principal nesses contextos.
O que é autoinfligido: o iPhone que volta para um app vazio
O ITP do Safari apaga todo o storage de script após 7 dias sem interação. O app guarda os dados em sqflite / sqlite3.wasm . Uma usuária gratuita de iPhone escreve um diário de sonhos, some por uma semana, e volta para um app vazio.
O diagnóstico correto não é “insista na instalação”. É que a persistência no servidor é premium . Vender sincronização quando a plataforma apaga os dados em sete dias é vender proteção contra um dano que o próprio produto permitiu. O login já é obrigatório, a conta já existe, e guardar texto no Postgres custa quase nada.
Higiene de PWA que falta
Item Estado Por quê
scope no manifest ausente Urgente: sem ele, uma navegação para fora — exatamente o que o redirect do OAuth faz — pode jogar a pessoa para fora do web app
screenshots ausente Destrava o diálogo de instalação rico do Chrome Android, com cara de loja
id , lang ausentes Identidade estável da PWA
start_url "." Trocar por "/"
apple-mobile-web-app-capable ausente Só há o mobile-web-app-capable moderno (index.html:45)
apple-touch-startup-image ausente Splash em branco no iOS
description já existe corrigido Está no manifest e no <meta> — a primeira leitura errou aqui
O capítulo do dinheiro, corrigido
Este foi o pedaço da pesquisa que mais errou, e ele erra dos dois lados.
A taxa reduzida do Google Play não vale aqui. corrigido O Billing Choice Program (10%) entrou em 30/06/2026 apenas para EUA, EEE e Reino Unido . Brasil fica nas taxas antigas — 15% em assinaturas — até 30/09/2027 . A comparação correta é Play 15% contra ~3,9% no web: ~11 pontos , não ~6. Em R$ 119,90/ano, da ordem de R$ 12 por assinante.
Mas esses 11 pontos não podem ser capturados dentro do app Android. Billing alternativo com escolha do usuário também não existe no Brasil até setembro de 2027. Empurrar a usuária Android para o checkout web não é ganho de margem — é risco de suspensão do único canal nativo. Play Billing é o único caminho sancionado dentro do app; o Web Billing serve iOS, desktop, e-mail e busca.
Pix não está no RevenueCat Web Billing. corrigido Ele expõe só cartão, Apple Pay e Google Pay. Rodar sobre a Stripe não significa poder ligar os métodos locais dela. Pix exige checkout Stripe direto — a Stripe adicionou recorrência por Pix Automático em 22/04/2026 — e um webhook Stripe → Supabase → concessão de entitlement, porque o RevenueCat é hoje a fonte única de verdade do isPremiumEffective . É projeto próprio, não configuração de painel — e uma falha nele produz uma assinante que pagou e não tem Premium, invisível num app sem crash reporting.
Num mercado onde o Pix domina e a recorrência por cartão falha muito, a compra avulsa Leitura do Ciclo por Pix é provavelmente o produto de maior conversão disponível — e é o único formato em que Pix casa naturalmente.
Três decisões pedidas
Sem iPhone, login com Apple, mais pagamentos
Antes de tudo, uma correção minha. Escrevi que o RevenueCat é a fonte única de verdade do isPremiumEffective . Não é — auth_provider.dart:89-92 é um OR de três fontes, e restorePurchases() já está ligado à paywall em subscription_page.dart:728 e :768 . Isso reduz o tamanho de vários riscos abaixo.
1 · Validar o iPhone sem ter um iPhone
Não é preciso. O plano muda de “provar que funciona uma vez” para “fazer o produto contar todo dia”, e sai de graça.
O suspeito número um mudou — e é pior do que eu disse. Eu apontei o OAuth do Google. Mas login_page.dart:569-573 mostra que o fluxo de e-mail e senha também passa pelo CaptchaGate , e lança se o token vier null .
As duas portas do app têm a mesma fechadura — e essa fechadura é uma WebView que o próprio código admite falhar em aparelho recém-instalado. Não existe caminho alternativo hoje: existe um gargalo único para 100% da base.
Passo Custo O que responde
Perguntar ao banco o que ele já sabe R$ 0 · 30 min auth.audit_log_entries já grava user_agent e ip_address de cada evento de auth. Um SELECT responde hoje se algum iPhone entrou e por qual método
Corrigir o scope do manifest R$ 0 · 10 min Sem scope , o iOS decide sozinho o que é “dentro do app”, e o redirect do OAuth é navegação fora da origem
Instrumentar a tentativa de login , com evento de início e correlação R$ 0 · 3-5h Distingue “ninguém tentou” de “tentou e sumiu no meio”. O audit log só vê o que chegou ao servidor — captcha que não renderizou morre no cliente
Healthcheck externo por cron R$ 0 · 2h Pega a morte silenciosa: Supabase fora, chave errada num build, CSP, provider desconfigurado — e o segredo semestral da Apple
Roteiro de 5 minutos para uma amiga com iPhone R$ 0 Os dois cenários que nenhuma fazenda entrega barato: login dentro do ícone instalado e link aberto no navegador do Instagram
Fazenda de dispositivos só depois, e só se o dado apontar falha específica: TestingBot dá 60 minutos grátis com aparelho real e sessão manual, sem cartão. Sauce Labs pago (~US$ 199/mês) é caro demais aqui. Se um dia precisar do Simulador do Xcode: Mac mini M4 na Scaleway a €0,22/h, mínimo de 24h ≈ €5,28 .
Duas ressalvas: um “não entrou” numa fazenda pode ser IP de datacenter disparando desafio do Google — conserta-se um bug que não existe. E instrumentar só mede quem chega: se nenhuma usuária de iPhone abrir o app, o dado fica mudo. (Tentei sondar o app ao vivo daqui: o WebKit do Playwright está bloqueado no allowlist do proxy e o domínio responde 403 no CONNECT. Sondagem remota está descartada neste ambiente.)
2 · Login com Apple
É possível sem app iOS, e o caminho é curto. Um App ID no portal com a capability ligada, um Services ID como client_id , Domains e Return URLs apontando para o Supabase, e no código signInWithOAuth(OAuthProvider.apple) — ~20 linhas, zero pacotes novos . O form_post da Apple vai para o servidor do Supabase, não para a página: o app só recebe um GET com ?code= , a mesma forma do fallback do Google que já roda.
Apple Developer Program (obrigatório — a isenção exclui quem vende serviço digital) US$ 99/ano
Rotação do segredo — a Apple rejeita exp acima de 15.777.000 s a cada 6 meses, para sempre
Implementação (20 linhas + botão em 2 telas + 8 chaves nos ARBs) ~meio dia
Três coisas precisam estar resolvidas antes do botão existir:
O scope e a prova de que o redirect volta. A Apple usa o mesmo mecanismo que pode já estar quebrado para o Google em standalone. Entregar um segundo botão pelo mesmo cano antes de consertar o cano é dobrar a aposta em terreno não verificado
SMTP próprio com o domínio registrado na Apple. Com Hide My Email o app recebe @privaterelay.appleid.com , e o relay só entrega se o domínio remetente estiver registrado em “Sign in with Apple for Email Communication” com SPF batendo. E o canal morre em massa sem aviso: em 09/08/2025 um desenvolvedor viu ~20.000 endereços começarem a dar hard bounce da noite para o dia
Vinculação de identidades por conta, não por e-mail. O Supabase só vincula quando os e-mails batem — e com Hide My Email eles nunca batem. O risco é menor do que parecia, porque restorePurchases() resolve quem comprou pela Play; mas quem comprou pelo Web Billing não tem recibo de dispositivo para restaurar
O cenário que nenhuma frente da pesquisa viu, e que é o pior possível neste produto: a pessoa entra com Apple + Hide My Email, a Apple para de encaminhar, e ela fica sem senha (entrou por social), sem OTP e sem reset. Num app de login obrigatório e diário íntimo, perder o acesso é perder o conteúdo .
Mitigação: pedir um e-mail de contato a quem entrar com relay, e manter e-mail+senha sempre visível.
Minha recomendação: adiar, não descartar. Compre o dado antes do compromisso perpétuo, e escreva o critério agora: se depois de 60 dias de instrumentação a fatia de tentativas de login vinda de iPhone for relevante, a Apple entra . O que vale fazer já, independente da Apple, é o SMTP próprio — ele sai do limite do SMTP embutido, viabiliza OTP, melhora a entrega de confirmação e reset hoje, e é pré-requisito absoluto do relay.
Item de 5 minutos antes de tudo isso: abrir Authentication → SMTP Settings no painel do Supabase e ver se já existe SMTP próprio. É configuração de painel e não aparece no repositório — a pesquisa afirmou que não existe sem poder verificar. verificar
3 · Mais formas de pagamento
A jogada de melhor retorno pode custar zero, e começa com uma verificação de 20 minutos. A página oficial do Google Play para o Brasil diz que o Pix serve para “comprar apps e conteúdo digital e renovar assinaturas automaticamente ”. Se isso valer no checkout real do produto de assinatura, o canal que traz a maior parte da receita já aceita Pix — e o trabalho vira mudar a copy, sem integrar nada.
Verificar antes de anunciar: uma página de ajuda genérica não é contrato de comportamento no checkout, e prometer “aceitamos Pix” sem aceitar gera reembolso e avaliação ruim. verificar
O que está fechado:
Dentro do app Android brasileiro, Play Billing é o único caminho até 30/09/2027. O Billing Choice liberou EEE/Reino Unido/EUA em 30/06/2026, Austrália em 30/09/2026, Japão e Coreia em 31/12/2026 — o Brasil fica por último
RevenueCat Web Billing expõe exatamente três métodos: cartão, Apple Pay e Google Pay. Não há Pix, não há boleto, e não dá para habilitar os métodos locais da Stripe por baixo — a conta Stripe é da RevenueCat
Stripe com conta brasileira aceita Pix só como avulso, e o Pix é invite-only para contas BR. Pix Automático não existe para conta brasileira, e o produto que resolveria isso (Managed Payments) não atende empresa no Brasil
Boleto é o oposto: funciona recorrente na Stripe BR, mas sem Customer Portal, sem Radar, confirmando em até 1 dia útil, liquidando em T+2 e exigindo CPF
O caminho certo, se quiser mais métodos no web, é trocar o motor — não construir webhook. O RevenueCat Web tem integrações nativas com Paddle Billing (Pix avulso, boleto, PayPal, cartões; merchant of record , o que resolve imposto nos builds en/es; 5% + US$ 0,50) e com Stripe Billing usando a conta dela . Nos dois casos o entitlement continua sendo do RevenueCat — nenhuma segunda fonte de verdade.
Construir webhook próprio + tabela de entitlement + OR no cliente é a única opção que cria de fato uma segunda fonte de verdade, e a que mais quebra em silêncio num app sem crash reporting. Descartar.
Duas correções sobre o Pix que circulam erradas: ele tem estorno forçado e você não pode contestar — a Stripe remove os fundos quando o parceiro aceita a devolução. O argumento de margem continua de pé; o de “zero chargeback” cai. E CPF : Paddle e boleto exigem CPF no checkout, e um app de diário íntimo que passa a guardar CPF muda de categoria de risco sob a LGPD — argumento real a favor do merchant of record , onde o dado fica com ele.
Ordem sugerida: verificar o Pix na Play (20 min) → se confirmar, mudar a copy e parar por aqui → se não confirmar, medir quanta gente chega à paywall do web e desiste, e só então escolher um motor. Antes de qualquer migração, olhar no painel do RevenueCat quantas assinaturas web existem hoje: com três, é um e-mail; com trezentas, é projeto próprio.
Calibração
O que o mercado cobra, e o que ele diz sobre a IA
89,4% dos trials começam no dia do install — o que faz de ativação e trial a mesma conversa, não duas
3,3× é o RLTV por pagante dos apps de preço alto contra os de preço baixo. “Barato converte mais” é falso nos dados agregados
21,1% é a retenção anual de apps com IA, contra 30,7% dos sem IA. O Conselheiro é argumento de conversão, não de retenção
O Brasil é o melhor lugar para construir e o pior para extrair: receita mediana por install de US$ 0,06-0,09 na América Latina contra US$ 0,39 na América do Norte.
A categoria acabou de mudar de dono. A Midjourney comprou o Co-Star (anunciado em 24/07/2026, ~4,3M MAU) e planeja um gerador de imagens astrológico. A categoria vai ser inundada de conteúdo gerado — o que torna autoria humana visível um diferencial defensável, não um detalhe.
Quem retém, retém por conteúdo humano perecível. CHANI é o de maior faturamento nos EUA (US$ 11,99/mês) e retém por conteúdo novo toda semana, escrito e narrado por astrólogas. The Pattern retém por lock-in social. Labyrinthos é o único concorrente de aprendizado real — e prova que o formato funciona: aulas, quizzes com repetição de erro, avatar que sobe de nível.
No Brasil os fortes são de astrologia e consulta, não de ensino: Astrolink (cujo pacote Android é literalmente com.astrolink.webapp ) e Personare, a partir de R$ 9,90.
Sobre preço: R$ 19,90/mês está no topo da faixa local; o anual de R$ 119,90 (~R$ 10/mês) está bem calibrado. Congelar a discussão de preço internacional até haver tráfego real — precificar para mercados sem distribuição é resolver o problema errado.
Contrapeso
O que já está bom, e não deve ser mexido
Paridade trilíngue travada por CI , com scanner de português hardcoded bloqueante.
Esteira de release de nível profissional: guarda de semver, versionCode determinístico conferido contra todas as tags, gate no SHA da tag, conferência de assinatura, consulta prévia à API da Play, aprovação humana, trava simétrica sandbox × produção.
Fonte única de verdade de acesso com gates fail-closed — o conteúdo pago não chega à árvore de widgets atrás do blur.
Ética de cobrança correta na Leitura do Ciclo: crédito gravado antes da geração, falha de IA não consome a compra, aviso antes de pagar.
Movimento reduzido respeitado em 16 pontos , 194 ilustrações próprias e mascote animado por sprites.
LanguageGuard e sync_coverage_test — travam classes inteiras de bug em vez de casos pontuais.
Plano
Cinco ondas e uma tarde
ONDA 0 Uma tarde Antes de decidir qualquer outra coisa hoje
Item O que fazer Esforço
Ler a base que já existe SQL no Postgres: contas totais, ativas em 30/90 dias, assinantes, retenção por coorte, quebra por signup_platform , quantas contas nunca completaram a lição 1. Sem escrever código de app baixo
Perguntar ao banco sobre o iPhone auth.audit_log_entries já grava user agent e IP de cada evento de auth — um SELECT diz hoje se algum iPhone entrou e por onde, sem precisar de aparelho baixo
Corrigir o scope do manifest "scope": "/" e start_url: "/" . Dez minutos, e é o candidato nº 1 a estar quebrando o retorno do OAuth em standalone baixo
Roteiro de 5 min para uma amiga com iPhone Cobre o que nenhuma fazenda entrega barato: login dentro do ícone instalado e link aberto no navegador do Instagram baixo
Rotacionar as chaves de IA Considerar as atuais comprometidas baixo
Critério de saída: você sabe se o problema é aquisição ou conversão, e se algum iPhone já conseguiu entrar
ONDA 1 Parar o sangramento Dano que já acontece hoje ~1 a 2 semanas
Item O que fazer Esforço
Proxy de IA Edge Function autenticada por JWT, chaves como secrets, teto por user_id ; apagar os arquivos de credencial do build médio
Teto de IA no Premium Generoso e invisível. Hoje é ilimitado e fica negativo com o sucesso baixo
Escrita Livre perde texto AutomaticKeepAliveClientMixin + _save() no dispose() + autosave baixo
Guarda de trabalho não salvo UnsavedChangesGuard nos 8 formulários sem PopScope baixo
Contraste do tema claro starYellow sobre surface dá 2,25:1 com 145 usos. Refazer + teste bloqueante iterando AppThemes.all médio
Higiene de PWA scope (urgente pelo OAuth), id , lang , screenshots , start_url: "/" , meta tags da Apple baixo
Rollout gradual userFraction: 0.2 na produção baixo
Critério de saída: nenhuma chave no bundle, nenhum formulário perde dado, o tema claro passa no teste
ONDA 2 Abrir os olhos Sem isto, as ondas seguintes são apostas ~2 semanas
Item O que fazer Esforço
Analytics PostHog ou Firebase, com dicionário de no máximo 25 eventos definido antes . Respeitar o toggle privacy_analytics , que existe na tela e não controla nada médio
Ligar os hooks órfãos O de bloqueio no boot, o OfferEngine emitindo remoto, o pagamento emitindo start/complete/cancel. Dá o funil completo em menos de um dia baixo
Crash reporting Nos 4 pontos que já capturam tudo, com versão, locale, plano e breadcrumb do DebugLogService baixo
Instrumentar a aposta web Modo de exibição (standalone vs aba), plataforma, instalação da PWA baixo
Remote config pobre Tabela app_config lida no boot com fallback nas constantes médio
Critério de saída: dá para ver D7, o funil de paywall por origem, e quanto do público é web
ONDA 3 Ser achável A onda que a decisão de não fazer iOS torna obrigatória ~3 a 4 semanas
Item O que fazer Esforço
Inverter o paywall primeiro Liberar detalhes da enciclopédia e significado de cartas e runas; manter e reforçar o pago em prática, registro, IA, rituais e mapa astral. Sem isso, o item seguinte canibaliza médio
HTML estático indexável Ao lado do canvas: 78 cartas, 24 runas, 8 datas da roda do ano, fases lunares e exatamente 1 lição por trilha (9 páginas, amostra da voz). Nos 3 idiomas, com hreflang e JSON-LD. ~130 URLs ≈ 390 páginas. Nunca as outras 79 lições, nunca os 46 rituais, nunca o mapa astral médio
Piloto antes das 390 Validar 3 páginas no Search Console — e testar o roteamento : as rotas estáticas não podem ser engolidas pelo fallback SPA do Flutter baixo
Landing estática na raiz HTML puro, com o app atrás do botão “entrar”. Hoje o visitante frio paga o download inteiro do runtime antes de entender o que é o produto médio
Link em todo compartilhamento Domínio no rodapé da arte 1080×1350 + URL curta rastreável no texto, apontando para a página estática do verbete exato — a carta que saiu, não a home baixo
Autoria humana visível Na abertura das trilhas: quem escreveu, com que fontes, o que é IA e o que não é baixo
Critério de saída: buscar o nome do produto retorna o domínio, e o compartilhamento tem endereço
ONDA 4 Fazer a porta abrir Login obrigatório, sem obstáculo desnecessário ~2 a 3 semanas
Item O que fazer Esforço
Tirar o Turnstile do caminho crítico Ele barra as duas portas: login_page.dart:569-573 mostra que e-mail e senha também passam pelo CaptchaGate . Conferir antes se está exigido no painel do Supabase e se o domínio está no Hostname Management do Turnstile baixo
OTP de 6 dígitos por e-mail O caminho que não pode quebrar: um POST e um input, sem popup, sem sair da origem — funciona igual em aba, em standalone e dentro do Instagram médio
Cadastro em duas opções e um campo “Continuar com Google” e e-mail com código de 6 dígitos. Eliminar senha, confirmar senha e o checkbox médio
Termos vs. dado sensível Aceite implícito para termos (com log de versão e timestamp), mas caixa própria e destacada para dado sensível — convicção religiosa é dado sensível pelo art. 5º II da LGPD, e o art. 11 exige consentimento específico médio
Onboarding antes da parede, no Android “O que te trouxe até aqui” com as 9 trilhas como chips + a carta do dia entregue ali. Na web esse papel cabe à página de conteúdo — seis telas sobre um canvas em branco competem com o tempo de carregamento médio
Tela de chegada pós-cadastro Trocar o pushNamedAndRemoveUntil('/home') por uma tela com UMA ação médio
Navegador embutido Detectar Instagram/TikTok e priorizar OTP ali médio
Permissão de notificação Não pedir durante o onboarding; adiar para depois da primeira lição ou do segundo dia baixo
Persistência no servidor grátis Para conta gratuita. Sincronização multi-dispositivo pode continuar Premium; guardar o que a pessoa escreveu, não médio
Free consegue fechar o dia Hoje 2 de cada 6 ritos são Premium, e os 6 atalhos padrão apontam para o muro baixo
Critério de saída: a taxa de conclusão do cadastro medida na Onda 2 subiu
ONDA 5 Fechar a venda e chamar de volta O e-mail como canal principal ~4 semanas
Item O que fazer Esforço
Infra de e-mail antes do conteúdo Subdomínio de marketing separado do transacional, SPF/DKIM/DMARC nos dois. Com login obrigatório, e-mail em spam tranca a pessoa fora do app médio
Motor de ciclo de vida D0 boas-vindas, D3/D7/D14 win-back com o gancho concreto da pessoa, carta de lua nova e cheia. daily_checkins já está no Supabase médio
Anual por e-mail à base Android Pelo checkout web — o único caminho legal de capturar os ~11 pontos baixo
Trial de 7 dias no anual Com paywall na primeira sessão logo depois do primeiro momento de valor médio
Paywall contextual Por origem, com benefícios reescritos para 88 lições e 46 rituais médio
Destravar a degustação da lição Dois pontos de edição: trail_page.dart:59 e lesson_page.dart:86 baixo
Notificação viva Pool de 20-30 corpos por estado, com texto discreto por padrão médio
Sequência protegida Aviso de risco, “véu de proteção” mensal automático, bestStreak exibido médio
Fim de assinatura Ler billingIssueDetectedAt ; banner antes de qualquer downgrade médio
Anúncios De 10/dia para 2-3 com cooldown de 15 min, e bloqueio total durante ritual, tiragem e resposta do Conselheiro baixo
Blindar o Conselheiro Recusa de saúde/jurídico/financeiro, protocolo de crise com CVV 188, botão de denúncia em toda saída de IA — a política de conteúdo gerado por IA da Play exige canal de denúncia in-app médio
Critério de saída: o funil de compra existe por origem, e o e-mail é um canal medido
Disciplina
O que não fazer
Web Push no iPhone Pior retorno da pesquisa inteira. Funil multiplicativo sobre ~18% dos aparelhos e exige backend que não existe. O canal é e-mail
Publicar as 88 lições É entregar a assinatura. São ~1.000 palavras autorais por lição, e ninguém busca “a Rede wiccana” em volume — busca “significado da carta A Torre”
Empurrar a usuária Android para o checkout web Risco de política, não ganho de margem: billing alternativo não existe no Brasil até set/2027. Uma suspensão derruba o único canal nativo
WhatsApp como canal de retorno Parte relevante desse público pratica em segredo, dentro de casa evangélica ou católica. Prévia na tela bloqueada expõe a pessoa — e denúncias de intolerância religiosa subiram 66,8% em 2024. Discrição é feature neste nicho
Temporadas com contagem regressiva e selo que se perde É o caminho mais rápido para virar o que o app diz não ser. Perecibilidade sim, urgência não: a lua cheia acontece e passa — isso é fato do mundo, não pressão de produto
Testar paywall duro agora O número vem de apps que não exigem cadastro antes. Login obrigatório + paywall duro é pedir duas coisas antes de dar uma
Precificar en/es Otimizar preço para mercados com distribuição zero. Congelar até haver tráfego real
Adicionar o 23º módulo 22 módulos e 148k linhas para uma pessoa. Depois da leitura da base: quais 5 concentram 80% das sessões, e o que se congela
Migração
O que as decisões fazem com quem já usa o app
A base é de 116 contas: 96 gratuitas, 20 com código beta vitalício e 4 pagantes da Play. Cinco das doze decisões tocam essas pessoas. Duas causam dano se implementadas de forma ingênua.
Decisão 2 — pode rebaixar os 20 códigos beta. Eles têm role='premium', plan='lifetime' em profiles , e o RevenueCat nunca ouviu falar deles . Um webhook que grave “o que o RevenueCat disser” marca as 20 como gratuitas.
E o espelho: os 4 pagantes hoje são role='free' no banco. Se o app confiar no servidor antes do backfill, eles perdem o Premium até o webhook disparar.
Requisito de projeto, não detalhe: o entitlement precisa de origem ( source: beta | play | web ); o webhook nunca toca em source='beta' ; o backfill dos 4 assinantes roda antes de virar a chave de leitura; e o isPremiumEffective continua sendo um OR, para que uma falha do webhook não derrube ninguém.
Decisão 1 — o bug de ressurreição escala de 15 para 116 pessoas. Confirmei: não existe tombstone em lugar nenhum — zero ocorrências de deleted_at ou soft delete em data_sync_service.dart , database_helper.dart e nos SQL do Supabase.
A etapa 4 do _syncEntity reinsere qualquer linha remota sem correspondente local. Apagar um sonho no aparelho o traz de volta no próximo sync. Isso já acontece hoje para as 15 pessoas que sincronizam; abrir a sincronização leva o mesmo defeito para 116.
O tombstone entra no MESMO PR da sincronização livre, não depois.
A primeira sincronização das 96 contas sobe meses de dado de uma vez. Pequeno em absoluto, mas lento no aparelho — precisa de progresso visível, não de tela travada
Respeitar quem desligou de propósito. O resolveCloudSyncPreference já distingue “desligado porque era Free” de “desligado pela pessoa” ( cloudSyncUserConfiguredKey ). Ao remover o isPremium , essa distinção tem que sobreviver
Boa notícia conferida: o RLS não precisa mudar. As 20 políticas de dreams , spells , daily_checkins , gratitudes e free_writings são todas baseadas só em user_id — nenhuma olha role ou premium.
Risco médio
Decisão 6 — as 116 nunca consentiram com analytics. O toggle privacy_analytics existe na tela e não controla nada. Introduzir um processador terceiro sem honrá-lo é pior que não ter o toggle. O público deste app escreve sobre crença e sofrimento nos diários
Decisão 9 — o consentimento de dado sensível não existe para quem já entrou. As 116 contas nasceram sob o checkbox atual, sem versão nem timestamp gravados. Pedir uma vez na próxima abertura é mais limpo e custa uma tela
Decisão 10 — trocar o remetente afeta a base inteira. E-mails passam a vir de um domínio sem reputação; redefinição de senha pode cair em spam durante o aquecimento — e com login obrigatório, spam tranca a pessoa fora do app. SPF, DKIM e DMARC antes do primeiro envio
Sem impacto
Decisão Por quê
3 · Carência no fim de plano Só é mais generoso do que hoje
4 e 5 · Cartas, runas, páginas estáticas Acontecem fora do app
7 · Trial de 7 dias Vale só para compras novas. Os 4 pagantes mantêm o preço e não seriam elegíveis
8 · Anúncio contido Só melhora para as 96 gratuitas
11 e 12 · Motor de cobrança e preço Nada muda
Três achados de segurança que apareceram na conferência
Não vieram das decisões — o linter do Supabase apontou, e valem entrar no plano.
redeem_beta_code é SECURITY DEFINER e executável pelo papel anon , via /rest/v1/rpc/ . A chave anônima vive dentro do bundle por natureza. Revogar o EXECUTE do anon , exigir sessão e limitar tentativas — códigos beta concedem vitalício
handle_new_user() também é executável por anon como SECURITY DEFINER
Proteção contra senha vazada está desligada no Supabase Auth. É um toggle no painel
Cinco funções sem search_path fixo
Autonomia
O que ainda depende de você
Depois das 12 decisões e da leitura da base, restou muito pouco .
Já resolvido
Ler a base — contas, plataforma, planos, coortes consultado
Existe assinante pagante na Play? 4 — 2 anuais, 2 mensais
Decisões de produto e monetização as 12 fechadas
Ainda depende de você — acesso a painel
Nenhuma exige decisão: são coisas que só você consegue abrir ou comprar.
O que Onde Bloqueia
Webhook do RevenueCat RevenueCat → Integrations A decisão 2. Preciso da URL da Edge Function cadastrada lá e do segredo de autenticação
Chave do PostHog Criar o projeto A decisão 6
SMTP próprio + DNS Supabase → SMTP Settings, SPF/DKIM/DMARC A decisão 10 e o e-mail de win-back inteiro
O Turnstile é exigido no servidor? Supabase → Auth → Attack Protection Mexer no captcha. Se estiver ligado lá, remover o gate no cliente quebra o login
Oferta base de 7 dias Play Console → grimorio_pro_yearly A decisão 7. O código lê introductoryPrice , mas a oferta nasce no Console
Teto de anúncio AdMob A decisão 8 (parte código, parte painel)
Aval para migração em produção — Tabelas novas e a coluna de estado de assinatura rodam no Postgres de produção
Ainda não sabido — e não bloqueia
O Pix aparece no checkout de assinatura da Play? 20 minutos com conta BR. Se sim, “mais formas de pagamento” vira mudança de copy
Alguém de iPhone já abriu o app web? Não há como saber hoje. O PostHog da decisão 6 responde em dias
O Google indexa as páginas estáticas? Só o piloto de 3 páginas responde
O que eu implemento sem mais nada
As decisões que são só código — sincronização livre (1) · fim de plano com carência (3, lado cliente) · anúncios (8, lado código) · cadastro enxuto com caixa de dado sensível (9)
Correções de dano — Escrita Livre com keepalive + autosave · UnsavedChangesGuard nos 8 formulários · contraste do tema claro com teste bloqueante
Higiene de PWA — scope , id , lang , screenshots , start_url · meta tags da Apple
Justiça no Free — rito do dia filtrado por plano · carência de anúncio na primeira sessão · atalhos que a pessoa consegue terminar · o Salem deixando de apontar sempre para o mesmo paywall
Coisas que existem e não aparecem — bestStreak · XP ao vivo · busca nos Diários · busca de feitiços sem acento · reordenar o Seu Dia · destravar a degustação da lição
Limpeza — product ids iOS mortos e o signInWithFacebook() que só retorna erro
Gerador estático — as ~330 páginas da decisão 5, a partir dos mesmos *_data_{pt,en,es}.dart que alimentam o app
A sequência que eu proporia ao chat de implementação
PR 1 — o que não depende de nada
Correções de dano, higiene de PWA, justiça no Free, coisas invisíveis, limpeza. Pode começar hoje
PR 2 — sincronização livre + persistência de assinatura
Decisões 1, 2 e 3 juntas: a segunda depende da primeira estar aberta. Precisa do webhook e do aval de migração
PR 3 — instrumentação
PostHog + tabelas próprias + login_attempts + healthcheck de login. Precisa da chave
PR 4 — descoberta
Gerador estático, piloto de 3 páginas, landing na raiz, link no compartilhamento. É a onda que ataca o gargalo real
PR 5 — conversão
Trial de 7 dias, paywall contextual, benefícios reescritos. Precisa da oferta base no Console
Resposta curta
Agora que a base foi lida, a ordem encurtou. Com 116 contas, nenhuma vinda do web e nenhum assinante pagante visível no servidor , o gargalo é aquisição — e tudo que é otimização de conversão pode esperar:
01 Ser achável 02 Fazer a porta abrir 03 Enxergar as 96 contas invisíveis 04 Cobrar pela coisa certa
As duas decisões de produto não atrapalham nenhuma delas. A do login obrigatório entrega o e-mail de 100% da base, que é o canal de retorno mais valioso que este app pode ter. A de não fazer iOS obriga o site a virar produto — e é exatamente ali que mora o modo convidado que o app não vai ter.
O caminho mais curto entre hoje e “app profissional” continua passando por ligar o que já está construído e desligado.
Revisão 2. Oito auditorias de código e cinco frentes de pesquisa de mercado sobre a versão 2.0.25+126, ambas submetidas a verificação factual hostil — as marcas corrigido apontam onde a primeira leitura errou. Números de mercado são benchmarks públicos, não medições deste app — fontes:
RevenueCat ,
Sensor Tower ,
WebKit ,
Android Developers Blog ,
Statista .
O relatório completo está em docs/AUDITORIA_PRODUTO_AGO2026.md .