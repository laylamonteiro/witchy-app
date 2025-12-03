# 🔮 Grimório de Bolso - Guia de Desenvolvimento

Este guia contém informações essenciais para desenvolvedores trabalhando no projeto.

## 📋 Pré-requisitos

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio ou VS Code com extensões Flutter
- Conta no [RevenueCat](https://app.revenuecat.com/) (para pagamentos)
- Conta no [Supabase](https://supabase.com/) (para autenticação e sync)

## 🚀 Configuração Inicial

### 1. Clone o Repositório

```bash
git clone https://github.com/laylamonteiro/witchy-app.git
cd witchy-app
```

### 2. Instale as Dependências

```bash
flutter pub get
```

### 3. Configure as Variáveis de Ambiente

#### Para Desenvolvimento Local

1. Copie o arquivo de exemplo:
   ```bash
   cp .env.example .env
   ```

2. Edite `.env` e adicione suas chaves:
   ```bash
   REVENUECAT_IOS_KEY=appl_xxxxxxxxxxxxxxxxx
   REVENUECAT_ANDROID_KEY=goog_xxxxxxxxxxxxxxxxx
   ```

3. Execute o app com as variáveis:
   ```bash
   flutter run --dart-define-from-file=.env
   ```

#### Para CI/CD (GitHub Actions)

As chaves são injetadas via GitHub Secrets durante o build:
- `REVENUECAT_IOS_KEY`
- `REVENUECAT_ANDROID_KEY`

Configure em: **Settings → Secrets and variables → Actions**

---

## 🛒 Configuração do RevenueCat

### Dashboard Setup (Passo a Passo)

#### 1️⃣ Criar Projeto
- Acesse: https://app.revenuecat.com/
- Crie um novo projeto: **"Grimório de Bolso"**

#### 2️⃣ Conectar as Lojas

**iOS (App Store Connect):**
1. Navegue: **Project Settings → App Settings → iOS**
2. Configure o **App-Specific Shared Secret**
3. Adicione o **Bundle ID**: `com.grimoriodebolso`

**Android (Google Play):**
1. Navegue: **Project Settings → App Settings → Android**
2. Faça upload do **Service Account JSON**
3. Adicione o **Package Name**: `com.grimoriodebolso`

#### 3️⃣ Criar Produtos nas Lojas

**📱 iOS - App Store Connect**

Acesse: https://appstoreconnect.apple.com/
- App → Features → In-App Purchases

Crie 3 produtos:

| Tipo | Product ID | Duração |
|------|-----------|---------|
| Auto-Renewable Subscription | `com.grimoriodebolso.pro.monthly` | 1 Month |
| Auto-Renewable Subscription | `com.grimoriodebolso.pro.yearly` | 1 Year |
| Non-Consumable | `com.grimoriodebolso.pro.lifetime` | N/A |

**🤖 Android - Google Play Console**

Acesse: https://play.google.com/console/
- Monetize → Products → Subscriptions

| Tipo | Product ID | Duração |
|------|-----------|---------|
| Subscription | `grimorio_pro_monthly` | 1 month |
| Subscription | `grimorio_pro_yearly` | 1 year |
| In-app product | `grimorio_pro_lifetime` | N/A |

#### 4️⃣ Configurar no RevenueCat

**A. Criar Produtos**
1. Navegue: **Products**
2. Clique: **Add Product**
3. Para cada produto, associe os IDs de iOS e Android

**B. Criar Entitlement**
1. Navegue: **Entitlements**
2. Crie: **"Grimorio de Bolso Pro"** (nome exato!)
3. Adicione os 3 produtos criados

**C. Criar Offering**
1. Navegue: **Offerings**
2. Crie offering: **"default"**
3. Adicione pacotes:
   - **Monthly** → grimorio_pro_monthly
   - **Annual** → grimorio_pro_yearly
   - **Lifetime** → grimorio_pro_lifetime

**D. Obter API Keys**
1. Navegue: **Project Settings → API Keys**
2. Copie as chaves públicas:
   - **iOS Public SDK Key** (appl_...)
   - **Android Public SDK Key** (goog_...)

---

## 🧪 Testes de Pagamento

### Sandbox Testing

**iOS:**
1. Configure uma conta de teste no App Store Connect
2. No dispositivo: Settings → App Store → Sandbox Account
3. Execute o app e teste compras

**Android:**
1. Adicione testers no Google Play Console
2. Navegue: Setup → License testing
3. Use contas Gmail configuradas como testers

### RevenueCat Tester

Use o **SDK Tester** no dashboard:
- Project Settings → SDK Tester
- Insira o App User ID do dispositivo
- Teste diferentes cenários (compra, restaurar, cancelar)

---

## 📱 Executando o App

### Modo Debug (sem pagamentos configurados)

```bash
flutter run
```

⚠️ **Nota:** Os botões de upgrade mostrarão um aviso de "Pagamentos Não Configurados"

### Modo Debug (com pagamentos)

```bash
flutter run --dart-define-from-file=.env
```

### Build de Produção

O workflow do GitHub Actions injeta as chaves automaticamente:

```bash
# Android
flutter build apk --dart-define=REVENUECAT_ANDROID_KEY=${{ secrets.REVENUECAT_ANDROID_KEY }}

# iOS
flutter build ios --dart-define=REVENUECAT_IOS_KEY=${{ secrets.REVENUECAT_IOS_KEY }}
```

---

## 🐛 Debugging

### Logs do RevenueCat

Os logs de debug são exibidos no console durante o desenvolvimento:

```
🔄 Iniciando RevenueCat...
📋 Plataforma: android
🔑 Configurando RevenueCat com API key...
✅ SDK configurado
🐛 Logs de debug habilitados
👂 Listener de CustomerInfo registrado
📥 Carregando informações do cliente...
🛒 Carregando ofertas...
✅ RevenueCat inicializado com sucesso!
   Status Pro: false
   Produtos disponíveis: 3
```

### Verificar Configuração

Se os botões não funcionarem, verifique os logs:

```
❌ RevenueCat não configurado - chaves de API ausentes
💡 Dica para desenvolvedores:
   1. Copie .env.example para .env
   2. Adicione suas chaves do RevenueCat
   3. Execute: flutter run --dart-define-from-file=.env
```

### Erros Comuns

**"Produtos não disponíveis"**
- Verifique se os produtos foram criados nas lojas
- Confirme que os Product IDs estão corretos
- Aguarde 24h após criar produtos (podem demorar para sincronizar)

**"Entitlement não encontrado"**
- Verifique se o entitlement "Grimorio de Bolso Pro" existe (nome exato!)
- Confirme que os produtos estão associados ao entitlement

**"Paywall não abre"**
- Verifique os logs do console
- Confirme que as API keys estão corretas
- Teste em um dispositivo real (não funciona em alguns emuladores)

---

## 📂 Estrutura de Código Relevante

```
lib/
├── core/
│   ├── config/
│   │   └── revenuecat_config.dart    # Configuração de chaves
│   └── services/
│       └── payment_service.dart       # Serviço de pagamentos
├── features/
│   ├── settings/
│   │   └── presentation/
│   │       └── pages/
│   │           └── settings_page.dart # Botão "Fazer Upgrade"
│   └── subscription/
│       └── presentation/
│           └── pages/
│               └── subscription_page.dart # Botão "Desbloquear Premium"
```

### Arquivos de Configuração

- `.env.example` - Template de variáveis de ambiente
- `.env` - Suas chaves locais (git-ignored)
- `lib/core/config/revenuecat_config.dart` - Configuração do SDK

---

## 🔐 Segurança

**NUNCA commit:**
- Arquivo `.env` com chaves reais
- Chaves de API hardcoded no código
- Credenciais em logs de produção

**Sempre:**
- Use `--dart-define` para injetar chaves
- Configure secrets no GitHub Actions
- Revise o `.gitignore` antes de commits

---

## 📚 Recursos Úteis

- [Documentação RevenueCat Flutter](https://docs.revenuecat.com/docs/flutter)
- [RevenueCat Dashboard](https://app.revenuecat.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Google Play Console](https://play.google.com/console/)

---

## 🆘 Suporte

Problemas? Verifique:
1. ✅ Logs no console (`flutter run`)
2. ✅ Configuração do RevenueCat Dashboard
3. ✅ Produtos criados nas lojas
4. ✅ API keys corretas no `.env`

Se o problema persistir, abra uma issue no repositório com:
- Logs do console
- Plataforma (iOS/Android)
- Versão do Flutter
- Passos para reproduzir
