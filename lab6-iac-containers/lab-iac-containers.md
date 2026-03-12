# Laboratório Prático: Protegendo Infraestrutura e Containers
## Módulo 6 - Segurança de IaC e Containers

---

## 🎯 OBJETIVOS DO LABORATÓRIO

Ao final deste laboratório, você será capaz de:

1. ✅ Identificar misconfigurations em código Terraform usando Checkov/TFSec
2. ✅ Detectar vulnerabilidades em imagens Docker com Trivy
3. ✅ Implementar policy-as-code para bloquear configurações inseguras
4. ✅ Compreender CVEs em containers e como priorizá-los
5. ✅ Integrar IaC Security e Container Security em pipelines CI/CD

**Duração:** 1.5 horas  
**Nível:** Intermediário  
**Pré-requisitos:** Docker instalado, conhecimento básico de Terraform

---

## 📚 PARTE 1: INFRASTRUCTURE AS CODE SECURITY (45 minutos)

### 🛠️ Ferramentas Necessárias

```bash
# Instalar Checkov (Python)
pip install checkov --break-system-packages

# OU instalar TFSec (Go - alternativa)
# Linux/Mac
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Verificar instalação
checkov --version
# ou
tfsec --version

# No lab pode ser necessário executar os comandos abaixo
cd /opt/venv/checkov
source ./bin/activate
checkov --version
# ou
sudo su
cd /root/go/bin/
./tfsec

```

---

### 📝 EXERCÍCIO 1.1: Análise de Terraform Vulnerável

#### Código Terraform Inseguro (main.tf)

Crie um arquivo `main.tf` com o seguinte conteúdo:

```hcl
# main.tf - CÓDIGO INTENCIONALMENTE VULNERÁVEL PARA APRENDIZADO

terraform {
  required_version = ">= 1.0"
}

# Provider AWS
provider "aws" {
  region = "us-east-1"
}

# ===== VULNERABILIDADE #1: Bucket S3 Público =====
resource "aws_s3_bucket" "data_bucket" {
  bucket = "minha-empresa-dados-sensiveis-2024"
  
  # PROBLEMA: Bucket completamente público
  acl = "public-read-write"
  
  tags = {
    Name        = "Data Bucket"
    Environment = "Production"
  }
}

# ===== VULNERABILIDADE #2: Bucket sem Criptografia =====
resource "aws_s3_bucket" "backup_bucket" {
  bucket = "minha-empresa-backups"
  
  # PROBLEMA: Sem criptografia em repouso
  # server_side_encryption_configuration está ausente
  
  versioning {
    enabled = false  # PROBLEMA: Versionamento desabilitado
  }
}

# ===== VULNERABILIDADE #3: Security Group Aberto =====
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for web servers"
  vpc_id      = "vpc-12345678"

  # PROBLEMA: SSH aberto para toda internet
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CRÍTICO: Todo mundo pode acessar!
  }

  # PROBLEMA: RDP aberto para toda internet
  ingress {
    description = "RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CRÍTICO: Windows RDP exposto!
  }

  # PROBLEMA: Tráfego de saída sem restrição
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ===== VULNERABILIDADE #4: RDS sem Criptografia =====
resource "aws_db_instance" "production_db" {
  identifier           = "production-database"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  
  username             = "admin"
  password             = "Admin123456"  # PROBLEMA: Senha hardcoded
  
  # PROBLEMA: Sem criptografia
  storage_encrypted    = false
  
  # PROBLEMA: Banco público
  publicly_accessible  = true
  
  # PROBLEMA: Backups desabilitados
  backup_retention_period = 0
  
  # PROBLEMA: Logs desabilitados
  enabled_cloudwatch_logs_exports = []
  
  skip_final_snapshot  = true
}

# ===== VULNERABILIDADE #5: IAM Policy Permissiva =====
resource "aws_iam_policy" "admin_policy" {
  name        = "developer-policy"
  description = "Policy for developers"
  
  # PROBLEMA: Wildcard em resources e actions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"  # CRÍTICO: Todas as ações!
        Resource = "*"  # CRÍTICO: Todos os recursos!
      }
    ]
  })
}

# ===== VULNERABILIDADE #6: EC2 sem IMDSv2 =====
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # PROBLEMA: IMDSv2 não obrigatório (vulnerável a SSRF)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"  # Deveria ser "required"
    http_put_response_hop_limit = 1
  }
  
  # PROBLEMA: Monitoramento detalhado desabilitado
  monitoring = false
  
  tags = {
    Name = "WebServer"
  }
}

# ===== VULNERABILIDADE #7: CloudTrail Desabilitado =====
# PROBLEMA: Sem logging de auditoria (CloudTrail ausente)
# Isso impede detecção de atividades maliciosas

# ===== VULNERABILIDADE #8: Secrets em Variáveis =====
variable "database_password" {
  description = "Database password"
  type        = string
  default     = "SuperSecret123!"  # PROBLEMA: Secret hardcoded
  # Deveria usar sensitive = true no mínimo
}

variable "api_key" {
  description = "API Key for external service"
  type        = string
  default     = "sk-1234567890abcdefghijklmnop"  # PROBLEMA: API key exposta
}
```

---

### 🔍 TAREFA 1: Executar Checkov

```bash
# Executar scan completo
checkov -f main.tf

# Executar com output em formato JSON
checkov -f main.tf -o json > checkov-results.json

# Executar com output compacto
checkov -f main.tf --compact

# Executar apenas verificações críticas e altas
checkov -f main.tf --check-severity CRITICAL,HIGH

# Executar e gerar relatório HTML
checkov -f main.tf -o cli -o junitxml --output-file-path results/
```

**Questões para Reflexão:**
1. Quantas vulnerabilidades CRÍTICAS foram encontradas?
2. Qual é a vulnerabilidade com maior risco?
3. Alguma vulnerabilidade foi classificada incorretamente?

---

### 🔧 EXERCÍCIO 1.2: Corrigir Vulnerabilidades Terraform

Crie um arquivo `main-secure.tf` com as correções:

```hcl
# main-secure.tf - VERSÃO SEGURA

terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}

# ===== CORREÇÃO #1: Bucket S3 Privado com Criptografia =====
resource "aws_s3_bucket" "data_bucket" {
  bucket = "minha-empresa-dados-sensiveis-2024"
  
  tags = {
    Name        = "Data Bucket"
    Environment = "Production"
  }
}

# Bloquear acesso público
resource "aws_s3_bucket_public_access_block" "data_bucket_pab" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Criptografia obrigatória
resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket_encryption" {
  bucket = aws_s3_bucket.data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      # ou usar KMS: sse_algorithm = "aws:kms" e kms_master_key_id
    }
  }
}

# Versionamento habilitado
resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
  bucket = aws_s3_bucket.data_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Logging habilitado
resource "aws_s3_bucket_logging" "data_bucket_logging" {
  bucket = aws_s3_bucket.data_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "data-bucket-logs/"
}

# ===== CORREÇÃO #2: Security Group Restrito =====
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for web servers"
  vpc_id      = "vpc-12345678"

  # SSH apenas de IPs corporativos
  ingress {
    description = "SSH from corporate network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Apenas rede interna
  }

  # HTTPS público (adequado para web servers)
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress restrito apenas para necessário
  egress {
    description = "HTTPS to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg-secure"
  }
}

# ===== CORREÇÃO #3: RDS Seguro =====
resource "aws_db_instance" "production_db" {
  identifier           = "production-database"
  engine               = "mysql"
  engine_version       = "8.0"  # Versão mais recente
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  
  # Usar secrets manager ao invés de hardcode
  username             = "admin"
  password             = random_password.db_password.result
  
  # Criptografia habilitada
  storage_encrypted    = true
  kms_key_id          = aws_kms_key.rds_key.arn
  
  # Banco PRIVADO
  publicly_accessible  = false
  
  # Backups habilitados
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  
  # Logs habilitados
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  
  # Snapshot final antes de destruir
  skip_final_snapshot  = false
  final_snapshot_identifier = "production-db-final-snapshot"
  
  # Multi-AZ para alta disponibilidade
  multi_az = true
  
  tags = {
    Name = "production-db-secure"
  }
}

# Gerar senha aleatória
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Armazenar senha no Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "production-db-password"
  
  kms_key_id = aws_kms_key.secrets_key.arn
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# ===== CORREÇÃO #4: IAM Policy com Least Privilege =====
resource "aws_iam_policy" "developer_policy" {
  name        = "developer-policy-secure"
  description = "Least privilege policy for developers"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::dev-bucket",
          "arn:aws:s3:::dev-bucket/*"
        ]
      },
      {
        Sid    = "EC2ReadOnly"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ===== CORREÇÃO #5: EC2 com IMDSv2 Obrigatório =====
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # IMDSv2 obrigatório (proteção contra SSRF)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 obrigatório
    http_put_response_hop_limit = 1
  }
  
  # Monitoramento detalhado habilitado
  monitoring = true
  
  # EBS criptografado
  root_block_device {
    encrypted = true
    kms_key_id = aws_kms_key.ebs_key.arn
  }
  
  tags = {
    Name = "WebServer-Secure"
  }
}

# ===== CORREÇÃO #6: CloudTrail Habilitado =====
resource "aws_cloudtrail" "audit_trail" {
  name                          = "organization-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  
  # Logs criptografados
  kms_key_id = aws_kms_key.cloudtrail_key.arn
  
  # Validação de integridade
  enable_log_file_validation = true
  
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}

# ===== KMS Keys para Criptografia =====
resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for Secrets Manager"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "ebs_key" {
  description             = "KMS key for EBS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "cloudtrail_key" {
  description             = "KMS key for CloudTrail"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
```

---

### ✅ TAREFA 2: Validar Correções

```bash
# Executar Checkov no código corrigido
checkov -f main-secure.tf

# Comparar resultados
echo "=== VULNERABILIDADES ENCONTRADAS ==="
echo "Código vulnerável:"
checkov -f main.tf --compact | grep "Failed checks"
echo "Código corrigido:"
checkov -f main-secure.tf --compact | grep "Failed checks"

# Gerar diff visual
diff <(checkov -f main.tf --compact) <(checkov -f main-secure.tf --compact)
```

**Questões para Análise:**
1. Todas as vulnerabilidades foram corrigidas?
2. Quais controles de segurança adicionais foram implementados?
3. Alguma correção introduziu novos problemas?

---

### 📋 EXERCÍCIO 1.3: Policy as Code Customizado

Crie políticas customizadas para sua organização:

```python
# custom_policy.py - Política customizada Checkov

from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories

class S3BucketMustHaveTagEnvironment(BaseResourceCheck):
    def __init__(self):
        name = "Ensure S3 bucket has Environment tag"
        id = "CKV_CUSTOM_1"
        supported_resources = ['aws_s3_bucket']
        categories = [CheckCategories.CONVENTION]
        super().__init__(name=name, id=id, categories=categories, 
                         supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Verifica se o bucket S3 tem a tag 'Environment'
        """
        if 'tags' in conf:
            tags = conf['tags'][0]
            if isinstance(tags, dict) and 'Environment' in tags:
                return CheckResult.PASSED
        return CheckResult.FAILED

check = S3BucketMustHaveTagEnvironment()
```

**Executar política customizada:**
```bash
checkov -f main.tf --external-checks-dir ./custom_policies/
```

---

## 🐳 PARTE 2: CONTAINER SECURITY (45 minutos)

### 🛠️ Ferramentas Necessárias

```bash
# Instalar Trivy
# Linux
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# macOS
brew install aquasecurity/trivy/trivy

# Verificar instalação
trivy --version
```

---

### 📝 EXERCÍCIO 2.1: Analisar Dockerfile Vulnerável

Crie um `Dockerfile.vulnerable`:

```dockerfile
# Dockerfile.vulnerable - INTENCIONALMENTE INSEGURO

# PROBLEMA #1: Usando imagem com tag 'latest' (não determinístico)
FROM ubuntu:latest

# PROBLEMA #2: Rodando como root (sem USER statement)

# PROBLEMA #3: Instalando pacotes desatualizados
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    curl \
    wget \
    git

# PROBLEMA #4: Deixando cache do apt (aumenta tamanho da imagem)
# apt-get clean não foi executado

# PROBLEMA #5: Usando pip sem --no-cache-dir
RUN pip install flask==0.12.2

# PROBLEMA #6: Copiando tudo (pode incluir secrets)
COPY . /app

# PROBLEMA #7: Credenciais hardcoded
ENV DATABASE_URL="postgresql://admin:password123@db.example.com:5432/production"
ENV API_KEY="sk-1234567890abcdefghijklmnop"

# PROBLEMA #8: Expondo porta privilegiada
EXPOSE 80

# PROBLEMA #9: Executando como root
WORKDIR /app
CMD ["python", "app.py"]
```

Crie também uma aplicação vulnerável `app.py`:

```python
# app.py - Aplicação Flask vulnerável
from flask import Flask, request
import os

app = Flask(__name__)

# Vulnerabilidade: Debug mode em produção
app.config['DEBUG'] = True

# Vulnerabilidade: Secret key fraca
app.config['SECRET_KEY'] = '123456'

@app.route('/')
def hello():
    # Vulnerabilidade: Uso de eval
    name = request.args.get('name', 'World')
    return eval(f"'Hello, {name}!'")

if __name__ == '__main__':
    # Vulnerabilidade: Rodando em 0.0.0.0 com debug
    app.run(host='0.0.0.0', port=80, debug=True)
```

---

### 🔍 TAREFA 3: Executar Trivy no Dockerfile

```bash
# Build da imagem vulnerável
docker build -f Dockerfile.vulnerable -t vulnerable-app:1.0 .

# Scan básico
trivy image vulnerable-app:1.0

# Scan com severidades específicas
trivy image --severity HIGH,CRITICAL vulnerable-app:1.0

# Scan com output JSON
trivy image -f json -o results.json vulnerable-app:1.0

# Scan apenas de vulnerabilidades (sem misconfigurations)
trivy image --scanners vuln vulnerable-app:1.0

# Scan completo (vulnerabilidades + secrets + misconfigurations)
trivy image --scanners vuln,secret,config vulnerable-app:1.0

# Scan ignorando vulnerabilidades não corrigidas
trivy image --ignore-unfixed vulnerable-app:1.0

# Scan com template customizado
trivy image --format template --template "@contrib/html.tpl" -o report.html vulnerable-app:1.0
```

---

### 📊 TAREFA 4: Analisar Resultados Trivy

**Entenda a saída do Trivy:**

```
vulnerable-app:1.0 (ubuntu 22.04)
===================================

Total: 247 (UNKNOWN: 0, LOW: 89, MEDIUM: 78, HIGH: 65, CRITICAL: 15)

┌────────────────┬────────────────┬──────────┬───────────────────┬───────────────┬───────────────────────────────────────┐
│    Library     │ Vulnerability  │ Severity │ Installed Version │ Fixed Version │                 Title                 │
├────────────────┼────────────────┼──────────┼───────────────────┼───────────────┼───────────────────────────────────────┤
│ libssl1.1      │ CVE-2023-12345 │ CRITICAL │ 1.1.1f-1ubuntu2   │ 1.1.1f-1ubuntu2.19│ openssl: buffer overflow in ...     │
│ python2.7      │ CVE-2023-67890 │ HIGH     │ 2.7.18-1          │ Not Fixed     │ python: remote code execution via ... │
└────────────────┴────────────────┴──────────┴───────────────────┴───────────────┴───────────────────────────────────────┘
```

**Questões para Análise:**
1. Quantas vulnerabilidades CRÍTICAS existem?
2. Quais vulnerabilidades não têm correção disponível?
3. Qual biblioteca tem mais vulnerabilidades?
4. Alguma vulnerabilidade tem exploit público conhecido?

---

### 🔧 EXERCÍCIO 2.2: Criar Dockerfile Seguro

Crie `Dockerfile.secure`:

```dockerfile
# Dockerfile.secure - VERSÃO SEGURA

# CORREÇÃO #1: Usar imagem específica e minimal
FROM python:3.11-slim-bookworm AS builder

# CORREÇÃO #2: Usar multi-stage build para reduzir tamanho
# CORREÇÃO #3: Criar usuário não-privilegiado
RUN groupadd -r appuser && useradd -r -g appuser appuser

# CORREÇÃO #4: Instalar apenas dependências necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# CORREÇÃO #5: Usar diretório de trabalho apropriado
WORKDIR /app

# CORREÇÃO #6: Copiar apenas requirements primeiro (cache de layer)
COPY requirements.txt .

# CORREÇÃO #7: Instalar dependências com versões fixas
RUN pip install --no-cache-dir -r requirements.txt

# Segunda stage - imagem final
FROM python:3.11-slim-bookworm

# Criar usuário
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copiar apenas artefatos necessários do builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# CORREÇÃO #8: Copiar apenas arquivos necessários
COPY app.py .

# CORREÇÃO #9: Configurar como usuário não-root
USER appuser

# CORREÇÃO #10: Usar porta não-privilegiada
EXPOSE 8080

# CORREÇÃO #11: Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# CORREÇÃO #12: Usar array format para CMD (evita shell injection)
CMD ["python", "app.py"]

# Metadata
LABEL maintainer="security@empresa.com" \
      version="1.0" \
      description="Aplicação Flask segura"
```

Crie `requirements.txt`:

```
Flask==3.0.0
gunicorn==21.2.0
python-dotenv==1.0.0
```

Crie `app-secure.py`:

```python
# app-secure.py - Versão segura
from flask import Flask, request, jsonify
from dotenv import load_dotenv
import os

# Carregar variáveis de ambiente
load_dotenv()

app = Flask(__name__)

# CORREÇÃO: Secret key de variável de ambiente
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', os.urandom(32))

# CORREÇÃO: Debug desabilitado em produção
app.config['DEBUG'] = False

@app.route('/')
def hello():
    # CORREÇÃO: Input sanitizado
    name = request.args.get('name', 'World')
    # Validação
    if not name.isalnum():
        return jsonify({"error": "Invalid name"}), 400
    return jsonify({"message": f"Hello, {name}!"})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    # CORREÇÃO: Usar gunicorn em produção
    # python app-secure.py apenas para dev local
    app.run(host='127.0.0.1', port=8080)
```

Crie `.dockerignore`:

```
# .dockerignore - Não incluir arquivos sensíveis
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.env
.git/
.gitignore
*.md
tests/
docs/
*.log
.DS_Store
secrets/
*.key
*.pem
```

---

### ✅ TAREFA 5: Validar Imagem Segura

```bash
# Build da imagem segura
docker build -f Dockerfile.secure -t secure-app:1.0 .

# Scan com Trivy
trivy image secure-app:1.0

# Comparar tamanhos
docker images | grep -E "vulnerable-app|secure-app"

# Comparar vulnerabilidades
echo "=== VULNERABILIDADES ==="
echo "Imagem vulnerável:"
trivy image --severity CRITICAL,HIGH vulnerable-app:1.0 | grep "Total:"
echo "Imagem segura:"
trivy image --severity CRITICAL,HIGH secure-app:1.0 | grep "Total:"
```

---

### 🔒 EXERCÍCIO 2.3: Scanning de Imagens Públicas

Analise imagens públicas comuns:

```bash
# Scan de imagens base populares
trivy image nginx:latest
trivy image node:latest
trivy image python:3.9
trivy image alpine:latest

# Comparar Alpine vs Ubuntu
trivy image ubuntu:22.04 --severity CRITICAL,HIGH | grep "Total:"
trivy image alpine:3.18 --severity CRITICAL,HIGH | grep "Total:"

# Scan de imagens de terceiros
trivy image redis:7.0
trivy image postgres:15
trivy image mongo:6.0
```

**Questões:**
1. Qual imagem base tem menos vulnerabilidades?
2. Alpine realmente é mais seguro que Ubuntu?
3. Versões "latest" vs versões fixas - qual a diferença?

---

## 🚀 PARTE 3: INTEGRAÇÃO CI/CD (BÔNUS)

### 📝 EXERCÍCIO 3.1: GitHub Actions Workflow

Crie `.github/workflows/security-scan.yml`:

```yaml
name: Security Scanning

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  terraform-security:
    name: Terraform Security Scan
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: terraform/
          framework: terraform
          output_format: cli
          soft_fail: false  # Falhar build se encontrar issues
          
      - name: Upload Checkov results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: checkov-results
          path: results/

  container-security:
    name: Container Security Scan
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Build Docker image
        run: docker build -t ${{ github.repository }}:${{ github.sha }} .
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ github.repository }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Falhar se encontrar vulnerabilidades
      
      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
```

---

### 📝 EXERCÍCIO 3.2: GitLab CI Pipeline

Crie `.gitlab-ci.yml`:

```yaml
stages:
  - security-scan
  - build
  - deploy

variables:
  TRIVY_VERSION: "0.48.0"
  CHECKOV_VERSION: "3.1.0"

terraform-security:
  stage: security-scan
  image: bridgecrew/checkov:${CHECKOV_VERSION}
  script:
    - checkov -d terraform/ -o cli -o junitxml --output-file-path results/
  artifacts:
    reports:
      junit: results/results_junitxml.xml
    paths:
      - results/
  allow_failure: false

container-security:
  stage: security-scan
  image: aquasec/trivy:${TRIVY_VERSION}
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - trivy image 
        --exit-code 1 
        --severity CRITICAL,HIGH 
        --format json 
        --output results.json 
        $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    reports:
      container_scanning: results.json
  allow_failure: false

build:
  stage: build
  # ... resto do pipeline
```

---

## 📊 ENTREGÁVEIS DO LABORATÓRIO

Ao final do laboratório, cada aluno deve entregar:

### 1. Relatório de IaC Security

```markdown
# Relatório - Infrastructure as Code Security

**Aluno:** [Nome]
**Data:** [Data]

## Vulnerabilidades Encontradas no Terraform

| # | Vulnerabilidade | Check ID | Severidade | Recurso | Status |
|---|----------------|----------|------------|---------|--------|
| 1 | Bucket S3 público | CKV_AWS_18 | CRITICAL | aws_s3_bucket | ✅ Corrigido |
| 2 | ... | ... | ... | ... | ... |

## Código Terraform Corrigido

```hcl
[Cole o código corrigido]
```

## Políticas Customizadas Criadas

[Descreva suas políticas customizadas]

## Lições Aprendidas

1. [Lista de insights]
```

### 2. Relatório de Container Security

```markdown
# Relatório - Container Security

**Aluno:** [Nome]
**Data:** [Data]

## Análise da Imagem Vulnerável

- **Total de CVEs:** [Número]
- **Críticos:** [Número]
- **Altos:** [Número]
- **CVE mais severo:** [CVE-XXXX-XXXXX]

## Dockerfile Seguro

```dockerfile
[Cole seu Dockerfile seguro]
```

## Comparação de Resultados

| Métrica | Imagem Vulnerável | Imagem Segura | Melhoria |
|---------|-------------------|---------------|----------|
| Tamanho | 850 MB | 180 MB | 79% redução |
| CVEs Críticos | 15 | 0 | 100% redução |
| CVEs Altos | 65 | 2 | 97% redução |

## Multi-Stage Build

[Explique como multi-stage build ajudou]
```

### 3. Pipeline CI/CD (Bônus)

- Arquivo `.github/workflows/security-scan.yml` OU `.gitlab-ci.yml`
- Screenshot do pipeline executando
- Explicação de cada stage

---

## 🎯 CHECKLIST DE VERIFICAÇÃO

### IaC Security ✅
- [ ] Executei Checkov no Terraform vulnerável
- [ ] Identifiquei todas as vulnerabilidades
- [ ] Corrigi todas as vulnerabilidades CRÍTICAS e ALTAS
- [ ] Validei correções com novo scan
- [ ] Criei pelo menos 1 política customizada
- [ ] Entendi a diferença entre cada tipo de misconfiguration

### Container Security ✅
- [ ] Instalei e executei Trivy
- [ ] Analisei Dockerfile vulnerável
- [ ] Identifiquei CVEs críticos
- [ ] Criei Dockerfile com multi-stage build
- [ ] Executei como usuário não-root
- [ ] Usei imagem base minimal
- [ ] Comparei tamanhos das imagens
- [ ] Validei redução de vulnerabilidades

### Integração CI/CD (Bônus) ✅
- [ ] Criei workflow/pipeline funcional
- [ ] Pipeline falha quando encontra vulnerabilidades
- [ ] Artefatos são salvos corretamente
- [ ] Testei localmente com act (GitHub) ou gitlab-runner

---

## 📚 RECURSOS ADICIONAIS

### Documentação Oficial
- **Checkov:** https://www.checkov.io/
- **TFSec:** https://aquasecurity.github.io/tfsec/
- **Trivy:** https://aquasecurity.github.io/trivy/
- **Terraform Best Practices:** https://www.terraform-best-practices.com/

### Benchmarks e Standards
- **CIS AWS Foundations Benchmark:** https://www.cisecurity.org/benchmark/amazon_web_services
- **CIS Docker Benchmark:** https://www.cisecurity.org/benchmark/docker
- **NIST Container Security:** https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf

### Bases de Dados de Vulnerabilidades
- **NVD - National Vulnerability Database:** https://nvd.nist.gov/
- **CVE Details:** https://www.cvedetails.com/
- **Snyk Vulnerability DB:** https://security.snyk.io/

### Ferramentas Complementares
- **Terrascan:** Policy as Code para IaC
- **Grype:** Alternative container scanner
- **Clair:** CoreOS container scanner
- **Snyk:** Commercial alternative

---

## 💡 DICAS E TROUBLESHOOTING

### Problemas Comuns

**Erro: "terraform not found"**
```bash
# Instalar Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Erro: "docker daemon not running"**
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

**Trivy muito lento**
```bash
# Usar cache local
export TRIVY_CACHE_DIR=~/.trivy/cache

# Usar database offline
trivy image --download-db-only
trivy image --skip-db-update your-image:tag
```

**Checkov falsos positivos**
```bash
# Ignorar checks específicos inline
resource "aws_s3_bucket" "example" {
  #checkov:skip=CKV_AWS_18:Bucket precisa ser público para CDN
  bucket = "public-cdn-bucket"
}

# Criar arquivo .checkov.yml
skip-check:
  - CKV_AWS_18
  - CKV_AWS_19
```

---

## 🏆 DESAFIOS EXTRAS

### Desafio 1: Zero Vulnerabilities
Crie uma imagem Docker com ZERO vulnerabilidades de severidade CRITICAL ou HIGH.

**Dica:** Use Alpine, distroless ou scratch base images.

### Desafio 2: Política Corporativa Completa
Crie um conjunto completo de políticas Checkov customizadas para:
- Todos os recursos devem ter tags: Owner, Environment, CostCenter
- Nenhum recurso pode usar default VPC
- Todos os dados em repouso devem ser criptografados
- Logging obrigatório em todos os recursos que suportam

### Desafio 3: Pipeline Completo
Crie pipeline que:
1. Executa Checkov no Terraform
2. Aplica Terraform se passar
3. Builda imagem Docker
4. Escaneia com Trivy
5. Publica se passar
6. Deploy em ambiente de staging
7. Testes de segurança automatizados
8. Deploy em produção com aprovação manual

---

**FIM DO LABORATÓRIO**

Este material foi desenvolvido para o Módulo 6 - "Segurança de IaC e Containers" do curso de Pós-Graduação em Cibersegurança Defensiva.

Professor: Fernando Silva - Engenheiro de Segurança de Aplicações

⏱️ **Tempo Total:** 1.5 horas (podendo estender com desafios extras)
