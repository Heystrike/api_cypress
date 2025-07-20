# Helpdesk API - Automação de Testes com Cypress

Este projeto contém a automação de testes para a Helpdesk API, desenvolvido com Cypress para validar os principais endpoints e funcionalidades do sistema de suporte técnico.

## 📋 Visão Geral

A automação de testes cobre os seguintes aspectos:

- ✅ **CRUD de Usuários** (Create, Read, Update, Delete)
- ✅ **CRUD de Tickets** (Create, Read, Update, Delete)
- ✅ **Validação de Schemas** (JSON Schema validation)
- ✅ **Testes Positivos e Negativos**
- ✅ **Validação de Status Codes**
- ✅ **Validação de Regras de Negócio**
- ✅ **Testes de Campos Obrigatórios**
- ✅ **Relatórios Detalhados**

## 🚀 Tecnologias Utilizadas

- **Cypress** - Framework de testes E2E
- **JavaScript** - Linguagem de programação
- **AJV** - Validação de JSON Schema
- **Faker.js** - Geração de dados de teste
- **Mochawesome** - Relatórios HTML

## 📁 Estrutura do Projeto

```
cypress-helpdesk-api/
├── cypress/
│   ├── e2e/
│   │   └── api/
│   │       ├── users/
│   │       │   ├── users-positive.cy.js
│   │       │   ├── users-negative.cy.js
│   │       │   └── users-business-rules.cy.js
│   │       ├── tickets/
│   │       │   ├── tickets-positive.cy.js
│   │       │   ├── tickets-negative.cy.js
│   │       │   └── tickets-business-rules.cy.js
│   │       ├── schemas/
│   │       │   ├── users-schema.cy.js
│   │       │   └── tickets-schema.cy.js
│   │       └── integration/
│   │           └── full-workflow.cy.js
│   ├── fixtures/
│   │   ├── users.json
│   │   ├── tickets.json
│   │   └── schemas/
│   │       ├── user-schema.json
│   │       └── ticket-schema.json
│   ├── support/
│   │   ├── commands.js
│   │   ├── api-commands.js
│   │   ├── e2e.js
│   │   └── utils/
│   │       ├── data-generator.js
│   │       └── schema-validator.js
│   └── reports/
├── docs/
│   └── api-improvements.md
├── package.json
├── cypress.config.js
└── README.md
```

## 🔧 Configuração e Instalação

### Pré-requisitos

- Node.js (versão 14 ou superior)
- npm ou yarn
- Git

### 1. Clone o repositório

```bash
git clone https://github.com/Heystrike/api_cypress.git
cd api_cypress
```

### 2. Instale as dependências

```bash
npm install
```

### 3. Configure a API de testes

Certifique-se de que a Helpdesk API esteja rodando localmente:

```bash
# Em outro terminal, clone e execute a API
git clone https://github.com/automacaohml/helpdesk-api.git
cd helpdesk-api
npm install
node server.js
```

A API estará disponível em: `http://localhost:3000`

## 🎯 Executando os Testes

### Executar todos os testes

```bash
npm test
```

### Executar com interface gráfica

```bash
npm run cypress:open
```

### Executar testes específicos

```bash
# Testes de usuários
npm run test:users

# Testes de tickets
npm run test:tickets

# Testes de schemas
npm run test:schemas

# Testes negativos
npm run test:negative
```

### Executar em diferentes navegadores

```bash
# Chrome
npm run cypress:run:chrome

# Firefox
npm run cypress:run:firefox
```

## 📊 Relatórios

### Gerar relatórios HTML

```bash
npm run report
npm run report:merge
npm run report:generate
```

Os relatórios serão gerados na pasta `cypress/reports/html/`

## 🧪 Cenários de Teste

### 👥 Testes de Usuários

#### Cenários Positivos:

- ✅ Criar usuário com dados válidos
- ✅ Listar todos os usuários
- ✅ Buscar usuário por ID
- ✅ Atualizar dados do usuário
- ✅ Deletar usuário

#### Cenários Negativos:

- ❌ Criar usuário sem nome
- ❌ Criar usuário sem email
- ❌ Criar usuário com email duplicado
- ❌ Buscar usuário inexistente
- ❌ Atualizar usuário inexistente
- ❌ Deletar usuário inexistente

### 🎫 Testes de Tickets

#### Cenários Positivos:

- ✅ Criar ticket com dados válidos
- ✅ Buscar ticket por ID
- ✅ Atualizar status do ticket
- ✅ Deletar ticket

#### Cenários Negativos:

- ❌ Criar ticket sem descrição
- ❌ Criar ticket sem userId
- ❌ Criar ticket com userId inexistente
- ❌ Buscar ticket inexistente
- ❌ Atualizar status de ticket inexistente
- ❌ Deletar ticket inexistente

### 🔍 Validações Implementadas

1. **Status Codes**: Validação de códigos HTTP corretos
2. **Response Time**: Verificação de performance da API
3. **Headers**: Validação de cabeçalhos de resposta
4. **Schema Validation**: Estrutura de dados JSON
5. **Business Rules**: Regras de negócio específicas
6. **Data Types**: Tipos de dados corretos
7. **Required Fields**: Campos obrigatórios
8. **Error Messages**: Mensagens de erro adequadas

## 🏗️ Arquitetura dos Testes

### Page Object Model

Utilização do padrão Page Object para organização e reutilização de código.

### Custom Commands

Comandos customizados para operações repetitivas da API.

### Data Driven Testing

Uso de fixtures e dados gerados dinamicamente.

### Schema Validation

Validação rigorosa de schemas JSON usando AJV.

## 📈 Métricas de Qualidade

- **Cobertura de Endpoints**: 100%
- **Cenários Positivos**: 100%
- **Cenários Negativos**: 100%
- **Validações de Schema**: 100%
- **Regras de Negócio**: 100%

## 🚧 Melhorias Sugeridas para a API

Consulte o arquivo [docs/api-improvements.md](docs/api-improvements.md) para sugestões detalhadas de melhorias na API.

## 🔄 CI/CD

### GitHub Actions

Exemplo de pipeline configurado para execução automática dos testes:

```yaml
name: Cypress Tests
on: [push, pull_request]
jobs:
  cypress-run:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Install dependencies
        run: npm ci

      - name: Run Cypress tests
        run: npm test

      - name: Upload reports
        uses: actions/upload-artifact@v3
        with:
          name: cypress-reports
          path: cypress/reports/
```

## 🎯 Resultados Esperados

- ✅ Cobertura completa dos endpoints da API
- ✅ Detecção precoce de bugs e regressões
- ✅ Validação rigorosa de contratos da API
- ✅ Relatórios detalhados para análise
- ✅ Integração com pipelines CI/CD
- ✅ Manutenibilidade e escalabilidade dos testes
