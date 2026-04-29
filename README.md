# Pro AI MCP — Guia de Instalação

| Data | Autor | Descrição |
| ---- | ----- | --------- |
| 27/04/2026 | CVB | Criação do projeto |
| 29/04/2026 | CVB | Guia expandido para Linux, Windows e macOS |

---

## O que é o Pro AI MCP?

O **Pro AI MCP** é uma plataforma de serviços **MCP (Model Context Protocol)** que conecta assistentes de inteligência artificial — como o Claude — diretamente aos bancos de dados dos principais ERPs de mercado. Com ele, é possível fazer perguntas em linguagem natural sobre dados financeiros, hospitalares, logísticos e de gestão, e receber respostas consultadas em tempo real nos sistemas da empresa.

Este repositório contém o **instalador oficial**, que automatiza todo o processo de download e implantação da plataforma.

> **Para quem não é técnico:** pense no Pro AI MCP como um "tradutor" entre o assistente de IA e os sistemas da empresa. Ele permite que o assistente responda perguntas como "quais fornecedores estão em atraso?" ou "qual foi a taxa de ocupação hospitalar em março?" consultando diretamente os bancos de dados dos ERPs. Este instalador faz todo o trabalho de configurar essa integração automaticamente: você cola um único comando no terminal e ele cuida do restante.

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

## Escolha o seu sistema operacional

- [Instalação no Linux](#instalação-no-linux)
- [Instalação no Windows](#instalação-no-windows)
- [Instalação no macOS](#instalação-no-macos)

---

## Instalação no Linux

### Passo 1 — Abra o terminal

No Linux, o terminal é o programa onde você digita comandos de texto. Veja como abrir dependendo da sua distribuição:

- **Ubuntu / Debian / Mint:** pressione `Ctrl + Alt + T`
- **Fedora / RHEL:** clique com o botão direito na área de trabalho → "Abrir terminal"
- **Qualquer distribuição:** procure por "Terminal" ou "Console" no menu de aplicativos

Uma janela preta com um cursor piscando vai aparecer. É nela que você vai colar os comandos dos próximos passos.

---

### Passo 2 — Instale o Docker

O Docker é o programa que vai rodar o Pro AI MCP. Siga os passos abaixo:

**1.** Atualize os pacotes do sistema (pode pedir a sua senha):

```bash
sudo apt update && sudo apt upgrade -y
```

> Se estiver usando Fedora/RHEL, substitua `apt` por `dnf`.

**2.** Instale o Docker:

```bash
sudo apt install -y docker.io
```

**3.** Inicie o Docker e configure-o para iniciar automaticamente com o sistema:

```bash
sudo systemctl enable docker --now
```

**4.** Adicione o seu usuário ao grupo Docker (para não precisar usar `sudo` toda vez):

```bash
sudo usermod -aG docker $USER
```

**5.** Feche o terminal e abra novamente para aplicar a alteração do passo anterior.

**6.** Verifique se o Docker foi instalado corretamente:

```bash
docker --version
```

Se aparecer algo como `Docker version 24.x.x`, a instalação foi bem-sucedida.

---

### Passo 3 — Ative o Docker Swarm

O Docker Swarm é o gerenciador de serviços utilizado pelo Pro AI MCP. Ative-o com o comando:

```bash
docker swarm init
```

Se aparecer a mensagem `Swarm initialized`, está pronto.

> **Nota:** se você receber um erro dizendo que já existe um swarm ativo, pode ignorar — significa que o Docker Swarm já estava configurado.

---

### Passo 4 — Verifique se o `curl` está instalado

O `curl` é a ferramenta usada para baixar o instalador. Verifique se ele está disponível:

```bash
curl --version
```

Se não estiver instalado, instale com:

```bash
sudo apt install -y curl
```

---

### Passo 5 — Configure as credenciais dos ERPs

Antes de instalar, você precisa criar um arquivo com as credenciais de acesso aos bancos de dados dos ERPs. Esse arquivo se chama `.env.production`.

**1.** Crie o arquivo no diretório home do seu usuário:

```bash
nano ~/.env.production
```

**2.** Cole o conteúdo abaixo no editor, substituindo os valores entre `< >` pelos dados reais de cada ERP:

```
TOTVS_HOST=<host-oracle-totvs>
TOTVS_PORT=1521
TOTVS_USER=<usuario>
TOTVS_PASSWORD=<senha>
TOTVS_SERVICE_NAME=<service-name>
TOTVS_FILIAL=01

TASY_HOST=<host-oracle-tasy>
TASY_PORT=1521
TASY_USER=<usuario>
TASY_PASSWORD=<senha>
TASY_SERVICE_NAME=<service-name>
TASY_SCHEMA=TASY

KMM_HOST=<host-postgres-kmm>
KMM_PORT=5432
KMM_USER=<usuario>
KMM_PASSWORD=<senha>
KMM_DBNAME=<banco>
KMM_SCHEMA=public

FOCUS_LAKE_SERVER=<endpoint-synapse>
FOCUS_LAKE_DATABASE=DW-FOCUS
FOCUS_LAKE_USER=<usuario>
FOCUS_LAKE_PASSWORD=<senha>

TASY_LAKE_HOST=<host-postgres-tasy-lake>
TASY_LAKE_PORT=5432
TASY_LAKE_USER=<usuario>
TASY_LAKE_PASSWORD=<senha>
TASY_LAKE_DBNAME=<banco>
TASY_LAKE_SCHEMA=public
```

**3.** Salve o arquivo: pressione `Ctrl + O` e depois `Ctrl + X` para sair.

> **Dica:** se preferir usar outro editor como `vim` ou `gedit`, substitua `nano` pelo editor de sua preferência. Em caso de dúvida, o `nano` é o mais simples.

> **Segurança:** as senhas são lidas deste arquivo somente durante o processo de instalação e armazenadas como Docker Secrets — elas não ficam expostas em arquivos de configuração após o deploy.

---

### Passo 6 — Execute o instalador

Com tudo pronto, rode o comando abaixo para instalar a versão mais recente do Pro AI MCP:

```bash
curl -fsSL https://raw.githubusercontent.com/bortolottic/pro-ai-mcp-installer/refs/heads/main/install.sh | bash
```

O instalador vai exibir o progresso no terminal. Aguarde até aparecer a mensagem:

```
======================================
 Deploy finalizado com sucesso
======================================
```

Pronto! O Pro AI MCP está instalado e em execução.

---

### Passo 7 — Verifique se os serviços estão rodando

Confirme que tudo está funcionando:

```bash
docker service ls
```

Você verá a lista de serviços ativos do Pro AI MCP. Todos devem aparecer com o status `running`.

---

## Instalação no Windows

No Windows, o Pro AI MCP roda dentro do **WSL2** (Windows Subsystem for Linux), que é uma camada Linux integrada ao Windows. O **Docker Desktop** gerencia os containers automaticamente.

> **Para leigos:** o WSL2 é como ter um "Linux dentro do Windows". O Docker Desktop é o programa que vai rodar o Pro AI MCP. Você não precisa entender tudo isso — basta seguir os passos.

---

### Passo 1 — Verifique a versão do Windows

O WSL2 e o Docker Desktop exigem **Windows 10 versão 2004 ou superior** (ou Windows 11).

**1.** Pressione `Win + R`, digite `winver` e pressione Enter.

**2.** Verifique se a versão exibida é **2004 ou superior**. Se for mais antiga, atualize o Windows pelo Windows Update antes de continuar.

---

### Passo 2 — Ative o WSL2

**1.** Clique no botão Iniciar do Windows e procure por **"PowerShell"**.

**2.** Clique com o botão direito no PowerShell e escolha **"Executar como administrador"**.

**3.** Na janela que abrir, cole o comando abaixo e pressione Enter:

```powershell
wsl --install
```

**4.** Aguarde a instalação terminar. Quando solicitado, **reinicie o computador**.

**5.** Após reiniciar, o Windows vai abrir uma janela pedindo para criar um nome de usuário e senha do Linux — defina os dois e anote em local seguro.

> **Dica:** a senha não aparece enquanto você digita. Isso é normal — basta digitar e pressionar Enter.

---

### Passo 3 — Instale o Docker Desktop

**1.** Acesse o site oficial do Docker e baixe o instalador para Windows:
`https://www.docker.com/products/docker-desktop/`

**2.** Execute o instalador baixado (`Docker Desktop Installer.exe`).

**3.** Durante a instalação, certifique-se de que a opção **"Use WSL 2 instead of Hyper-V"** está marcada.

**4.** Conclua a instalação e reinicie o computador se solicitado.

**5.** Abra o **Docker Desktop** pelo menu Iniciar. Aguarde ele inicializar — o ícone da baleia vai aparecer na barra de tarefas (perto do relógio) quando estiver pronto.

---

### Passo 4 — Configure o Docker Desktop para usar o WSL2

**1.** Abra o Docker Desktop.

**2.** Clique no ícone de engrenagem (⚙) no canto superior direito para abrir as configurações.

**3.** Vá em **"Resources"** → **"WSL Integration"**.

**4.** Ative a integração com a sua distribuição Linux (geralmente aparece como **"Ubuntu"**).

**5.** Clique em **"Apply & Restart"**.

---

### Passo 5 — Ative o Docker Swarm

**1.** Abra o **WSL** pelo menu Iniciar (procure por "Ubuntu" ou "WSL").

**2.** Na janela do terminal Linux que abrir, execute:

```bash
docker swarm init
```

Se aparecer a mensagem `Swarm initialized`, está pronto.

---

### Passo 6 — Configure as credenciais dos ERPs

Antes de instalar, você precisa criar o arquivo `.env.production` com as credenciais de acesso aos bancos de dados. Faça isso dentro do terminal do WSL (Ubuntu).

**1.** No terminal do WSL, crie o arquivo:

```bash
nano ~/.env.production
```

**2.** Cole o conteúdo abaixo, substituindo os valores entre `< >` pelos dados reais de cada ERP:

```
TOTVS_HOST=<host-oracle-totvs>
TOTVS_PORT=1521
TOTVS_USER=<usuario>
TOTVS_PASSWORD=<senha>
TOTVS_SERVICE_NAME=<service-name>
TOTVS_FILIAL=01

TASY_HOST=<host-oracle-tasy>
TASY_PORT=1521
TASY_USER=<usuario>
TASY_PASSWORD=<senha>
TASY_SERVICE_NAME=<service-name>
TASY_SCHEMA=TASY

KMM_HOST=<host-postgres-kmm>
KMM_PORT=5432
KMM_USER=<usuario>
KMM_PASSWORD=<senha>
KMM_DBNAME=<banco>
KMM_SCHEMA=public

FOCUS_LAKE_SERVER=<endpoint-synapse>
FOCUS_LAKE_DATABASE=DW-FOCUS
FOCUS_LAKE_USER=<usuario>
FOCUS_LAKE_PASSWORD=<senha>

TASY_LAKE_HOST=<host-postgres-tasy-lake>
TASY_LAKE_PORT=5432
TASY_LAKE_USER=<usuario>
TASY_LAKE_PASSWORD=<senha>
TASY_LAKE_DBNAME=<banco>
TASY_LAKE_SCHEMA=public
```

**3.** Salve o arquivo: pressione `Ctrl + O` e depois `Ctrl + X` para sair.

---

### Passo 7 — Execute o instalador

Ainda no terminal do WSL (Ubuntu), execute o comando de instalação:

```bash
curl -fsSL https://raw.githubusercontent.com/bortolottic/pro-ai-mcp-installer/refs/heads/main/install.sh | bash
```

Aguarde o processo terminar. Quando aparecer a mensagem abaixo, a instalação foi concluída com sucesso:

```
======================================
 Deploy finalizado com sucesso
======================================
```

---

### Passo 8 — Verifique se os serviços estão rodando

No terminal do WSL, confirme que os serviços estão ativos:

```bash
docker service ls
```

Você verá a lista de serviços do Pro AI MCP em execução.

---

## Instalação no macOS

O Docker Desktop para macOS roda nativamente, sem precisar de camada adicional. Funciona tanto em Macs com chip Intel quanto em Macs com chip Apple Silicon (M1, M2, M3 e M4).

---

### Passo 1 — Abra o Terminal

O Terminal é o programa onde você digita comandos no Mac. Veja como abrir:

- **Opção 1:** pressione `Cmd + Espaço`, digite `Terminal` e pressione Enter.
- **Opção 2:** abra o Finder → vá em **Aplicativos** → **Utilitários** → **Terminal**.

Uma janela escura com um cursor piscando vai aparecer. É nela que você vai colar os comandos dos próximos passos.

---

### Passo 2 — Instale o Homebrew

O Homebrew é o gerenciador de pacotes mais usado no macOS — ele facilita a instalação de programas via terminal.

**1.** No Terminal, cole o comando abaixo e pressione Enter:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**2.** O instalador pode pedir a **senha do seu Mac** e solicitar que você pressione Enter para confirmar. Siga as instruções exibidas na tela.

**3.** Ao final, se o seu Mac tiver chip Apple Silicon (M1/M2/M3/M4), o Homebrew vai exibir um aviso pedindo para executar dois comandos adicionais. Copie e execute-os um por vez — eles aparecem no próprio terminal após a instalação.

**4.** Verifique se o Homebrew foi instalado:

```bash
brew --version
```

Se aparecer algo como `Homebrew 4.x.x`, está pronto.

---

### Passo 3 — Instale o Docker Desktop

**1.** No Terminal, execute:

```bash
brew install --cask docker
```

**2.** Aguarde o download e a instalação terminarem.

**3.** Abra o Docker Desktop pelo Launchpad ou pelo Spotlight (`Cmd + Espaço` → digite "Docker"). Na primeira vez, o macOS pode pedir permissão para abrir o aplicativo — clique em **"Abrir"**.

**4.** O Docker vai solicitar permissões de sistema. Clique em **"OK"** ou **"Permitir"** nas janelas que aparecerem.

**5.** Aguarde o Docker inicializar — o ícone da baleia vai aparecer na barra de menus (canto superior direito da tela) quando estiver pronto.

---

### Passo 4 — Verifique a instalação do Docker

No Terminal, confirme que o Docker está funcionando:

```bash
docker --version
```

Se aparecer algo como `Docker version 26.x.x`, a instalação foi bem-sucedida.

---

### Passo 5 — Ative o Docker Swarm

O Docker Swarm é o gerenciador de serviços utilizado pelo Pro AI MCP. Ative-o com:

```bash
docker swarm init
```

Se aparecer a mensagem `Swarm initialized`, está pronto.

> **Nota:** se você receber um erro dizendo que já existe um swarm ativo, pode ignorar — significa que o Docker Swarm já estava configurado.

---

### Passo 6 — Configure as credenciais dos ERPs

Antes de instalar, você precisa criar o arquivo `.env.production` com as credenciais de acesso aos bancos de dados de cada ERP.

**1.** No Terminal, crie o arquivo:

```bash
nano ~/.env.production
```

**2.** Cole o conteúdo abaixo, substituindo os valores entre `< >` pelos dados reais de cada ERP:

```
TOTVS_HOST=<host-oracle-totvs>
TOTVS_PORT=1521
TOTVS_USER=<usuario>
TOTVS_PASSWORD=<senha>
TOTVS_SERVICE_NAME=<service-name>
TOTVS_FILIAL=01

TASY_HOST=<host-oracle-tasy>
TASY_PORT=1521
TASY_USER=<usuario>
TASY_PASSWORD=<senha>
TASY_SERVICE_NAME=<service-name>
TASY_SCHEMA=TASY

KMM_HOST=<host-postgres-kmm>
KMM_PORT=5432
KMM_USER=<usuario>
KMM_PASSWORD=<senha>
KMM_DBNAME=<banco>
KMM_SCHEMA=public

FOCUS_LAKE_SERVER=<endpoint-synapse>
FOCUS_LAKE_DATABASE=DW-FOCUS
FOCUS_LAKE_USER=<usuario>
FOCUS_LAKE_PASSWORD=<senha>

TASY_LAKE_HOST=<host-postgres-tasy-lake>
TASY_LAKE_PORT=5432
TASY_LAKE_USER=<usuario>
TASY_LAKE_PASSWORD=<senha>
TASY_LAKE_DBNAME=<banco>
TASY_LAKE_SCHEMA=public
```

**3.** Salve o arquivo: pressione `Ctrl + O` e depois `Ctrl + X` para sair.

> **Segurança:** as senhas são lidas deste arquivo somente durante o processo de instalação e armazenadas como Docker Secrets — elas não ficam expostas em arquivos de configuração após o deploy.

---

### Passo 7 — Execute o instalador

Com tudo pronto, rode o comando abaixo no Terminal para instalar a versão mais recente do Pro AI MCP:

```bash
curl -fsSL https://raw.githubusercontent.com/bortolottic/pro-ai-mcp-installer/refs/heads/main/install.sh | bash
```

Aguarde o processo terminar. Quando aparecer a mensagem abaixo, a instalação foi concluída com sucesso:

```
======================================
 Deploy finalizado com sucesso
======================================
```

---

### Passo 8 — Verifique se os serviços estão rodando

Confirme que os serviços estão ativos:

```bash
docker service ls
```

Você verá a lista de serviços do Pro AI MCP em execução.

---

## Instalar uma versão específica

Caso precise de uma versão específica (para ambientes de homologação ou rollback):

**Linux, macOS ou WSL2 (Windows):**

```bash
curl -fsSL https://raw.githubusercontent.com/bortolottic/pro-ai-mcp-installer/refs/heads/main/install.sh | bash -s V1.0.26.2
```

Substitua `V1.0.26.2` pelo número da versão desejada. Todas as versões disponíveis estão na página de [Releases do GitHub](https://github.com/bortolottic/pro-ai-mcp-installer/releases).

---

## Após a instalação

Ao concluir, os seguintes endpoints ficam disponíveis:

```
http://<host>:9090/totvs/sse      — TOTVS Protheus
http://<host>:9090/tasy/sse       — TASY Philips
http://<host>:9090/kmm/sse        — KMM Transportes
http://<host>:9090/focus-lake/sse — Focus Lake
http://<host>:9090/tasy-lake/sse  — TASY Lake DW
```

Substitua `<host>` pelo endereço IP ou nome do servidor onde o Pro AI MCP foi instalado.

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

### Configurar o Claude Desktop

Após a instalação, adicione os endpoints ao arquivo de configuração do Claude Desktop (`config.json`) para que o assistente passe a ter acesso aos dados dos ERPs:

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

## O que o instalador faz (para técnicos)

O `install.sh` executa as seguintes etapas automaticamente:

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

## Solução de problemas

| Problema | Possível causa | Solução |
| -------- | -------------- | ------- |
| `curl ou wget não encontrado` | Nenhuma das ferramentas está instalada | Execute: `sudo apt install -y curl` |
| Erro ao baixar o pacote | URL incorreta ou versão inexistente | Verifique as [releases disponíveis](https://github.com/bortolottic/pro-ai-mcp-installer/releases) |
| `Docker not found` | Docker não está instalado ou não está em execução | Instale o Docker e certifique-se de que está rodando |
| `permission denied` ao rodar Docker | Usuário não está no grupo docker | Execute `sudo usermod -aG docker $USER` e abra um novo terminal |
| `This node is already part of a swarm` | Docker Swarm já foi inicializado | Pode ignorar esse erro e continuar |
| Serviço não inicia | Credenciais incorretas no `.env.production` | Revise host, usuário, senha e service_name do ERP |
| Serviço não conecta ao banco | Banco de dados inacessível pela rede | Verifique firewall e conectividade com `telnet <host> <porta>` |
| Deploy falha silenciosamente | Problema no `deploy_production.sh` | Verifique os logs com `docker service ls` e `docker service logs -f pro-ai-mcp_<serviço>` |
| Docker Desktop não inicia (Windows) | Virtualização desativada na BIOS | Acesse a BIOS do computador e ative a opção de virtualização (VT-x/AMD-V) |
| WSL não instala (Windows) | Windows desatualizado | Atualize o Windows pelo Windows Update e tente novamente |
| `brew: command not found` (macOS) | Homebrew não foi instalado ou não está no PATH | Reinstale o Homebrew e siga as instruções exibidas ao final da instalação |
| Docker não abre (macOS) | macOS bloqueou o aplicativo por segurança | Vá em **Ajustes do Sistema** → **Privacidade e Segurança** e clique em "Abrir mesmo assim" |

---

## Versões disponíveis

Todas as versões estão listadas na página de [Releases do GitHub](https://github.com/bortolottic/pro-ai-mcp-installer/releases).

---

## Suporte

Em caso de dúvidas ou problemas, entre em contato com a equipe responsável pelo projeto.
