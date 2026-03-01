# Laboratório Prático: SCA - Software Composition Analysis
## Módulo 4 - Gerenciando Dependências Vulneráveis

---

## 🎯 OBJETIVOS DO LABORATÓRIO

Ao final deste laboratório, você será capaz de:

1. ✅ Identificar vulnerabilidades em dependências usando OWASP Dependency Check
2. ✅ Analisar e interpretar CVEs com CVSS scores
3. ✅ Gerar e compreender SBOM (Software Bill of Materials)
4. ✅ Utilizar Dependency Track para monitoramento contínuo
5. ✅ Implementar políticas de segurança para dependências
6. ✅ Integrar SCA em pipelines CI/CD
7. ✅ Comparar diferentes ferramentas de SCA

**Duração:** 1 hora  
**Nível:** Intermediário  
**Pré-requisitos:** Docker, Java/Node.js/Python instalado

---

## 📚 PARTE 1: CONFIGURAÇÃO DO AMBIENTE (10 minutos)

### 🛠️ Instalação das Ferramentas

#### Opção 1: OWASP Dependency Check (CLI)

```bash
# Download da versão mais recente
VERSION=9.0.9
wget https://github.com/jeremylong/DependencyCheck/releases/download/v${VERSION}/dependency-check-${VERSION}-release.zip

# Extrair
unzip dependency-check-${VERSION}-release.zip
cd dependency-check/bin

# Tornar executável (Linux/Mac)
chmod +x dependency-check.sh

# Verificar instalação
./dependency-check.sh --version

# Criar alias para facilitar uso
alias dependency-check='~/dependency-check/bin/dependency-check.sh'
```

#### Opção 2: OWASP Dependency Check (Docker)

```bash
# Pull da imagem oficial
docker pull owasp/dependency-check:latest

# Verificar instalação
docker run --rm owasp/dependency-check:latest --version

# Criar alias
alias dependency-check='docker run --rm -v $(pwd):/src -v ~/.m2:/root/.m2 owasp/dependency-check:latest --scan /src'
```

---

#### OWASP Dependency Track (Servidor)

```bash
# Subir Dependency Track com Docker Compose
cat > docker-compose-dtrack.yml << 'EOF'
version: '3.8'

services:
  dtrack-apiserver:
    image: dependencytrack/apiserver:latest
    environment:
      - ALPINE_DATABASE_MODE=external
      - ALPINE_DATABASE_URL=jdbc:postgresql://postgres:5432/dtrack
      - ALPINE_DATABASE_DRIVER=org.postgresql.Driver
      - ALPINE_DATABASE_USERNAME=dtrack
      - ALPINE_DATABASE_PASSWORD=dtrack
    ports:
      - "8081:8080"
    depends_on:
      - postgres
    volumes:
      - dtrack-data:/data
    restart: unless-stopped

  dtrack-frontend:
    image: dependencytrack/frontend:latest
    ports:
      - "8080:8080"
    environment:
      - API_BASE_URL=http://localhost:8081
    depends_on:
      - dtrack-apiserver
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=dtrack
      - POSTGRES_USER=dtrack
      - POSTGRES_PASSWORD=dtrack
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  dtrack-data:
  postgres-data:
EOF

# Iniciar Dependency Track
docker-compose -f docker-compose-dtrack.yml up -d

# Aguardar inicialização (pode levar ~2 minutos)
echo "Aguardando Dependency Track inicializar..."
sleep 120

# Acessar: http://localhost:8080
# Credenciais padrão: admin / admin
echo "✅ Dependency Track disponível em: http://localhost:8080"
echo "   Usuário: admin"
echo "   Senha: admin1"
```

---

### 📦 Projetos de Exemplo para Análise

#### Projeto 1: Aplicação Node.js Vulnerável

```bash
# Criar diretório do projeto
mkdir vulnerable-node-app
cd vulnerable-node-app

# Criar package.json com dependências desatualizadas
cat > package.json << 'EOF'
{
  "name": "vulnerable-node-app",
  "version": "1.0.0",
  "description": "Aplicação Node.js com dependências vulneráveis",
  "main": "index.js",
  "dependencies": {
    "express": "4.16.0",
    "lodash": "4.17.4",
    "mongoose": "5.0.0",
    "request": "2.88.0",
    "moment": "2.19.3",
    "jquery": "3.3.1",
    "axios": "0.18.0",
    "debug": "2.6.8",
    "ws": "7.4.5",
    "node-forge": "0.10.0"
  },
  "devDependencies": {
    "webpack": "4.28.0",
    "serialize-javascript": "2.1.0"
  }
}
EOF

# Criar aplicação simples
cat > index.js << 'EOF'
const express = require('express');
const lodash = require('lodash');
const mongoose = require('mongoose');
const request = require('request');

const app = express();

app.get('/', (req, res) => {
  res.send('Aplicação com dependências vulneráveis');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
EOF

# Instalar dependências
npm install
```

---

#### Projeto 2: Aplicação Python Vulnerável

```bash
# Criar diretório do projeto
mkdir vulnerable-python-app
cd vulnerable-python-app

# Criar requirements.txt com versões antigas
cat > requirements.txt << 'EOF'
Flask==0.12.2
Django==1.11.0
requests==2.6.0
Jinja2==2.7.3
cryptography==2.3
paramiko==2.0.0
PyYAML==3.12
Pillow==5.2.0
urllib3==1.24.1
lxml==4.2.5
SQLAlchemy==1.2.0
Werkzeug==0.14.1
EOF

# Criar aplicação simples
cat > app.py << 'EOF'
from flask import Flask, request, render_template_string
import requests
import yaml

app = Flask(__name__)

@app.route('/')
def index():
    return "Aplicação Python com dependências vulneráveis"

if __name__ == '__main__':
    app.run(debug=True)
EOF

# Criar ambiente virtual e instalar
python3 -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate
pip install -r requirements.txt
```

---

#### Projeto 3: Aplicação Java Vulnerável

```bash
# Criar diretório do projeto
mkdir vulnerable-java-app
cd vulnerable-java-app

# Criar pom.xml com dependências antigas
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>vulnerable-java-app</artifactId>
    <version>1.0.0</version>
    
    <dependencies>
        <!-- Spring Framework (vulnerável) -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
            <version>4.3.0.RELEASE</version>
        </dependency>
        
        <!-- Log4j (vulnerável ao Log4Shell) -->
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-core</artifactId>
            <version>2.14.1</version>
        </dependency>
        
        <!-- Apache Struts (múltiplas CVEs) -->
        <dependency>
            <groupId>org.apache.struts</groupId>
            <artifactId>struts2-core</artifactId>
            <version>2.3.20</version>
        </dependency>
        
        <!-- Jackson Databind (vulnerável) -->
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.9.8</version>
        </dependency>
        
        <!-- Commons Collections (deserialização insegura) -->
        <dependency>
            <groupId>commons-collections</groupId>
            <artifactId>commons-collections</artifactId>
            <version>3.2.1</version>
        </dependency>
        
        <!-- Apache Commons FileUpload -->
        <dependency>
            <groupId>commons-fileupload</groupId>
            <artifactId>commons-fileupload</artifactId>
            <version>1.3.1</version>
        </dependency>
    </dependencies>
</project>
EOF

echo "✅ Projetos de exemplo criados!"
```

---

## 🔍 PARTE 2: DEPENDENCY CHECK - ANÁLISE BÁSICA (15 minutos)

### 📝 EXERCÍCIO 2.1: Scan de Projeto Node.js

```bash
cd vulnerable-node-app

# Scan com Dependency Check (CLI)
dependency-check.sh \
  --project "Vulnerable Node App" \
  --scan . \
  --format HTML \
  --format JSON \
  --out ./reports

# OU com Docker
docker run --rm \
  -v $(pwd):/src \
  -v $(pwd)/reports:/report \
  owasp/dependency-check:latest \
  --scan /src \
  --format HTML \
  --format JSON \
  --format XML \
  --project "Vulnerable Node App" \
  --out /report

# Aguardar conclusão do scan (pode levar 2-5 minutos na primeira vez)
```

**Estrutura do Relatório Gerado:**

```
reports/
├── dependency-check-report.html  # Relatório visual completo
├── dependency-check-report.json  # Dados estruturados
└── dependency-check-report.xml   # Formato XML para CI/CD
```

---

### 📊 TAREFA 1: Analisar Relatório HTML

Abra `reports/dependency-check-report.html` no navegador.

**Seções do Relatório:**

1. **Summary**
   - Total de dependências analisadas
   - Distribuição de severidade (Critical/High/Medium/Low)
   - Dependências com CVEs conhecidos

2. **Dependency Details**
   - Lista de cada dependência
   - CVEs associados
   - CVSS scores
   - CPE (Common Platform Enumeration)

3. **Vulnerabilities**
   - Detalhes de cada CVE
   - Descrição da vulnerabilidade
   - Links para NVD (National Vulnerability Database)
   - Versões afetadas e corrigidas

---

### 📋 QUESTÕES PARA ANÁLISE:

**1. Quantas dependências foram analisadas?**
   - Total: _______
   - Com vulnerabilidades: _______
   - Sem vulnerabilidades: _______

**2. Distribuição de Severidade:**
   - Critical: _______
   - High: _______
   - Medium: _______
   - Low: _______

**3. Top 5 CVEs Mais Críticos:**

| CVE ID | CVSS Score | Severidade | Dependência | Descrição |
|--------|------------|------------|-------------|-----------|
| CVE-XXXX-XXXXX | 9.8 | Critical | express | [Descrição] |
| | | | | |
| | | | | |
| | | | | |
| | | | | |

**4. Dependências Mais Problemáticas:**

Liste as 3 dependências com mais CVEs:
1. _______________________ (_____ CVEs)
2. _______________________ (_____ CVEs)
3. _______________________ (_____ CVEs)

---

### 🔧 EXERCÍCIO 2.2: Entendendo CVSS Score

**CVSS (Common Vulnerability Scoring System) v3.1**

Exemplo de análise detalhada de um CVE:

```
CVE-2021-44228 (Log4Shell)
├── CVSS Base Score: 10.0 (CRITICAL)
├── Vector: CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H
├── Componentes:
│   ├── AV:N - Attack Vector: Network (Remoto)
│   ├── AC:L - Attack Complexity: Low (Fácil de explorar)
│   ├── PR:N - Privileges Required: None (Sem autenticação)
│   ├── UI:N - User Interaction: None (Automático)
│   ├── S:C  - Scope: Changed (Afeta outros componentes)
│   ├── C:H  - Confidentiality: High (Vazamento de dados)
│   ├── I:H  - Integrity: High (Modificação de dados)
│   └── A:H  - Availability: High (Negação de serviço)
├── Exploit Available: YES
└── Patch Available: YES (Upgrade to 2.17.0+)
```

**TAREFA:** Selecione um CVE Critical do seu relatório e preencha:

```
CVE-____-______
├── CVSS Base Score: ____
├── Vector: ________________________
├── Exploitabilidade:
│   ├── Fácil de explorar? [Sim/Não]
│   ├── Requer autenticação? [Sim/Não]
│   └── Exploit público disponível? [Sim/Não]
├── Impacto:
│   ├── Confidencialidade: [High/Medium/Low/None]
│   ├── Integridade: [High/Medium/Low/None]
│   └── Disponibilidade: [High/Medium/Low/None]
└── Correção:
    ├── Patch disponível? [Sim/Não]
    └── Versão corrigida: ___________
```

---

### 📝 EXERCÍCIO 2.3: Scan de Projeto Python

```bash
cd ../vulnerable-python-app

# Ativar ambiente virtual
source venv/bin/activate  # Windows: venv\Scripts\activate

# Scan com Dependency Check
docker run --rm \
  -v $(pwd):/src \
  -v $(pwd)/reports:/report \
  owasp/dependency-check:latest \
  --scan /src \
  --format HTML \
  --format JSON \
  --project "Vulnerable Python App" \
  --enableExperimental \
  --out /report

# Desativar ambiente virtual
deactivate
```

**Nota:** Python requer `--enableExperimental` para análise de requirements.txt

---

### 📝 EXERCÍCIO 2.4: Scan de Projeto Java

```bash
cd ../vulnerable-java-app

# Scan com Dependency Check
docker run --rm \
  -v $(pwd):/src \
  -v $(pwd)/reports:/report \
  -v ~/.m2:/root/.m2 \
  owasp/dependency-check:latest \
  --scan /src \
  --format HTML \
  --format JSON \
  --project "Vulnerable Java App" \
  --out /report

# Para projetos Maven, você também pode usar:
# mvn org.owasp:dependency-check-maven:check
```

---

## 🎯 PARTE 3: SBOM - SOFTWARE BILL OF MATERIALS (10 minutos)

### 📝 EXERCÍCIO 3.1: Gerar SBOM em Formato CycloneDX

```bash
cd vulnerable-node-app

# Gerar SBOM usando CycloneDX
npm install -g @cyclonedx/cyclonedx-npm

# Gerar SBOM
cyclonedx-npm --output-file sbom.json

# Visualizar SBOM
cat sbom.json | jq '.'

# Informações no SBOM:
# - Lista completa de componentes
# - Versões exatas
# - Licenças
# - Hashes (checksums)
# - Dependências transitivas
```

**Exemplo de SBOM (CycloneDX):**

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "version": 1,
  "metadata": {
    "component": {
      "type": "application",
      "name": "vulnerable-node-app",
      "version": "1.0.0"
    }
  },
  "components": [
    {
      "type": "library",
      "name": "express",
      "version": "4.16.0",
      "purl": "pkg:npm/express@4.16.0",
      "licenses": [
        {
          "license": {
            "id": "MIT"
          }
        }
      ]
    }
  ],
  "dependencies": [
    {
      "ref": "pkg:npm/express@4.16.0",
      "dependsOn": [
        "pkg:npm/accepts@1.3.5",
        "pkg:npm/body-parser@1.18.3"
      ]
    }
  ]
}
```

---

### 📝 EXERCÍCIO 3.2: Importar SBOM no Dependency Track

```bash
# Gerar API Key no Dependency Track
# 1. Acessar http://localhost:8080
# 2. Login: admin / admin1
# 3. Administration → Access Management → Teams
# 4. Selecionar "Automation" → API Keys → Generate

# Definir API Key (substitua com a sua)
export DTRACK_API_KEY="your-api-key-here"

# Criar projeto no Dependency Track
curl -X PUT http://localhost:8081/api/v1/project \
  -H "X-Api-Key: ${DTRACK_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Vulnerable Node App",
    "version": "1.0.0",
    "description": "Aplicação Node.js para demonstração de SCA"
  }'

# Upload SBOM para Dependency Track
curl -X PUT http://localhost:8081/api/v1/bom \
  -H "X-Api-Key: ${DTRACK_API_KEY}" \
  -H "Content-Type: multipart/form-data" \
  -F "project=Vulnerable Node App" \
  -F "bom=@sbom.json"

# Aguardar processamento (30 segundos)
sleep 30

echo "✅ SBOM importado! Acesse http://localhost:8080 para visualizar"
```

---

### 📊 TAREFA 2: Explorar Dependency Track Dashboard

Acesse http://localhost:8080 e explore:

**1. Dashboard Principal:**
   - Projetos ativos
   - Vulnerabilidades por severidade
   - Métricas de risco
   - Tendências ao longo do tempo

**2. Detalhes do Projeto:**
   - Lista de componentes
   - Vulnerabilidades identificadas
   - Score de risco do projeto
   - Dependências transitivas (árvore)

**3. Vulnerability Details:**
   - CVE completo
   - CVSS score detalhado
   - CWE (Common Weakness Enumeration)
   - Referências externas
   - Versões afetadas vs corrigidas

**4. Policy Violations:**
   - Licenças não permitidas
   - Componentes banidos
   - Vulnerabilidades acima do threshold

---

## 🔧 PARTE 4: CORREÇÃO DE VULNERABILIDADES (10 minutos)

### 📝 EXERCÍCIO 4.1: Atualizar Dependências Node.js

```bash
cd vulnerable-node-app

# Verificar versões desatualizadas
npm outdated

# Criar package.json atualizado
cat > package-updated.json << 'EOF'
{
  "name": "vulnerable-node-app",
  "version": "2.0.0",
  "description": "Aplicação Node.js com dependências atualizadas",
  "main": "index.js",
  "dependencies": {
    "express": "^4.18.2",
    "lodash": "^4.17.21",
    "mongoose": "^7.6.3",
    "axios": "^1.6.0",
    "moment": "^2.29.4",
    "ws": "^8.14.2"
  },
  "devDependencies": {
    "webpack": "^5.89.0"
  }
}
EOF

# Backup do package.json original
cp package.json package-vulnerable.json

# Usar versão atualizada
cp package-updated.json package.json

# Limpar e reinstalar
rm -rf node_modules package-lock.json
npm install

# Executar novo scan
docker run --rm \
  -v $(pwd):/src \
  -v $(pwd)/reports-fixed:/report \
  owasp/dependency-check:latest \
  --scan /src \
  --format HTML \
  --format JSON \
  --project "Vulnerable Node App - Fixed" \
  --out /report
```

---

### 📊 TAREFA 3: Comparar Antes vs Depois

| Métrica | Antes (Vulnerável) | Depois (Corrigido) | Melhoria |
|---------|-------------------|-------------------|----------|
| Total de CVEs | _______ | _______ | -____% |
| CVEs Critical | _______ | _______ | -____% |
| CVEs High | _______ | _______ | -____% |
| CVEs Medium | _______ | _______ | -____% |
| CVEs Low | _______ | _______ | -____% |
| Dependências vulneráveis | _______ | _______ | -____% |

**Observações:**
- Alguma vulnerabilidade não tem correção disponível?
- Quais dependências ainda precisam de atenção?
- Alguma breaking change nas atualizações?

---

### 📝 EXERCÍCIO 4.2: Atualizar Dependências Python

```bash
cd ../vulnerable-python-app

# Ativar ambiente virtual
source venv/bin/activate

# Verificar versões desatualizadas
pip list --outdated

# Criar requirements.txt atualizado
cat > requirements-updated.txt << 'EOF'
Flask==3.0.0
Django==4.2.7
requests==2.31.0
Jinja2==3.1.2
cryptography==41.0.5
paramiko==3.3.1
PyYAML==6.0.1
Pillow==10.1.0
urllib3==2.1.0
lxml==4.9.3
SQLAlchemy==2.0.23
Werkzeug==3.0.1
EOF

# Backup do requirements.txt original
cp requirements.txt requirements-vulnerable.txt

# Usar versão atualizada
cp requirements-updated.txt requirements.txt

# Reinstalar
pip install -r requirements.txt --upgrade

# Gerar SBOM atualizado
pip install cyclonedx-bom
cyclonedx-py -r -i requirements.txt -o sbom-fixed.json

# Desativar ambiente virtual
deactivate

# Scan atualizado
docker run --rm \
  -v $(pwd):/src \
  -v $(pwd)/reports-fixed:/report \
  owasp/dependency-check:latest \
  --scan /src \
  --format HTML \
  --format JSON \
  --project "Vulnerable Python App - Fixed" \
  --enableExperimental \
  --out /report
```

---

## 🚀 PARTE 5: POLÍTICAS DE SEGURANÇA (10 minutos)

### 📝 EXERCÍCIO 5.1: Criar Políticas no Dependency Track

Acesse Dependency Track → Policy Management → Create Policy

**Política 1: Bloquear CVEs Críticos**

```json
{
  "name": "Block Critical CVEs",
  "violationState": "FAIL",
  "conditions": [
    {
      "subject": "SEVERITY",
      "operator": "IS",
      "value": "CRITICAL"
    }
  ]
}
```

**Política 2: Alertar sobre Licenças GPL**

```json
{
  "name": "Warn GPL Licenses",
  "violationState": "WARN",
  "conditions": [
    {
      "subject": "LICENSE",
      "operator": "MATCHES",
      "value": "GPL.*"
    }
  ]
}
```

**Política 3: Bloquear Componentes EOL (End of Life)**

```json
{
  "name": "Block EOL Components",
  "violationState": "FAIL",
  "conditions": [
    {
      "subject": "VERSION",
      "operator": "IS_LESS_THAN",
      "value": "LATEST_VERSION"
    },
    {
      "subject": "AGE",
      "operator": "IS_GREATER_THAN",
      "value": "730"
    }
  ]
}
```

---

### 📝 EXERCÍCIO 5.2: Criar Política de Supressão

Nem todas as vulnerabilidades são aplicáveis ao seu contexto.

**Exemplo de Supressão:**

```xml
<!-- dependency-suppression.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <!-- Suprimir CVE específico se não aplicável -->
    <suppress>
        <notes>
            CVE-2021-44228 (Log4Shell) não é aplicável pois não usamos JNDI lookups
        </notes>
        <packageUrl regex="true">^pkg:maven/org\.apache\.logging\.log4j/log4j\-core@.*$</packageUrl>
        <cve>CVE-2021-44228</cve>
    </suppress>
    
    <!-- Suprimir vulnerabilidades em ambiente de desenvolvimento -->
    <suppress>
        <notes>
            Webpack usado apenas em desenvolvimento, não em produção
        </notes>
        <packageUrl regex="true">^pkg:npm/webpack@.*$</packageUrl>
        <cvssBelow>7.0</cvssBelow>
    </suppress>
    
    <!-- Suprimir falso positivo -->
    <suppress>
        <notes>
            Falso positivo confirmado - nossa versão não é vulnerável
        </notes>
        <gav regex="true">^commons-collections:commons-collections:.*$</gav>
        <cpe>cpe:/a:apache:commons_collections</cpe>
    </suppress>
</suppressions>
```

**Usar arquivo de supressão:**

```bash
docker run --rm \
  -v $(pwd):/src \
  -v $(pwd)/reports:/report \
  owasp/dependency-check:latest \
  --scan /src \
  --format HTML \
  --project "App with Suppressions" \
  --suppression /src/dependency-suppression.xml \
  --out /report
```

---

## 🔄 PARTE 6: INTEGRAÇÃO CI/CD (10 minutos)

### 📝 EXERCÍCIO 6.1: GitHub Actions Workflow

Crie `.github/workflows/sca-scan.yml`:

```yaml
name: SCA - Dependency Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Toda segunda-feira às 2h

jobs:
  dependency-check:
    name: OWASP Dependency Check
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run Dependency Check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: ${{ github.repository }}
          path: '.'
          format: 'HTML'
          args: >
            --enableRetired
            --enableExperimental
            --failOnCVSS 7
            --suppression dependency-suppression.xml
      
      - name: Upload Dependency Check results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: dependency-check-report
          path: reports/
      
      - name: Parse results and fail on critical
        if: always()
        run: |
          # Contar vulnerabilidades críticas
          CRITICAL=$(grep -o "Critical" reports/dependency-check-report.html | wc -l)
          HIGH=$(grep -o "High" reports/dependency-check-report.html | wc -l)
          
          echo "Critical vulnerabilities: $CRITICAL"
          echo "High vulnerabilities: $HIGH"
          
          if [ $CRITICAL -gt 0 ]; then
            echo "❌ Found $CRITICAL critical vulnerabilities!"
            exit 1
          fi
          
          if [ $HIGH -gt 10 ]; then
            echo "⚠️  Found $HIGH high vulnerabilities (threshold: 10)"
            exit 1
          fi
          
          echo "✅ Dependency check passed"

  dependency-track:
    name: Upload SBOM to Dependency Track
    runs-on: ubuntu-latest
    needs: dependency-check
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Generate SBOM
        run: |
          npm install -g @cyclonedx/cyclonedx-npm
          cyclonedx-npm --output-file sbom.json
      
      - name: Upload to Dependency Track
        uses: DependencyTrack/gh-upload-sbom@v1
        with:
          serverhostname: 'dependencytrack.company.com'
          apikey: ${{ secrets.DTRACK_API_KEY }}
          project: ${{ github.repository }}
          bomfilename: 'sbom.json'

  npm-audit:
    name: NPM Audit (Node.js projects)
    runs-on: ubuntu-latest
    if: hashFiles('package.json') != ''
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run npm audit
        run: |
          npm audit --audit-level=high --json > npm-audit.json || true
          
          # Gerar relatório legível
          npm audit --audit-level=high
      
      - name: Upload npm audit results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: npm-audit-report
          path: npm-audit.json

  pip-audit:
    name: Pip Audit (Python projects)
    runs-on: ubuntu-latest
    if: hashFiles('requirements.txt') != ''
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install pip-audit
        run: pip install pip-audit
      
      - name: Run pip audit
        run: |
          pip-audit -r requirements.txt --format json > pip-audit.json || true
          pip-audit -r requirements.txt
      
      - name: Upload pip audit results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: pip-audit-report
          path: pip-audit.json

  security-gate:
    name: Security Quality Gate
    runs-on: ubuntu-latest
    needs: [dependency-check, npm-audit, pip-audit]
    if: always()
    
    steps:
      - name: Download all artifacts
        uses: actions/download-artifact@v3
      
      - name: Aggregate results
        run: |
          echo "📊 Security Scan Summary"
          echo "========================"
          
          # Analisar resultados do Dependency Check
          if [ -f dependency-check-report/dependency-check-report.json ]; then
            echo "Dependency Check: ✅ Completed"
          fi
          
          # Analisar NPM Audit
          if [ -f npm-audit-report/npm-audit.json ]; then
            CRITICAL=$(jq '.metadata.vulnerabilities.critical' npm-audit-report/npm-audit.json)
            HIGH=$(jq '.metadata.vulnerabilities.high' npm-audit-report/npm-audit.json)
            echo "NPM Audit: Critical=$CRITICAL, High=$HIGH"
          fi
          
          # Analisar Pip Audit
          if [ -f pip-audit-report/pip-audit.json ]; then
            echo "Pip Audit: ✅ Completed"
          fi
          
          echo "✅ Security gate check completed"
```

---

### 📝 EXERCÍCIO 6.2: GitLab CI Pipeline

Crie `.gitlab-ci.yml`:

```yaml
stages:
  - scan
  - report
  - deploy

variables:
  DEPENDENCY_CHECK_VERSION: "9.0.9"
  DTRACK_URL: "https://dependencytrack.company.com"

dependency-check:
  stage: scan
  image: owasp/dependency-check:latest
  script:
    - |
      /usr/share/dependency-check/bin/dependency-check.sh \
        --project "$CI_PROJECT_NAME" \
        --scan . \
        --format HTML \
        --format JSON \
        --format XML \
        --failOnCVSS 7 \
        --suppression dependency-suppression.xml \
        --out reports/
  artifacts:
    when: always
    paths:
      - reports/
    reports:
      junit: reports/dependency-check-junit.xml
  allow_failure: false

npm-audit:
  stage: scan
  image: node:18
  only:
    exists:
      - package.json
  script:
    - npm ci
    - npm audit --json > npm-audit.json || true
    - npm audit --audit-level=high
  artifacts:
    paths:
      - npm-audit.json
  allow_failure: true

pip-audit:
  stage: scan
  image: python:3.11
  only:
    exists:
      - requirements.txt
  before_script:
    - pip install pip-audit
  script:
    - pip-audit -r requirements.txt --format json > pip-audit.json || true
    - pip-audit -r requirements.txt
  artifacts:
    paths:
      - pip-audit.json
  allow_failure: true

generate-sbom:
  stage: scan
  image: node:18
  script:
    - npm install -g @cyclonedx/cyclonedx-npm
    - cyclonedx-npm --output-file sbom.json
  artifacts:
    paths:
      - sbom.json

upload-to-dtrack:
  stage: report
  image: curlimages/curl:latest
  needs:
    - generate-sbom
  script:
    - |
      curl -X PUT "${DTRACK_URL}/api/v1/bom" \
        -H "X-Api-Key: ${DTRACK_API_KEY}" \
        -H "Content-Type: multipart/form-data" \
        -F "project=${CI_PROJECT_NAME}" \
        -F "bom=@sbom.json"
  only:
    - main
    - develop

security-report:
  stage: report
  image: alpine:latest
  needs:
    - dependency-check
    - npm-audit
    - pip-audit
  before_script:
    - apk add --no-cache jq
  script:
    - |
      echo "# Security Scan Report" > security-report.md
      echo "" >> security-report.md
      echo "## Summary" >> security-report.md
      echo "" >> security-report.md
      
      # Dependency Check
      if [ -f reports/dependency-check-report.json ]; then
        TOTAL_DEPS=$(jq '.dependencies | length' reports/dependency-check-report.json)
        echo "- Total dependencies: $TOTAL_DEPS" >> security-report.md
      fi
      
      # NPM Audit
      if [ -f npm-audit.json ]; then
        CRITICAL=$(jq '.metadata.vulnerabilities.critical' npm-audit.json)
        HIGH=$(jq '.metadata.vulnerabilities.high' npm-audit.json)
        echo "- NPM Critical: $CRITICAL" >> security-report.md
        echo "- NPM High: $HIGH" >> security-report.md
      fi
      
      cat security-report.md
  artifacts:
    paths:
      - security-report.md
```

---

## 📊 PARTE 7: COMPARAÇÃO DE FERRAMENTAS SCA (5 minutos)

### 📝 EXERCÍCIO 7.1: Comparar Diferentes Ferramentas

Vamos executar múltiplas ferramentas SCA no mesmo projeto:

```bash
cd vulnerable-node-app

# 1. OWASP Dependency Check (já executado)

# 2. NPM Audit (nativo Node.js)
npm audit --json > npm-audit-results.json
npm audit

# 3. Snyk (criar conta grátis em snyk.io)
npm install -g snyk
snyk auth
snyk test --json > snyk-results.json
snyk test

# 4. Retire.js (focado em JavaScript)
npm install -g retire
retire --js --outputformat json --outputpath retire-results.json
retire --js

# 5. npm-check-updates (atualização de dependências)
npm install -g npm-check-updates
ncu --format json > ncu-results.json
ncu
```

---

### 📊 TAREFA 4: Tabela Comparativa de Ferramentas

| Ferramenta | Total CVEs | Critical | High | Falsos Positivos | Tempo | Facilidade |
|------------|-----------|----------|------|------------------|-------|------------|
| Dependency Check | _____ | _____ | _____ | _____ | _____ min | ⭐⭐⭐⭐ |
| NPM Audit | _____ | _____ | _____ | _____ | _____ min | ⭐⭐⭐⭐⭐ |
| Snyk | _____ | _____ | _____ | _____ | _____ min | ⭐⭐⭐⭐ |
| Retire.js | _____ | _____ | _____ | _____ | _____ min | ⭐⭐⭐ |

**Análise:**

**Vantagens de cada ferramenta:**

1. **OWASP Dependency Check:**
   - ✅ Suporta múltiplas linguagens
   - ✅ Base de dados NVD completa
   - ✅ Open source e gratuito
   - ❌ Mais lento
   - ❌ Alguns falsos positivos

2. **NPM Audit:**
   - ✅ Nativo do Node.js
   - ✅ Muito rápido
   - ✅ Integrado com npm
   - ❌ Apenas Node.js
   - ❌ Base de dados menor

3. **Snyk:**
   - ✅ Excelente UI/UX
   - ✅ Correções automáticas
   - ✅ Banco de dados proprietário maior
   - ❌ Requer conta (limitações no plano free)
   - ❌ Comercial

4. **Retire.js:**
   - ✅ Focado em JavaScript
   - ✅ Detecta bibliotecas EOL
   - ✅ Leve e rápido
   - ❌ Apenas JavaScript
   - ❌ Menos abrangente

---

## 📋 ENTREGÁVEIS DO LABORATÓRIO

### 1. Relatório de Análise SCA

```markdown
# Relatório - Software Composition Analysis

**Aluno:** [Nome]
**Data:** [Data]
**Projeto Analisado:** [Nome do projeto]

## 1. Análise Inicial - Código Vulnerável

### Resumo Executivo
- **Total de dependências:** _____
- **Dependências com vulnerabilidades:** _____
- **Total de CVEs:** _____
- **Distribuição de severidade:**
  - Critical: _____
  - High: _____
  - Medium: _____
  - Low: _____

### Top 5 CVEs Críticos

1. **CVE-XXXX-XXXXX**
   - Dependência: [nome]
   - CVSS Score: [score]
   - Descrição: [breve descrição]
   - Exploit disponível: [Sim/Não]
   - Correção: [versão]

[Repetir para 5 CVEs]

## 2. Análise CVSS Detalhada

[Preencher análise detalhada de 1 CVE conforme template fornecido]

## 3. SBOM Gerado

- **Formato:** CycloneDX / SPDX
- **Total de componentes:** _____
- **Dependências transitivas:** _____
- **Licenças identificadas:** [lista]

## 4. Correção de Vulnerabilidades

### Ações Tomadas
- [Lista de dependências atualizadas]
- [Breaking changes identificadas]
- [Dependências sem correção disponível]

### Resultados Após Correção

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| Total CVEs | ___ | ___ | ___% |
| Critical | ___ | ___ | ___% |
| High | ___ | ___ | ___% |

## 5. Políticas Implementadas

### Políticas Criadas
1. [Nome da política 1]
   - Condições: [descrição]
   - Ação: FAIL / WARN

2. [Nome da política 2]

### Supressões Aplicadas
- [CVE suprimido 1]: [Justificativa]
- [CVE suprimido 2]: [Justificativa]

## 6. Comparação de Ferramentas

[Preencher tabela comparativa]

### Conclusões
- Melhor ferramenta para CI/CD: _____
- Melhor para análise profunda: _____
- Recomendação final: _____

## 7. Integração CI/CD

### Pipeline Implementado
- [ ] GitHub Actions
- [ ] GitLab CI
- [ ] Outro: _______

### Testes Realizados
- Scan executou com sucesso: [Sim/Não]
- Build falhou corretamente com CVE crítico: [Sim/Não]
- Artefatos salvos: [Sim/Não]
- SBOM enviado para Dependency Track: [Sim/Não]

## 8. Lições Aprendidas

1. [Insight 1]
2. [Insight 2]
3. [Insight 3]

## 9. Recomendações para Produção

- [Recomendação 1]
- [Recomendação 2]
- [Recomendação 3]
```

---

### 2. Evidências Práticas

Incluir nos entregáveis:

- ✅ Relatório HTML do Dependency Check (antes)
- ✅ Relatório HTML do Dependency Check (depois)
- ✅ Arquivo SBOM em JSON (CycloneDX)
- ✅ Screenshot do Dependency Track com projeto importado
- ✅ Arquivo de supressão (dependency-suppression.xml)
- ✅ Workflow/Pipeline CI/CD (.github/workflows ou .gitlab-ci.yml)
- ✅ Screenshot de build executando
- ✅ Tabela comparativa de ferramentas preenchida

---

## 🎯 CHECKLIST DE VERIFICAÇÃO

### OWASP Dependency Check ✅
- [ ] Instalei Dependency Check (CLI ou Docker)
- [ ] Executei scan em projeto Node.js
- [ ] Executei scan em projeto Python
- [ ] Executei scan em projeto Java
- [ ] Analisei relatórios HTML gerados
- [ ] Identifiquei CVEs Critical e High
- [ ] Entendi CVSS score de pelo menos 3 CVEs

### SBOM ✅
- [ ] Gerei SBOM em formato CycloneDX
- [ ] Analisei estrutura do SBOM
- [ ] Identifiquei dependências transitivas
- [ ] Verifiquei licenças de dependências

### Dependency Track ✅
- [ ] Instalei Dependency Track via Docker Compose
- [ ] Criei projeto no Dependency Track
- [ ] Importei SBOM com sucesso
- [ ] Explorei dashboard e métricas
- [ ] Configurei pelo menos 1 política

### Correção de Vulnerabilidades ✅
- [ ] Atualizei dependências vulneráveis
- [ ] Executei novo scan após correções
- [ ] Comparei resultados antes/depois
- [ ] Documentei breaking changes

### Políticas e Supressões ✅
- [ ] Criei política de bloqueio de CVEs críticos
- [ ] Criei arquivo de supressão
- [ ] Justifiquei cada supressão
- [ ] Testei políticas funcionando

### Integração CI/CD ✅
- [ ] Criei pipeline funcional (GitHub/GitLab)
- [ ] Pipeline executa scan automaticamente
- [ ] Pipeline falha com CVEs críticos
- [ ] SBOM é enviado para Dependency Track
- [ ] Testei pelo menos 1 build completo

### Comparação de Ferramentas ✅
- [ ] Executei pelo menos 3 ferramentas diferentes
- [ ] Preenchi tabela comparativa
- [ ] Identifiquei vantagens de cada uma
- [ ] Defini recomendação para meu cenário

---

## 📚 RECURSOS ADICIONAIS

### Documentação Oficial
- **OWASP Dependency Check:** https://owasp.org/www-project-dependency-check/
- **Dependency Track:** https://docs.dependencytrack.org/
- **CycloneDX:** https://cyclonedx.org/
- **NVD - National Vulnerability Database:** https://nvd.nist.gov/

### Bases de Dados de Vulnerabilidades
- **GitHub Advisory Database:** https://github.com/advisories
- **NPM Security Advisories:** https://www.npmjs.com/advisories
- **PyPI Advisory Database:** https://github.com/pypa/advisory-database
- **RubySec:** https://rubysec.com/

### Ferramentas Complementares
- **Snyk:** https://snyk.io/
- **WhiteSource (Mend):** https://www.mend.io/
- **Sonatype Nexus Lifecycle:** https://www.sonatype.com/
- **JFrog Xray:** https://jfrog.com/xray/
- **npm-audit:** https://docs.npmjs.com/cli/v8/commands/npm-audit
- **pip-audit:** https://github.com/pypa/pip-audit
- **bundler-audit:** https://github.com/rubysec/bundler-audit

### SBOM Standards
- **CycloneDX Specification:** https://cyclonedx.org/specification/overview/
- **SPDX:** https://spdx.dev/
- **NTIA SBOM:** https://www.ntia.gov/sbom

---

## 💡 DICAS E TROUBLESHOOTING

### Problemas Comuns

**Dependency Check muito lento na primeira vez:**
```bash
# Cache do NVD é baixado na primeira execução
# Pode levar 10-20 minutos
# Execuções subsequentes são muito mais rápidas

# Atualizar cache manualmente
dependency-check.sh --updateonly
```

**Falsos positivos:**
```bash
# Usar arquivo de supressão
dependency-check.sh \
  --suppression dependency-suppression.xml \
  --scan .
```

**Dependency Track não inicia:**
```bash
# Verificar logs
docker-compose -f docker-compose-dtrack.yml logs -f

# Aguardar mais tempo (primeira inicialização pode levar 3-5 min)
# Verificar se porta 8080/8081 não está em uso
netstat -tuln | grep -E '8080|8081'
```

**NPM Audit encontra vulnerabilidades sem correção:**
```bash
# Usar overrides no package.json (npm 8.3+)
{
  "overrides": {
    "vulnerable-package": "^2.0.0"
  }
}

# Ou usar resolutions (Yarn)
{
  "resolutions": {
    "vulnerable-package": "^2.0.0"
  }
}
```

**Python pip-audit falha:**
```bash
# Instalar versão mais recente
pip install --upgrade pip-audit

# Usar apenas PyPI
pip-audit --no-deps -r requirements.txt
```

---

## 🏆 DESAFIOS EXTRAS

### Desafio 1: Monitoramento Contínuo
Configure Dependency Track para:
- Enviar notificações por email em novas vulnerabilidades
- Integrar com Slack/Teams
- Criar dashboard de métricas de segurança
- Tracking de correções ao longo do tempo

### Desafio 2: Política Corporativa Completa
Crie um conjunto completo de políticas:
- Bloquear licenças copyleft (GPL, AGPL)
- Permitir apenas Apache, MIT, BSD
- Bloquear componentes com idade > 2 anos sem atualizações
- Requerer CVSS < 4.0 para todas as dependências

### Desafio 3: Análise de Supply Chain
Investigue a cadeia de suprimentos de uma dependência:
- Quantos maintainers o pacote tem?
- Quando foi o último commit?
- Existem dependências transitivas problemáticas?
- O projeto tem política de segurança?
- Existe processo de disclosure de vulnerabilidades?

### Desafio 4: Automação de Correções
Crie script que:
1. Executa scan SCA
2. Identifica dependências com patches disponíveis
3. Cria branch com atualizações
4. Abre Pull Request automático
5. Executa testes para validar compatibilidade

---

## 📊 MÉTRICAS DE SUCESSO

Ao final do laboratório, você deve ser capaz de:

- ✅ Executar scans SCA em < 5 minutos
- ✅ Interpretar CVSS scores corretamente
- ✅ Gerar SBOM completo e válido
- ✅ Configurar Dependency Track funcional
- ✅ Criar políticas de segurança efetivas
- ✅ Integrar SCA em pipeline CI/CD
- ✅ Comparar e selecionar ferramentas SCA adequadas
- ✅ Atualizar dependências com segurança

**Benchmark de Redução de Vulnerabilidades:**
- Alvo: Reduzir 90%+ das vulnerabilidades Critical
- Alvo: Reduzir 70%+ das vulnerabilidades High
- Alvo: Documentar 100% das supressões

---

**FIM DO LABORATÓRIO**

Este material foi desenvolvido para o Módulo 4 - "SCA - Software Composition Analysis" do curso de Pós-Graduação em Cibersegurança Defensiva.

Professor: Fernando Silva - Engenheiro de Segurança de Aplicações

⏱️ **Tempo Total:** 1 hora (podendo estender com desafios extras)
