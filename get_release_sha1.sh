#!/bin/bash

# Script para obter o SHA-1 do certificado de RELEASE do Android
# Este SHA-1 é usado quando você gera um .aab ou .apk de release

echo "================================"
echo "SHA-1 do Certificado de RELEASE"
echo "================================"
echo ""

# Verificar se key.properties existe
KEY_PROPERTIES="android/key.properties"

if [ ! -f "$KEY_PROPERTIES" ]; then
    echo "⚠️  Arquivo key.properties não encontrado em: $KEY_PROPERTIES"
    echo ""
    echo "O arquivo key.properties deve conter as configurações do keystore de release."
    echo "Exemplo:"
    echo "  storeFile=caminho/para/seu-keystore.jks"
    echo "  keyAlias=seu-alias"
    echo "  storePassword=sua-senha"
    echo "  keyPassword=senha-da-chave"
    exit 1
fi

echo "📁 Lendo configurações de: $KEY_PROPERTIES"
echo ""

# Ler propriedades do arquivo
STORE_FILE=$(grep "storeFile=" "$KEY_PROPERTIES" | cut -d'=' -f2)
KEY_ALIAS=$(grep "keyAlias=" "$KEY_PROPERTIES" | cut -d'=' -f2)
STORE_PASSWORD=$(grep "storePassword=" "$KEY_PROPERTIES" | cut -d'=' -f2)
KEY_PASSWORD=$(grep "keyPassword=" "$KEY_PROPERTIES" | cut -d'=' -f2)

if [ -z "$STORE_FILE" ]; then
    echo "⚠️  storeFile não encontrado em key.properties"
    exit 1
fi

# Se o caminho não for absoluto, considerar relativo ao diretório android
if [[ "$STORE_FILE" != /* ]]; then
    STORE_FILE="android/$STORE_FILE"
fi

if [ ! -f "$STORE_FILE" ]; then
    echo "⚠️  Arquivo keystore não encontrado em: $STORE_FILE"
    echo ""
    echo "Verifique se o caminho em key.properties está correto."
    exit 1
fi

echo "✅ Keystore encontrado: $STORE_FILE"
echo "✅ Alias: $KEY_ALIAS"
echo ""
echo "🔑 Obtendo SHA-1 do certificado de RELEASE..."
echo ""

# Executar keytool para obter o SHA-1
if [ -n "$STORE_PASSWORD" ]; then
    keytool -list -v -keystore "$STORE_FILE" -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" -keypass "$KEY_PASSWORD" 2>/dev/null | grep -E "SHA1:|SHA256:"
else
    echo "⚠️  storePassword não encontrado em key.properties"
    echo "Execute manualmente:"
    echo ""
    echo "keytool -list -v -keystore \"$STORE_FILE\" -alias \"$KEY_ALIAS\""
    echo ""
    exit 1
fi

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
echo "4. ADICIONE o SHA-1 do certificado de RELEASE na lista"
echo "   (mantenha o SHA-1 de debug também!)"
echo ""
echo "5. Salve e aguarde alguns minutos para propagar"
echo ""
echo "6. Gere um novo .aab e teste o login com Google novamente"
echo ""
echo "⚠️  IMPORTANTE: Você precisa ter AMBOS os SHA-1 registrados:"
echo "   - SHA-1 do certificado de DEBUG (para desenvolvimento)"
echo "   - SHA-1 do certificado de RELEASE (para .aab/.apk de produção)"
echo ""
