# Service account da Play (upload automático do AAB)

O `release.yml` envia o AAB a uma **faixa de teste** da Play sem passo
manual. Para isso ele precisa de uma service account do Google com permissão
de publicar **só em faixas de teste** — a promoção para produção continua
exclusivamente humana, na Play Console, de propósito.

Setup único (~10 min):

## 1. Criar a service account (Google Cloud)

1. [console.cloud.google.com](https://console.cloud.google.com) → selecione o
   projeto (pode ser o mesmo `grimorio-de-bolso` usado no OAuth do login
   Google).
2. **IAM & Admin → Service Accounts → Create service account**.
   - Nome: `play-publisher` (ou similar).
   - Não conceda nenhum papel de projeto — nada é necessário aqui.
3. Na service account criada → aba **Keys → Add key → Create new key →
   JSON** → baixe o arquivo. **Guarde com o mesmo cuidado do keystore**: é a
   chave de publicar o app.

## 2. Dar acesso na Play Console

1. [play.google.com/console](https://play.google.com/console) → **Usuários e
   permissões → Convidar novos usuários**.
2. E-mail: o da service account (`play-publisher@<projeto>.iam.gserviceaccount.com`).
3. **Permissões do app** → selecione só o Grimório de Bolso.
4. Conceda apenas: **"Lançar em faixas de teste"** (Release to testing
   tracks). **NÃO** conceda lançamento em produção — é a defesa em
   profundidade: mesmo um workflow comprometido não conseguiria publicar
   para o público.

## 3. Registrar o secret no GitHub

Settings → Secrets and variables → Actions → **New repository secret**:

- Nome: `PLAY_SERVICE_ACCOUNT_JSON`
- Valor: o **conteúdo bruto** do JSON baixado (sem base64).

## 4. Escolher a faixa: variável `PLAY_TRACK`

Mesma tela, aba **Variables** → *New repository variable*:

- Nome: `PLAY_TRACK`
- Valor: o **identificador** da faixa (não o nome que aparece na tela).

A API da Play usa identificadores, não rótulos. Os fixos:

| Na Play Console | Identificador |
|---|---|
| Internal testing | `internal` |
| Closed testing — Alpha | `alpha` |
| Open testing | `beta` |
| Produção | `production` — **recusado pelo workflow de propósito** |

Uma faixa fechada que **você criou** (ex.: "Closed testing — Pré-produção")
tem um identificador próprio, gerado pela Play. Para descobrir:

*Test and release → Testing → Closed testing → **Manage track*** na faixa
desejada, e leia o fim da URL:

```
https://play.google.com/console/u/0/developers/<id>/app/<id>/tracks/AQUI
```

Esse `AQUI` é o valor de `PLAY_TRACK`.

> Errar o identificador não estraga nada: antes de qualquer build, o job
> `preparar` pergunta à Play quais faixas o app tem e falha listando todas
> elas se a sua não estiver lá. Você corrige a variável e roda de novo —
> sem commit, sem versão queimada, sem nada publicado pela metade.
>
> Essa checagem também roda no **dry-run** (`somente_validar: true`), que é
> a forma de confirmar o valor da variável sem publicar nada.

## Avisos

- O upload via API só funciona porque o app **já existe** na Play (a v126
  foi publicada manualmente) — para um app novo, o primeiro upload é sempre
  manual.
- A permissão pode levar **até ~24h** para propagar na primeira vez.
- Erro `The caller does not have permission` = passo 2 incompleto (convite
  não aceito/propagado ou permissão errada).
- Rotação: para trocar a chave, crie uma key nova na service account,
  atualize o secret e delete a antiga no Cloud Console.
