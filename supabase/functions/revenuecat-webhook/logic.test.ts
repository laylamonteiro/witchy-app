// Testes da lógica pura do webhook. Rode com:
//   deno test supabase/functions/revenuecat-webhook/logic.test.ts
//
// Não sobem servidor nem tocam rede (por isso a lógica mora em logic.ts,
// separada do Deno.serve de index.ts).

import { assertEquals } from 'jsr:@std/assert@1'
import {
  decide,
  planForGrant,
  planFromProductId,
  pickSupabaseUid,
  safeEqual,
  PRO_ENTITLEMENT,
} from './logic.ts'

const UID = '11111111-2222-3333-4444-555555555555'
const EXP = 1893456000000 // 2030-01-01
const EVENT_AT = 1735689600000 // 2025-01-01

function ev(overrides: Record<string, unknown>) {
  return {
    type: 'INITIAL_PURCHASE',
    app_user_id: UID,
    environment: 'PRODUCTION',
    entitlement_ids: [PRO_ENTITLEMENT],
    product_id: 'grimorio_pro_monthly',
    expiration_at_ms: EXP,
    event_timestamp_ms: EVENT_AT,
    ...overrides,
  }
}

Deno.test('planFromProductId: duração explícita, ou null', () => {
  assertEquals(planFromProductId('grimorio_pro_monthly'), 'monthly')
  assertEquals(planFromProductId('com.grimoriodebolso.pro.yearly'), 'yearly')
  assertEquals(planFromProductId('plano_anual'), 'yearly')
  assertEquals(planFromProductId('grimorio_pro_lifetime'), 'lifetime')
  assertEquals(planFromProductId('plano_mensal'), 'monthly') // "plano" tem "ano"
  assertEquals(planFromProductId('grimorio_pro'), null) // sem token
  assertEquals(planFromProductId(''), null)
})

Deno.test('planForGrant: vitalício SÓ em compra única sem expiração', () => {
  assertEquals(planForGrant('NON_RENEWING_PURCHASE', 'grimorio_pro', null), 'lifetime')
  assertEquals(planForGrant('NON_RENEWING_PURCHASE', 'grimorio_pro_lifetime', null), 'lifetime')
  // O buraco corrigido: grant temporário sem token NÃO pode virar lifetime
  // (viraria irrevogável). Cai no padrão seguro `monthly`.
  assertEquals(planForGrant('TEMPORARY_ENTITLEMENT_GRANT', 'grimorio_pro', null), 'monthly')
  // Assinatura sem token, mas com expiração → mensal (revogável).
  assertEquals(planForGrant('RENEWAL', 'grimorio_pro', EXP), 'monthly')
})

Deno.test('pickSupabaseUid: acha o uuid; ignora anônimo', () => {
  assertEquals(pickSupabaseUid({ app_user_id: UID }), UID)
  assertEquals(pickSupabaseUid({ app_user_id: '$RCAnonymousID:abc', aliases: [UID] }), UID)
  assertEquals(pickSupabaseUid({ app_user_id: '$RCAnonymousID:abc' }), null)
})

Deno.test('compra inicial concede premium com expiração e tempo de evento', () => {
  const d = decide(ev({ type: 'INITIAL_PURCHASE' }))
  assertEquals(d.action, 'apply')
  if (d.action === 'apply') {
    assertEquals(d.plan, 'monthly')
    assertEquals(d.uid, UID)
    assertEquals(typeof d.expiresIso, 'string')
    assertEquals(d.eventAtIso, '2025-01-01T00:00:00.000Z')
  }
})

Deno.test('renovação anual → yearly', () => {
  const d = decide(ev({ type: 'RENEWAL', product_id: 'grimorio_pro_yearly' }))
  assertEquals(d.action === 'apply' && d.plan, 'yearly')
})

Deno.test('vitalício não tem expiração no espelho', () => {
  const d = decide(ev({ type: 'NON_RENEWING_PURCHASE', product_id: 'grimorio_pro_lifetime', expiration_at_ms: null }))
  assertEquals(d.action, 'apply')
  if (d.action === 'apply') {
    assertEquals(d.plan, 'lifetime')
    assertEquals(d.expiresIso, null)
  }
})

Deno.test('grant temporário NÃO vira lifetime (evita premium irrevogável)', () => {
  const d = decide(ev({ type: 'TEMPORARY_ENTITLEMENT_GRANT', product_id: 'grimorio_pro', expiration_at_ms: null }))
  assertEquals(d.action, 'apply')
  assertEquals(d.action === 'apply' && d.plan, 'monthly')
})

Deno.test('product change usa o produto NOVO (new_product_id)', () => {
  const d = decide(ev({ type: 'PRODUCT_CHANGE', product_id: 'grimorio_pro_monthly', new_product_id: 'grimorio_pro_yearly' }))
  assertEquals(d.action === 'apply' && d.plan, 'yearly')
})

Deno.test('expiração encerra o acesso (free)', () => {
  const d = decide(ev({ type: 'EXPIRATION' }))
  assertEquals(d.action === 'apply' && d.plan, 'free')
})

Deno.test('assinatura pausada MANTÉM o acesso (espera EXPIRATION)', () => {
  const d = decide(ev({ type: 'SUBSCRIPTION_PAUSED' }))
  assertEquals(d.action, 'ignore')
})

Deno.test('cancelamento MANTÉM o acesso (não mexe)', () => {
  const d = decide(ev({ type: 'CANCELLATION' }))
  assertEquals(d.action, 'ignore')
})

Deno.test('problema de cobrança MANTÉM o acesso (tolerância)', () => {
  const d = decide(ev({ type: 'BILLING_ISSUE' }))
  assertEquals(d.action, 'ignore')
})

Deno.test('consumível da Leitura do Ciclo nunca mexe no Premium', () => {
  const d = decide(ev({ type: 'NON_RENEWING_PURCHASE', product_id: 'leitura_ciclo_mes', entitlement_ids: [] }))
  assertEquals(d.action, 'ignore')
  assertEquals(d.reason, 'consumivel_ciclo')
})

Deno.test('evento sem o entitlement Pro é ignorado', () => {
  const d = decide(ev({ type: 'INITIAL_PURCHASE', entitlement_ids: ['Outro'] }))
  assertEquals(d.action, 'ignore')
  assertEquals(d.reason, 'evento_nao_pro')
})

Deno.test('sem uid Supabase (assinante anônimo) é ignorado', () => {
  const d = decide(ev({ app_user_id: '$RCAnonymousID:xyz', aliases: [] }))
  assertEquals(d.action, 'ignore')
  assertEquals(d.reason, 'sem_uid_supabase')
})

Deno.test('transfer não rebaixa ninguém', () => {
  const d = decide(ev({ type: 'TRANSFER' }))
  assertEquals(d.action, 'ignore')
})

Deno.test('safeEqual', () => {
  assertEquals(safeEqual('abc', 'abc'), true)
  assertEquals(safeEqual('abc', 'abd'), false)
  assertEquals(safeEqual('abc', 'abcd'), false)
})
