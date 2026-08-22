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

## 🐛 Troubleshooting

### 🔍 **Problema: Paywall abre, mas ao clicar "Começar Agora" não acontece nada**

**Sintomas:**
- Paywall do RevenueCat abre normalmente
- Produtos aparecem com preços
- Ao selecionar um plano e clicar em "Começar Agora", nada acontece
- Ao fechar o paywall, aparece: *"Erro ao processar compra. Tente novamente"*

**Diagnóstico:**

1. **Verifique os logs do console** durante a tentativa de compra:
   ```bash
   flutter run
   # Tente fazer uma compra e observe os logs
   ```

2. **Logs esperados durante inicialização bem-sucedida:**
   ```
   🔄 Iniciando RevenueCat...
   ✅ SDK configurado
   📥 Carregando informações do cliente...
   🛒 Carregando ofertas...
   ✅ Offering encontrada: default
   📦 Pacotes disponíveis: 3
      📦 $rc_monthly:
         - Product ID: grimorio_pro_monthly (ou com.grimoriodebolso.pro.monthly)
> **Preço:** os valores abaixo são de quando este documento foi escrito e NÃO são a fonte da verdade. O preço vigente vem sempre da RevenueCat em tempo de execução; os valores de RESERVA (usados só quando a loja não responde) ficam em `lib/features/auth/presentation/widgets/premium_blur_widget.dart`. Documento que repete preço apodrece no próximo reajuste.

         - Preço: R$ 9,90
      📦 $rc_annual:
         - Product ID: grimorio_pro_yearly (ou com.grimoriodebolso.pro.yearly)
         - Preço: R$ 79,90
   ✅ Produtos carregados: 3
   ```

3. **Logs durante tentativa de compra:**
   ```
   🛒 Iniciando compra: SubscriptionType.monthly
   📦 Buscando ofertas...
   ✅ Offering encontrada: default
   ✅ Pacote encontrado: $rc_monthly
   🚀 Iniciando compra na loja...
   ```

**Possíveis Causas e Soluções:**

#### ❌ **Erro: "Produto não disponível para compra"**

**Causa:** Os produtos não foram criados ou não estão aprovados nas lojas.

**Solução:**

**Para iOS:**
1. Acesse [App Store Connect](https://appstoreconnect.apple.com/)
2. Vá em: **App → Features → In-App Purchases**
3. Verifique se os produtos existem:
   - `com.grimoriodebolso.pro.monthly`
   - `com.grimoriodebolso.pro.yearly`
   - `com.grimoriodebolso.pro.lifetime`
4. **Status deve ser:** "Ready to Submit" ou "Approved"
5. **Importante:** Novos produtos podem demorar até 24h para sincronizar

**Para Android:**
1. Acesse [Google Play Console](https://play.google.com/console/)
2. Vá em: **Monetize → Products → Subscriptions** (ou In-app products para lifetime)
3. Verifique se os produtos existem:
   - `grimorio_pro_monthly`
   - `grimorio_pro_yearly`
   - `grimorio_pro_lifetime`
4. **Status deve ser:** "Active"
5. Certifique-se de que o app foi publicado pelo menos como "Internal Testing"

---

#### ❌ **Erro: "Nenhuma oferta disponível"**

**Causa:** A offering "default" não existe ou não tem produtos associados.

**Solução:**
1. Acesse [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Vá em: **Offerings**
3. Verifique se existe uma offering chamada **"default"** (exatamente esse nome!)
4. Abra a offering e verifique se os 3 pacotes estão adicionados:
   - **Monthly** (Monthly package)
   - **Annual** (Annual package)
   - **Lifetime** (Lifetime package)

---

#### ❌ **Erro: "IDs dos produtos não correspondem"**

**Causa:** Os Product IDs no RevenueCat não batem com os das lojas.

**Solução:**
1. No [RevenueCat Dashboard](https://app.revenuecat.com/), vá em **Products**
2. Para cada produto, verifique:
   - **iOS ID** deve ser EXATAMENTE: `com.grimoriodebolso.pro.monthly` (ou yearly/lifetime)
   - **Android ID** deve ser EXATAMENTE: `grimorio_pro_monthly` (ou yearly/lifetime)
3. **Atenção:** IDs são case-sensitive e devem ser idênticos aos criados nas lojas

---

#### ❌ **Erro: "Compras não permitidas neste dispositivo"**

**Causa:** Restrições de compra no dispositivo ou conta não configurada para sandbox.

**Solução:**

**Para iOS:**
1. Abra **Configurações → Screen Time → Content & Privacy Restrictions**
2. Verifique se "In-App Purchases" está **permitido**
3. Para testar em sandbox:
   - Vá em **Configurações → App Store → Sandbox Account**
   - Faça login com uma conta de teste criada no App Store Connect
   - **Importante:** Use uma conta diferente da sua conta principal do Apple ID

**Para Android:**
1. Verifique se você está logado com uma conta Google válida
2. Para testar:
   - Adicione sua conta como "License tester" no Google Play Console
   - Ou publique o app em "Internal Testing" e instale via Play Store

---

#### ❌ **Erro: "Entitlement não encontrado após compra"**

**Causa:** O entitlement não está configurado corretamente.

**Solução:**
1. No [RevenueCat Dashboard](https://app.revenuecat.com/), vá em **Entitlements**
2. Verifique se existe um entitlement chamado **"Grimorio de Bolso Pro"** (exatamente esse nome!)
3. Abra o entitlement e verifique se os 3 produtos estão associados:
   - grimorio_pro_monthly / com.grimoriodebolso.pro.monthly
   - grimorio_pro_yearly / com.grimoriodebolso.pro.yearly
   - grimorio_pro_lifetime / com.grimoriodebolso.pro.lifetime

---

### 📋 **Checklist de Configuração Completa**

Use este checklist para garantir que tudo está configurado:

#### RevenueCat Dashboard
- [ ] Projeto "Grimório de Bolso" criado
- [ ] App Store Connect conectado (iOS)
- [ ] Google Play Console conectado (Android)
- [ ] 3 produtos criados e configurados
- [ ] Entitlement "Grimorio de Bolso Pro" criado
- [ ] Os 3 produtos estão associados ao entitlement
- [ ] Offering "default" criada
- [ ] Os 3 pacotes (Monthly, Annual, Lifetime) estão na offering
- [ ] API Keys copiadas (iOS e Android)

#### App Store Connect (iOS)
- [ ] 3 In-App Purchases criados
- [ ] Product IDs corretos: `com.grimoriodebolso.pro.*`
- [ ] Status: "Ready to Submit" ou "Approved"
- [ ] Conta de teste sandbox criada
- [ ] App-Specific Shared Secret configurado no RevenueCat

#### Google Play Console (Android)
- [ ] 2 Subscriptions criados (monthly, yearly)
- [ ] 1 In-app product criado (lifetime)
- [ ] Product IDs corretos: `grimorio_pro_*`
- [ ] Status: "Active"
- [ ] App publicado em "Internal Testing" (mínimo)
- [ ] Service Account JSON configurado no RevenueCat
- [ ] License testers adicionados

#### GitHub / Local
- [ ] Secrets configurados no GitHub Actions
- [ ] Arquivo `.env` criado localmente (para dev)
- [ ] App executado com `--dart-define-from-file=.env`

---

### 🧪 **Como Testar Compras em Sandbox**

#### iOS (Sandbox Testing)
```bash
1. Crie uma conta de teste no App Store Connect:
   - Users and Access → Sandbox Testers → Add (+)

2. No dispositivo/simulador:
   - Settings → App Store → Sandbox Account
   - Faça login com a conta de teste

3. Execute o app e tente comprar

4. ⚠️  IMPORTANTE:
   - Use SEMPRE a conta de teste, nunca sua conta real
   - Não confirme pagamento com conta real (você será cobrado!)
   - Sandbox não cobra valores reais
```

#### Android (Internal Testing)
```bash
1. Publique o app em Internal Testing:
   - Google Play Console → Testing → Internal testing
   - Upload do APK/AAB
   - Adicione testers (email)

2. Instale o app via Play Store (não via sideload)

3. A compra será feita em modo sandbox automaticamente

4. Para testar sem ser cobrado:
   - Adicione sua conta em "License testing"
   - Selecione "License response: LICENSED"
```

---

### 📞 **Debug Avançado**

Se os problemas persistirem, habilite logs detalhados:

1. **Logs já estão habilitados automaticamente** em modo debug
2. **Execute o app e observe o console:**
   ```bash
   flutter run --verbose
   ```
3. **Procure por estas mensagens:**
   - ❌ Qualquer linha com "❌" indica um erro
   - ⚠️  Linhas com "⚠️" indicam avisos importantes
   - 🛒 "Iniciando compra" indica que o botão funcionou
   - ✅ "Compra concluída" indica sucesso

---

## 🆘 Suporte

Problemas? Siga esta ordem:

1. ✅ **Verifique os logs** do console (`flutter run --verbose`)
2. ✅ **Consulte o Troubleshooting** acima para seu erro específico
3. ✅ **Use o checklist** para validar a configuração
4. ✅ **Teste em sandbox** seguindo os passos acima
5. ✅ **Aguarde 24h** se acabou de criar os produtos (sincronização das lojas)

Se o problema persistir, abra uma issue no repositório incluindo:
- **Logs completos** do console (do início até o erro)
- **Plataforma** (iOS/Android + versão)
- **Versão do Flutter** (`flutter --version`)
- **Screenshots** da configuração no RevenueCat Dashboard
- **Passos para reproduzir** o problema
