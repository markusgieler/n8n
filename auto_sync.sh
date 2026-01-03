#!/bin/bash
export XDG_RUNTIME_DIR="/run/user/1000"
# ==============================================================================
# UNIVERSAL GIT AUTO-SYNCER
# Descrição: Script "Drop-in" para sincronizar automaticamente qualquer repositório.
# Como usar: Coloque este arquivo na raiz do projeto e agende no Cron.
# ==============================================================================
# Autor Markus

# --- 1. CONFIGURAÇÃO DINÂMICA (Não precisa editar nada abaixo) ---

# Identifica o diretório onde o script está (Raiz do Projeto)
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Nome do arquivo de log
LOG_NAME="sync.log"
LOG_FILE="$PROJECT_DIR/$LOG_NAME"
DATE=$(date "+%Y-%m-%d_%H-%M-%S")

# --- 2. VERIFICAÇÕES DE SEGURANÇA ---

cd "$PROJECT_DIR" || exit 1

# Verifica se é um repositório Git válido
if [ ! -d ".git" ]; then
    echo "[$DATE] ERRO: O diretório $PROJECT_DIR não é um repositório Git." >> "$LOG_FILE"
    exit 1
fi

# Descobre qual a branch atual automaticamente (main, master, develop, etc.)
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$CURRENT_BRANCH" ]; then
    echo "[$DATE] ERRO: Não foi possível detectar a branch atual." >> "$LOG_FILE"
    exit 1
fi

# --- 3. AUTO-IGNORE (Evita loop de commits do log) ---

if [ -f ".gitignore" ]; then
    if ! grep -q "$LOG_NAME" ".gitignore"; then
        echo "" >> ".gitignore"
        echo "# --- Auto Sync Log ---" >> ".gitignore"
        echo "$LOG_NAME" >> ".gitignore"
        echo "[$DATE] SETUP: $LOG_NAME adicionado ao .gitignore." >> "$LOG_FILE"
    fi
else
    # Se não existir .gitignore, cria um
    echo "$LOG_NAME" > ".gitignore"
fi

# --- 4. FLUXO DE SINCRONIZAÇÃO ---

# Verifica se há mudanças locais (arquivos modificados, novos ou deletados)
CHANGES_EXIST=$(git status --porcelain)

# Verifica se há commits locais que ainda não subiram (ahead)
COMMITS_AHEAD=$(git log origin/"$CURRENT_BRANCH".."$CURRENT_BRANCH" 2>/dev/null)

if [[ -n "$CHANGES_EXIST" ]] || [[ -n "$COMMITS_AHEAD" ]]; then

    # Adiciona tudo
    git add .

    # Faz commit apenas se houver mudanças nos arquivos (evita commit vazio se for só push pendente)
    if ! git diff-index --quiet HEAD --; then
        git commit -m "sync: auto-save $DATE" >> "$LOG_FILE" 2>&1
    fi

    # Pull com Rebase (Traz novidades do servidor sem criar commit de merge feio)
    # Timeout de 30s para não travar se a internet estiver ruim
    timeout 30s git pull --rebase origin "$CURRENT_BRANCH" >> "$LOG_FILE" 2>&1

    # Push para a branch correta
    if git push origin "$CURRENT_BRANCH" >> "$LOG_FILE" 2>&1; then
        echo "[$DATE] SUCESSO: Sincronização concluída na branch $CURRENT_BRANCH." >> "$LOG_FILE"
    else
        echo "[$DATE] ERRO: Falha ao fazer Push para $CURRENT_BRANCH." >> "$LOG_FILE"
    fi

else
    # Opcional: Se quiser logar que rodou mas não tinha nada
    # echo "[$DATE] Info: Nada a sincronizar." >> "$LOG_FILE"
    :
fi

