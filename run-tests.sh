#!/bin/bash

# Script para execução rápida de testes de API
# Uso: ./run-tests.sh [tipo]
# Exemplos:
#   ./run-tests.sh                    # Executa todos os testes
#   ./run-tests.sh users              # Executa apenas testes de usuários
#   ./run-tests.sh tickets            # Executa testes de tickets

set -e

# Configurações
API_URL="http://localhost:3000"
WAIT_TIME=30

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verifica se a API está rodando
check_api() {
    log_info "Verificando se a API está rodando em $API_URL..."
    
    for i in $(seq 1 $WAIT_TIME); do
        if curl -s -f "$API_URL/users" >/dev/null 2>&1; then
            log_success "API está rodando!"
            return 0
        fi
        
        if [ $i -eq 1 ]; then
            log_warning "API não está rodando. Tentando novamente..."
        fi
        
        echo -n "."
        sleep 1
    done
    
    echo ""
    log_error "API não está respondendo após ${WAIT_TIME}s"
    log_error "Por favor, certifique-se de que a Helpdesk API está rodando em $API_URL"
    echo ""
    echo "Para iniciar a API:"
    echo "1. git clone https://github.com/automacaohml/helpdesk-api.git"
    echo "2. cd helpdesk-api && npm install && npm start"
    exit 1
}

# Executa testes baseado no tipo
run_tests() {
    local test_type=$1
    
    # Casos especiais hardcoded
    case $test_type in
        "config")
            log_info "Executando testes de configuração (sem API)..."
            npx cypress run --spec 'cypress/e2e/api/test-config.cy.js'
            return
            ;;
        "root")
            log_info "Executando testes na raiz..."
            npx cypress run --spec 'cypress/e2e/api/*.cy.js'
            return
            ;;
        "all"|"")
            log_info "Executando todos os testes..."
            npm test
            return
            ;;
    esac
    
    # Detecção dinâmica de diretórios
    if [ -d "cypress/e2e/api/$test_type" ]; then
        test_count=$(find "cypress/e2e/api/$test_type" -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
        if [ "$test_count" -gt 0 ]; then
            log_info "Executando testes de $test_type ($test_count arquivos)..."
            npx cypress run --spec "cypress/e2e/api/$test_type/**/*"
        else
            log_error "Nenhum arquivo de teste encontrado em cypress/e2e/api/$test_type"
            exit 1
        fi
    else
        # Mostra tipos disponíveis dinamicamente
        log_error "Tipo de teste inválido: $test_type"
        echo ""
        echo "Tipos disponíveis:"
        echo "  config      - Testes de configuração (sem API)"
        
        # Scan dinâmico
        for dir in cypress/e2e/api/*/; do
            if [ -d "$dir" ]; then
                category=$(basename "$dir")
                count=$(find "$dir" -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
                echo "  $category$(printf '%*s' $((12-${#category})) '') - $count arquivos"
            fi
        done
        
        root_files=$(find cypress/e2e/api -maxdepth 1 -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
        if [ "$root_files" -gt 0 ]; then
            echo "  root        - $root_files arquivos na raiz"
        fi
        
        echo "  all         - Todos os testes (padrão)"
        exit 1
    fi
}

# Gera relatórios
generate_reports() {
    if [ -d "cypress/reports" ] && [ "$(ls -A cypress/reports/*.json 2>/dev/null)" ]; then
        log_info "Gerando relatórios..."
        npm run report:merge 2>/dev/null || true
        npm run report:generate 2>/dev/null || true
        
        if [ -f "cypress/reports/html/index.html" ]; then
            log_success "Relatório HTML gerado: cypress/reports/html/index.html"
        fi
    fi
}

# Função principal
main() {
    local test_type=$1
    
    echo "🧪 Executando testes da Helpdesk API"
    echo "=================================="
    
    # Detecta automaticamente os tipos de teste disponíveis
    get_available_test_types() {
        echo "Tipos disponíveis:"
        echo "  config      - Testes de configuração (sem API) ✅"
        
        # Scan dinâmico de diretórios
        for dir in cypress/e2e/api/*/; do
            if [ -d "$dir" ]; then
                category=$(basename "$dir")
                count=$(find "$dir" -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
                echo "  $category$(printf '%*s' $((12-${#category})) '') - Testes de $category ($count arquivos)"
            fi
        done
        
        # Verifica arquivos na raiz
        root_files=$(find cypress/e2e/api -maxdepth 1 -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
        if [ "$root_files" -gt 0 ]; then
            echo "  root        - Testes na raiz ($root_files arquivos)"
        fi
        
        echo "  all         - Todos os testes (requer API)"
    }
    
    # Mostra ajuda para tipos inválidos ou help
    if [ "$test_type" = "help" ] || [ "$test_type" = "--help" ] || [ "$test_type" = "-h" ]; then
        echo ""
        echo "Uso: ./run-tests.sh [tipo]"
        echo ""
        get_available_test_types
        echo ""
        echo "Exemplos:"
        echo "  ./run-tests.sh config           # Testes sem API"
        echo "  ./run-tests.sh users            # Testes de usuários"
        echo "  ./run-tests.sh all              # Todos os testes"
        echo ""
        echo "Para usar com API:"
        echo "  1. git clone https://github.com/automacaohml/helpdesk-api.git"
        echo "  2. cd helpdesk-api && npm install && npm start"
        echo "  3. ./run-tests.sh [tipo]"
        exit 0
    fi
    
    # Pula verificação da API para testes de configuração
    if [ "$test_type" != "config" ]; then
        # Verifica API
        check_api
    else
        log_info "Executando testes de configuração (não requer API)"
    fi
    
    # Executa testes
    run_tests "$test_type"
    
    # Gera relatórios
    generate_reports
    
    log_success "Testes completados! 🎉"
    
    # Resumo dinâmico
    echo ""
    echo "📊 Resumo da Execução:"
    echo "   🎯 Tipo executado: ${test_type:-"all"}"
    
    # Estrutura de testes detectada
    TOTAL_FILES=$(find cypress/e2e -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
    echo "   📁 Total de arquivos de teste: $TOTAL_FILES"
    
    # Artifacts gerados
    if [ -d "cypress/videos" ] && [ "$(ls -A cypress/videos 2>/dev/null)" ]; then
        video_count=$(find cypress/videos -name "*.mp4" 2>/dev/null | wc -l || echo "0")
        echo "   🎬 Vídeos gerados: $video_count"
    fi
    if [ -d "cypress/screenshots" ] && [ "$(ls -A cypress/screenshots 2>/dev/null)" ]; then
        screenshot_count=$(find cypress/screenshots -name "*.png" 2>/dev/null | wc -l || echo "0")
        echo "   📸 Screenshots: $screenshot_count"
    fi
    if [ -f "cypress/reports/html/index.html" ]; then
        echo "   📋 Relatório HTML: cypress/reports/html/index.html"
    fi
    if [ -f "cypress/reports/html/merged-report.html" ]; then
        echo "   📋 Relatório Consolidado: cypress/reports/html/merged-report.html"
    fi
    
    # Mostra estrutura de testes disponível
    echo ""
    echo "📂 Estrutura de testes disponível:"
    for dir in cypress/e2e/api/*/; do
        if [ -d "$dir" ]; then
            category=$(basename "$dir")
            count=$(find "$dir" -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
            case "$category" in
                "users") echo "   👥 Users: $count arquivos" ;;
                "tickets") echo "   🎫 Tickets: $count arquivos" ;;
                "schemas") echo "   📋 Schemas: $count arquivos" ;;
                "integration") echo "   🔄 Integration: $count arquivos" ;;
                "negative") echo "   ❌ Negative: $count arquivos" ;;
                *) echo "   📂 $category: $count arquivos" ;;
            esac
        fi
    done
    
    root_files=$(find cypress/e2e/api -maxdepth 1 -name "*.cy.js" 2>/dev/null | wc -l || echo "0")
    if [ "$root_files" -gt 0 ]; then
        echo "   ⚙️ Config/Root: $root_files arquivos"
    fi
}

# Executa script
main "$@"
