# O QR code e o endereço `/baixar`

Um QR impresso não pode ser trocado. Se ele apontar direto para a Play, um
iPhone que o ler chega numa loja que não tem o app; se apontar direto para o
site, um Android que o ler nunca instala nada. Por isso o QR aponta para **um
endereço só**, e a decisão fica do lado do servidor, refeita a cada leitura:

```
https://grimoriodebolso.app/baixar
```

| Quem lê | Para onde vai |
| --- | --- |
| Android (inclusive dentro do Instagram/WhatsApp) | Google Play — `com.grimoriodebolso.app` |
| iPhone / iPad | o app web, em `https://grimoriodebolso.app/` |
| Computador, ou aparelho não reconhecido | o app web |

O iOS cai no app web porque **não existe publicação na App Store**. No dia em
que existir, muda-se `functions/baixar.js` e *todo QR já impresso* passa a
levar para a App Store sozinho — nada precisa ser reimpresso. É exatamente
essa a razão de existir este endereço em vez de um link direto.

## Como gerar o QR

Qualquer gerador serve; o conteúdo do código é só o texto da URL. Duas coisas
importam:

- **Nível de correção de erro `M` ou `Q`.** Um cartaz encosta na parede, mancha,
  dobra — a correção de erro é o que faz o código continuar legível.
- **Não use encurtador.** Ele acrescenta um salto, pode sair do ar e tira de
  você o controle do destino, que é justamente o que este endereço dá.

## Saber de onde veio cada instalação

Acrescente `?origem=` para marcar cada peça, e faça um QR por peça:

```
https://grimoriodebolso.app/baixar?origem=panfleto
https://grimoriodebolso.app/baixar?origem=feira
https://grimoriodebolso.app/baixar?origem=vitrine
```

No caminho do Android isso vira o `referrer` do link da Play, e aparece na
Play Console em **Aquisição de usuários → Origens de tráfego** como
`utm_source`. O `utm_medium` é sempre `qr` e o `utm_campaign`, `baixar`.

Sem `?origem=`, o `utm_source` é `qr`.

> Só valem letras, números, `-` e `_`, até 32 caracteres. Qualquer outra coisa
> (espaço, acento, sinal) é ignorada e volta para `qr` — um valor estranho não
> quebra o link, só não é rastreado.

## Conferir os dois caminhos sem ter os dois aparelhos

`?destino=` força um dos lados:

```
https://grimoriodebolso.app/baixar?destino=play   # sempre a Play
https://grimoriodebolso.app/baixar?destino=web    # sempre o app web
```

Serve para testar, e também para um QR que deva ir **sempre** para a Play.

## Onde isso mora

`functions/baixar.js`, na raiz do repositório — **não** dentro de `site/`.

É uma [Cloudflare Pages Function](https://developers.cloudflare.com/pages/functions/).
O `wrangler pages deploy public` compila o diretório `functions/` do lugar de
onde é chamado (a raiz do repositório) e gera o roteamento sozinho: só
`/baixar` passa pelo código, todo o resto do site continua sendo arquivo
estático servido direto, com o `site/_headers` valendo como sempre.

Consequência prática: **mover ou renomear esse diretório derruba o endereço**,
e o deploy segue verde, porque para o wrangler um `functions/` ausente
simplesmente significa "este site não tem Functions".

A resposta é um **302** (nunca 301) com `Cache-Control: no-store` e
`Vary: User-Agent`. Um 301 ficaria gravado no navegador para sempre — e o
destino deste endereço muda no dia em que houver App Store. O `Vary` impede
que um cache no caminho entregue a um iPhone a resposta calculada para um
Android.

## O teste

`test/redirecionamento_qr_test.mjs`, com `node test/redirecionamento_qr_test.mjs`.
Roda nos dois workflows, antes de qualquer publicação. Ele usa User-Agents
reais (Android, o navegador embutido do Instagram, iPhone, iPad, iPad em modo
desktop, Windows) e cobre o que não dá para conferir depois de o cartaz estar
impresso.
