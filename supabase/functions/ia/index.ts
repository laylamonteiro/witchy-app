// ============================================================================
// GRIMÓRIO DE BOLSO — O INTERMEDIÁRIO DAS CHAMADAS DE IA
// ============================================================================
// ESTE ARQUIVO NÃO ESTÁ NO AR. Ele é o material preparado para o achado
// "as chaves da Groq e da Gemini vão compiladas dentro do site" — publicar
// uma Edge Function exige o painel ou a CLI do Supabase, que não é minha
// para usar. O passo a passo está em docs/CHAVES_DE_IA.md.
//
// NUNCA FOI EXECUTADO. Não há Deno nem Supabase CLI na máquina em que ele
// foi escrito, então trate-o como um rascunho revisável, não como código
// testado: rode `supabase functions serve ia` e faça uma chamada antes de
// confiar nele.
//
// POR QUE EXISTE
// --------------
// Hoje o app manda a chave do provedor no cabeçalho, do próprio navegador.
// No aparelho isso é frágil; na web é público — o JavaScript de
// grimoriodebolso.app carrega a chave em texto, e quem abrir o DevTools a
// copia. Quem copiar consome a cota e a fatura sem passar pelo app. É a
// única coisa da auditoria que um estranho explora sozinho.
//
// A ideia é a mais simples que resolve: o corpo do pedido continua sendo
// montado no Dart, exatamente como hoje, e só o ENDEREÇO muda. Esta função
// põe a chave, encaminha e devolve a resposta do provedor sem tocar nela —
// então `_contentFromResponse` e os leitores de visão continuam valendo sem
// uma linha de mudança.
// ============================================================================

// Fail-closed em três pontos, e é de propósito: sem sessão não responde, com
// modelo fora da lista não responde, com origem fora da lista não responde.
// Um intermediário permissivo troca "roubam a chave" por "usam a chave pelo
// meu servidor", que é o mesmo prejuízo com mais passos.

const PROVEDORES = {
  groq: {
    chave: () => Deno.env.get('GROQ_API_KEY') ?? '',
    url: (_modelo: string) => 'https://api.groq.com/openai/v1/chat/completions',
    cabecalho: (chave: string) => ({ Authorization: `Bearer ${chave}` }),
  },
  gemini: {
    chave: () => Deno.env.get('GEMINI_API_KEY') ?? '',
    url: (modelo: string) =>
      `https://generativelanguage.googleapis.com/v1beta/models/${modelo}:generateContent`,
    cabecalho: (chave: string) => ({ 'x-goog-api-key': chave }),
  },
} as const

type Provedor = keyof typeof PROVEDORES

// Os modelos que o app pede hoje. O padrão existe para a função funcionar
// no primeiro deploy sem configuração extra; `MODELOS_PERMITIDOS` (separados
// por vírgula) sobrepõe. Lista vazia NÃO libera geral — recusa tudo.
const MODELOS_PADRAO = [
  'llama-3.3-70b-versatile',
  'qwen/qwen3.6-27b',
  'gemini-3.6-flash',
]

function modelosPermitidos(): string[] {
  const bruto = Deno.env.get('MODELOS_PERMITIDOS')
  if (!bruto) return MODELOS_PADRAO
  return bruto.split(',').map((m) => m.trim()).filter((m) => m.length > 0)
}

// As mesmas origens do resto do projeto (ver docs/AMBIENTES_WEB.md). O
// curinga `*` fica de fora: com credencial no pedido ele nem é aceito pelo
// navegador, e aqui seria convidar qualquer site a gastar a cota.
function origensPermitidas(): string[] {
  const bruto = Deno.env.get('ORIGENS_PERMITIDAS')
  if (bruto) return bruto.split(',').map((o) => o.trim()).filter(Boolean)
  return [
    'https://grimoriodebolso.app',
    'https://staging.grimorio-de-bolso.pages.dev',
  ]
}

function cabecalhosDeCors(origem: string | null): Record<string, string> {
  const permitidas = origensPermitidas()
  // Sem Origin é chamada de app nativo (não há CORS a resolver).
  if (!origem || !permitidas.includes(origem)) return {}
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

  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors })
  if (req.method !== 'POST') return resposta({ erro: 'metodo' }, 405, cors)

  // Origem apresentada e não autorizada: recusa antes de ler o corpo. (Sem
  // Origin — app nativo — passa: quem defende ali é a sessão, abaixo.)
  if (origem && Object.keys(cors).length === 0) {
    return resposta({ erro: 'origem' }, 403, cors)
  }

  // 1. SESSÃO. Sem uma pessoa autenticada por trás, a função seria um
  //    proxy aberto com a nossa fatura. O token é validado contra o próprio
  //    Supabase; não confiamos em nada que venha no corpo.
  const autorizacao = req.headers.get('Authorization') ?? ''
  const token = autorizacao.toLowerCase().startsWith('bearer ')
    ? autorizacao.slice(7).trim()
    : ''
  if (!token) return resposta({ erro: 'sem sessao' }, 401, cors)

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
  const anon = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  if (!supabaseUrl || !anon) return resposta({ erro: 'configuracao' }, 500, cors)

  const quem = await fetch(`${supabaseUrl}/auth/v1/user`, {
    headers: { Authorization: `Bearer ${token}`, apikey: anon },
  })
  if (!quem.ok) return resposta({ erro: 'sessao invalida' }, 401, cors)

  // 2. CORPO.
  let pedido: { provedor?: string; modelo?: string; corpo?: unknown }
  try {
    pedido = await req.json()
  } catch (_) {
    return resposta({ erro: 'corpo ilegivel' }, 400, cors)
  }

  const provedor = pedido.provedor as Provedor | undefined
  if (!provedor || !(provedor in PROVEDORES)) {
    return resposta({ erro: 'provedor' }, 400, cors)
  }
  const modelo = (pedido.modelo ?? '').trim()
  if (!modelo || !modelosPermitidos().includes(modelo)) {
    return resposta({ erro: 'modelo' }, 400, cors)
  }
  if (pedido.corpo === null || typeof pedido.corpo !== 'object') {
    return resposta({ erro: 'corpo' }, 400, cors)
  }

  const config = PROVEDORES[provedor]
  const chave = config.chave()
  if (!chave) return resposta({ erro: 'chave ausente' }, 500, cors)

  // 3. ENCAMINHA. A resposta volta como veio — status e JSON —, porque o
  //    app já sabe ler o formato de cada provedor, inclusive os erros (o 429
  //    da Groq alimenta a espera curta do Perfil Mágico).
  //
  //    NADA DE LOG DO CONTEÚDO: o corpo carrega o mapa astral e o texto que
  //    a pessoa escreveu. O que se registra é provedor, modelo e status.
  try {
    const upstream = await fetch(config.url(modelo), {
      method: 'POST',
      headers: {
        ...config.cabecalho(chave),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(pedido.corpo),
    })
    console.log(`ia: ${provedor}/${modelo} -> ${upstream.status}`)
    const texto = await upstream.text()
    return new Response(texto, {
      status: upstream.status,
      headers: { 'Content-Type': 'application/json', ...cors },
    })
  } catch (e) {
    console.error(`ia: ${provedor}/${modelo} falhou: ${e}`)
    return resposta({ erro: 'provedor indisponivel' }, 502, cors)
  }
})
