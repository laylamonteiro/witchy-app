# As chaves de IA e o navegador

> **Estado:** a exposição **continua aberta**, mas por um passo só: falta
> publicar a função e ligar o interruptor. O lado do app está pronto (Etapa
> 3) e a decisão de produto foi tomada — **exige conta**. Publicar uma Edge
> Function exige o painel ou a CLI do Supabase, que não é minha para usar.

## O que está exposto, e como conferir

A CI escreve as chaves reais dentro de arquivos `.dart`
(`.github/actions/credenciais-app/action.yml`) e o app as manda no cabeçalho,
direto do cliente. São quatro pontos, todos em `lib/core/ai/ai_service.dart`:

| Onde | Cabeçalho |
|---|---|
| `_groqText` | `Authorization: Bearer ${GroqCredentials.apiKey}` |
| `_geminiText` | `x-goog-api-key: GeminiCredentials.apiKey` |
| `_visionCall` (ramo Gemini) | `x-goog-api-key: GeminiCredentials.apiKey` |
| `_visionCall` (ramo Groq) | `Authorization: Bearer ${GroqCredentials.apiKey}` |

No aparelho isso já é frágil. **Na web é público:** o JavaScript servido em
`grimoriodebolso.app` carrega as chaves em texto, e quem abrir o DevTools as
copia. Quem copiar consome a cota — e a fatura — sem passar pelo app.

Para confirmar num build web local:

```bash
flutter build web --release --dart-define=... # como o release.yml faz
grep -ro 'gsk_[A-Za-z0-9]\{20,\}' build/web/ | head   # Groq
grep -ro 'AIza[A-Za-z0-9_-]\{30,\}' build/web/ | head # Gemini
```

### A Prokerala **não** está exposta — e saiu

A auditoria listou três chaves. São duas. Nenhum `.dart` do repositório
referencia `ProkeralaCredentials`: o mapa astral é calculado no aparelho
(Swiss Ephemeris, `sweph_service.dart`), e o arquivo de credencial era
gerado num caminho que ninguém importava. Um arquivo não importado não é
compilado, então o `clientSecret` nunca chegou a bundle nenhum — só ficava no
disco do runner, à toa.

A geração foi removida da CI. Os secrets `PROKERALA_CLIENT_ID` e
`PROKERALA_CLIENT_SECRET` não são mais lidos por workflow nenhum e **podem
ser apagados do GitHub** — ainda mais por já terem vazado uma vez
(`docs/SECURITY.md`).

## Etapa 1 — hoje, sem esperar nada (painel)

Enquanto o intermediário não existe:

1. **Gire as duas chaves** (Groq e Google AI Studio) e atualize os secrets do
   GitHub. Gire de novo depois de **cada** publicação web, porque cada
   publicação republica a chave.
2. **Ponha teto de gasto** nos dois provedores. É o que transforma "alguém
   copiou a chave" de prejuízo aberto em prejuízo limitado.

## Etapa 2 — o intermediário (`supabase/functions/ia/`)

A função está escrita e versionada. Ela recebe o corpo que o app já monta
hoje, põe a chave do lado do servidor, encaminha e devolve a resposta do
provedor **sem tocar nela** — então `_contentFromResponse` e os leitores de
visão continuam valendo sem uma linha de mudança.

Ela recusa em três pontos, de propósito: sem sessão do Supabase, com modelo
fora da lista, e com origem fora da lista. Um intermediário permissivo troca
"roubam a chave" por "usam a chave pelo meu servidor" — o mesmo prejuízo com
mais passos.

> ⚠️ **Nunca foi executada.** Foi escrita numa máquina sem Deno e sem a CLI
> do Supabase. Rode `supabase functions serve ia` e faça uma chamada antes de
> confiar nela.

```bash
supabase functions deploy ia --project-ref <ref>

supabase secrets set GROQ_API_KEY=... GEMINI_API_KEY=...
# opcionais (têm padrão no código):
supabase secrets set MODELOS_PERMITIDOS='llama-3.3-70b-versatile,qwen/qwen3.6-27b,gemini-3.6-flash'
supabase secrets set ORIGENS_PERMITIDAS='https://grimoriodebolso.app,https://staging.grimorio-de-bolso.pages.dev'
```

`SUPABASE_URL` e `SUPABASE_ANON_KEY` já existem no ambiente das funções.

Conferência, com um token de sessão de verdade:

```bash
curl -i -X POST "$SUPABASE_URL/functions/v1/ia" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "apikey: $ANON" -H 'Content-Type: application/json' \
  -d '{"provedor":"groq","modelo":"llama-3.3-70b-versatile","corpo":{
        "model":"llama-3.3-70b-versatile",
        "messages":[{"role":"user","content":"diga ok"}],
        "max_tokens":10}}'
```

Esperado: `200` com o JSON da Groq. Sem o `Authorization`: `401`. Com
`"modelo":"outro"`: `400`.

## Etapa 3 — o app já aponta para lá, atrás de um interruptor

**Decidido pela dona do produto: exige conta.** Quem usa o app sem criar
conta perde a IA na web. Foi a escolha consciente contra a alternativa
(aceitar anônimo), que protegeria a chave do provedor mas deixaria a função
gastável por qualquer um que tenha a `anon key` — que também é pública.

O app **já está religado**: os quatro pontos que montavam a URL do provedor
e o cabeçalho da chave (`_groqText`, `_geminiText` e os dois ramos de
`_visionCall`) passam agora por um único `_postarNoProvedor`, e o corpo e a
leitura da resposta não mudaram. Sem sessão, a tela recebe
`errorNeedsAccount` — uma frase que diz o que fazer, e não um 401 cru
travestido de "erro de conexão".

**O interruptor nasce desligado, e é de propósito:** a função precisa estar
no ar ANTES. Enquanto `IA_PELO_SERVIDOR` não for passado, o app segue no
caminho direto de sempre, exatamente como antes deste trabalho.

A ordem, então, é:

1. `supabase functions deploy ia` (Etapa 2) e a conferência por `curl`.
2. Acrescentar `--dart-define=IA_PELO_SERVIDOR=true` ao build web em
   `release.yml` e em `branch-validate.yml`.
3. Confirmar no staging que a IA responde logada e recusa deslogada.
4. Só então a Etapa 4.

`test/ia_pelo_servidor_test.dart` tranca o estado inicial: um build que
ligasse o caminho novo por engano, sem função no ar, não teria sintoma
nenhum até alguém tentar usar a IA.

## Etapa 4 — o gate que impede a volta

Depois que a IA na web passar pela função, as chaves não devem mais entrar no
build web. Aí o `release.yml` pode parar de passar `GROQ_API_KEY` e
`GEMINI_API_KEY` para o job de web, e um passo depois do build pode falhar se
alguma chave reaparecer no bundle:

```bash
if grep -rqE 'gsk_[A-Za-z0-9]{20,}|AIza[A-Za-z0-9_-]{30,}' public/; then
  echo "::error::chave de IA no bundle web publicado."
  exit 1
fi
```

Enquanto o interruptor da Etapa 3 estiver desligado, esse gate **falharia
todo build** — por isso ele está aqui como texto, e não no workflow. Ligue-o
no mesmo commit em que ligar o `IA_PELO_SERVIDOR`.
