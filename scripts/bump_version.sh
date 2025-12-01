#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# BUMP VERSION SCRIPT
# ═══════════════════════════════════════════════════════════════════════════
#
# Script para incrementar versão do Grimório de Bolso localmente
#
# Uso:
#   ./scripts/bump_version.sh [type]
#
# Tipos:
#   build   - Incrementa build number:  1.0.0+5 → 1.0.0+6
#   patch   - Incrementa patch version: 1.0.0 → 1.0.1
#   minor   - Incrementa minor version: 1.0.0 → 1.1.0
#   major   - Incrementa major version: 1.0.0 → 2.0.0
#
# Exemplos:
#   ./scripts/bump_version.sh build
#   ./scripts/bump_version.sh patch
#   ./scripts/bump_version.sh minor
#   ./scripts/bump_version.sh major
#
# ═══════════════════════════════════════════════════════════════════════════

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Função para printar com cor
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Função para mostrar uso
show_usage() {
    print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
    print_color "$PURPLE" "🔢 BUMP VERSION - Grimório de Bolso"
    print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
    echo ""
    print_color "$BLUE" "Uso:"
    echo "  ./scripts/bump_version.sh [type]"
    echo ""
    print_color "$BLUE" "Tipos de incremento:"
    echo "  build   - Incrementa build number:  1.0.0+5 → 1.0.0+6"
    echo "  patch   - Incrementa patch version: 1.0.0 → 1.0.1"
    echo "  minor   - Incrementa minor version: 1.0.0 → 1.1.0"
    echo "  major   - Incrementa major version: 1.0.0 → 2.0.0"
    echo ""
    print_color "$BLUE" "Exemplos:"
    echo "  ./scripts/bump_version.sh build"
    echo "  ./scripts/bump_version.sh patch"
    echo ""
    print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
}

# Verifica argumentos
if [ $# -eq 0 ]; then
    print_color "$RED" "❌ Erro: Tipo de incremento não especificado"
    echo ""
    show_usage
    exit 1
fi

INCREMENT_TYPE=$1

# Valida tipo
if [[ ! "$INCREMENT_TYPE" =~ ^(build|patch|minor|major)$ ]]; then
    print_color "$RED" "❌ Erro: Tipo inválido '$INCREMENT_TYPE'"
    print_color "$YELLOW" "   Tipos válidos: build, patch, minor, major"
    echo ""
    show_usage
    exit 1
fi

# Verifica se pubspec.yaml existe
if [ ! -f "pubspec.yaml" ]; then
    print_color "$RED" "❌ Erro: pubspec.yaml não encontrado"
    print_color "$YELLOW" "   Execute este script na raiz do projeto"
    exit 1
fi

print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
print_color "$PURPLE" "🔢 Incrementando versão"
print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
echo ""

# Lê versão atual
CURRENT_VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //')
print_color "$BLUE" "📌 Versão atual: $CURRENT_VERSION"

# Separa version name e version code
VERSION_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
VERSION_CODE=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Calcula nova versão
case "$INCREMENT_TYPE" in
    build)
        # Incrementa apenas build number
        NEW_VERSION_CODE=$((VERSION_CODE + 1))
        NEW_VERSION="${VERSION_NAME}+${NEW_VERSION_CODE}"
        print_color "$GREEN" "🔄 Incrementando build number..."
        ;;

    patch|minor|major)
        # Separa major.minor.patch
        IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"

        case "$INCREMENT_TYPE" in
            patch)
                PATCH=$((PATCH + 1))
                print_color "$GREEN" "🔄 Incrementando patch version..."
                ;;
            minor)
                MINOR=$((MINOR + 1))
                PATCH=0
                print_color "$GREEN" "🔄 Incrementando minor version..."
                ;;
            major)
                MAJOR=$((MAJOR + 1))
                MINOR=0
                PATCH=0
                print_color "$GREEN" "🔄 Incrementando major version..."
                ;;
        esac

        NEW_VERSION_NAME="${MAJOR}.${MINOR}.${PATCH}"
        NEW_VERSION_CODE=$((VERSION_CODE + 1))
        NEW_VERSION="${NEW_VERSION_NAME}+${NEW_VERSION_CODE}"
        ;;
esac

print_color "$GREEN" "✨ Nova versão: $NEW_VERSION"
echo ""

# Confirmar mudança
print_color "$YELLOW" "⚠️  Atenção: Esta ação irá modificar pubspec.yaml"
read -p "Continuar? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_color "$RED" "❌ Operação cancelada"
    exit 1
fi

# Atualiza pubspec.yaml
sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml

if [ $? -eq 0 ]; then
    print_color "$GREEN" "✅ pubspec.yaml atualizado com sucesso!"
    echo ""
    print_color "$BLUE" "📝 Resumo:"
    print_color "$BLUE" "   Versão anterior: $CURRENT_VERSION"
    print_color "$GREEN" "   Nova versão: $NEW_VERSION"
    echo ""

    # Sugestão de próximos passos
    print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
    print_color "$PURPLE" "📋 Próximos passos sugeridos:"
    print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
    echo ""
    print_color "$BLUE" "1. Revisar mudanças:"
    echo "   git diff pubspec.yaml"
    echo ""
    print_color "$BLUE" "2. Commitar:"
    echo "   git add pubspec.yaml"
    echo "   git commit -m \"chore: bump version to $NEW_VERSION\""
    echo ""
    print_color "$BLUE" "3. Fazer push:"
    echo "   git push"
    echo ""
    print_color "$BLUE" "4. Ou criar tag para release:"
    echo "   git tag v$NEW_VERSION"
    echo "   git push origin v$NEW_VERSION"
    echo ""
    print_color "$PURPLE" "═══════════════════════════════════════════════════════════════════════════"
else
    print_color "$RED" "❌ Erro ao atualizar pubspec.yaml"
    exit 1
fi
