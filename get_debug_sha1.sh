#!/bin/bash

# Script para obter o SHA-1 do certificado de debug do Android
# Este SHA-1 precisa ser adicionado ao Google Cloud Console

echo "================================"
echo "SHA-1 do Certificado de Debug"
echo "================================"
echo ""

# Caminho padrão do debug.keystore no Linux/Mac
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

if [ ! -f "$DEBUG_KEYSTORE" ]; then
    echo "⚠️  Arquivo debug.keystore não encontrado em: $DEBUG_KEYSTORE"
    echo ""
    echo "O debug.keystore é criado automaticamente quando você executa o app pela primeira vez."
    echo "Execute 'flutter run' uma vez e tente novamente."
    exit 1
fi

echo "📁 Keystore encontrado: $DEBUG_KEYSTORE"
echo ""
echo "🔑 Obtendo SHA-1..."
echo ""

# Executar keytool para obter o SHA-1
keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep "SHA1:"

echo ""
echo "================================"
echo "PRÓXIMOS PASSOS:"
echo "================================"
echo ""
echo "1. Copie o SHA-1 acima (apenas os caracteres depois de 'SHA1:')"
echo ""
echo "2. Acesse o Google Cloud Console:"
echo "   https://console.cloud.google.com/apis/credentials?project=grimorio-de-bolso"
echo ""
echo "3. Clique no OAuth 2.0 Client ID do Android:"
echo "   '625869809120-6dsf72i1ilpdevm9k8ptvo0qiofia9v7.apps.googleusercontent.com'"
echo ""
echo "4. Adicione o SHA-1 do certificado de debug na lista de SHA-1"
echo ""
echo "5. Salve e aguarde alguns minutos para propagar"
echo ""
echo "6. Teste o login com Google novamente"
echo ""
