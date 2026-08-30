// ============================================================================
// GRIMÓRIO DE BOLSO — LÓGICA PURA DO WEBHOOK DO REVENUECAT
// ============================================================================
// Separada do handler (index.ts) porque é a parte que decide dinheiro e
// merece teste isolado (logic.test.ts) — sem subir servidor nem tocar rede.
//
// Traduz um evento do RevenueCat na intenção "aplicar tal plano" ou "ignorar",
// espelhando a mesma dedução de duração que o app faz em
// PaymentService.subscriptionTypeFromIdentifier.
// ============================================================================

/// O entitlement Pro (mesmo valor de RevenueCatConfig.proEntitlementId).
export const PRO_ENTITLEMENT = 'Grimorio de Bolso Pro'

/// Consumíveis da Leitura do Ciclo — NUNCA mexem no acesso Premium (o crédito
/// vive na tabela cycle_readings). Ver docs/ORIGEM_E_PAGAMENTO.md.
export const CYCLE_PRODUCTS = ['leitura_ciclo_mes', 'leitura_ciclo_semana']

/// Eventos que CONCEDEM/renovam acesso.
const GRANT_TYPES = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'UNCANCELLATION',
  'PRODUCT_CHANGE',
  'SUBSCRIPTION_EXTENDED',
  'NON_RENEWING_PURCHASE',
  'TEMPORARY_ENTITLEMENT_GRANT',
])

/// Eventos que ENCERRAM o acesso. SÓ a expiração de verdade: é o sinal que o
/// RevenueCat dá quando o direito realmente acabou (o reembolso chega como
/// CANCELLATION seguido de EXPIRATION; a pausa e a tolerância de cobrança
/// também terminam em EXPIRATION). Rebaixar antes disso derrubaria um
/// assinante ainda válido.
const REVOKE_TYPES = new Set([
  'EXPIRATION',
])

/// Eventos que MANTÊM o acesso (não fazem nada no espelho):
/// - CANCELLATION: auto-renovação desligada, mas continua valendo até expirar.
/// - BILLING_ISSUE: entrou em tolerância; o RevenueCat mantém o entitlement.
/// - SUBSCRIPTION_PAUSED: a pausa (Play) normalmente só vale no fim do ciclo;
///   o acesso segue até lá e o fim chega como EXPIRATION. Esperamos por ele.
const KEEP_ACCESS_TYPES = new Set([
  'CANCELLATION',
  'BILLING_ISSUE',
  'SUBSCRIPTION_PAUSED',
])

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export type PlanId = 'monthly' | 'yearly' | 'lifetime'

/// Duração EXPLÍCITA no id do produto, ou null quando o id não diz. Espelha a
/// regra do app (evita os tokens curtos "ano"/"mes", que são substring de
/// palavras comuns). NUNCA "chuta" lifetime — quem decide o vitalício sem
/// token no id é [planForGrant], e só para compra única.
export function planFromProductId(
  productId: string | null | undefined,
): PlanId | null {
  const id = (productId ?? '').toLowerCase()
  if (id.includes('lifetime') || id.includes('vitalic')) return 'lifetime'
  if (
    id.includes('annual') || id.includes('anual') ||
    id.includes('yearly') || id.includes('year')
  ) return 'yearly'
  if (
    id.includes('monthly') || id.includes('mensal') || id.includes('month')
  ) return 'monthly'
  return null
}

/// O plano de um evento de concessão. Se o id não diz a duração, só vira
/// `lifetime` quando é COMPRA ÚNICA (NON_RENEWING_PURCHASE) sem expiração —
/// nunca a partir de um grant temporário ou de uma assinatura sem token, que
/// viraria um vitalício IRREVOGÁVEL (a trava de lifetime nunca o derrubaria).
/// O padrão seguro é `monthly`: revogável por uma EXPIRATION futura.
export function planForGrant(
  type: string,
  productId: string | null | undefined,
  expirationAtMs: number | null | undefined,
): PlanId {
  const explicit = planFromProductId(productId)
  if (explicit) return explicit
  const noExp = (expirationAtMs ?? null) === null
  if (type === 'NON_RENEWING_PURCHASE' && noExp) return 'lifetime'
  return 'monthly'
}

/// O App User ID do RevenueCat É o id do Supabase (Purchases.logIn(userId)).
/// Pega o primeiro candidato com forma de uuid entre app_user_id, aliases e
/// original_app_user_id — assinantes anônimos ($RCAnonymousID:...) não casam e
/// são ignorados (não há perfil a atualizar).
export function pickSupabaseUid(
  // deno-lint-ignore no-explicit-any
  event: any,
): string | null {
  const aliases = Array.isArray(event?.aliases) ? event.aliases : []
  const cands = [event?.app_user_id, ...aliases, event?.original_app_user_id]
  for (const c of cands) {
    if (typeof c === 'string' && UUID_RE.test(c)) return c
  }
  return null
}

export type Decision =
  | {
    action: 'apply'
    uid: string
    plan: string
    expiresIso: string | null
    eventAtIso: string | null
    reason: string
  }
  | { action: 'ignore'; reason: string }

/// Traduz um evento do RevenueCat na intenção de espelho. NUNCA rebaixa por
/// evento ambíguo: CANCELLATION/BILLING_ISSUE/PAUSED mantêm acesso, e o que
/// não é do entitlement Pro é ignorado — a trava de "nunca derrubar assinante
/// válido" começa aqui e termina em apply_subscription_state (que nunca
/// rebaixa lifetime/admin nem aplica evento fora de ordem).
export function decide(
  // deno-lint-ignore no-explicit-any
  event: any,
): Decision {
  if (!event || typeof event !== 'object') {
    return { action: 'ignore', reason: 'sem_event' }
  }

  const type = String(event.type ?? '')
  // PRODUCT_CHANGE carrega o produto NOVO em new_product_id; os demais eventos
  // não têm o campo e caem em product_id.
  const productId = String(event.new_product_id ?? event.product_id ?? '')

  if (CYCLE_PRODUCTS.some((p) => productId.includes(p))) {
    return { action: 'ignore', reason: 'consumivel_ciclo' }
  }

  const uid = pickSupabaseUid(event)
  if (!uid) return { action: 'ignore', reason: 'sem_uid_supabase' }

  const eventAtIso = event.event_timestamp_ms != null
    ? new Date(Number(event.event_timestamp_ms)).toISOString()
    : null

  const ents: string[] = Array.isArray(event.entitlement_ids)
    ? event.entitlement_ids
    : (event.entitlement_id ? [event.entitlement_id] : [])
  const proTouched = ents.includes(PRO_ENTITLEMENT)

  if (GRANT_TYPES.has(type)) {
    if (!proTouched) return { action: 'ignore', reason: 'evento_nao_pro' }
    const plan = planForGrant(type, productId, event.expiration_at_ms)
    const noExp = event.expiration_at_ms == null
    const expiresIso = plan === 'lifetime' || noExp
      ? null
      : new Date(Number(event.expiration_at_ms)).toISOString()
    return { action: 'apply', uid, plan, expiresIso, eventAtIso, reason: type }
  }

  if (REVOKE_TYPES.has(type)) {
    if (!proTouched) return { action: 'ignore', reason: 'evento_nao_pro' }
    return {
      action: 'apply',
      uid,
      plan: 'free',
      expiresIso: null,
      eventAtIso,
      reason: type,
    }
  }

  if (KEEP_ACCESS_TYPES.has(type)) {
    return { action: 'ignore', reason: type + '_mantem_acesso' }
  }

  // TRANSFER e outros (INVOICE_ISSUANCE, SUBSCRIBER_ALIAS, ...): não mexem no
  // acesso. TRANSFER (entitlement muda de conta) é raro e ambíguo — o
  // conservador é não rebaixar ninguém por engano; o próximo RENEWAL/EXPIRATION
  // da conta certa acerta o espelho, e o RevenueCat corrige o app ao vivo.
  return { action: 'ignore', reason: 'tipo_ignorado:' + type }
}

/// Comparação de tamanho constante do segredo do webhook (evita timing
/// attack — a função é pública porque verify_jwt=false, então o segredo é a
/// única porta).
export function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false
  let diff = 0
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i)
  return diff === 0
}
