# Configurar API para Cálculos Precisos de Mapa Astral

O app usa a **Prokerala Astrology API** para cálculos precisos de mapas astrais baseados em Swiss Ephemeris.

## Por que usar API externa?

- ✨ **Precisão profissional**: Cálculos baseados em Swiss Ephemeris (biblioteca usada por astrólogos profissionais)
- 🆓 **100% Gratuito**: Plano gratuito permanente, sem cartão de crédito
- 🚀 **Sem limites de tempo**: A conta gratuita nunca expira
- 📊 **Dados completos**: Posições planetárias, casas, aspectos, retrógrados
- 🔐 **OAuth 2.0**: Autenticação segura com renovação automática de tokens

## 🔐 Configuração Segura de Credenciais

### Passo 1: Obter Credenciais Gratuitas

1. Acesse: https://api.prokerala.com/
2. Clique em **"Sign Up"** e crie uma conta gratuita
3. Confirme seu email
4. No dashboard, vá em **"Clients"** → **"Create New Client"**
5. Preencha:
   - **Client Name**: Grimório de Bolso (ou qualquer nome)
   - **HTTP Origins**: `https://localhost` (necessário para mobile apps)
   - **Environment**: Production
6. Clique em **"Create"**
7. Copie:
   - **Client ID** (UUID longo)
   - **Client Secret** (string longa)

### Passo 2: Configurar no App (SEGURO)

O app usa um sistema seguro onde as credenciais **NÃO são commitadas no Git**.

1. Navegue até: `lib/features/astrology/data/services/`

2. Copie o arquivo de exemplo:
   ```bash
   cp prokerala_credentials.example.dart prokerala_credentials.dart
   ```

3. Edite `prokerala_credentials.dart` e substitua pelos seus valores:
   ```dart
   class ProkeralaCredentials {
     static const String clientId = 'COLE_SEU_CLIENT_ID_AQUI';
     static const String clientSecret = 'COLE_SEU_CLIENT_SECRET_AQUI';
   }
   ```

4. **NÃO commite este arquivo!** Ele está protegido pelo `.gitignore`

### Passo 3: Testar

1. Compile o app:
   ```bash
   flutter build apk --release
   ```

2. Instale no dispositivo

3. Vá em **Ferramentas → Astrologia → Calcular Mapa Astral**

4. Insira dados de nascimento e teste os cálculos

## ⚠️ Segurança - O Que Foi Corrigido

### ❌ ANTES (Inseguro):
- Credenciais hardcoded no código
- Commitadas no histórico do Git
- Visíveis no repositório remoto
- **NUNCA faça isso!**

### ✅ AGORA (Seguro):
- Credenciais em arquivo separado (`prokerala_credentials.dart`)
- Arquivo no `.gitignore` (não vai para o Git)
- Arquivo exemplo (`prokerala_credentials.example.dart`) no Git (sem credenciais reais)
- Cada desenvolvedor configura suas próprias credenciais localmente

## 🚨 Ação Recomendada

Se você já tinha credenciais configuradas antes, **revogue-as**:

1. Acesse: https://api.prokerala.com/
2. Faça login
3. Vá em **"Clients"**
4. Encontre o client "Grimório de Bolso"
5. Clique em **"Delete"** ou **"Regenerate Secret"**
6. Crie um novo client com novas credenciais
7. Configure no arquivo `prokerala_credentials.dart` local

## 📁 Estrutura de Arquivos

```
lib/features/astrology/data/services/
├── prokerala_credentials.example.dart  ✅ (vai pro Git - sem segredos)
├── prokerala_credentials.dart          🔒 (NÃO vai pro Git - com suas credenciais reais)
└── external_chart_api.dart             ✅ (vai pro Git - importa as credenciais)
```

## ❓ FAQ

**P: O que fazer se eu commitar credenciais por acidente?**
R:
1. Revogue as credenciais imediatamente no painel da Prokerala
2. Crie novas credenciais
3. Limpe o histórico do Git (ou aceite que as antigas estão comprometidas)

**P: As credenciais vão no APK compilado?**
R: Sim, mas o APK em si é distribuído a usuários específicos (você). APIs gratuitas geralmente têm rate limits por IP, então o risco é controlado.

**P: Como compartilhar o projeto com outros desenvolvedores?**
R:
1. Compartilhe o repositório normalmente
2. Cada desenvolvedor cria suas próprias credenciais Prokerala (grátis)
3. Cada um configura seu próprio arquivo `prokerala_credentials.dart` local

**P: E se eu não configurar as credenciais?**
R: O app usa cálculos locais como fallback (±2° de precisão). Funciona, mas menos preciso.

## 🔧 Troubleshooting

### Erro: "Cannot find prokerala_credentials.dart"
**Solução**: Você esqueceu de copiar o arquivo exemplo. Execute:
```bash
cp lib/features/astrology/data/services/prokerala_credentials.example.dart \
   lib/features/astrology/data/services/prokerala_credentials.dart
```

### Erro: "API key inválida"
**Solução**: Verifique se copiou corretamente o Client ID e Secret

### Erro: "Limite de requisições excedido"
**Solução**: Aguarde alguns minutos. O plano gratuito tem rate limits

## 📚 Recursos

- **API Docs**: https://api.prokerala.com/docs
- **Dashboard**: https://api.prokerala.com/
- **Suporte**: support@prokerala.com

---

**Nota**: A API Prokerala usa astrologia tropical ocidental, padrão no Brasil e mundo ocidental.
