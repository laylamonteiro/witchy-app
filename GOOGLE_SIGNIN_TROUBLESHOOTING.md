# Guia de Troubleshooting - Google Sign-In Error 10 (DEVELOPER_ERROR)

## ❌ Erro:
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.b: 10:)
```

Este é o erro **DEVELOPER_ERROR** do Google Sign-In no Android.

---

## ✅ Checklist de Configuração

### 1. Verificar serverClientId no código ✅
**Arquivo:** `lib/features/auth/data/repositories/supabase_auth_repository.dart`

```dart
_googleSignIn = GoogleSignIn(
  serverClientId: '625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com',
);
```

**Status:** ✅ Já configurado

---

### 2. Verificar SHA-1 no Google Cloud Console

**Obter seu SHA-1 de debug:**
```bash
./get_debug_sha1.sh
```

**Verificar no Google Cloud Console:**
1. Acesse: https://console.cloud.google.com/apis/credentials?project=grimorio-de-bolso
2. Procure por: **OAuth 2.0 Client ID** do tipo **Android**
3. Package name deve ser: `com.grimoriodebolso.app`
4. Verifique se o SHA-1 obtido pelo script está na lista

**SHA-1 esperado (debug):** `8bd7bb97b95c8d5e549d5584a01fe27aec85da98`

---

### 3. Verificar Web Client ID no Google Cloud Console

**No mesmo console:**
1. Procure por: **OAuth 2.0 Client ID** do tipo **Web application**
2. Copie o Client ID
3. Deve ser: `625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com`
4. Se for diferente, atualize no código (passo 1)

---

### 4. Verificar google-services.json

**Arquivo:** `android/app/google-services.json`

Deve conter:
- **Package name:** `com.grimoriodebolso.app`
- **OAuth client com client_type: 1** (Android) com seu SHA-1
- **OAuth client com client_type: 3** (Web) - este é o serverClientId

Se algo estiver errado, baixe um novo `google-services.json` do Firebase Console.

---

### 5. Limpar e Rebuildar

**IMPORTANTE:** Depois de fazer qualquer alteração, sempre limpe e rebuilde:

```bash
# Limpar build cache
flutter clean

# Reinstalar dependências
flutter pub get

# Rebuildar e rodar
flutter run
```

---

### 6. Aguardar Propagação

Se você acabou de fazer alterações no Google Cloud Console:
- ⏱️ Aguarde **5-10 minutos** para as mudanças propagarem
- 🔄 Tente novamente depois desse tempo

---

### 7. Verificar Permissões no AndroidManifest.xml

**Arquivo:** `android/app/src/main/AndroidManifest.xml`

Deve ter:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**Status:** ✅ Já configurado

---

## 🔧 Comandos de Debug

### Verificar SHA-1 atual:
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### Verificar se google-services.json está sendo processado:
```bash
cd android
./gradlew :app:dependencies | grep google-services
```

### Ver logs detalhados do Google Sign-In:
```bash
flutter run --verbose
# Depois tente fazer login e copie TODO o log
```

---

## 🐛 Causas Comuns

1. **SHA-1 não registrado** ❌
   - Solução: Registrar SHA-1 no Google Cloud Console

2. **serverClientId incorreto ou ausente** ❌
   - Solução: Verificar e corrigir no código

3. **Mudanças no Console não propagadas** ⏱️
   - Solução: Aguardar 5-10 minutos

4. **Build cache corrompido** 🗑️
   - Solução: `flutter clean && flutter pub get`

5. **google-services.json desatualizado** 📄
   - Solução: Baixar novo do Firebase Console

6. **Certificado errado sendo usado** 🔑
   - Debug: Usar SHA-1 de debug
   - Release: Usar SHA-1 de release (se configurado)

---

## 📞 Próximos Passos se o Erro Persistir

1. Execute o app com logs verbosos:
   ```bash
   flutter run --verbose
   ```

2. Tente fazer login com Google

3. Copie **TODO o log** (especialmente a parte do erro)

4. Verifique no Google Cloud Console:
   - Se o Android Client está habilitado
   - Se o Web Client está habilitado
   - Se ambos estão no mesmo projeto

5. Tire um screenshot da configuração do OAuth Client no Google Cloud Console

---

## ✅ Configuração Esperada

**Google Cloud Console deve ter:**

1. **OAuth 2.0 Client ID - Android**
   - Application type: Android
   - Package name: `com.grimoriodebolso.app`
   - SHA-1: `8bd7bb97b95c8d5e549d5584a01fe27aec85da98`

2. **OAuth 2.0 Client ID - Web**
   - Application type: Web application
   - Client ID: `625869809120-vekqjnltlccc7llalu6adgl1js8tngob.apps.googleusercontent.com`

**Código deve ter:**
- serverClientId configurado com o Web Client ID
- google_sign_in: ^6.1.0 no pubspec.yaml

**google-services.json deve ter:**
- client_type: 1 (Android) com SHA-1
- client_type: 3 (Web) com o Web Client ID
