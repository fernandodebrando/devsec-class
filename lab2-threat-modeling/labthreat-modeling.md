# Laboratório Prático: Design Seguro e Modelagem de Ameaças
## Módulo 2 - Identificar Riscos Antes de Escrever Código

---

## 🎯 OBJETIVOS DO LABORATÓRIO

Ao final deste laboratório, você será capaz de:

1. ✅ Criar Diagramas de Fluxo de Dados (DFD) para aplicações
2. ✅ Aplicar a metodologia STRIDE para identificar ameaças
3. ✅ Utilizar OWASP Threat Dragon para modelagem
4. ✅ Derivar requisitos de segurança a partir de ameaças
5. ✅ Priorizar ameaças usando DREAD
6. ✅ Documentar controles de mitigação
7. ✅ Integrar Threat Modeling no SDLC

**Duração:** 1 hora  
**Nível:** Intermediário  
**Pré-requisitos:** Conhecimento básico de arquitetura de software, HTTP/APIs

---

## 📚 PARTE 1: CONFIGURAÇÃO DO AMBIENTE (10 minutos)

### 🛠️ Instalação das Ferramentas

#### Opção 1: OWASP Threat Dragon (Desktop - Recomendado)

```bash
# Download da versão mais recente
# https://github.com/OWASP/threat-dragon/releases

# Linux
wget https://github.com/OWASP/threat-dragon/releases/download/v2.2.0/threat-dragon-2.2.0.AppImage
chmod +x threat-dragon-2.2.0.AppImage
./threat-dragon-2.2.0.AppImage

# macOS
brew install --cask owasp-threat-dragon

# Windows
# Baixar e instalar o .exe de: https://github.com/OWASP/threat-dragon/releases

echo "✅ OWASP Threat Dragon instalado!"
```

---

#### Opção 2: OWASP Threat Dragon (Web - Sem instalação)

```bash
# Acessar versão web
# https://www.threatdragon.com/

# OU rodar localmente com Docker
docker run -p 8080:3000 threatdragon/owasp-threat-dragon:latest

# Acessar: http://localhost:8080

echo "✅ Threat Dragon disponível no navegador!"
```

---

#### Ferramentas Complementares

```bash
# Draw.io (para diagramas alternativos)
# https://app.diagrams.net/

# Microsoft Threat Modeling Tool (Windows only)
# https://www.microsoft.com/en-us/download/details.aspx?id=49168

# IriusRisk (versão Community)
# https://www.iriusrisk.com/community-edition

echo "✅ Ferramentas complementares disponíveis!"
```

---

### 📖 Materiais de Referência

Baixar templates e guias:

```bash
# Criar diretório de trabalho
mkdir threat-modeling-lab
cd threat-modeling-lab

# Criar guia STRIDE de referência
cat > STRIDE_Reference.md << 'EOF'
# STRIDE Threat Model - Referência Rápida

## O que é STRIDE?

STRIDE é um acrônimo para 6 categorias de ameaças:

### S - Spoofing (Falsificação de Identidade)
**Definição:** Atacante se passa por outra entidade (usuário, sistema, etc.)
**Exemplos:**
- Login com credenciais roubadas
- Falsificação de token JWT
- IP spoofing
- Session hijacking

**Perguntas:**
- Como autenticamos usuários?
- Tokens podem ser forjados?
- Validamos a origem das requisições?

---

### T - Tampering (Adulteração de Dados)
**Definição:** Modificação não autorizada de dados
**Exemplos:**
- SQL Injection modificando dados
- Man-in-the-middle alterando payloads
- Modificação de cookies/tokens
- Adulteração de logs

**Perguntas:**
- Dados em trânsito estão protegidos?
- Temos integridade de dados?
- Logs podem ser alterados?

---

### R - Repudiation (Repúdio)
**Definição:** Usuário nega ter realizado uma ação
**Exemplos:**
- Falta de logs de auditoria
- Logs não assinados digitalmente
- Ausência de rastro de transações
- Timestamps não confiáveis

**Perguntas:**
- Todas as ações são logadas?
- Logs têm timestamp confiável?
- Existe prova não-repudiável?

---

### I - Information Disclosure (Vazamento de Informações)
**Definição:** Exposição de informações sensíveis
**Exemplos:**
- SQL Injection expondo dados
- Stack traces com informações sensíveis
- Dados em logs
- Enumeração de usuários
- Metadata vazada

**Perguntas:**
- Dados sensíveis estão criptografados?
- Mensagens de erro revelam detalhes internos?
- Quem tem acesso a quais dados?

---

### D - Denial of Service (Negação de Serviço)
**Definição:** Tornar sistema/recurso indisponível
**Exemplos:**
- Flood de requisições (DDoS)
- Resource exhaustion
- Regex DoS (ReDoS)
- Algoritmic complexity attacks
- Fork bombs

**Perguntas:**
- Sistema tem rate limiting?
- Recursos têm limites (timeout, memória)?
- Há proteção contra DoS?

---

### E - Elevation of Privilege (Escalação de Privilégios)
**Definição:** Ganhar acesso além do permitido
**Exemplos:**
- SQL Injection ganhando acesso admin
- Path traversal lendo arquivos protegidos
- IDOR (Insecure Direct Object Reference)
- Bypass de autorização
- Container escape

**Perguntas:**
- Princípio do menor privilégio aplicado?
- Validamos autorização em todas as ações?
- Usuários podem acessar recursos de outros?

---

## Como Aplicar STRIDE

1. **Desenhar DFD** (Data Flow Diagram)
2. **Para cada elemento do DFD:**
   - Entidade Externa → S, R
   - Processo → S, T, R, I, D, E (TODOS)
   - Data Store → T, R, I, D
   - Data Flow → T, I, D
3. **Listar ameaças específicas**
4. **Priorizar com DREAD**
5. **Definir mitigações**

EOF

# Criar template DREAD
cat > DREAD_Template.md << 'EOF'
# DREAD - Priorização de Ameaças

## O que é DREAD?

Sistema de pontuação para priorizar ameaças (0-10 cada):

### D - Damage Potential (Potencial de Dano)
- 0: Nenhum dano
- 5: Vazamento de informações não-críticas
- 10: Comprometimento total do sistema

### R - Reproducibility (Reprodutibilidade)
- 0: Muito difícil de reproduzir
- 5: Requer condições específicas
- 10: Sempre funciona

### E - Exploitability (Explorabilidade)
- 0: Requer habilidades avançadas e ferramentas customizadas
- 5: Requer conhecimento técnico
- 10: Exploit público disponível, fácil de executar

### A - Affected Users (Usuários Afetados)
- 0: Nenhum usuário
- 5: Alguns usuários
- 10: Todos os usuários

### D - Discoverability (Descoberta)
- 0: Muito difícil de descobrir
- 5: Requer análise
- 10: Vulnerabilidade óbvia

**Score DREAD = (D + R + E + A + D) / 5**

**Priorização:**
- 8-10: CRÍTICO - Corrigir imediatamente
- 5-7: ALTO - Corrigir em breve
- 3-4: MÉDIO - Incluir no backlog
- 0-2: BAIXO - Aceitar ou corrigir quando possível
EOF

echo "✅ Materiais de referência criados!"
```

---

## 🎨 PARTE 2: FUNDAMENTOS DE DFD (10 minutos)

### 📝 EXERCÍCIO 2.1: Entender Elementos de DFD

**Elementos básicos de Data Flow Diagram:**

```
┌─────────────────────────────────────────────────────────┐
│ ELEMENTOS DE DFD (Data Flow Diagram)                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ 1. ENTIDADE EXTERNA (External Entity)                   │
│    ┌──────────┐                                         │
│    │  User    │  Representa: Usuários, sistemas externos│
│    └──────────┘  Ameaças: Spoofing, Repudiation         │
│                                                          │
│ 2. PROCESSO (Process)                                   │
│    ┌──────────┐                                         │
│    │ Process  │  Representa: Código, serviço, API       │
│    │  1.0     │  Ameaças: TODAS (STRIDE completo)       │
│    └──────────┘                                         │
│                                                          │
│ 3. DATA STORE (Data Store)                             │
│    ║          ║                                         │
│    ║ Database ║  Representa: BD, arquivos, cache        │
│    ║          ║  Ameaças: Tampering, Info Disclosure    │
│                                                          │
│ 4. DATA FLOW (Data Flow)                               │
│    ────────────>  Representa: Dados em trânsito         │
│                   Ameaças: Tampering, Info Disclosure   │
│                                                          │
│ 5. TRUST BOUNDARY (Fronteira de Confiança)             │
│    ─ ─ ─ ─ ─ ─   Separa áreas com diferentes níveis    │
│                   de confiança (internet vs intranet)   │
└─────────────────────────────────────────────────────────┘
```

---

### 📝 EXERCÍCIO 2.2: DFD Simples - Login System

Vamos criar um DFD básico para um sistema de login:

```bash
cat > login_system_dfd.txt << 'EOF'
# DFD: Sistema de Login Simples

Componentes:
┌──────────┐                                    ║          ║
│   User   │ ──(1. Credentials)──> [Web App] ──│ User DB  │
└──────────┘                          │         ║          ║
                                      │
                              (2. Session Token)
                                      │
                                      v
                                 ┌─────────┐
                                 │ Browser │
                                 │ Cookie  │
                                 └─────────┘

Fluxo de Dados:
1. User → Web App: Username + Password (HTTPS)
2. Web App → User DB: Query user credentials
3. User DB → Web App: User record
4. Web App → User: Session token (Cookie)

Trust Boundaries:
- Internet (User) ─ ─ ─ ─ ─ | DMZ (Web App) ─ ─ ─ ─ ─ | Internal (Database)
EOF

cat login_system_dfd.txt
```

---

### 📊 TAREFA 1: Identificar Ameaças STRIDE no Login System

Preencha a tabela:

| Elemento | Ameaças STRIDE Aplicáveis | Exemplo de Ameaça Específica |
|----------|---------------------------|------------------------------|
| User (Entidade Externa) | S, R | S: Atacante usa credenciais roubadas |
| Web App (Processo) | S, T, R, I, D, E | T: SQL Injection modificando dados |
| User DB (Data Store) | T, R, I, D | I: Backup exposto vazando senhas |
| Credentials (Data Flow) | T, I, D | I: Senha trafegando em HTTP |
| Session Token (Data Flow) | T, I, D | T: Token interceptado e modificado |

**Questões para discussão:**
1. Qual ameaça tem maior impacto?
2. Qual é mais fácil de explorar?
3. Quais controles de segurança mitigariam cada ameaça?

---

## 🔨 PARTE 3: THREAT DRAGON - PRIMEIRO MODELO (15 minutos)

### 📝 EXERCÍCIO 3.1: Criar Modelo de E-commerce Simples

Vamos modelar uma aplicação de e-commerce básica.

**Passo 1: Abrir OWASP Threat Dragon**

```bash
# Se instalou desktop version
./threat-dragon-2.2.0.AppImage

# Se rodando no Docker
# Acessar: http://localhost:8080

# Se usando versão web
# Acessar: https://www.threatdragon.com/
```

---

**Passo 2: Criar Novo Modelo**

1. **New Threat Model**
   - Name: `E-commerce Application`
   - Owner: `[Seu Nome]`
   - Reviewer: `Security Team`

2. **Add Diagram**
   - Name: `Customer Purchase Flow`
   - Description: `Fluxo de compra do cliente`

---

**Passo 3: Adicionar Elementos ao DFD**

Adicione os seguintes elementos:

```
┌──────────────────────────────────────────────────────────────┐
│                    E-commerce DFD                             │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────┐         ┌──────────────┐        ║            ║│
│  │ Customer │────(1)─>│   Web App    │───(2)─>║  Product   ║│
│  └──────────┘         │  (Frontend)  │        ║  Database  ║│
│       │               └──────────────┘        ║            ║│
│       │                      │                               │
│       │                      │(3)                            │
│       │                      v                               │
│       │               ┌──────────────┐        ║            ║│
│       │               │   Payment    │───(4)─>║  Order     ║│
│       │               │   Gateway    │        ║  Database  ║│
│       │               └──────────────┘        ║            ║│
│       │                      │                               │
│       └──────(5)─────────────┘                               │
│                                                               │
│  Trust Boundaries:                                           │
│  ─ ─ ─ ─ ─ ─ Internet ─ ─ ─ ─ ─ │ DMZ ─ ─ ─ │ Internal    │
└──────────────────────────────────────────────────────────────┘

Elementos para adicionar no Threat Dragon:
1. External Entity: "Customer"
2. Process: "Web App (Frontend)"
3. Process: "Payment Gateway"
4. Data Store: "Product Database"
5. Data Store: "Order Database"
6. Data Flows:
   - Customer → Web App (Browse Products)
   - Web App → Product DB (Query Products)
   - Web App → Payment Gateway (Process Payment)
   - Payment Gateway → Order DB (Store Order)
   - Payment Gateway → Customer (Confirmation)
7. Trust Boundaries:
   - Internet/DMZ
   - DMZ/Internal
```

---

**Passo 4: Adicionar Ameaças STRIDE**

Para cada elemento, clique e adicione ameaças:

**Exemplo 1: Customer (External Entity)**

Clique em "Customer" → "Add Threat"

```
Threat: Spoofing - Fake Customer Account
├─ Category: Spoofing
├─ Description: Atacante cria conta falsa com dados roubados
├─ STRIDE: S
├─ Status: Open
├─ Priority: High
├─ Mitigation:
│  - Implementar verificação de email/telefone
│  - Exigir autenticação multifator (MFA)
│  - Validação de cartão de crédito
└─ Owner: Identity Team
```

---

**Exemplo 2: Web App (Process)**

```
Threat 1: SQL Injection
├─ Category: Tampering + Information Disclosure + Elevation of Privilege
├─ Description: Atacante injeta SQL via campo de busca
├─ STRIDE: T, I, E
├─ Status: Open
├─ Priority: Critical
├─ Mitigation:
│  - Usar prepared statements
│  - Input validation
│  - Princípio do menor privilégio no DB
│  - WAF (Web Application Firewall)
└─ Owner: Development Team

Threat 2: XSS (Cross-Site Scripting)
├─ Category: Tampering + Information Disclosure
├─ Description: Código JavaScript malicioso injetado em reviews
├─ STRIDE: T, I
├─ Status: Open
├─ Priority: High
├─ Mitigation:
│  - Output encoding/escaping
│  - Content Security Policy (CSP)
│  - Input sanitization
└─ Owner: Development Team

Threat 3: Denial of Service
├─ Category: Denial of Service
├─ Description: Flood de requisições esgota recursos
├─ STRIDE: D
├─ Status: Open
├─ Priority: Medium
├─ Mitigation:
│  - Rate limiting
│  - CAPTCHA em operações sensíveis
│  - Auto-scaling
│  - CDN/DDoS protection
└─ Owner: Infrastructure Team
```

---

**Exemplo 3: Payment Gateway (Process)**

```
Threat 1: Man-in-the-Middle
├─ Category: Tampering + Information Disclosure
├─ Description: Interceptação de dados de cartão de crédito
├─ STRIDE: T, I
├─ Status: Open
├─ Priority: Critical
├─ Mitigation:
│  - TLS 1.3 obrigatório
│  - Certificate pinning
│  - HSTS (HTTP Strict Transport Security)
│  - Não armazenar dados de cartão (usar tokenização)
└─ Owner: Security Team

Threat 2: Payment Fraud
├─ Category: Spoofing + Tampering
├─ Description: Transação com cartão roubado
├─ STRIDE: S, T
├─ Status: Open
├─ Priority: High
├─ Mitigation:
│  - 3D Secure (3DS2)
│  - Verificação de CVV
│  - Análise de fraude (velocity checks)
│  - Geolocation validation
└─ Owner: Payment Team
```

---

**Exemplo 4: Order Database (Data Store)**

```
Threat 1: Unauthorized Data Access
├─ Category: Information Disclosure
├─ Description: Acesso não autorizado a dados de pedidos
├─ STRIDE: I
├─ Status: Open
├─ Priority: High
├─ Mitigation:
│  - Criptografia em repouso (AES-256)
│  - RBAC (Role-Based Access Control)
│  - Auditoria de acessos
│  - Database firewall
└─ Owner: DBA Team

Threat 2: Data Tampering
├─ Category: Tampering
├─ Description: Modificação de status de pedido
├─ STRIDE: T
├─ Status: Open
├─ Priority: Medium
├─ Mitigation:
│  - Triggers de auditoria
│  - Assinatura digital de registros críticos
│  - Logs imutáveis
└─ Owner: DBA Team
```

---

**Exemplo 5: Data Flow - Customer → Web App**

```
Threat: Credential Interception
├─ Category: Information Disclosure
├─ Description: Senha interceptada se transmitida em HTTP
├─ STRIDE: I
├─ Status: Open
├─ Priority: Critical
├─ Mitigation:
│  - HTTPS em todas as páginas
│  - HSTS preload
│  - Secure cookies (Secure, HttpOnly, SameSite)
└─ Owner: Development Team
```

---

### 📊 TAREFA 2: Completar Modelagem no Threat Dragon

**Checklist de Ameaças a Adicionar:**

- [ ] **Customer (External Entity)**
  - [ ] Spoofing: Conta falsa
  - [ ] Repudiation: Negar compra

- [ ] **Web App (Process)**
  - [ ] SQL Injection
  - [ ] XSS
  - [ ] CSRF
  - [ ] Session Hijacking
  - [ ] Denial of Service

- [ ] **Payment Gateway (Process)**
  - [ ] Man-in-the-Middle
  - [ ] Payment Fraud
  - [ ] API key exposure
  - [ ] Replay attacks

- [ ] **Product Database (Data Store)**
  - [ ] Unauthorized Access
  - [ ] Data Tampering
  - [ ] Backup Exposure

- [ ] **Order Database (Data Store)**
  - [ ] PII Exposure
  - [ ] Data Integrity
  - [ ] Ransomware

- [ ] **Data Flows**
  - [ ] TLS/HTTPS enforcement
  - [ ] Input validation
  - [ ] Output encoding

---

## 🎯 PARTE 4: PRIORIZAÇÃO COM DREAD (10 minutos)

### 📝 EXERCÍCIO 4.1: Calcular DREAD Score

Vamos priorizar as ameaças usando DREAD:

```bash
cat > threat_prioritization.md << 'EOF'
# Priorização de Ameaças - E-commerce Application

## Ameaça 1: SQL Injection no Web App

### DREAD Score:
- **D**amage: 10 (Comprometimento total do DB)
- **R**eproducibility: 10 (Sempre funciona se vulnerável)
- **E**xploitability: 8 (SQLMap e outras ferramentas públicas)
- **A**ffected Users: 10 (Todos os clientes)
- **D**iscoverability: 9 (Fácil de encontrar com scanner)

**Score: (10+10+8+10+9)/5 = 9.4 - CRÍTICO**

**Justificativa:** 
Impacto catastrófico, fácil de explorar, afeta todos usuários.
DEVE ser corrigido antes do lançamento.

---

## Ameaça 2: XSS em Reviews de Produtos

### DREAD Score:
- **D**amage: 7 (Roubo de sessões, defacement)
- **R**eproducibility: 10 (Sempre funciona)
- **E**xploitability: 9 (Ferramentas automatizadas)
- **A**ffected Users: 8 (Usuários que visualizam review)
- **D**iscoverability: 7 (Scanner encontra facilmente)

**Score: (7+10+9+8+7)/5 = 8.2 - CRÍTICO**

**Justificativa:** 
Alto impacto em confidencialidade e integridade.
Correção prioritária.

---

## Ameaça 3: Man-in-the-Middle no Payment Gateway

### DREAD Score:
- **D**amage: 10 (Roubo de dados de cartão)
- **R**eproducibility: 5 (Requer posição de rede privilegiada)
- **E**xploitability: 6 (Requer conhecimento técnico)
- **A**ffected Users: 3 (Usuários na mesma rede insegura)
- **D**iscoverability: 4 (Difícil de detectar sem ferramentas)

**Score: (10+5+6+3+4)/5 = 5.6 - ALTO**

**Justificativa:** 
Impacto extremo, mas difícil de explorar.
TLS já deve estar implementado.

---

## Ameaça 4: Denial of Service via Product Search

### DREAD Score:
- **D**amage: 5 (Indisponibilidade temporária)
- **R**eproducibility: 10 (Sempre funciona)
- **E**xploitability: 10 (Simples script)
- **A**ffected Users: 10 (Todos)
- **D**iscoverability: 10 (Óbvio)

**Score: (5+10+10+10+10)/5 = 9.0 - CRÍTICO**

**Justificativa:** 
Apesar de dano "apenas" de disponibilidade, é trivial de explorar.
Rate limiting deve ser implementado.

---

## Ameaça 5: Fake Customer Account

### DREAD Score:
- **D**amage: 6 (Fraude limitada por validações)
- **R**eproducibility: 8 (Funciona com dados roubados)
- **E**xploitability: 7 (Requer dados de terceiros)
- **A**ffected Users: 2 (Vítimas de roubo de identidade)
- **D**iscoverability: 5 (Requer análise de padrões)

**Score: (6+8+7+2+5)/5 = 5.6 - ALTO**

**Justificativa:** 
Fraude é preocupante, mas controles já existem (validação de cartão).
MFA adiciona camada extra.

---

## Resumo de Priorização

| Ameaça | DREAD Score | Prioridade | Ação |
|--------|-------------|------------|------|
| SQL Injection | 9.4 | CRÍTICO | Corrigir ANTES do lançamento |
| DoS via Search | 9.0 | CRÍTICO | Implementar rate limiting |
| XSS em Reviews | 8.2 | CRÍTICO | Output encoding obrigatório |
| MitM Payment | 5.6 | ALTO | Validar TLS está configurado |
| Fake Account | 5.6 | ALTO | Considerar MFA |

EOF

cat threat_prioritization.md
```

---

### 📊 TAREFA 3: Priorizar Suas Ameaças

Para cada ameaça identificada no Threat Dragon, calcule o DREAD score:

| Ameaça | D | R | E | A | D | Score | Prioridade |
|--------|---|---|---|---|---|-------|------------|
| SQL Injection | 10 | 10 | 8 | 10 | 9 | 9.4 | CRÍTICO |
| XSS | 7 | 10 | 9 | 8 | 7 | 8.2 | CRÍTICO |
| _______ | __ | __ | __ | __ | __ | ___ | _______ |
| _______ | __ | __ | __ | __ | __ | ___ | _______ |
| _______ | __ | __ | __ | __ | __ | ___ | _______ |

**Ordenar por Score (maior para menor)**

---

## 📋 PARTE 5: REQUISITOS DE SEGURANÇA (10 minutos)

### 📝 EXERCÍCIO 5.1: Derivar Requisitos de Segurança

A partir das ameaças, derivar requisitos técnicos específicos:

```bash
cat > security_requirements.md << 'EOF'
# Requisitos de Segurança - E-commerce Application

## 1. Autenticação e Controle de Acesso

### REQ-AUTH-001: Autenticação Forte
**Derivado de:** Ameaça de Spoofing (Fake Customer Account)
**Requisito:** Sistema DEVE implementar autenticação multifator (MFA) para todas as contas.
**Critérios de Aceitação:**
- SMS/Email OTP disponível
- Suporte a TOTP (Google Authenticator, Authy)
- MFA obrigatório para operações sensíveis (mudança de senha, novo endereço de entrega)

### REQ-AUTH-002: Bloqueio de Conta
**Derivado de:** Ameaça de Brute Force
**Requisito:** Sistema DEVE bloquear conta após 5 tentativas de login falhadas
**Critérios de Aceitação:**
- Bloqueio temporário (30 minutos) após 5 tentativas
- CAPTCHA após 3 tentativas
- Notificação ao usuário de tentativas suspeitas

---

## 2. Proteção de Dados

### REQ-DATA-001: Criptografia em Trânsito
**Derivado de:** Ameaça de Man-in-the-Middle
**Requisito:** TODAS as comunicações DEVEM usar TLS 1.3
**Critérios de Aceitação:**
- TLS 1.2 e anteriores desabilitados
- HSTS habilitado com max-age mínimo de 1 ano
- Certificate pinning no app móvel
- Redirect automático HTTP → HTTPS

### REQ-DATA-002: Criptografia em Repouso
**Derivado de:** Ameaça de Data Exposure
**Requisito:** Dados sensíveis DEVEM ser criptografados em repouso
**Critérios de Aceitação:**
- AES-256 para dados de clientes
- Senhas com bcrypt (cost factor >= 12)
- Dados de cartão tokenizados (não armazenados)
- Chaves gerenciadas por KMS (Key Management Service)

### REQ-DATA-003: Segurança de Dados de Pagamento
**Derivado de:** Ameaça de Payment Data Theft
**Requisito:** Sistema NÃO DEVE armazenar dados completos de cartão de crédito
**Critérios de Aceitação:**
- PCI-DSS compliance
- Tokenização via payment gateway
- Apenas últimos 4 dígitos exibidos
- CVV NUNCA armazenado

---

## 3. Validação de Input

### REQ-INPUT-001: SQL Injection Prevention
**Derivado de:** Ameaça de SQL Injection
**Requisito:** Sistema DEVE usar prepared statements para TODAS as queries
**Critérios de Aceitação:**
- Zero concatenação de strings em SQL
- ORM configurado para parameterized queries
- Database user com least privilege
- WAF com regras anti-SQLi

### REQ-INPUT-002: XSS Prevention
**Derivado de:** Ameaça de Cross-Site Scripting
**Requisito:** Sistema DEVE aplicar output encoding em TODOS os dados de usuário
**Critérios de Aceitação:**
- HTML escaping em templates
- Content Security Policy (CSP) implementado
- Sanitização de HTML em rich text (reviews)
- DOM-based XSS prevention

### REQ-INPUT-003: Input Validation
**Derivado de:** Múltiplas ameaças de injection
**Requisito:** Sistema DEVE validar TODOS os inputs do usuário
**Critérios de Aceitação:**
- Whitelist validation (não blacklist)
- Validação de tipo, formato, range
- Reject por padrão, accept por exceção
- Server-side validation obrigatória

---

## 4. Disponibilidade e Rate Limiting

### REQ-AVAIL-001: Rate Limiting
**Derivado de:** Ameaça de Denial of Service
**Requisito:** Sistema DEVE implementar rate limiting em TODAS as APIs públicas
**Critérios de Aceitação:**
- 100 requisições/minuto por IP em endpoints públicos
- 10 requisições/minuto em login
- 429 Too Many Requests retornado quando excedido
- Exponential backoff sugerido

### REQ-AVAIL-002: Resource Limits
**Derivado de:** Ameaça de Resource Exhaustion
**Requisito:** Sistema DEVE ter timeouts e limites de recursos
**Critérios de Aceitação:**
- Request timeout: 30 segundos
- Upload size limit: 10MB
- Pagination obrigatória (max 100 itens/página)
- Circuit breaker em integrações externas

---

## 5. Logging e Auditoria

### REQ-LOG-001: Audit Trail
**Derivado de:** Ameaça de Repudiation
**Requisito:** Sistema DEVE logar TODAS as operações sensíveis
**Critérios de Aceitação:**
- Login/logout
- Mudanças de senha
- Transações financeiras
- Modificações de dados críticos
- Logs com timestamp, user ID, IP, ação

### REQ-LOG-002: Log Protection
**Derivado de:** Ameaça de Log Tampering
**Requisito:** Logs DEVEM ser write-only e centralizados
**Critérios de Aceitação:**
- Logs enviados para SIEM centralizado
- Logs locais não podem ser modificados
- Retenção mínima: 1 ano
- Alertas em tempo real para eventos críticos

---

## 6. Segurança de Sessão

### REQ-SESS-001: Secure Cookies
**Derivado de:** Ameaça de Session Hijacking
**Requisito:** Cookies de sessão DEVEM ter flags de segurança
**Critérios de Aceitação:**
- Secure flag (HTTPS only)
- HttpOnly flag (não acessível por JS)
- SameSite=Strict
- Session timeout: 30 minutos de inatividade

### REQ-SESS-002: CSRF Protection
**Derivado de:** Ameaça de Cross-Site Request Forgery
**Requisito:** Sistema DEVE implementar proteção anti-CSRF
**Critérios de Aceitação:**
- CSRF token em todos os formulários
- Double-submit cookie pattern
- Validação de origin/referer header
- SameSite cookies

---

## 7. Princípio do Menor Privilégio

### REQ-ACCESS-001: Least Privilege
**Derivado de:** Ameaça de Elevation of Privilege
**Requisito:** Componentes DEVEM ter apenas privilégios necessários
**Critérios de Aceitação:**
- Web app não roda como root/admin
- Database user tem apenas SELECT/INSERT/UPDATE (não DROP)
- Containers rodam como non-root user
- IAM roles com permissões mínimas

---

## Matriz de Rastreabilidade

| Ameaça | Requisito(s) | Status | Owner |
|--------|--------------|--------|-------|
| SQL Injection | REQ-INPUT-001, REQ-ACCESS-001 | Implementado | Dev Team |
| XSS | REQ-INPUT-002 | Em desenvolvimento | Dev Team |
| MitM | REQ-DATA-001 | Implementado | Infrastructure |
| Data Exposure | REQ-DATA-002 | Implementado | Infrastructure |
| DoS | REQ-AVAIL-001, REQ-AVAIL-002 | Planejado | Infrastructure |
| Session Hijacking | REQ-SESS-001, REQ-SESS-002 | Implementado | Dev Team |
| Fake Account | REQ-AUTH-001, REQ-AUTH-002 | Planejado | Dev Team |
| Repudiation | REQ-LOG-001, REQ-LOG-002 | Implementado | Ops Team |

EOF

cat security_requirements.md
```

---

### 📊 TAREFA 4: Criar Requisitos para Suas Ameaças

Template para derivar requisitos:

```
REQUISITO: [Nome descritivo]
├─ Derivado de: [Ameaça específica]
├─ Categoria STRIDE: [S/T/R/I/D/E]
├─ Descrição: Sistema DEVE/DEVE NOT [ação específica]
├─ Prioridade: [Critical/High/Medium/Low]
├─ Critérios de Aceitação:
│  - [Critério 1]
│  - [Critério 2]
│  - [Critério 3]
└─ Owner: [Time responsável]
```

---

## 🔄 PARTE 6: INTEGRAÇÃO NO SDLC (5 minutos)

### 📝 EXERCÍCIO 6.1: Quando Fazer Threat Modeling?

```bash
cat > threat_modeling_sdlc.md << 'EOF'
# Threat Modeling no SDLC

## Quando Aplicar Threat Modeling?

### 1. Fase de Requisitos (OBRIGATÓRIO)
**Timing:** Início do projeto, antes de arquitetura
**Objetivo:** Identificar requisitos de segurança
**Saída:** Lista de requisitos derivados de ameaças
**Esforço:** 2-4 horas
**Participantes:** Product Owner, Arquiteto, Security Champion

### 2. Fase de Design (OBRIGATÓRIO)
**Timing:** Após definição de arquitetura, antes de implementação
**Objetivo:** Validar arquitetura contra ameaças conhecidas
**Saída:** DFD completo, lista de ameaças priorizadas
**Esforço:** 4-8 horas
**Participantes:** Arquiteto, Tech Lead, Security Engineer, DBA

### 3. Durante Implementação (OPCIONAL)
**Timing:** Quando decisões de design mudam
**Objetivo:** Validar mudanças arquiteturais
**Saída:** Ameaças adicionais identificadas
**Esforço:** 1-2 horas
**Participantes:** Tech Lead, Developer, Security Champion

### 4. Pré-Release (RECOMENDADO)
**Timing:** 2-4 semanas antes do lançamento
**Objetivo:** Revisão final de segurança
**Saída:** Checklist de validação
**Esforço:** 2-3 horas
**Participantes:** Security Team, Product Manager

### 5. Pós-Incidente (OBRIGATÓRIO)
**Timing:** Após qualquer incidente de segurança
**Objetivo:** Entender como ameaça não foi identificada
**Saída:** Modelo atualizado, lições aprendidas
**Esforço:** 2-4 horas
**Participantes:** Incident Response, Security, Engineering

### 6. Manutenção (ANUAL)
**Timing:** Revisão anual ou a cada major release
**Objetivo:** Atualizar modelo com novas ameaças/tecnologias
**Saída:** Modelo atualizado
**Esforço:** 2-3 horas
**Participantes:** Security Champion, Tech Lead

---

## Gatilhos para Revisar Threat Model

Revisar modelo quando:
- ✅ Nova integração com sistema externo
- ✅ Mudança de tecnologia (novo framework, cloud provider)
- ✅ Novas funcionalidades sensíveis (pagamentos, dados pessoais)
- ✅ Mudança de arquitetura (monolito → microserviços)
- ✅ Compliance nova (PCI-DSS, LGPD, GDPR)
- ✅ Nova superfície de ataque (API pública, app móvel)

---

## Template de Reunião de Threat Modeling

### Pré-reunião (1 semana antes)
- [ ] Enviar materiais de referência (STRIDE, exemplos)
- [ ] Compartilhar diagrama preliminar (se disponível)
- [ ] Agendar 3-4 horas bloqueadas

### Durante a reunião
- [ ] 0-15min: Introdução e contexto
- [ ] 15-45min: Criar/revisar DFD
- [ ] 45-120min: Identificar ameaças (STRIDE)
- [ ] 120-150min: Priorizar ameaças (DREAD)
- [ ] 150-180min: Definir mitigações e requisitos
- [ ] 180-210min: Atribuir responsáveis e prazos

### Pós-reunião
- [ ] Documentar modelo no Threat Dragon
- [ ] Criar tickets/issues para cada mitigação
- [ ] Compartilhar report com stakeholders
- [ ] Agendar review em 3 meses

EOF

cat threat_modeling_sdlc.md
```

---

## 📋 ENTREGÁVEIS DO LABORATÓRIO

### 1. Relatório de Threat Modeling

```markdown
# Relatório - Threat Modeling: E-commerce Application

**Projeto:** E-commerce Application
**Data:** [Data]
**Modelador:** [Seu Nome]
**Participantes:** [Lista de participantes]
**Revisado por:** [Security Team]

---

## 1. Executive Summary

### Escopo
Sistema de e-commerce com funcionalidades:
- Catálogo de produtos
- Carrinho de compras
- Checkout e pagamento
- Gestão de pedidos
- Reviews de produtos

### Principais Descobertas
- **Total de ameaças identificadas:** _____
- **Ameaças CRÍTICAS (DREAD > 8.0):** _____
- **Ameaças ALTAS (DREAD 5.0-7.9):** _____
- **Requisitos de segurança derivados:** _____

### Recomendações Principais
1. [Recomendação 1]
2. [Recomendação 2]
3. [Recomendação 3]

---

## 2. Diagrama de Fluxo de Dados (DFD)

[Inserir imagem exportada do Threat Dragon]

### Componentes Modelados
- **External Entities:** Customer, Payment Processor
- **Processes:** Web App, Payment Gateway, Order Service
- **Data Stores:** Product DB, Order DB, User DB
- **Data Flows:** [Lista de fluxos principais]
- **Trust Boundaries:** Internet | DMZ | Internal Network

---

## 3. Ameaças Identificadas

### Resumo por Categoria STRIDE

| Categoria | Quantidade | % do Total |
|-----------|------------|------------|
| Spoofing | _____ | ____% |
| Tampering | _____ | ____% |
| Repudiation | _____ | ____% |
| Information Disclosure | _____ | ____% |
| Denial of Service | _____ | ____% |
| Elevation of Privilege | _____ | ____% |
| **TOTAL** | **_____** | **100%** |

---

## 4. Top 10 Ameaças Priorizadas (DREAD)

### Ameaça #1: [Nome]
**DREAD Score:** 9.4 (CRÍTICO)
**Componente Afetado:** Web App
**Categoria STRIDE:** Tampering, Information Disclosure, Elevation of Privilege
**Descrição:** [Descrição detalhada]
**Cenário de Ataque:** [Como atacante exploraria]
**Impacto:** [Consequências se explorado]
**Mitigação:**
- [Controle 1]
- [Controle 2]
**Status:** Open
**Owner:** Development Team
**Prazo:** Antes do lançamento

[Repetir para top 10 ameaças]

---

## 5. Requisitos de Segurança Derivados

Total de requisitos: _____

### Por Categoria

| Categoria | Requisitos | Status |
|-----------|-----------|--------|
| Autenticação | _____ | [Implementado/Planejado] |
| Criptografia | _____ | [Implementado/Planejado] |
| Validação de Input | _____ | [Implementado/Planejado] |
| Controle de Acesso | _____ | [Implementado/Planejado] |
| Logging | _____ | [Implementado/Planejado] |
| Disponibilidade | _____ | [Implementado/Planejado] |

### Requisitos Críticos (Must-Have)

[Lista de requisitos críticos que DEVEM ser implementados antes do lançamento]

---

## 6. Matriz de Rastreabilidade

| Ameaça ID | Ameaça | DREAD | Requisito(s) | Controle(s) | Status | Owner |
|-----------|--------|-------|--------------|-------------|--------|-------|
| T-001 | SQL Injection | 9.4 | REQ-001, REQ-002 | Prepared Statements, WAF | Done | Dev |
| T-002 | XSS | 8.2 | REQ-003 | Output Encoding, CSP | In Progress | Dev |
| ... | ... | ... | ... | ... | ... | ... |

---

## 7. Plano de Ação

### Antes do Lançamento (P0 - Bloqueante)
- [ ] [Ação 1] - Owner: [Nome] - Prazo: [Data]
- [ ] [Ação 2] - Owner: [Nome] - Prazo: [Data]

### Sprint Atual (P1 - Alta)
- [ ] [Ação 1]
- [ ] [Ação 2]

### Backlog (P2 - Média)
- [ ] [Ação 1]
- [ ] [Ação 2]

### Aceito como Risco (P3 - Baixa)
- [ ] [Risco 1] - Justificativa: [Razão]

---

## 8. Suposições e Limitações

### Suposições
- Sistema operará em AWS com segurança padrão da plataforma
- Payment gateway (Stripe) possui certificações PCI-DSS
- Usuários acessarão via browsers modernos (últimas 2 versões)

### Limitações do Modelo
- Não modelamos infraestrutura detalhada (Kubernetes, load balancers)
- Third-party services foram tratados como black box
- Mobile app será modelado separadamente

### Out of Scope
- Ameaças físicas ao datacenter
- Social engineering contra funcionários
- Supply chain attacks em dependências

---

## 9. Próximos Passos

1. **Imediato (esta semana):**
   - Criar tickets para ameaças P0
   - Review com Security Team

2. **Curto Prazo (este mês):**
   - Implementar controles críticos
   - Validação de correções

3. **Médio Prazo (este trimestre):**
   - Revisar modelo após mudanças arquiteturais
   - Training de STRIDE para time

4. **Longo Prazo (anual):**
   - Review anual completo
   - Atualizar com novas ameaças (OWASP Top 10, etc.)

---

## 10. Referências

- OWASP Threat Dragon Model: [link/arquivo]
- Diagramas: [pasta/repositório]
- Requisitos de Segurança: [documento]
- Tracking de Mitigações: [Jira board/GitHub issues]

---

## Aprovações

| Role | Nome | Assinatura | Data |
|------|------|------------|------|
| Security Architect | [Nome] | | |
| Engineering Lead | [Nome] | | |
| Product Owner | [Nome] | | |

```

---

### 2. Arquivos Exportados do Threat Dragon

**Salvar modelo:**
1. File → Save
2. Exportar como JSON: `ecommerce-threat-model.json`
3. Exportar diagrama: Screenshot ou PDF

**Incluir nos entregáveis:**
- ✅ Arquivo JSON do Threat Dragon
- ✅ PDF/PNG do DFD
- ✅ Lista de ameaças (export para CSV)
- ✅ Relatório completo em Markdown/PDF
- ✅ Planilha de priorização DREAD
- ✅ Documento de requisitos de segurança

---

## 🎯 CHECKLIST DE VERIFICAÇÃO

### Fundamentos ✅
- [ ] Instalei OWASP Threat Dragon
- [ ] Entendi elementos de DFD (Entities, Process, Data Store, Data Flow)
- [ ] Compreendi STRIDE (6 categorias de ameaças)
- [ ] Entendi DREAD (priorização de ameaças)
- [ ] Li materiais de referência (STRIDE_Reference.md)

### Modelagem no Threat Dragon ✅
- [ ] Criei novo Threat Model
- [ ] Adicionei pelo menos 5 elementos ao DFD
- [ ] Desenhei Trust Boundaries
- [ ] Conectei elementos com Data Flows
- [ ] Apliquei STRIDE a cada elemento
- [ ] Adicionei pelo menos 10 ameaças
- [ ] Categorizei cada ameaça (S/T/R/I/D/E)

### Priorização ✅
- [ ] Calculei DREAD score para pelo menos 5 ameaças
- [ ] Ordenei ameaças por score
- [ ] Identifiquei ameaças críticas (DREAD > 8.0)
- [ ] Justifiquei score de cada ameaça

### Requisitos de Segurança ✅
- [ ] Derivei pelo menos 5 requisitos de segurança
- [ ] Requisitos são específicos e testáveis
- [ ] Atribuí owner para cada requisito
- [ ] Criei matriz de rastreabilidade (Ameaça → Requisito)

### Documentação ✅
- [ ] Exportei modelo do Threat Dragon (JSON)
- [ ] Exportei diagrama DFD (imagem/PDF)
- [ ] Criei relatório completo
- [ ] Documentei top 10 ameaças
- [ ] Criei plano de ação com prazos

### Integração SDLC ✅
- [ ] Entendi quando fazer Threat Modeling
- [ ] Identifiquei gatilhos para revisar modelo
- [ ] Planejei review periódico (anual/trimestral)

---

## 📚 RECURSOS ADICIONAIS

### Documentação Oficial
- **OWASP Threat Dragon:** https://owasp.org/www-project-threat-dragon/
- **OWASP Threat Modeling:** https://owasp.org/www-community/Threat_Modeling
- **Threat Modeling Manifesto:** https://www.threatmodelingmanifesto.org/

### Metodologias
- **STRIDE:** https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
- **PASTA:** https://owasp.org/www-pdf-archive/AppSecEU2012_PASTA.pdf
- **LINDDUN:** https://linddun.org/ (Privacy threat modeling)
- **OCTAVE:** https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=51546

### Ferramentas
- **OWASP Threat Dragon:** https://www.threatdragon.com/
- **Microsoft Threat Modeling Tool:** https://aka.ms/threatmodelingtool
- **IriusRisk:** https://www.iriusrisk.com/
- **Threagile:** https://threagile.io/
- **PyTM:** https://github.com/izar/pytm (Python threat modeling)

### Livros e Guias
- **Threat Modeling: Designing for Security** - Adam Shostack
- **Threat Modeling Process** - OWASP
- **Microsoft SDL Threat Modeling** - Microsoft Security

### Templates e Exemplos
- **OWASP TM Examples:** https://github.com/OWASP/threat-dragon/tree/main/td.vue/public/example-models
- **Threat Dragon Schemas:** https://github.com/OWASP/threat-dragon/tree/main/td.vue/src/service/threats

---

## 💡 DICAS E TROUBLESHOOTING

### Problemas Comuns

**Threat Dragon não abre:**
```bash
# Linux AppImage precisa de permissões
chmod +x threat-dragon-*.AppImage

# Se falhar, tentar versão web
docker run -p 8080:3000 threatdragon/owasp-threat-dragon:latest
```

**DFD muito complexo:**
```
Solução: Dividir em múltiplos diagramas
- Diagrama de contexto (alto nível)
- Diagramas de componentes (detalhados)
- Um DFD por fluxo de negócio principal
```

**Muitas ameaças identificadas (overwhelming):**
```
Solução: Priorização rigorosa
1. Focar apenas em DREAD > 7.0 inicialmente
2. Agrupar ameaças similares
3. Aceitar riscos baixos (< 4.0) documentando justificativa
4. Distribuir correções ao longo de sprints
```

**Time resistente a Threat Modeling:**
```
Solução: Começar pequeno
1. Primeira sessão: 1 hora, 1 componente crítico
2. Mostrar valor: quantas vulnerabilidades encontradas
3. Demonstrar custo/benefício: encontrar bug no design vs produção
4. Gamificar: "quem encontra mais ameaças?"
```

**Falta de conhecimento de segurança:**
```
Solução: Usar checklists e exemplos
1. Usar STRIDE_Reference.md como guia
2. Consultar exemplos do OWASP
3. Convidar Security Champion para facilitar
4. Training de 1h antes da sessão
```

---

## 🏆 DESAFIOS EXTRAS

### Desafio 1: Threat Modeling de Sistema Real
Modele uma aplicação real que você conhece:
- Seu projeto atual
- Sistema open source conhecido (WordPress, GitLab)
- Infraestrutura da sua empresa

Entregas:
- DFD completo
- 20+ ameaças identificadas
- Requisitos de segurança

---

### Desafio 2: Comparação de Metodologias
Compare STRIDE com PASTA ou LINDDUN:
- Modele a mesma aplicação com 2 metodologias
- Compare ameaças encontradas
- Qual metodologia é melhor para qual contexto?

---

### Desafio 3: Automatização
Crie script para:
- Gerar relatório automaticamente do JSON do Threat Dragon
- Extrair ameaças e criar issues no GitHub/Jira
- Dashboard de métricas (total de ameaças, por STRIDE, por DREAD)

Exemplo:
```python
import json

with open('threat-model.json') as f:
    model = json.load(f)

# Extrair ameaças
threats = []
for diagram in model['detail']['diagrams']:
    for cell in diagram['cells']:
        if 'threats' in cell:
            threats.extend(cell['threats'])

# Agrupar por STRIDE
by_stride = {}
for threat in threats:
    category = threat.get('type', 'Unknown')
    by_stride[category] = by_stride.get(category, 0) + 1

print(f"Total de ameaças: {len(threats)}")
for category, count in by_stride.items():
    print(f"{category}: {count}")
```

---

### Desafio 4: Threat Model Review
Organize sessão de revisão por pares:
- Trocar modelos com colega
- Revisar modelo do outro
- Encontrar ameaças que foram perdidas
- Feedback construtivo

---

## 📊 MÉTRICAS DE SUCESSO

Ao final do laboratório, você deve ser capaz de:

- ✅ Criar DFD completo em < 30 minutos
- ✅ Identificar 15+ ameaças usando STRIDE
- ✅ Calcular DREAD score corretamente
- ✅ Derivar requisitos de segurança específicos e testáveis
- ✅ Documentar modelo completo para aprovação
- ✅ Defender decisões de priorização
- ✅ Integrar Threat Modeling no processo de desenvolvimento

**Benchmark de Ameaças Identificadas:**
- **Iniciante:** 5-10 ameaças
- **Intermediário:** 10-20 ameaças
- **Avançado:** 20+ ameaças com justificativas detalhadas

**Economia de Custos:**
- Corrigir no design: **$1** (1x custo)
- Corrigir no código: **$10** (10x custo)
- Corrigir em produção: **$100+** (100x+ custo)

**ROI de Threat Modeling:**
- Tempo investido: 4-8 horas
- Vulnerabilidades evitadas: 5-15
- Custo evitado: $5,000 - $50,000+
- **ROI: 10x - 100x**

---

**FIM DO LABORATÓRIO**

Este material foi desenvolvido para o Módulo 2 - "Design Seguro e Modelagem de Ameaças" do curso de Pós-Graduação em Cibersegurança Defensiva.

Professor: Fernando Silva - Engenheiro de Segurança de Aplicações

⏱️ **Tempo Total:** 1 hora (podendo estender com desafios extras)
