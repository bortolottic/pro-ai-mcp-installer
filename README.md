# Pro AI MCP — Installer

| Data | Autor | Descrição |
| ---- | ----- | --------- |
| 27/04/2026 | CVB | Criação do projeto |

---

## O que é o Pro AI MCP?

O **Pro AI MCP** é uma plataforma de serviços **MCP (Model Context Protocol)** que permite consulta e integração em tempo real com ERPs de mercado via assistentes de inteligência artificial — como o Claude. A plataforma conecta o assistente diretamente às bases de dados transacionais dos ERPs, permitindo consultas em linguagem natural sobre dados financeiros, hospitalares, logísticos e de gestão.

Este repositório contém o **instalador oficial**, que automatiza todo o processo de download e implantação da plataforma em servidores Linux (ou Windows via WSL2).

> **Para quem não é técnico:** pense no Pro AI MCP como um "tradutor" entre o assistente de IA e os sistemas da empresa — ele permite que o assistente responda perguntas como "quais fornecedores estão em atraso?" ou "qual foi a taxa de ocupação hospitalar em março?" consultando diretamente os bancos de dados dos ERPs. Este instalador faz todo o trabalho de configurar essa integração automaticamente: você cola um único comando no terminal e ele cuida do restante.

### Serviços incluídos

| Serviço | ERP | Banco de Dados | Endpoint |
| ------- | --- | -------------- | -------- |
| **TOTVS Protheus** | TOTVS | Oracle | `/totvs/sse` |
| **TASY Philips** | TASY Healthcare | Oracle | `/tasy/sse` |
| **KMM Transportes** | KMM | PostgreSQL | `/kmm/sse` |
| **Focus Lake** | Focus | Azure Synapse | `/focus-lake/sse` |
| **TASY Lake DW** | TASY | PostgreSQL | `/tasy-lake/sse` |

Todos os serviços ficam acessíveis por uma única porta externa (**9090**) via proxy Nginx.

---

## Requisitos

Antes de instalar, certifique-se de que o servidor ou máquina possui:

| Requisito | Por quê é necessário |
| --------- | -------------------- |
| **Docker Desktop** (Linux/WSL2) | Os serviços MCP são executados dentro de containers Docker |
| **Docker Swarm** ativado | Gerencia e escala os containers em produção |
| **Acesso de rede aos bancos de dados** | Os serviços conectam diretamente às bases transacionais dos ERPs (Oracle, PostgreSQL, Azure Synapse) |
| **Arquivo `.env.production`** configurado | Contém as credenciais de conexão de cada ERP (host, usuário, senha, schema) |
| **`curl` ou `wget`** | Necessário para baixar o pacote de instalação |
| **Licença de produto válida** | O sistema exige uma licença ativa para funcionar |

> **Para leigos:** Docker é como uma "caixa isolada" onde cada serviço MCP roda sem interferir no resto do servidor. O Docker Swarm é o gerenciador dessas caixas, garantindo que elas estejam sempre no ar.

### Portas utilizadas

| Porta | Serviço |
| ----- | ------- |
| **9090** | Proxy Nginx — acesso externo único |
| 8001 | TOTVS MCP (interno) |
| 8002 | TASY MCP (interno) |
| 8003 | KMM MCP (interno) |
| 8004 | Focus Lake MCP (interno) |
| 8005 | TASY Lake MCP (interno) |

---

## Antes de instalar

O instalador carrega as credenciais dos ERPs a partir de um arquivo `.env.production`. Esse arquivo deve estar presente no pacote ou criado antes do deploy.

Edite o arquivo com os dados de conexão de cada ERP:

```
TOTVS_HOST=<host-oracle-totvs>
TOTVS_PORT=1521
TOTVS_USER=<usuario>
TOTVS_SERVICE_NAME=<service-name>
TOTVS_FILIAL=01

TASY_HOST=<host-oracle-tasy>
TASY_PORT=1521
TASY_USER=<usuario>
TASY_SERVICE_NAME=<service-name>
TASY_SCHEMA=TASY

KMM_HOST=<host-postgres-kmm>
KMM_PORT=5432
KMM_USER=<usuario>
KMM_DBNAME=<banco>
KMM_SCHEMA=public

FOCUS_LAKE_SERVER=<endpoint-synapse>
FOCUS_LAKE_DATABASE=DW-FOCUS
FOCUS_LAKE_USER=<usuario>

TASY_LAKE_HOST=<host-postgres-tasy-lake>
TASY_LAKE_PORT=5432
TASY_LAKE_USER=<usuario>
TASY_LAKE_DBNAME=<banco>
TASY_LAKE_SCHEMA=public
```

> As senhas **não ficam no arquivo** — o deploy as lê das variáveis `TOTVS_PASSWORD`, `TASY_PASSWORD`, `KMM_PASSWORD`, `FOCUS_LAKE_PASSWORD` e `TASY_LAKE_PASSWORD` e as armazena como Docker Secrets de forma segura.

---

## Instalação

### Instalar a versão mais recente

Abra o terminal (Linux ou Windows com WSL2) e execute:

```bash
curl -fsSL https://raw.githubusercontent.com/bortolottic/pro-ai-mcp-installer/refs/heads/main/install.sh | bash
```

O instalador irá automaticamente:
1. Detectar a versão mais recente disponível
2. Baixar o pacote de instalação
3. Descompactar os arquivos
4. Carregar o `.env.production`, criar os Docker Secrets e subir todos os serviços via Docker Swarm

### Instalar uma versão específica

Caso precise de uma versão específica (por exemplo, para ambientes de homologação ou rollback):

```bash
curl -fsSL https://raw.githubusercontent.com/bortolottic/pro-ai-mcp-installer/refs/heads/main/install.sh | bash -s v1.0.26.2
```

Substitua `v1.0.26.2` pelo número da versão desejada.

---

## Como funciona (para técnicos)

O `install.sh` executa as seguintes etapas:

1. **Detecção de versão** — consulta a API do GitHub (`/releases/latest`) para obter a tag da versão mais recente, caso nenhuma versão seja especificada.
2. **Download** — baixa o arquivo `pro-ai-mcp-<versão>.tar.gz` diretamente da página de releases do GitHub, usando `curl` ou `wget` (o que estiver disponível).
3. **Extração** — descompacta o pacote em `/tmp/pro-ai-mcp`.
4. **Deploy** — executa o script `deploy_production.sh` incluso no pacote, que:
   - Carrega as variáveis do `.env.production`
   - Inicializa o Docker Swarm (se ainda não estiver ativo)
   - Cria os Docker Secrets com as senhas dos bancos de dados
   - Faz pull das imagens Docker de cada serviço (proxy, totvs, tasy, kmm, focus-lake, tasy-lake)
   - Sobe o stack `pro-ai-mcp` via Docker Swarm

```
GitHub Releases
      │
      ▼
install.sh  ──► baixa .tar.gz ──► extrai ──► deploy_production.sh
                                                      │
                                          ┌───────────┼────────────┐
                                          ▼           ▼            ▼
                                     Docker Swarm  Secrets     Stack deploy
                                          │
                            ┌────────────┼────────────────────────┐
                            ▼            ▼            ▼            ▼
                         proxy        totvs         tasy          kmm
                        (nginx)     (Oracle)      (Oracle)     (PostgreSQL)
                        :9090        :8001          :8002         :8003
```

---

## Após a instalação

Ao concluir, o instalador exibe os endpoints disponíveis:

```
http://<host>:9090/totvs/sse      — TOTVS Protheus
http://<host>:9090/tasy/sse       — TASY Philips
http://<host>:9090/kmm/sse        — KMM Transportes
http://<host>:9090/focus-lake/sse — Focus Lake
http://<host>:9090/tasy-lake/sse  — TASY Lake DW
```

### Configurar o Claude Desktop

Adicione os endpoints ao arquivo de configuração do Claude Desktop (`config.json`):

```json
{
  "mcpServers": {
    "totvs":      { "url": "http://<host>:9090/totvs/sse" },
    "tasy":       { "url": "http://<host>:9090/tasy/sse" },
    "kmm":        { "url": "http://<host>:9090/kmm/sse" },
    "focus_lake": { "url": "http://<host>:9090/focus-lake/sse" },
    "tasy_lake":  { "url": "http://<host>:9090/tasy-lake/sse" }
  }
}
```

---

## Solução de problemas

| Problema | Possível causa | Solução |
| -------- | -------------- | ------- |
| `curl ou wget não encontrado` | Nenhuma das ferramentas está instalada | Instale com `apt install curl` ou `apt install wget` |
| Erro ao baixar o pacote | URL incorreta ou versão inexistente | Verifique as [releases disponíveis](https://github.com/bortolottic/pro-ai-mcp-installer/releases) |
| Docker não encontrado | Docker não está instalado ou não está no PATH | Instale o Docker Desktop e certifique-se de que está rodando |
| Serviço não inicia | Credenciais incorretas no `.env.production` | Revise host, usuário, senha e service_name do ERP |
| Serviço não conecta ao banco | Banco de dados inacessível pela rede | Verifique firewall e conectividade com `telnet <host> <porta>` |
| Deploy falha silenciosamente | Problema no `deploy_production.sh` | Verifique os logs com `docker service ls` e `docker service logs -f pro-ai-mcp_<serviço>` |

---

## Versões disponíveis

Todas as versões estão listadas na página de [Releases do GitHub](https://github.com/bortolottic/pro-ai-mcp-installer/releases).

---

## Suporte

Em caso de dúvidas ou problemas, entre em contato com a equipe responsável pelo projeto.
