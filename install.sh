#!/usr/bin/env bash

set -e

REPO="bortolottic/pro-ai-mcp-installer"
PACKAGE_NAME="pro-ai-mcp"
VERSION="${1:-latest}"

TMP_DIR="/tmp/${PACKAGE_NAME}"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

echo "======================================"
echo " Pro AI MCP Installer"
echo "======================================"

# Detect latest version

if [ "$VERSION" = "latest" ]; then
echo "Detectando última versão..."

VERSION=$(curl -s https://api.github.com/repos/$REPO/releases/latest \
| grep tag_name \
| cut -d '"' -f4)
fi

echo "Versão: $VERSION"

PACKAGE_FILE="${PACKAGE_NAME}-${VERSION}.tar.gz"

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${PACKAGE_FILE}"

echo "Baixando pacote..."

if command -v curl >/dev/null 2>&1; then
curl -L "$DOWNLOAD_URL" -o package.tar.gz
elif command -v wget >/dev/null 2>&1; then
wget "$DOWNLOAD_URL" -O package.tar.gz
else
echo "Erro: curl ou wget não encontrado."
exit 1
fi

echo "Descompactando..."

tar -xzf package.tar.gz

cd ${PACKAGE_NAME}

chmod +x deploy_production.sh

echo "Executando deploy..."

./deploy_production.sh

echo "======================================"
echo " Deploy finalizado com sucesso"
echo "======================================"
