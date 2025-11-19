# Como Testar o App no Celular

Este guia explica como testar o "Grimório de Bolso" no seu celular (Android ou iOS).

## OPÇÃO 1: Testar no Android via USB (MAIS FÁCIL)

### Pré-requisitos
1. Celular Android
2. Cabo USB
3. Android Studio instalado (ou apenas as ferramentas do Android SDK)

### Passo a Passo

#### 1. Ativar o Modo Desenvolvedor no celular
1. Abra **Configurações** no celular
2. Vá em **Sobre o telefone**
3. Toque 7 vezes em **Número da versão** (ou **Versão do MIUI/One UI**, dependendo do celular)
4. Aparecerá uma mensagem dizendo que você é um desenvolvedor

#### 2. Ativar Depuração USB
1. Volte para **Configurações**
2. Procure por **Opções do desenvolvedor** (pode estar em Sistema > Avançado)
3. Ative **Depuração USB**
4. (Opcional) Ative também **Instalação via USB**

#### 3. Conectar o celular ao computador
1. Conecte o celular ao PC via cabo USB
2. No celular, escolha o modo **Transferência de arquivos (MTP)** ou **PTP**
3. Uma mensagem aparecerá perguntando se você confia no computador - aceite!

#### 4. Verificar se o Flutter detecta o celular
Abra o terminal no VSCode e execute:
```bash
flutter devices
```

Você deve ver algo como:
```
SM-XXXXX (mobile) • XXXXXXXX • android-arm64 • Android 13 (API 33)
```

#### 5. Rodar o app no celular
No terminal, execute:
```bash
flutter run
```

OU no VSCode:
- Clique no canto inferior direito onde aparece o device
- Selecione seu celular Android
- Pressione F5 (ou clique em Run > Start Debugging)

O app será instalado e aberto automaticamente no seu celular!

---

## OPÇÃO 2: Testar no iOS via USB (SOMENTE PARA MAC)

### Pré-requisitos
1. iPhone
2. Mac com Xcode instalado
3. Cabo Lightning/USB-C

### Passo a Passo

#### 1. Configurar certificado de desenvolvedor
1. Abra o Xcode
2. Vá em **Preferences > Accounts**
3. Adicione sua Apple ID (pode ser gratuita)

#### 2. Conectar o iPhone
1. Conecte o iPhone ao Mac
2. Confie no computador quando solicitado

#### 3. Configurar o projeto
No terminal:
```bash
cd ios
pod install
cd ..
```

#### 4. Abrir no Xcode
```bash
open ios/Runner.xcworkspace
```

No Xcode:
1. Selecione seu iPhone no topo
2. Em **Signing & Capabilities**, selecione seu Team
3. Feche o Xcode

#### 5. Rodar o app
```bash
flutter run
```

---

## OPÇÃO 3: Gerar APK para instalar manualmente (Android)

Se você não conseguir conectar via USB, pode gerar um arquivo APK e instalar diretamente no celular.

### Gerar o APK
No terminal:
```bash
flutter build apk --release
```

O APK será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Transferir para o celular
1. Copie o arquivo `app-release.apk` para o celular (via cabo USB, Bluetooth, Google Drive, etc.)
2. No celular, abra o arquivo APK
3. Permita instalação de fontes desconhecidas quando solicitado
4. Instale o app!

---

## OPÇÃO 4: Testar via Wi-Fi (Android - Avançado)

### Pré-requisitos
- Celular e PC na mesma rede Wi-Fi
- ADB instalado
- Celular conectado via USB pelo menos uma vez

### Passo a Passo

#### 1. Conectar inicialmente via USB
```bash
adb tcpip 5555
```

#### 2. Descobrir o IP do celular
No celular:
- Vá em **Configurações > Wi-Fi**
- Toque na rede conectada
- Veja o endereço IP (exemplo: 192.168.1.100)

#### 3. Conectar via Wi-Fi
```bash
adb connect 192.168.1.100:5555
```

#### 4. Desconectar o cabo USB

Agora pode usar:
```bash
flutter run
```

---

## Problemas Comuns

### "No devices found"
- Verifique se a Depuração USB está ativada
- Tente outro cabo USB (alguns cabos só carregam, não transferem dados)
- Reinstale os drivers do celular (Windows)
- Execute: `adb kill-server` e depois `adb start-server`

### "Unauthorized device"
- Veja se apareceu a mensagem no celular para confiar no computador
- Revogue as autorizações em Opções do desenvolvedor e tente novamente

### App não abre no celular
- Verifique se tem espaço suficiente no celular
- Limpe o cache: `flutter clean` e rode novamente

### Erro ao compilar
Certifique-se de que as dependências estão instaladas:
```bash
flutter pub get
flutter doctor -v
```

---

## Comandos Úteis

```bash
# Ver todos os dispositivos conectados
flutter devices

# Limpar build anterior
flutter clean

# Instalar dependências
flutter pub get

# Rodar em modo debug
flutter run

# Rodar em modo release (mais rápido)
flutter run --release

# Ver logs do app
flutter logs

# Gerar APK
flutter build apk --release

# Gerar AAB (para Google Play)
flutter build appbundle --release
```

---

## Dicas

1. **Hot Reload**: Quando o app estiver rodando, pressione `r` no terminal para recarregar mudanças rapidamente!

2. **Hot Restart**: Pressione `R` (maiúsculo) para reiniciar o app completamente

3. **Performance**: Use `flutter run --release` para testar a performance real do app

4. **Multiple devices**: Se tiver vários dispositivos conectados:
   ```bash
   flutter run -d <device-id>
   ```

5. **Wireless debugging (Android 11+)**:
   - Vá em Opções do desenvolvedor > Depuração sem fio
   - Pareie o dispositivo usando o código QR

---

## Próximos Passos

Depois de testar no celular:
1. Teste todas as funcionalidades (Calendário Lunar, Grimório, Diários, Enciclopédia)
2. Verifique a performance e responsividade
3. Teste em diferentes tamanhos de tela
4. Reporte bugs ou melhorias necessárias

---

Feito com 🌙 para bruxas e bruxos
