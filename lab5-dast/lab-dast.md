# Laboratório Prático: DAST - Dynamic Application Security Testing
## Módulo 5 - Teste Automatizado em Aplicações Web

---

## 🎯 OBJETIVOS DO LABORATÓRIO

Ao final deste laboratório, você será capaz de:

1. ✅ Executar varreduras DAST usando OWASP ZAP em diferentes modos
2. ✅ Interpretar relatórios de segurança e priorizar vulnerabilidades
3. ✅ Realizar scans de headers de segurança com Nikto
4. ✅ Integrar DAST em pipelines CI/CD
5. ✅ Comparar resultados SAST vs DAST
6. ✅ Validar correções de vulnerabilidades em runtime

**Duração:** 1 hora  
**Nível:** Intermediário  
**Pré-requisitos:** Docker instalado, conhecimento básico de HTTP/APIs

---

## 📚 PARTE 1: CONFIGURAÇÃO DO AMBIENTE (15 minutos)

### 🛠️ Instalação das Ferramentas

#### Opção 1: OWASP ZAP via Docker (Recomendado)

```bash
# Pull da imagem oficial do ZAP
docker pull ghcr.io/zaproxy/zaproxy:stable

# Verificar instalação
docker run --rm ghcr.io/zaproxy/zaproxy:stable zap.sh -version

# Criar alias para facilitar uso
alias zap-cli='docker run --rm -v $(pwd):/zap/wrk/:rw ghcr.io/zaproxy/zaproxy:stable'
```

#### Opção 2: OWASP ZAP Desktop (Interface Gráfica)

```bash
# Linux
wget https://github.com/zaproxy/zaproxy/releases/download/v2.14.0/ZAP_2.14.0_Linux.tar.gz
tar -xvf ZAP_2.14.0_Linux.tar.gz
cd ZAP_2.14.0
./zap.sh

# macOS
brew install --cask owasp-zap

# Windows
# Baixar instalador de: https://www.zaproxy.org/download/
```

#### Instalação do Nikto

```bash
# Linux/Mac
git clone https://github.com/sullo/nikto.git
cd nikto/program
chmod +x nikto.pl

# Verificar instalação
./nikto.pl -Version

# Ubuntu/Debian
sudo apt-get install nikto

# macOS
brew install nikto
```

---

### 🎯 Aplicações Vulneráveis para Teste

#### Opção 1: OWASP Juice Shop (Recomendado)

```bash
# Subir Juice Shop com Docker
docker run -d -p 3000:3000 bkimminich/juice-shop

# Verificar se está rodando
curl http://localhost:3000

# Acessar no browser: http://localhost:3000
```

#### Opção 2: DVWA (Damn Vulnerable Web Application)

```bash
# Subir DVWA com Docker
docker run -d -p 80:80 vulnerables/web-dvwa

# Acessar: http://localhost
# Credenciais padrão: admin/password
```

#### Opção 3: WebGoat

```bash
# Subir WebGoat
docker run -d -p 8080:8080 -p 9090:9090 webgoat/webgoat

# Acessar: http://localhost:8080/WebGoat
```

---

## 🔍 PARTE 2: OWASP ZAP - BASELINE SCAN (20 minutos)

### 📝 EXERCÍCIO 2.1: ZAP Baseline Scan Básico

O **Baseline Scan** é um scan passivo rápido (~5 minutos) ideal para CI/CD.

```bash
# Executar baseline scan no Juice Shop
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t http://host.docker.internal:3000 \
  -r baseline-report.html \
  -l PASS

# Flags importantes:
# -t: Target URL
# -r: Report filename
# -l: Minimum level to show (PASS, IGNORE, INFO, WARN, FAIL)
```

**⚠️ Nota:** No Linux, use `--network=host` e `-t http://localhost:3000`

```bash
# Linux
docker run --rm --network=host -v $(pwd):/zap/wrk/:rw -t \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://localhost:3000 -r baseline-report.html
```

---

### 📊 TAREFA 1: Analisar Relatório Baseline

Abra o arquivo `baseline-report.html` no navegador.

**Estrutura do Relatório:**
```
ZAP Scanning Report
├── Summary
│   ├── Risk Level Distribution
│   └── Alert Type Distribution
├── Alerts (ordenado por severidade)
│   ├── High
│   ├── Medium
│   ├── Low
│   └── Informational
└── Appendix
    └── Alert Types
```

**Questões para Análise:**

1. **Quantos alertas de cada severidade foram encontrados?**
   - High: ___
   - Medium: ___
   - Low: ___
   - Informational: ___

2. **Quais são os 3 alertas mais críticos?**
   - Alerta 1: ______________________
   - Alerta 2: ______________________
   - Alerta 3: ______________________

3. **Algum alerta está relacionado ao OWASP Top 10?**
   - [ ] A01 - Broken Access Control
   - [ ] A02 - Cryptographic Failures
   - [ ] A03 - Injection
   - [ ] A05 - Security Misconfiguration
   - [ ] A07 - Identification and Authentication Failures

---

### 📝 EXERCÍCIO 2.2: ZAP Baseline com Configurações Avançadas

```bash
# Scan com todas as regras habilitadas
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t http://host.docker.internal:3000 \
  -r baseline-full-report.html \
  -l PASS \
  -j  # Gera também relatório JSON

# Scan com configuração customizada
cat > zap-config.conf << 'EOF'
# Regras para desabilitar
10202 # Absence of Anti-CSRF Tokens (se app não usa CSRF tokens)
10038 # Content Security Policy (CSP) Header Not Set (se intencional)
EOF

docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t http://host.docker.internal:3000 \
  -r baseline-custom-report.html \
  -c zap-config.conf

# Scan focado em OWASP Top 10
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t http://host.docker.internal:3000 \
  -r baseline-owasp-report.html \
  --autooff \
  -a  # Incluir alertas do add-on OWASP Top 10
```

---

## 🎯 PARTE 3: OWASP ZAP - FULL SCAN (20 minutos)

### 📝 EXERCÍCIO 3.1: ZAP Full Scan com Spider

O **Full Scan** é um scan ativo completo que pode levar horas.

```bash
# Full scan com spider automático
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -r full-scan-report.html \
  -m 5  # Máximo de 5 minutos (para fins de laboratório)

# Full scan com autenticação (se necessário)
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -r full-scan-auth-report.html \
  -U admin  # Username
  -m 10
```

---

### 🔐 EXERCÍCIO 3.2: ZAP com Autenticação (Juice Shop)

Para testar áreas autenticadas, precisamos configurar autenticação no ZAP.

#### Passo 1: Criar script de autenticação

Crie `juice-auth-script.js`:

```javascript
// juice-auth-script.js
// Script de autenticação para Juice Shop

function authenticate(helper, paramsValues, credentials) {
    var loginUrl = paramsValues.get("loginUrl");
    var email = credentials.getParam("email");
    var password = credentials.getParam("password");
    
    var postData = JSON.stringify({
        email: email,
        password: password
    });
    
    var msg = helper.prepareMessage();
    msg.setRequestHeader("Content-Type: application/json");
    msg.setRequestBody(postData);
    msg.getRequestHeader().setURI(new org.apache.commons.httpclient.URI(loginUrl, true));
    msg.getRequestHeader().setMethod("POST");
    
    helper.sendAndReceive(msg);
    
    return msg;
}

function getRequiredParamsNames() {
    return ["loginUrl"];
}

function getOptionalParamsNames() {
    return [];
}

function getCredentialsParamsNames() {
    return ["email", "password"];
}
```

#### Passo 2: Executar scan autenticado

```bash
# Criar usuário no Juice Shop primeiro
# Email: test@juice-sh.op
# Password: Test123!

# Executar scan com contexto de autenticação
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -r authenticated-scan-report.html \
  -J juice-auth-script.js \
  -z "-config api.addrs.addr.name=.* -config api.addrs.addr.regex=true"
```

---

### 📊 TAREFA 2: Comparar Baseline vs Full Scan

| Métrica | Baseline Scan | Full Scan |
|---------|---------------|-----------|
| Tempo de execução | _______ | _______ |
| Total de alertas | _______ | _______ |
| Alertas High | _______ | _______ |
| Alertas Medium | _______ | _______ |
| URLs testadas | _______ | _______ |

**Questões:**
1. O Full Scan encontrou vulnerabilidades que o Baseline não encontrou?
2. Quais tipos de vulnerabilidades só aparecem em scans ativos?
3. Vale a pena o tempo extra do Full Scan?

---

## 🔍 PARTE 4: ANÁLISE DE HEADERS DE SEGURANÇA COM NIKTO (15 minutos)

### 📝 EXERCÍCIO 4.1: Scan Básico com Nikto

```bash
# Scan básico
nikto -h http://localhost:3000

# Scan com output em arquivo
nikto -h http://localhost:3000 -o nikto-results.txt

# Scan com output HTML
nikto -h http://localhost:3000 -Format html -o nikto-results.html

# Scan focado em headers de segurança
nikto -h http://localhost:3000 -Tuning 2

# Tuning options:
# 0 - File Upload
# 1 - Interesting File / Seen in logs
# 2 - Misconfiguration / Default File
# 3 - Information Disclosure
# 4 - Injection (XSS/Script/HTML)
# 5 - Remote File Retrieval - Inside Web Root
# 6 - Denial of Service
# 7 - Remote File Retrieval - Server Wide
# 8 - Command Execution / Remote Shell
# 9 - SQL Injection
# a - Authentication Bypass
# b - Software Identification
# c - Remote Source Inclusion
# x - Reverse Tuning Options (exclude)
```

---

### 📊 TAREFA 3: Analisar Headers de Segurança

O Nikto vai reportar headers ausentes ou mal configurados:

**Checklist de Headers de Segurança:**

```
Security Headers Analysis
├── ✅ Presente e Correto
├── ⚠️  Presente mas Mal Configurado
└── ❌ Ausente

Headers para verificar:
□ X-Frame-Options
□ X-Content-Type-Options
□ Strict-Transport-Security (HSTS)
□ Content-Security-Policy (CSP)
□ X-XSS-Protection
□ Referrer-Policy
□ Permissions-Policy
□ Cross-Origin-Embedder-Policy (COEP)
□ Cross-Origin-Opener-Policy (COOP)
□ Cross-Origin-Resource-Policy (CORP)
```

**Exemplo de Análise:**

```
❌ AUSENTE: Strict-Transport-Security
   Risco: Ataques man-in-the-middle via downgrade HTTP
   Correção: Adicionar header HSTS
   
   Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

❌ AUSENTE: Content-Security-Policy
   Risco: Cross-Site Scripting (XSS)
   Correção: Implementar CSP restritiva
   
   Content-Security-Policy: default-src 'self'; script-src 'self'; 
                            style-src 'self' 'unsafe-inline'
```

---

### 📝 EXERCÍCIO 4.2: Validar Correções de Headers

Vamos criar uma aplicação com headers corretos e comparar.

Crie `secure-app.js`:

```javascript
// secure-app.js - Aplicação com headers de segurança corretos
const express = require('express');
const helmet = require('helmet');

const app = express();

// Helmet adiciona vários headers de segurança automaticamente
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  noSniff: true,
  frameguard: { action: 'deny' },
  xssFilter: true,
}));

app.get('/', (req, res) => {
  res.send('<h1>Aplicação Segura</h1>');
});

app.listen(4000, () => {
  console.log('Secure app rodando na porta 4000');
});
```

**Criar package.json:**

```json
{
  "name": "secure-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "helmet": "^7.1.0"
  }
}
```

**Executar:**

```bash
npm install
node secure-app.js

# Em outro terminal, scan com Nikto
nikto -h http://localhost:4000 -o secure-app-nikto.txt

# Comparar com scan anterior
diff nikto-results.txt secure-app-nikto.txt
```

---

## 🚀 PARTE 5: TESTES DE VULNERABILIDADES ESPECÍFICAS (15 minutos)

### 📝 EXERCÍCIO 5.1: Testar SQL Injection com ZAP

```bash
# Scan focado em SQL Injection
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -r sqli-scan-report.html \
  -m 5 \
  --scanners sqli  # Apenas SQL Injection scanner
```

**Validação Manual:**

```bash
# Testar SQL Injection manualmente no Juice Shop
# URL: http://localhost:3000/rest/products/search?q=

# Payload normal
curl "http://localhost:3000/rest/products/search?q=apple"

# Payload malicioso (SQLi)
curl "http://localhost:3000/rest/products/search?q=apple')) OR 1=1--"

# Validar se retorna todos os produtos (vulnerável)
```

---

### 📝 EXERCÍCIO 5.2: Testar XSS com ZAP

```bash
# Scan focado em XSS
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://host.docker.internal:3000 \
  -r xss-scan-report.html \
  -m 5 \
  --scanners xss  # Apenas XSS scanner
```

**Validação Manual:**

```bash
# Testar XSS refletido
curl "http://localhost:3000/search?q=<script>alert('XSS')</script>"

# Testar XSS stored (requer POST)
curl -X POST http://localhost:3000/api/feedbacks \
  -H "Content-Type: application/json" \
  -d '{"comment":"<script>alert(document.cookie)</script>","rating":5}'
```

---

### 📝 EXERCÍCIO 5.3: Testar CSRF

```bash
# Verificar se aplicação está protegida contra CSRF
curl -v http://localhost:3000 | grep -i "csrf"

# Tentar fazer request sem token CSRF
curl -X POST http://localhost:3000/api/user/change-password \
  -H "Content-Type: application/json" \
  -d '{"current":"old","new":"hacked"}'
```

---

## 🔄 PARTE 6: INTEGRAÇÃO CI/CD (BÔNUS)

### 📝 EXERCÍCIO 6.1: ZAP em GitHub Actions

Crie `.github/workflows/dast-scan.yml`:

```yaml
name: DAST Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Toda segunda-feira às 2h

jobs:
  zap-baseline:
    name: OWASP ZAP Baseline Scan
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Start application
        run: |
          docker-compose up -d
          sleep 30  # Aguardar app inicializar
      
      - name: ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.10.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'
          fail_action: true  # Falhar se encontrar High/Medium
      
      - name: Upload ZAP results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: zap-reports
          path: |
            report_html.html
            report_json.json
      
      - name: Stop application
        if: always()
        run: docker-compose down

  zap-full-scan:
    name: OWASP ZAP Full Scan (Weekly)
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Start application
        run: |
          docker-compose up -d
          sleep 30
      
      - name: ZAP Full Scan
        uses: zaproxy/action-full-scan@v0.8.0
        with:
          target: 'http://localhost:3000'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a -j -m 10'
      
      - name: Upload results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: zap-full-scan-reports
          path: |
            report_html.html
            report_json.json
            report_md.md

  nikto-scan:
    name: Nikto Security Scan
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Start application
        run: |
          docker-compose up -d
          sleep 30
      
      - name: Run Nikto
        run: |
          docker run --network host \
            securecodebox/scanner-nikto \
            nikto -h http://localhost:3000 -Format html -o /tmp/nikto-results.html
          
          # Copiar resultados
          docker cp $(docker ps -lq):/tmp/nikto-results.html ./nikto-results.html
      
      - name: Upload Nikto results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: nikto-report
          path: nikto-results.html

  security-gate:
    name: Security Quality Gate
    runs-on: ubuntu-latest
    needs: [zap-baseline, nikto-scan]
    
    steps:
      - name: Download ZAP results
        uses: actions/download-artifact@v3
        with:
          name: zap-reports
      
      - name: Parse ZAP results
        run: |
          # Contar vulnerabilidades High e Critical
          HIGH_COUNT=$(jq '[.site[].alerts[] | select(.riskcode == "3")] | length' report_json.json)
          CRITICAL_COUNT=$(jq '[.site[].alerts[] | select(.riskcode == "4")] | length' report_json.json)
          
          echo "High vulnerabilities: $HIGH_COUNT"
          echo "Critical vulnerabilities: $CRITICAL_COUNT"
          
          # Falhar se encontrar vulnerabilidades críticas
          if [ "$CRITICAL_COUNT" -gt 0 ]; then
            echo "❌ Found $CRITICAL_COUNT critical vulnerabilities!"
            exit 1
          fi
          
          # Warning se encontrar high
          if [ "$HIGH_COUNT" -gt 5 ]; then
            echo "⚠️  Found $HIGH_COUNT high vulnerabilities!"
            exit 1
          fi
          
          echo "✅ Security scan passed!"
```

**Criar arquivo de regras `.zap/rules.tsv`:**

```tsv
# ZAP Scanning Rules
# Format: Rule ID	IGNORE|WARN|FAIL

# Ignorar alertas informativos
10049	IGNORE	# Storable and Cacheable Content
10015	IGNORE	# Incomplete or No Cache-control

# Alertas que devem falhar o build
40012	FAIL	# Cross Site Scripting (Reflected)
40014	FAIL	# Cross Site Scripting (Persistent)
40018	FAIL	# SQL Injection
90019	FAIL	# Server Side Code Injection

# Warnings (não falham build mas aparecem no report)
10020	WARN	# X-Frame-Options Header Not Set
10021	WARN	# X-Content-Type-Options Header Missing
10035	WARN	# Strict-Transport-Security Header Not Set
```

---

### 📝 EXERCÍCIO 6.2: ZAP em GitLab CI

Crie `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - security-scan
  - deploy

variables:
  APP_URL: "http://localhost:3000"
  ZAP_VERSION: "stable"

# Build da aplicação
build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
  only:
    - main
    - develop

# DAST com ZAP Baseline
zap-baseline:
  stage: security-scan
  image: ghcr.io/zaproxy/zaproxy:${ZAP_VERSION}
  services:
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: app
  script:
    - sleep 30  # Aguardar app inicializar
    - |
      zap-baseline.py \
        -t http://app:3000 \
        -r baseline-report.html \
        -J baseline-report.json \
        -l PASS
  artifacts:
    when: always
    paths:
      - baseline-report.html
      - baseline-report.json
    reports:
      junit: baseline-report.xml
  allow_failure: false

# DAST com ZAP Full Scan (apenas em schedule)
zap-full-scan:
  stage: security-scan
  image: ghcr.io/zaproxy/zaproxy:${ZAP_VERSION}
  services:
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: app
  script:
    - sleep 30
    - |
      zap-full-scan.py \
        -t http://app:3000 \
        -r full-scan-report.html \
        -J full-scan-report.json \
        -m 10 \
        -a
  artifacts:
    when: always
    paths:
      - full-scan-report.html
      - full-scan-report.json
  only:
    - schedules
  allow_failure: true

# Nikto Scan
nikto-scan:
  stage: security-scan
  image: securecodebox/scanner-nikto
  services:
    - name: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
      alias: app
  script:
    - sleep 30
    - nikto -h http://app:3000 -Format html -o nikto-report.html
  artifacts:
    when: always
    paths:
      - nikto-report.html
  allow_failure: true

# Security Quality Gate
security-gate:
  stage: security-scan
  image: alpine:latest
  dependencies:
    - zap-baseline
  before_script:
    - apk add --no-cache jq
  script:
    - |
      # Analisar resultados JSON do ZAP
      HIGH=$(jq '[.site[].alerts[] | select(.riskcode == "3")] | length' baseline-report.json)
      CRITICAL=$(jq '[.site[].alerts[] | select(.riskcode == "4")] | length' baseline-report.json)
      
      echo "📊 Security Scan Results:"
      echo "   Critical: $CRITICAL"
      echo "   High: $HIGH"
      
      # Falhar se encontrar vulnerabilidades críticas
      if [ "$CRITICAL" -gt 0 ]; then
        echo "❌ FAILED: Found $CRITICAL critical vulnerabilities"
        exit 1
      fi
      
      # Warning se muitas high
      if [ "$HIGH" -gt 10 ]; then
        echo "⚠️  WARNING: Found $HIGH high vulnerabilities"
        exit 1
      fi
      
      echo "✅ PASSED: Security scan approved"
  allow_failure: false
```

---

## 📊 PARTE 7: COMPARAÇÃO SAST VS DAST (10 minutos)

### 📝 EXERCÍCIO 7.1: Análise Comparativa

Vamos criar uma aplicação com vulnerabilidades conhecidas e comparar:

Crie `vulnerable-app.py`:

```python
# vulnerable-app.py
from flask import Flask, request, render_template_string
import sqlite3

app = Flask(__name__)

# VULNERABILIDADE #1: SQL Injection (SAST detecta, DAST detecta)
@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
    cursor.execute(query)  # SQL Injection aqui!
    
    return "Logged in" if cursor.fetchone() else "Failed"

# VULNERABILIDADE #2: XSS Refletido (DAST detecta melhor)
@app.route('/search')
def search():
    query = request.args.get('q', '')
    return render_template_string(f"<h1>Resultados: {query}</h1>")  # XSS!

# VULNERABILIDADE #3: Credenciais Hardcoded (SAST detecta, DAST não)
DB_PASSWORD = "admin123"  # SAST vai pegar, DAST não consegue ver código

# VULNERABILIDADE #4: Debug Mode (DAST detecta, SAST pode não)
app.config['DEBUG'] = True  # DAST verá stack traces, SAST pode avisar

# VULNERABILIDADE #5: Falta de Rate Limiting (DAST detecta, SAST não)
@app.route('/api/data')
def api():
    # Sem rate limiting - DAST pode testar fazendo múltiplas requests
    return {"data": "sensitive"}

# VULNERABILIDADE #6: Headers Inseguros (DAST detecta, SAST não)
# Faltam: X-Frame-Options, CSP, HSTS - DAST vai reportar

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

**Executar SAST (Semgrep):**

```bash
# Instalar Semgrep
pip install semgrep --break-system-packages

# Scan SAST
semgrep --config=auto vulnerable-app.py > sast-results.txt
```

**Executar DAST (ZAP):**

```bash
# Subir aplicação
python vulnerable-app.py &

# Aguardar inicializar
sleep 5

# Scan DAST
docker run --rm --network=host -v $(pwd):/zap/wrk/:rw -t \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://localhost:5000 -r dast-results.html
```

---

### 📊 TAREFA 4: Preencher Tabela Comparativa

| Vulnerabilidade | SAST Detecta? | DAST Detecta? | Observações |
|-----------------|---------------|---------------|-------------|
| SQL Injection | ✅ Sim | ✅ Sim | Ambos detectam |
| XSS Refletido | ⚠️  Parcial | ✅ Sim | DAST mais efetivo |
| Credenciais Hardcoded | ✅ Sim | ❌ Não | SAST-only |
| Debug Mode | ⚠️  Avisa | ✅ Sim | DAST vê stack traces |
| Rate Limiting | ❌ Não | ✅ Sim | DAST testa comportamento |
| Headers Inseguros | ❌ Não | ✅ Sim | DAST-only |
| Lógica de Negócio | ❌ Não | ⚠️  Parcial | Requer teste manual |
| Path Traversal | ✅ Sim | ✅ Sim | Ambos detectam |

**Conclusões:**

1. **SAST é melhor para:**
   - Detectar problemas no código-fonte
   - Encontrar credenciais hardcoded
   - Análise de fluxo de dados
   - Feedback rápido para desenvolvedores

2. **DAST é melhor para:**
   - Testar aplicação completa em runtime
   - Detectar problemas de configuração
   - Validar headers de segurança
   - Testar integração entre componentes

3. **Abordagem Ideal:**
   - **SAST no CI/CD:** Feedback rápido durante desenvolvimento
   - **DAST no CI/CD:** Validação antes de deploy
   - **DAST em Produção:** Monitoramento contínuo (regression testing)

---

## 📋 ENTREGÁVEIS DO LABORATÓRIO

### 1. Relatório de Análise DAST

```markdown
# Relatório - Dynamic Application Security Testing

**Aluno:** [Nome]
**Data:** [Data]
**Aplicação Testada:** [OWASP Juice Shop / DVWA / Outra]

## 1. ZAP Baseline Scan

### Resumo de Resultados
- **Tempo de scan:** _____ minutos
- **URLs testadas:** _____ URLs
- **Total de alertas:** _____
  - High: _____
  - Medium: _____
  - Low: _____
  - Informational: _____

### Top 5 Vulnerabilidades Encontradas

1. **[Nome da Vulnerabilidade]**
   - Severidade: [High/Medium/Low]
   - OWASP: [A0X:2021]
   - Descrição: [Breve descrição]
   - URL Afetada: [URL]
   - Recomendação: [Como corrigir]

2. [Repetir para as 5 vulnerabilidades mais críticas]

## 2. Nikto Scan - Headers de Segurança

### Headers Ausentes
- [ ] Strict-Transport-Security (HSTS)
- [ ] Content-Security-Policy (CSP)
- [ ] X-Frame-Options
- [ ] X-Content-Type-Options
- [ ] Referrer-Policy

### Correções Recomendadas
```
[Listar headers recomendados e valores]
```

## 3. Comparação SAST vs DAST

### Vulnerabilidades Únicas do DAST
- [Lista de vulnerabilidades que só DAST encontrou]

### Vantagens Observadas do DAST
- [Lista de vantagens práticas observadas]

### Limitações Observadas do DAST
- [Lista de limitações encontradas]

## 4. Integração CI/CD

### Pipeline Implementado
- [ ] GitHub Actions
- [ ] GitLab CI
- [ ] Outro: _______

### Configurações Aplicadas
```yaml
[Cole trecho relevante do workflow/pipeline]
```

### Testes de Validação
- Build passou/falhou com vulnerabilidades: _______
- Tempo médio de scan na pipeline: _______

## 5. Conclusões e Lições Aprendidas

[Escreva suas conclusões sobre DAST, quando usar, limitações, etc.]
```

---

### 2. Evidências Práticas

Incluir nos entregáveis:

- ✅ Screenshot do relatório HTML do ZAP Baseline
- ✅ Screenshot do relatório HTML do ZAP Full Scan
- ✅ Arquivo JSON com resultados completos do ZAP
- ✅ Resultados do Nikto em formato HTML
- ✅ Arquivo de configuração do pipeline CI/CD
- ✅ Screenshot do pipeline executando
- ✅ Tabela comparativa SAST vs DAST preenchida

---

## 🎯 CHECKLIST DE VERIFICAÇÃO

### OWASP ZAP ✅
- [ ] Executei ZAP Baseline Scan com sucesso
- [ ] Executei ZAP Full Scan com sucesso
- [ ] Analisei relatórios HTML gerados
- [ ] Identifiquei vulnerabilidades High/Critical
- [ ] Testei configuração customizada do ZAP
- [ ] Executei scan com autenticação (se aplicável)

### Nikto ✅
- [ ] Executei Nikto contra aplicação vulnerável
- [ ] Identifiquei headers de segurança ausentes
- [ ] Criei aplicação com headers corretos
- [ ] Validei correções com novo scan
- [ ] Documentei todos os headers recomendados

### Comparação SAST vs DAST ✅
- [ ] Executei SAST (Semgrep) no código vulnerável
- [ ] Executei DAST (ZAP) na mesma aplicação
- [ ] Preenchi tabela comparativa
- [ ] Identifiquei vantagens de cada abordagem
- [ ] Documentei casos de uso para cada ferramenta

### Integração CI/CD ✅
- [ ] Criei pipeline funcional (GitHub/GitLab)
- [ ] Pipeline executa ZAP automaticamente
- [ ] Pipeline falha quando encontra vulnerabilidades
- [ ] Artefatos são salvos corretamente
- [ ] Testei pelo menos 1 build completo

---

## 📚 RECURSOS ADICIONAIS

### Documentação Oficial
- **OWASP ZAP:** https://www.zaproxy.org/docs/
- **ZAP API:** https://www.zaproxy.org/docs/api/
- **Nikto:** https://github.com/sullo/nikto
- **OWASP Testing Guide:** https://owasp.org/www-project-web-security-testing-guide/

### Scripts e Automação
- **ZAP Docker:** https://www.zaproxy.org/docs/docker/
- **ZAP GitHub Actions:** https://github.com/marketplace/actions/owasp-zap-baseline-scan
- **ZAP Automation Framework:** https://www.zaproxy.org/docs/automate/

### Aplicações para Prática
- **OWASP Juice Shop:** https://owasp.org/www-project-juice-shop/
- **DVWA:** https://github.com/digininja/DVWA
- **WebGoat:** https://github.com/WebGoat/WebGoat
- **OWASP NodeGoat:** https://github.com/OWASP/NodeGoat

### Headers de Segurança
- **Security Headers:** https://securityheaders.com/
- **Mozilla Observatory:** https://observatory.mozilla.org/
- **OWASP Secure Headers:** https://owasp.org/www-project-secure-headers/

---

## 💡 DICAS E TROUBLESHOOTING

### Problemas Comuns

**ZAP demora muito tempo:**
```bash
# Limitar tempo de scan
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://example.com -m 5  # Máximo 5 minutos

# Usar baseline ao invés de full scan em CI/CD
```

**ZAP não consegue acessar localhost:**
```bash
# Linux: usar --network=host
docker run --rm --network=host -v $(pwd):/zap/wrk/:rw -t \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://localhost:3000

# Mac/Windows: usar host.docker.internal
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://host.docker.internal:3000
```

**Nikto retorna muitos falsos positivos:**
```bash
# Focar apenas em headers e misconfigurations
nikto -h http://localhost:3000 -Tuning 2,3

# Ignorar testes específicos
nikto -h http://localhost:3000 -Tuning x 6  # Excluir DoS tests
```

**Pipeline CI/CD falha por timeout:**
```yaml
# Aumentar timeout no GitHub Actions
- name: ZAP Scan
  timeout-minutes: 15  # Aumentar de 5 para 15 minutos
```

**Muitas vulnerabilidades detectadas (overwhelming):**
```bash
# Filtrar apenas High e Critical
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://localhost:3000 -l WARN  # Apenas WARN e FAIL
```

---

## 🏆 DESAFIOS EXTRAS

### Desafio 1: ZAP API Scan
Configure e execute um scan focado em APIs REST usando OpenAPI/Swagger spec.

```bash
# Gerar OpenAPI spec da sua API
# Depois executar ZAP API scan
docker run --rm -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py -t http://localhost:3000/api \
  -f openapi -d api-spec.yaml \
  -r api-scan-report.html
```

### Desafio 2: Scan Autenticado Completo
Configure autenticação completa no ZAP para testar todas as áreas privadas da aplicação.

Passos:
1. Configurar context de autenticação
2. Criar usuário de teste
3. Executar spider autenticado
4. Executar active scan autenticado
5. Comparar resultados com scan não-autenticado

### Desafio 3: DAST em Produção
Configure scanning contínuo em ambiente de produção com:
- Scans agendados (diários/semanais)
- Notificações de novas vulnerabilidades
- Dashboard de métricas de segurança
- Tracking de correções

### Desafio 4: Custom ZAP Scripts
Crie scripts customizados para ZAP detectar vulnerabilidades específicas da sua aplicação.

Exemplo: Detectar tokens JWT fracos, validar lógica de negócio específica, testar rate limiting customizado.

---

## 📊 MÉTRICAS DE SUCESSO

Ao final do laboratório, você deve ser capaz de:

- ✅ Executar scans DAST automatizados em < 10 minutos
- ✅ Identificar e priorizar vulnerabilidades por severidade
- ✅ Diferenciar quando usar SAST vs DAST
- ✅ Integrar DAST em pipeline CI/CD funcional
- ✅ Validar correções de vulnerabilidades
- ✅ Gerar relatórios profissionais de segurança
- ✅ Configurar headers de segurança adequados

**Benchmark de Performance:**
- Baseline Scan: ~5 minutos
- Full Scan: ~30-60 minutos
- Nikto Scan: ~2 minutos
- Pipeline CI/CD: ~10 minutos total

---

**FIM DO LABORATÓRIO**

Este material foi desenvolvido para o Módulo 5 - "DAST - Dynamic Application Security Testing" do curso de Pós-Graduação em Cibersegurança Defensiva.

Professor: Fernando Silva - Engenheiro de Segurança de Aplicações

⏱️ **Tempo Total:** 1 hora (podendo estender com desafios extras)
