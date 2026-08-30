// Testes da lógica pura do webhook. Rode com:
//   deno test supabase/functions/revenuecat-webhook/logic.test.ts
//
// Não sobem servidor nem tocam rede (por isso a lógica mora em logic.ts,
// separada do Deno.serve de index.ts).

import { assertEquals } from 'jsr:@std/assert@1'
import { decide, planFromProduct, pickSupabaseUid, safeEqual, PRO_ENTITLEMENT } from './logic.ts'

const UID = '11111111-2222-3333-4444-555555555555'
const EXP = 1893456000000 // 2030-01-01, só para ter uma expiração no futuro

function ev(overrides: Record<string, unknown>) {
  return {
    type: 'INITIAL_PURCHASE',
    app_user_id: UID,
    environment: 'PRODUCTION',
    entitlement_ids: [PRO_ENTITLEMENT],
    product_id: 'grimorio_pro_monthly',
    expiration_at_ms: EXP,
    ...overrides,
  }
}

Deno.test('planFromProduct: durações por id', () => {
  assertEquals(planFromProduct('grimorio_pro_monthly', EXP), 'monthly')
  assertEquals(planFromProduct('com.grimoriodebolso.pro.yearly', EXP), 'yearly')
  assertEquals(planFromProduct('plano_anual', EXP), 'yearly')
  assertEquals(planFromProduct('grimorio_pro_lifetime', null), 'lifetime')
  assertEquals(planFromProduct('vitalicio', null), 'lifetime')
})

Deno.test('planFromProduct: sem duração no id, decide pela expiração', () => {
  assertEquals(planFromProduct('grimorio_pro', EXP), 'monthly') // tem expiração → assinatura
  assertEquals(planFromProduct('grimorio_pro', null), 'lifetime') // sem expiração → única
  assertEquals(planFromProduct('plano_mensal', EXP), 'monthly') // "plano" contém "ano" — não pode virar anual
})

Deno.test('pickSupabaseUid: acha o uuid; ignora anônimo', () => {
  assertEquals(pickSupabaseUid({ app_user_id: UID }), UID)
  assertEquals(pickSupabaseUid({ app_user_id: '$RCAnonymousID:abc', aliases: [UID] }), UID)
  assertEquals(pickSupabaseUid({ app_user_id: '$RCAnonymousID:abc' }), null)
})

Deno.test('compra inicial concede premium com expiração', () => {
  const d = decide(ev({ type: 'INITIAL_PURCHASE' }))
  assertEquals(d.action, 'apply')
  if (d.action === 'apply') {
    assertEquals(d.plan, 'monthly')
    assertEquals(d.uid, UID)
    assertEquals(typeof d.expiresIso, 'string')
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

Deno.test('expiração encerra o acesso (free)', () => {
  const d = decide(ev({ type: 'EXPIRATION' }))
  assertEquals(d.action === 'apply' && d.plan, 'free')
})

Deno.test('assinatura pausada encerra o acesso (free)', () => {
  const d = decide(ev({ type: 'SUBSCRIPTION_PAUSED' }))
  assertEquals(d.action === 'apply' && d.plan, 'free')
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
