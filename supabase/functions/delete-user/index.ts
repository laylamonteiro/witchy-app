// ============================================================================
// GRIMÓRIO DE BOLSO — APAGAR A CONTA DE QUEM PEDIU
// ============================================================================
// O `deleteAccount` do app apaga as linhas de dados e o `profiles`, e confere
// tabela por tabela que sumiram mesmo. O que ele NÃO alcança é a conta no
// Auth: a chave de serviço é a única que pode apagá-la, e ela não pode viver
// dentro do app. Sem esta função o app dizia "conta excluída com sucesso" e o
// cadastro ficava — o e-mail seguia ocupado depois de um pedido explícito de
// exclusão, tentar se cadastrar de novo era recusado com "já está em uso", e
// entrar com a senha antiga recriava o perfil e devolvia o acesso a uma conta
// que o app tinha dito não existir mais.
//
// SEGURANÇA — a função não aceita ID DE NINGUÉM.
//   Quem é apagado sai de `/auth/v1/user`, ou seja, do crachá de sessão de
//   quem chamou. O corpo do pedido não é lido, e não há parâmetro para
//   apontar a outra conta: no pior caso alguém apaga a própria conta, que é
//   exatamente o que esta porta existe para fazer. É a diferença entre uma
//   função de exclusão e uma arma.
//
// `verify_jwt=false` pelo mesmo motivo da função `ia`: com ele ligado o
// gateway recusaria o preflight de CORS (OPTIONS), que por definição não
// carrega Authorization, e a web quebraria com um erro opaco. A sessão é
// validada AQUI, contra o próprio Supabase, no passo 1.
//
// Fail-closed: sem `SUPABASE_SERVICE_ROLE_KEY` a função devolve 500 e o app
// mostra erro — nunca "excluída" sobre uma conta que continua de pé.
//
// DEPLOY: `supabase functions deploy delete-user --no-verify-jwt`
//   (ou pela ferramenta do Supabase, como a `ia`).
// ============================================================================

// As mesmas origens das outras funções (ver docs/AMBIENTES_WEB.md). O curinga
// `*` fica de fora: com credencial no pedido o navegador nem o aceita.
function origensPermitidas(): string[] {
  const bruto = Deno.env.get('ORIGENS_PERMITIDAS')
  if (bruto) return bruto.split(',').map((o) => o.trim()).filter(Boolean)
  return [
    'https://grimoriodebolso.app',
    'https://staging.grimorio-de-bolso.pages.dev',
  ]
}

// Prévias de branch do Cloudflare Pages. Um rótulo só, só https.
const PREVIA_PAGES = /^https:\/\/[a-z0-9-]+\.grimorio-de-bolso\.pages\.dev$/

function origemAutorizada(origem: string): boolean {
  return origensPermitidas().includes(origem) || PREVIA_PAGES.test(origem)
}

function cabecalhosDeCors(origem: string | null): Record<string, string> {
  // Sem Origin é chamada de app nativo (não há CORS a resolver).
  if (!origem || !origemAutorizada(origem)) return {}
  return {
    'Access-Control-Allow-Origin': origem,
    'Access-Control-Allow-Headers': 'authorization, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    Vary: 'Origin',
  }
}

function resposta(
  corpo: unknown,
  status: number,
  cors: Record<string, string>,
): Response {
  return new Response(JSON.stringify(corpo), {
    status,
    headers: { 'Content-Type': 'application/json', ...cors },
  })
}

Deno.serve(async (req: Request) => {
  const origem = req.headers.get('Origin')
  const cors = cabecalhosDeCors(origem)

  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: cors })
  }
  if (req.method !== 'POST') return resposta({ erro: 'metodo' }, 405, cors)

  // Origem apresentada e não autorizada: recusa antes de qualquer outra
  // coisa. (Sem Origin — app nativo — passa: quem defende ali é a sessão.)
  if (origem && Object.keys(cors).length === 0) {
    return resposta({ erro: 'origem' }, 403, cors)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const anon = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  const servico = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  if (!supabaseUrl || !anon || !servico) {
    console.error('delete-user: SUPABASE_URL/ANON_KEY/SERVICE_ROLE_KEY ausente')
    return resposta({ erro: 'configuracao' }, 500, cors)
  }

  // 1. SESSÃO. É daqui, e só daqui, que sai QUEM vai ser apagado.
  const autorizacao = req.headers.get('Authorization') ?? ''
  const token = autorizacao.toLowerCase().startsWith('bearer ')
    ? autorizacao.slice(7).trim()
    : ''
  if (!token) return resposta({ erro: 'sem sessao' }, 401, cors)

  let uid = ''
  try {
    const quem = await fetch(`${supabaseUrl}/auth/v1/user`, {
      headers: { Authorization: `Bearer ${token}`, apikey: anon },
    })
    if (!quem.ok) return resposta({ erro: 'sessao invalida' }, 401, cors)
    const pessoa = await quem.json()
    uid = typeof pessoa?.id === 'string' ? pessoa.id : ''
  } catch (e) {
    console.error(`delete-user: falha ao validar a sessao: ${e}`)
    return resposta({ erro: 'indisponivel' }, 503, cors)
  }
  if (!uid) return resposta({ erro: 'sessao invalida' }, 401, cors)

  // 2. APAGA. Exclusão DEFINITIVA, não a lógica (`should_soft_delete`): é a
  //    permanente que libera o e-mail, e o e-mail continuar ocupado depois de
  //    um pedido de exclusão é metade do defeito que esta função conserta.
  try {
    const fim = await fetch(`${supabaseUrl}/auth/v1/admin/users/${uid}`, {
      method: 'DELETE',
      headers: {
        apikey: servico,
        Authorization: `Bearer ${servico}`,
      },
    })

    // 404 é sucesso: a conta já não existe. O app pode ter perdido a
    // resposta de uma tentativa que deu certo, e a segunda tentativa não
    // pode falhar por a primeira ter funcionado.
    if (fim.ok || fim.status === 404) {
      console.log(`delete-user: ${uid} apagada (${fim.status})`)
      return resposta({ ok: true }, 200, cors)
    }

    const motivo = (await fim.text()).replace(/\s+/g, ' ').trim().slice(0, 300)
    console.error(`delete-user: ${fim.status} ao apagar ${uid}: ${motivo}`)
    return resposta({ erro: 'nao_apagou' }, 502, cors)
  } catch (e) {
    console.error(`delete-user: falha ao apagar ${uid}: ${e}`)
    return resposta({ erro: 'indisponivel' }, 503, cors)
  }
})
