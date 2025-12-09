# 🔐 GUIA COMPLETO: Configuração do Login com Google

## 📋 RESUMO DOS PROBLEMAS ENCONTRADOS

### ❌ Erros Críticos:
1. **GoogleSignIn sem Client ID** - Falta configurar o Web Client ID
2. **Plugin Google Services ausente no build.gradle**
3. **Configuração do Supabase Dashboard incompleta**
4. **Erros de código no teste de login** (AuthResult.isSuccess não existe)

---

## ✅ SOLUÇÃO COMPLETA

### **ETAPA 1: Obter o Web Client ID do Google**

Você já tem o `google-services.json` configurado. Agora precisa do **Web Client ID**:

1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Selecione o projeto: `grimorio-de-bolso`
3. Vá em **APIs & Services > Credentials**
4. Procure por **"Web client (auto created by Google Service)"** ou crie um novo OAuth 2.0 Client ID do tipo **Web application**
5. Copie o **Client ID** que tem este formato:
   ```
   625869809120-XXXXXXXXX.apps.googleusercontent.com
   ```

**NOTA:** No seu `google-services.json` já há um client_type 3 (Web):
```json
{
  "client_id": "625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com",
  "client_type": 3
}
```
**Este é o seu Web Client ID!** ✅

---

### **ETAPA 2: Configurar o Supabase Dashboard**

1. Acesse seu projeto no [Supabase Dashboard](https://supabase.com/dashboard)
2. Vá em **Authentication > Providers**
3. Habilite o **Google Provider**
4. Cole o **Client ID** e **Client Secret** do Google Cloud Console:
   - **Client ID:** `625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com`
   - **Client Secret:** (você precisa pegar no Google Cloud Console)

5. **Configurar Redirect URLs no Google Cloud Console:**
   - Vá em **APIs & Services > Credentials**
   - Clique no Web Client ID
   - Em **Authorized redirect URIs**, adicione:
     ```
     https://SEU_PROJETO.supabase.co/auth/v1/callback
     ```
     (Substitua `SEU_PROJETO` pela URL do seu projeto Supabase)

---

### **ETAPA 3: Adicionar Google Services Plugin no Android**

#### 📝 **android/build.gradle** (projeto root)

Adicione a dependência do Google Services:

```gradle
buildscript {
    ext.kotlin_version = '2.2.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.6.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'  // ← ADICIONAR ESTA LINHA
    }
}
```

#### 📝 **android/app/build.gradle**

Adicione o plugin no **FINAL** do arquivo:

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// ... resto do código ...

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}

// ↓ ADICIONAR NO FINAL DO ARQUIVO
apply plugin: 'com.google.gms.google-services'
```

---

### **ETAPA 4: Configurar o GoogleSignIn com Client ID**

#### 📝 **lib/features/auth/data/repositories/supabase_auth_repository.dart**

Modifique a inicialização do GoogleSignIn (linha 110):

```dart
/// Google Sign-In configurado
/// Requer: google-services.json (Android) e GoogleService-Info.plist (iOS)
static final _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // ↓ ADICIONAR O SERVIDOR CLIENT ID (Web Client ID)
  serverClientId: '625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com',
);
```

**⚠️ IMPORTANTE:** O `serverClientId` deve ser o **Web Client ID** (client_type 3), NÃO o Android Client ID!

---

### **ETAPA 5: Corrigir erros de compilação no teste de login**

#### 📝 **lib/core/diagnostic/diagnostic_page.dart**

Corrija os erros de API:

**Linha 1753:** `isAuthenticated` não existe no AuthProvider. Use outro método.

**Linha 1760:** Substitua `result.isSuccess` por `result.success`

**Linha 1775 e 1778:** Substitua `result.message` por `result.errorMessage`

**Exemplos de correção:**

```dart
// ❌ ERRADO
if (result.isSuccess) {

// ✅ CORRETO
if (result.success) {

// ❌ ERRADO
_addLog('   Mensagem: ${result.message}');

// ✅ CORRETO
_addLog('   Mensagem: ${result.errorMessage}');
```

---

### **ETAPA 6: Configurar iOS (Opcional, mas recomendado)**

Se você vai testar no iOS, precisa do `GoogleService-Info.plist`:

1. No Google Cloud Console, faça download do `GoogleService-Info.plist`
2. Adicione ao projeto em `ios/Runner/GoogleService-Info.plist`
3. Adicione o URL Scheme no `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.625869809120-XXXXXXXXX</string>
        </array>
    </dict>
</array>
```

(Substitua `XXXXXXXXX` pelo resto do Client ID reverso)

---

## 🧪 TESTANDO O LOGIN

Depois de fazer todas as configurações:

1. Execute `flutter clean`
2. Execute `flutter pub get`
3. Execute `flutter run`
4. Vá em **Settings > Admin > Diagnóstico Completo > Login Google**
5. Clique em **"Testar Google Login"**
6. Copie os logs e me envie!

---

## 📚 CHECKLIST FINAL

- [ ] Obteve o Web Client ID do Google Cloud Console
- [ ] Configurou o Google Provider no Supabase Dashboard
- [ ] Adicionou Redirect URLs no Google Cloud Console
- [ ] Adicionou `google-services` classpath no `android/build.gradle`
- [ ] Adicionou `apply plugin` no `android/app/build.gradle`
- [ ] Configurou `serverClientId` no GoogleSignIn
- [ ] Corrigiu erros de compilação no diagnostic_page.dart
- [ ] (Opcional) Configurou iOS com GoogleService-Info.plist

---

## 🔍 INFORMAÇÕES DO SEU PROJETO

**Google Cloud Project:**
- Project ID: `grimorio-de-bolso`
- Project Number: `625869809120`
- Package Name: `com.grimoriodebolso.app`

**Client IDs encontrados:**
- **Android:** `625869809120-6dsf72i1ilpdevm9k8ptvo0qiofia9v7.apps.googleusercontent.com`
- **Web (use este!):** `625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com`

**Deep Link Scheme:**
- `io.supabase.grimorio://callback`

---

## ❓ DÚVIDAS COMUNS

**P: Qual Client ID devo usar?**
R: Use o **Web Client ID** (client_type 3) no `serverClientId` do GoogleSignIn. Isso permite que o Supabase valide o token.

**P: Por que preciso do Google Services plugin?**
R: O plugin processa o `google-services.json` e injeta configurações necessárias no app Android.

**P: O login funciona sem o Supabase?**
R: Não neste caso. O fluxo é: Google → Supabase → Seu app. O Supabase gerencia a sessão.

---

## 🆘 PRÓXIMOS PASSOS SE AINDA NÃO FUNCIONAR

1. Me envie os logs do teste de login
2. Verifique se o Client Secret está correto no Supabase
3. Confirme que as Redirect URLs estão corretas
4. Teste primeiro no Android (iOS tem mais configurações)

---

**Última atualização:** Dezembro 2025
