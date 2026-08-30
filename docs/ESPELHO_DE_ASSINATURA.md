# Espelho da assinatura em `profiles` — como funciona e como ligar

O plano da pessoa (`role`/`plan`/`plan_expires_at`) passa a viver no banco como
**espelho vivo do RevenueCat**, mantido por webhook. O RevenueCat continua
sendo a fonte de verdade (ver `docs/ORIGEM_E_PAGAMENTO.md`); o banco é um cache
durável para o assinante entrar Premium na hora (web/reinstalação) e para
suporte/relatório.

## Como funciona (visão geral)

```
Compra/renovação/expiração na loja
        │
        ▼
RevenueCat  ──webhook (POST, Authorization: <segredo>)──▶  Edge Function
                                                            revenuecat-webhook
                                                                   │
                                                  service_role via RPC
                                                  apply_subscription_state(...)
                                                                   │
                                                                   ▼
                                                     profiles.role/plan/
                                                     plan_expires_at/plan_source
        app lê no login  ◀───────────────────────────────────────┘
```

- **`apply_subscription_state`** é a ÚNICA porta de escrita do espelho.
  `SECURITY INVOKER`, executável só pela `service_role`. Travas: nunca rebaixa
  `admin`, nunca rebaixa `lifetime` (Código Premium ou compra vitalícia).
- **O cliente NÃO escreve `role`/`plan`** (o lockdown segue de pé). Nada aqui
  reabre a auto-promoção.
- **O app só rebaixa com sinal positivo** de "não é mais Pro"
  (`PaymentService.deveRebaixar`): RevenueCat consultado E negando. Se o SDK não
  carregou (web/rede ruim), mantém o acesso do espelho — nunca derruba
  assinante válido por falha de rede.

## O que já está no ar

- **Migração aplicada** (`subscription_mirror`): colunas `plan_expires_at`,
  `plan_updated_at`, `plan_source` (anuláveis) + função
  `apply_subscription_state`. Não afetou nenhuma linha existente.
- **Edge Function publicada**: `revenuecat-webhook` (verify_jwt=false).
  Enquanto o segredo abaixo não existir, ela **recusa tudo** (fail-closed).
- **App**: lê o espelho no login (já lia `role`/`plan`) e não rebaixa sem
  status conhecido.

## O que falta — 2 passos (só você faz, precisam do painel)

### 1. Definir o segredo do webhook

Gere um segredo forte (guarde-o):

```bash
openssl rand -hex 32
```

Defina-o como **Function Secret** no Supabase (Dashboard → Project Settings →
Edge Functions → **Secrets**, ou via CLI):

```bash
supabase secrets set REVENUECAT_WEBHOOK_SECRET='<o segredo gerado>' \
  --project-ref zadqmtamrkbvdpmqtexb
```

(`SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` já são injetados
automaticamente na função — não precisa configurar.)

### 2. Cadastrar o webhook no RevenueCat

Painel do RevenueCat → **Integrations → Webhooks → Add**:

- **URL**:
  `https://zadqmtamrkbvdpmqtexb.supabase.co/functions/v1/revenuecat-webhook`
- **Authorization header**: o MESMO segredo do passo 1, **exatamente** como
  está (o header é comparado byte a byte). Se o RevenueCat exigir um prefixo,
  use o valor cru sem `Bearer`.
- **Environment**: comece por **Production**. (A função ignora eventos que não
  sejam `PRODUCTION`, a menos que você defina o secret
  `REVENUECAT_ALLOW_SANDBOX=true` — útil só num projeto de teste.)
- **Eventos**: pode mandar todos. A função trata os que importam e ignora o
  resto:
  - concedem/renovam: `INITIAL_PURCHASE`, `RENEWAL`, `UNCANCELLATION`,
    `PRODUCT_CHANGE`, `SUBSCRIPTION_EXTENDED`, `NON_RENEWING_PURCHASE`,
    `TEMPORARY_ENTITLEMENT_GRANT`
  - encerram: `EXPIRATION`, `SUBSCRIPTION_PAUSED`
  - **mantêm acesso** (no-op): `CANCELLATION`, `BILLING_ISSUE`
  - ignorados: `TRANSFER` e os demais

## Conferência

**Antes do segredo** (deve recusar — fail-closed):

```bash
curl -i -X POST \
  https://zadqmtamrkbvdpmqtexb.supabase.co/functions/v1/revenuecat-webhook \
  -H 'Content-Type: application/json' -d '{"event":{"type":"INITIAL_PURCHASE"}}'
# → HTTP 500 {"erro":"nao_configurado"}
```

**Depois do segredo**, header errado deve dar 401:

```bash
curl -i -X POST \
  https://zadqmtamrkbvdpmqtexb.supabase.co/functions/v1/revenuecat-webhook \
  -H 'Authorization: errado' -H 'Content-Type: application/json' \
  -d '{"event":{"type":"INITIAL_PURCHASE"}}'
# → HTTP 401 {"erro":"nao_autorizado"}
```

**Ponta a ponta**: no RevenueCat, use **Send test event** no webhook (ou faça
uma compra sandbox com `REVENUECAT_ALLOW_SANDBOX=true`) e confira a linha:

```sql
SELECT id, role, plan, plan_expires_at, plan_source, plan_updated_at
  FROM public.profiles
 WHERE plan_source = 'revenuecat'
 ORDER BY plan_updated_at DESC
 LIMIT 20;
```

Os logs da função (Dashboard → Edge Functions → revenuecat-webhook → Logs)
mostram `tipo uid -> plano` em cada evento, sem dado sensível.

## Backfill dos assinantes já ativos (opcional, hoje não urgente)

O espelho preenche **daqui pra frente**: cada compra/renovação/expiração cai no
webhook. Um assinante de loja que comprou ANTES disto continua `free/free` no
banco até o próximo evento dele (a renovação seguinte).

Hoje isso é praticamente inofensivo: toda a base atual entrou pelo app Android
(`signup_platform`), onde o RevenueCat carrega normalmente e o acesso não
depende do espelho — e os 24 `premium/lifetime` do banco são Código Premium
(protegidos pela trava de lifetime). **Não há assinatura de loja mensal/anual
no banco para corrigir.**

Se e quando quiser um backfill imediato (ex.: depois que a web tiver
assinantes), o caminho é iterar os `profiles.id`, consultar cada um na REST API
do RevenueCat (`GET /v1/subscribers/{app_user_id}` com a **secret API key**) e
chamar `apply_subscription_state` para os que tiverem o entitlement ativo. Dá
para fazer como uma Edge Function de mão única; me peça que eu escrevo.

## Segurança — por que isto não reabre o buraco do lockdown

- A escrita do espelho passa só pela `service_role` (servidor), validada pelo
  segredo do webhook. `authenticated`/`anon` **não** têm EXECUTE em
  `apply_subscription_state` nem UPDATE em `role`/`plan`.
- `apply_subscription_state` é `SECURITY INVOKER`: se um dia for concedida a
  `authenticated` por engano, roda com o privilégio do cliente e o lockdown a
  barra — não há como o cliente declarar o próprio plano.
- A função da web é pública (verify_jwt=false), então o **segredo é a única
  porta** — mantenha-o forte e secreto, e gire-o (passo 1 + passo 2 juntos) se
  vazar.
