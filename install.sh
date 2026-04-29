#!/usr/bin/env bash
# =============================================================================
# install.sh — Pro AI MCP Installer
#
# Uso:
#   bash install.sh [VERSION]
#
# Exemplos:
#   bash install.sh              # instala a última versão
#   bash install.sh v1.0.26.2   # instala versão específica
#
# Configuração do cliente:
#   O arquivo .env.production deve existir na máquina antes da instalação.
#   Localizações verificadas (em ordem de prioridade):
#
#     1. Variável de ambiente:  ENV_FILE=/caminho/.env.production bash install.sh
#     2. Sistema:               /etc/pro-ai-mcp/.env.production   (recomendado)
#     3. Usuário:               ~/.pro-ai-mcp/.env.production
#     4. Diretório atual:       ./.env.production
# =============================================================================
set -euo pipefail

REPO="bortolottic/pro-ai-mcp-installer"
PACKAGE_NAME="pro-ai-mcp"
VERSION="${1:-latest}"

echo "======================================"
echo " Pro AI MCP Installer"
echo "======================================"

# ── Resolver arquivo de configuração do cliente ───────────────────────────────
resolve_env_file() {
    if [[ -n "${ENV_FILE:-}" && -f "${ENV_FILE}" ]]; then
        echo "${ENV_FILE}"
        return 0
    fi

    local candidates=(
        "/etc/pro-ai-mcp/.env.production"
        "${HOME}/.pro-ai-mcp/.env.production"
        "$(pwd)/.env.production"
    )

    for candidate in "${candidates[@]}"; do
        if [[ -f "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

ENV_FILE_PATH=$(resolve_env_file) || {
    echo ""
    echo "ERRO: Arquivo .env.production não encontrado."
    echo ""
    echo "Crie o arquivo de configuração em um dos locais abaixo:"
    echo "  /etc/pro-ai-mcp/.env.production    <- recomendado (sistema)"
    echo "  ~/.pro-ai-mcp/.env.production      <- alternativa (usuário)"
    echo "  ./.env.production                  <- diretório atual"
    echo ""
    echo "Ou defina a variável ENV_FILE:"
    echo "  ENV_FILE=/caminho/.env.production bash install.sh"
    echo ""
    echo "Consulte o README para ver o formato do arquivo."
    exit 1
}

echo "Configuração encontrada: ${ENV_FILE_PATH}"

# ── Detectar versão ───────────────────────────────────────────────────────────
if [[ "$VERSION" == "latest" ]]; then
    echo "Detectando última versão..."
    VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
        | grep tag_name \
        | cut -d '"' -f4)
fi

echo "Versão: ${VERSION}"

# ── Download do pacote ────────────────────────────────────────────────────────
TMP_DIR="/tmp/${PACKAGE_NAME}"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

PACKAGE_FILE="${PACKAGE_NAME}-${VERSION}.tar.gz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${PACKAGE_FILE}"

echo "Baixando ${PACKAGE_FILE}..."

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${DOWNLOAD_URL}" -o package.tar.gz
elif command -v wget >/dev/null 2>&1; then
    wget -q "${DOWNLOAD_URL}" -O package.tar.gz
else
    echo "ERRO: curl ou wget não encontrado."
    exit 1
fi

# ── Extração ──────────────────────────────────────────────────────────────────
echo "Descompactando..."
tar -xzf package.tar.gz
cd "${PACKAGE_NAME}"

# ── Injetar configuração do cliente ──────────────────────────────────────────
# Copia o .env.production da máquina para o diretório do pacote.
# O arquivo de release NÃO contém configurações de cliente.
cp "${ENV_FILE_PATH}" .env.production
echo "Configuração injetada a partir de: ${ENV_FILE_PATH}"

# ── Deploy ────────────────────────────────────────────────────────────────────
chmod +x deploy_production.sh
echo "Executando deploy..."
./deploy_production.sh

echo ""
echo "======================================"
echo " Deploy finalizado com sucesso"
echo "======================================"
