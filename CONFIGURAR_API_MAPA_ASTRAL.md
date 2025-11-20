# Configurar API para Cálculos Precisos de Mapa Astral

O app agora usa a **Prokerala Astrology API** para cálculos precisos de mapas astrais baseados em Swiss Ephemeris.

## Por que usar API externa?

- ✨ **Precisão profissional**: Cálculos baseados em Swiss Ephemeris (biblioteca usada por astrólogos profissionais)
- 🆓 **100% Gratuito**: Plano gratuito permanente, sem cartão de crédito
- 🚀 **Sem limites de tempo**: A conta gratuita nunca expira
- 📊 **Dados completos**: Posições planetárias, casas, aspectos, retrógrados
- 🔐 **OAuth 2.0**: Autenticação segura com renovação automática de tokens

## ✅ Credenciais Já Configuradas!

O app já está configurado com as credenciais do **Grimório de Bolso**:
- Client ID: `1575f4ab-2cde-4be0-9fc9-51d820fbd6e6`
- Client Secret: `CbgSDMjlGuFyEOwLdlMEJXR2MJ6SlFKH2ETbfvpz`

**Você não precisa fazer nada!** Basta compilar o app e testar.

## Como Obter Suas Próprias Credenciais (Opcional)

Se quiser criar suas próprias credenciais no futuro:

### Passo 1: Criar Conta

1. Acesse: https://api.prokerala.com/
2. Clique em **"Sign Up"** (canto superior direito)
3. Preencha:
   - Nome
   - Email
   - Senha
4. Confirme seu email

### Passo 2: Criar Client OAuth 2.0

1. Faça login no painel: https://api.prokerala.com/
2. Vá em **"Clients"** → **"Create New Client"**
3. Preencha:
   - **Client Name**: Grimório de Bolso (ou qualquer nome)
   - **HTTP Origins**: `https://localhost` (necessário para mobile apps)
   - **Environment**: Production
4. Clique em **"Create"**
5. Copie:
   - **Client ID** (UUID)
   - **Client Secret** (string longa)

### Passo 3: Configurar no App (Se Usar Suas Próprias Credenciais)

Abra o arquivo: `lib/features/astrology/data/services/external_chart_api.dart`

Substitua as linhas 25-26:

```dart
// ANTES:
static const _clientId = '1575f4ab-2cde-4be0-9fc9-51d820fbd6e6';
static const _clientSecret = 'CbgSDMjlGuFyEOwLdlMEJXR2MJ6SlFKH2ETbfvpz';

// DEPOIS (com suas credenciais):
static const _clientId = 'seu-client-id-aqui';
static const _clientSecret = 'seu-client-secret-aqui';
```

### Passo 4: Testar

1. Compile o app: `flutter build apk --release`
2. Instale no dispositivo
3. Vá em **Ferramentas → Astrologia → Calcular Mapa Astral**
4. Insira dados de nascimento:
   - Data: 31/03/1994
   - Hora: 19:39
   - Local: São Paulo, Brazil
5. Verifique se os resultados são precisos comparando com astro.com

## Limites do Plano Gratuito

- **Requisições**: Suficiente para uso pessoal
- **Tempo**: Sem expiração
- **Custo**: R$ 0,00 / mês
- **Cartão**: Não necessário

## Troubleshooting

### Erro: "API key inválida"
- ✅ Verifique se copiou a API key completa (começa com `pk_`)
- ✅ Confirme que o User ID está correto
- ✅ Certifique-se de que confirmou o email

### Erro: "Limite de requisições excedido"
- ✅ Aguarde alguns minutos
- ✅ No plano gratuito, há limite diário razoável
- ✅ Se precisar mais, considere upgrade

### Erro: "Erro na conexão"
- ✅ Verifique sua conexão com internet
- ✅ Tente novamente em alguns segundos
- ✅ Se persistir, verifique status da API: https://status.prokerala.com/

## Fallback para Cálculos Locais

Se a API externa falhar, o app automaticamente usa cálculos locais simplificados (±2° de precisão) como fallback.

Para **desabilitar** a API externa e usar apenas cálculos locais:

Arquivo: `lib/features/astrology/data/services/chart_calculator.dart`

```dart
// Linha 26 - mudar de true para false:
static const bool _useExternalAPI = false;
```

## Upgrade para Plano Pago (Opcional)

Se você quiser mais requisições ou recursos avançados:

1. Acesse: https://api.prokerala.com/pricing
2. Planos a partir de ₹1000/mês (~R$ 60)
3. Recursos extras:
   - Mais requisições por dia
   - Suporte prioritário
   - Webhooks
   - PDF reports

## Suporte

- 📧 Email: support@prokerala.com
- 📚 Docs: https://api.prokerala.com/docs
- 💬 GitHub: https://github.com/prokerala/astrology-sdk

---

**Nota**: As instruções acima são para a API Prokerala Western Astrology. O app está configurado para usar astrologia ocidental (tropical), que é o padrão usado no Brasil e no mundo ocidental.
