# Configurar API para Cálculos Precisos de Mapa Astral

O app agora usa a **Prokerala Astrology API** para cálculos precisos de mapas astrais baseados em Swiss Ephemeris.

## Por que usar API externa?

- ✨ **Precisão profissional**: Cálculos baseados em Swiss Ephemeris (biblioteca usada por astrólogos profissionais)
- 🆓 **100% Gratuito**: Plano gratuito permanente, sem cartão de crédito
- 🚀 **Sem limites de tempo**: A conta gratuita nunca expira
- 📊 **Dados completos**: Posições planetárias, casas, aspectos, retrógrados

## Como Obter API Key Gratuita

### Passo 1: Criar Conta

1. Acesse: https://api.prokerala.com/
2. Clique em **"Sign Up"** (canto superior direito)
3. Preencha:
   - Nome
   - Email
   - Senha
4. Confirme seu email

### Passo 2: Obter Credenciais

1. Faça login no painel: https://api.prokerala.com/
2. No dashboard, você verá:
   - **User ID**: (ex: `12345`)
   - **API Key**: (ex: `pk_abc123def456...`)
3. Copie ambos os valores

### Passo 3: Configurar no App

Abra o arquivo: `lib/features/astrology/data/services/external_chart_api.dart`

Substitua as linhas 13-14:

```dart
// ANTES:
static const _apiKey = 'SUBSTITUA_PELA_SUA_CHAVE_API_PROKERALA_AQUI';
static const _userId = 'SUBSTITUA_PELO_SEU_USER_ID_AQUI';

// DEPOIS (com suas credenciais):
static const _apiKey = 'pk_abc123def456...';  // Sua API Key
static const _userId = '12345';  // Seu User ID
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
