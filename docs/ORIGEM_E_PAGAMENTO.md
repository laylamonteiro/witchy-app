# De onde a pessoa veio, e o que muda no pagamento

Hoje praticamente toda usuária chegou pela **Play Store**. Com o webapp no
ar isso deixa de ser verdade, e as duas origens **não** cobram, cancelam
nem reembolsam do mesmo jeito. Este documento existe para que a resposta a
"onde eu cancelo?" nunca dependa de memória.

## As duas origens

| | **Play Store** (app Android) | **Webapp** (grimoriodebolso.app) |
| --- | --- | --- |
| Quem cobra | Google Play | Stripe, via RevenueCat Web Billing |
| Chave no app | `REVENUECAT_ANDROID_KEY` | `REVENUECAT_WEB_KEY` (prod) / `REVENUECAT_WEB_KEY_SANDBOX` (staging) |
| `store` no RevenueCat | `PLAY_STORE` | `RC_BILLING` |
| Cancelar | Play Store → Assinaturas | Portal do RevenueCat/Stripe |
| Reembolso | Google (política da Play) | Stripe, por você |
| Teste sem cobrar | Licence tester na Play | Cartão de teste do Stripe (chave sandbox) |

> A chave de Android/iOS **não** tem par sandbox/produção: a própria loja
> decide o ambiente (license tester → sandbox). Só a web precisa de duas
> chaves. Ver `docs/AMBIENTES_WEB.md`.

## A regra de ouro: quem manda é o RevenueCat, não o nosso banco

O direito de acesso (entitlement `Grimorio de Bolso Pro`) e a loja que o
emitiu vivem no RevenueCat. **Não duplique isso no perfil.** Se copiássemos
"esta pessoa é da Play" para o `profiles`, o dado envelheceria no primeiro
cancelamento, upgrade ou troca de loja — e passaríamos a mandar a pessoa
cancelar no lugar errado.

Na prática:

- **Para agir** (abrir o cancelamento): use `CustomerInfo.managementURL`.
  O RevenueCat devolve o endereço certo para a loja daquela assinatura, e
  é isso que `PaymentService.openManagementPage()` já faz. Nunca monte a
  URL na mão.
- **Para saber a loja**: `entitlement.store` do entitlement ativo.
- **Para saber de onde a CONTA veio**: aí sim é nosso — ver abaixo.

## O que é nosso: a origem do cadastro

`profiles.signup_platform` (`android`, `ios` ou `web`) guarda onde a conta
**nasceu**. É histórico: não muda nunca, então não envelhece. Serve para
responder "quantas usuárias novas vieram do site?" — pergunta que o
RevenueCat não responde, porque ele só conhece quem pagou.

Preenchido uma vez, na criação do perfil.

As contas anteriores ao campo foram carimbadas como `android` pela
migração, e isso **não** é estimativa: até o webapp aceitar cadastro, a
Play Store era a única porta de entrada. Por isso a migração tem uma data
de corte — carimbar tudo indiscriminadamente marcaria como Play quem já
tivesse entrado pelo site (as contas de teste na web, inclusive).

`NULL` que sobrar significa "criada depois do corte e ainda sem carimbo", e
some sozinho conforme as pessoas entram numa versão que preenche o campo.

## Uma pessoa, duas plataformas

O mesmo login funciona no app e no site. Como o RevenueCat identifica pelo
mesmo App User ID (o id do Supabase), **o acesso atravessa as duas**: quem
assinou na Play entra Premium no site sem pagar de novo.

O que **não** atravessa é a gestão: quem assinou na Play cancela na Play,
mesmo estando no site quando decidiu cancelar. O `managementURL` já leva
ao lugar certo — é mais um motivo para nunca montar essa URL na mão.

## Compras avulsas (Leitura do Ciclo)

Os consumíveis (`leitura_ciclo_semana`, `leitura_ciclo_mes`) seguem a
mesma divisão de lojas, com uma diferença importante: **consumível não
gera entitlement**. O crédito é registrado por nós, na tabela
`cycle_readings`, e sincronizado.

Consequência prática: reinstalar o app **não** restaura um crédito ainda
não usado pela loja — ele volta pelo nosso sync, não pelo "restaurar
compras". Por isso a tabela `cycle_readings` está no sync desde o começo;
tirá-la de lá faria a pessoa perder algo que pagou.

Na web o consumível é comprado por **pacote de offering** (`getOfferings` /
`purchasePackage`): o SDK web não implementa `getProducts` nem
`purchaseStoreProduct`, então a busca por produto solto quebraria.

## Checklist quando entrar uma loja nova (iOS, por exemplo)

1. Chave própria no app e nos secrets do CI.
2. Produtos criados na loja **e** ligados ao entitlement no RevenueCat
   (menos os consumíveis, que não podem ter entitlement — ver
   `RevenueCatConfig`).
3. `signup_platform` aceita o novo valor.
4. Este documento ganha a coluna correspondente.
