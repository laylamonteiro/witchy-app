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

> ✅ **Publicada em 06/09/2026** no projeto `zadqmtamrkbvdpmqtexb` (v1, via
> MCP do Supabase), com **`verify_jwt=false`**. Não é afrouxamento: a sessão é
> validada na própria função, contra `/auth/v1/user`. Com `verify_jwt=true` o
> gateway recusaria o preflight de CORS (`OPTIONS`), que não carrega
> `Authorization`, e a web quebraria com um erro opaco de CORS.
>
> A função também aceita as **prévias de branch**
> (`https://<alias>.grimorio-de-bolso.pages.dev`), não só produção e
> `staging.` — sem isso a validação numa prévia dava 403 de origem.
>
> ⏳ **Falta, e é só painel:** cadastrar os secrets `GROQ_API_KEY` e
> `GEMINI_API_KEY` em **Edge Functions → Secrets**. Até lá a função responde
> `500 {"erro":"chave ausente"}` — fail-closed, de propósito. Depois disso,
> a conferência por `curl` abaixo.

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

1. ✅ `supabase functions deploy ia` (Etapa 2). ⏳ A conferência por `curl`
   depende dos secrets (painel).
2. ✅ `--dart-define=IA_PELO_SERVIDOR=true` no build web de `release.yml` e
   de `branch-validate.yml` (06/09/2026).
3. ⏳ Confirmar no staging/prévia que a IA responde logada e recusa
   deslogada — **depois** de cadastrar os secrets.
4. ✅ Etapa 4 no mesmo commit (ver abaixo).

> ⚠️ **Não corte uma tag de release antes de cadastrar os secrets.** Produção
> só publica web em tag, então mergear este trabalho na `main` é seguro; mas
> na primeira tag depois dele a IA na web passa a falar com a função, e sem
> os dois secrets ela responderia `500` até eles existirem. Staging e prévias
> já estão no caminho novo assim que o commit publicar — é ali que se valida.

**Efeito colateral tratado:** `AIService._hasGemini` decidia "tem Gemini?"
olhando só a chave **local** (`GeminiCredentials.apiKey.isNotEmpty`). Com a
chave vazia no bundle web (Etapa 4), o app acharia que não tem Gemini e
degradaria visão e sonhos para Groq em silêncio, mesmo com a chave no
servidor. Agora vale `temGeminiDisponivel(peloServidor, chaveLocal)`:
pelo servidor **ou** com chave local. `test/gemini_pelo_servidor_test.dart`
tranca a regra.

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

✅ **Ligado no mesmo commit do interruptor (06/09/2026).** É o passo
"🔒 Nenhuma chave de IA no bundle web" nos jobs web de `release.yml` e de
`branch-validate.yml`, logo depois de montar `public/`. O job web **não
recebe mais** `GROQ_API_KEY` nem `GEMINI_API_KEY` (a action de credenciais
escreve stubs vazios). O gate lista só os **arquivos** que casarem, nunca a
chave, para o log do CI não virar mais um lugar onde ela aparece.

O job **Android** continua recebendo as chaves e no caminho direto: o
interruptor foi ligado só no web, onde a chave era pública. Levar o Android
para a função é o passo natural seguinte (o app já suporta; é só o define e
o `IaPeloServidor` exigir conta lá também), mas é decisão de produto.
