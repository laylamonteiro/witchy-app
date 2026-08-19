# Service account da Play (upload automático do AAB)

O `release.yml` envia o AAB à faixa de **teste interno** da Play sem passo
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

## Avisos

- O upload via API só funciona porque o app **já existe** na Play (a v126
  foi publicada manualmente) — para um app novo, o primeiro upload é sempre
  manual.
- A permissão pode levar **até ~24h** para propagar na primeira vez.
- Erro `The caller does not have permission` = passo 2 incompleto (convite
  não aceito/propagado ou permissão errada).
- Rotação: para trocar a chave, crie uma key nova na service account,
  atualize o secret e delete a antiga no Cloud Console.
