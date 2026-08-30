// ============================================================================
// GRIMÓRIO DE BOLSO — WEBHOOK DO REVENUECAT (espelho de assinatura)
// ============================================================================
// Recebe os eventos do RevenueCat e mantém `profiles.role/plan/plan_expires_at`
// como ESPELHO VIVO do direito de acesso. O RevenueCat continua sendo a fonte
// de verdade (ver docs/ORIGEM_E_PAGAMENTO.md e docs/ESPELHO_DE_ASSINATURA.md);
// aqui só refletimos cada evento no banco, para o assinante entrar Premium na
// hora do login (inclusive na web/reinstalação) e para suporte/relatório.
//
// SEGURANÇA (esta função roda com verify_jwt=false — é chamada por servidor,
// não por sessão de usuário):
//   1. O ÚNICO portão é o segredo compartilhado `REVENUECAT_WEBHOOK_SECRET`,
//      configurado tanto aqui (Function Secrets) quanto no painel do RevenueCat
//      (Webhook → Authorization header). Sem ele, fail-closed (500). Header
//      diferente → 401. Comparação de tamanho constante.
//   2. A escrita vai por `apply_subscription_state` com a service_role. O
//      cliente NÃO tem EXECUTE nessa função nem UPDATE em role/plan — o
//      lockdown continua de pé, e nada aqui abre caminho de auto-promoção.
//   3. Só ambiente PRODUCTION afeta o banco (a menos que
//      REVENUECAT_ALLOW_SANDBOX=true), para compra de teste não virar Premium.
//
// RE-TENTATIVA: falha ao aplicar responde 500 de propósito — o RevenueCat
// re-entrega, e apply_subscription_state é idempotente (aplica estado
// absoluto), então re-entrega repetida não faz mal.
//
// DEPLOY: `supabase functions deploy revenuecat-webhook --no-verify-jwt`
//   (ou já publicado via ferramenta). Passo a passo e configuração do painel
//   em docs/ESPELHO_DE_ASSINATURA.md.
// ============================================================================

import { decide, safeEqual } from './logic.ts'

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return json({ erro: 'metodo' }, 405)

  // 1. SEGREDO. Fail-closed: sem segredo configurado, não processa nada.
  const secret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET') ?? ''
  if (!secret) {
    console.error('revenuecat-webhook: REVENUECAT_WEBHOOK_SECRET ausente')
    return json({ erro: 'nao_configurado' }, 500)
  }
  const auth = req.headers.get('Authorization') ?? ''
  if (!safeEqual(auth, secret)) return json({ erro: 'nao_autorizado' }, 401)

  // 2. CORPO.
  let payload: { event?: unknown }
  try {
    payload = await req.json()
  } catch (_) {
    return json({ erro: 'corpo_ilegivel' }, 400)
  }
  // deno-lint-ignore no-explicit-any
  const event = (payload as any)?.event
  if (!event || typeof event !== 'object') return json({ erro: 'sem_event' }, 400)

  // 3. AMBIENTE. Só PRODUCTION afeta o banco — fail-closed: ambiente ausente
  // ou sandbox NÃO processa (compra de teste não vira Premium na produção).
  // Para testar ponta a ponta com sandbox, defina REVENUECAT_ALLOW_SANDBOX=true
  // (e remova depois).
  const allowSandbox = (Deno.env.get('REVENUECAT_ALLOW_SANDBOX') ?? '') === 'true'
  if (event.environment !== 'PRODUCTION' && !allowSandbox) {
    return json({ ignored: 'nao_producao' }, 200)
  }

  // 4. DECIDE (lógica pura, testada em logic.test.ts).
  const d = decide(event)
  if (d.action === 'ignore') {
    console.log(`revenuecat-webhook: ${event.type} ignorado (${d.reason})`)
    return json({ ignored: d.reason }, 200)
  }

  // 5. APLICA via service_role (a única porta de escrita do espelho).
  const url = Deno.env.get('SUPABASE_URL') ?? ''
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  if (!url || !key) {
    console.error('revenuecat-webhook: SUPABASE_URL/SERVICE_ROLE_KEY ausente')
    return json({ erro: 'configuracao' }, 500)
  }

  try {
    const res = await fetch(`${url}/rest/v1/rpc/apply_subscription_state`, {
      method: 'POST',
      headers: {
        apikey: key,
        Authorization: `Bearer ${key}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        p_user_id: d.uid,
        p_plan: d.plan,
        p_expires_at: d.expiresIso,
        p_source: 'revenuecat',
        p_event_at: d.eventAtIso,
      }),
    })
    const body = await res.text()
    if (!res.ok) {
      // 500 → o RevenueCat re-entrega. Não perdemos um evento de cobrança.
      console.error(`revenuecat-webhook: RPC ${res.status} p/ ${d.uid}: ${body}`)
      return json({ erro: 'rpc_falhou' }, 500)
    }
    // Log mínimo: tipo, uid (uuid, não é PII), plano e retorno da função.
    console.log(`revenuecat-webhook: ${d.reason} ${d.uid} -> ${d.plan} (${body})`)
    return json({ ok: true, plan: d.plan }, 200)
  } catch (e) {
    console.error(`revenuecat-webhook: falha ao aplicar p/ ${d.uid}: ${e}`)
    return json({ erro: 'indisponivel' }, 500)
  }
})
