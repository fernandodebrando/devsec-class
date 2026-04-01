# devsec-class

Repositório dedicado a compartilhar os materiais e exemplos utilizados nos laboratórios práticos do curso de **Pós-Graduação em Cibersegurança Defensiva** — disciplina de Desenvolvimento Seguro.

**Professor:** Fernando Silva — Engenheiro de Segurança de Aplicações

---

## Estrutura do Repositório

```
devsec-class/
├── lab1-fundamentals/       # Módulo 1 — Fundamentos e Mindset de Ataque
├── lab2-threat-modeling/    # Módulo 2 — Design Seguro e Modelagem de Ameaças
├── lab3-sast/               # Módulo 3 — SAST: Análise Estática de Código
├── lab4-sca/                # Módulo 4 — SCA: Análise de Composição de Software
├── lab5-dast/               # Módulo 5 — DAST: Teste Dinâmico de Segurança
├── lab6-iac-containers/     # Módulo 6 — Segurança de IaC e Containers
└── lab7-ai/                 # Módulo 7 — IA e Desenvolvimento Seguro
```

---

## Laboratórios

### Lab 1 — Fundamentos e Mindset de Ataque

**Diretório:** [lab1-fundamentals/](lab1-fundamentals/)
**Duração:** 30 minutos | **Nível:** Iniciante

Introdução ao mindset ofensivo como base para construir defesas mais eficazes. O aluno explora vulnerabilidades reais em ambiente controlado usando o OWASP Juice Shop.

**Tópicos abordados:**
- OWASP Top 10 (2021) — conceitos e exemplos práticos
- SQL Injection: exploração via parâmetros de busca, UNION-based exfiltration
- Cross-Site Scripting (XSS): tipos Reflected, Stored e DOM-based
- Interceptação e manipulação de requisições HTTP com **OWASP ZAP**
- Mindset Red Team, Blue Team e Purple Team

**Ferramentas:** OWASP Juice Shop, OWASP ZAP

---

### Lab 2 — Design Seguro e Modelagem de Ameaças

**Diretório:** [lab2-threat-modeling/](lab2-threat-modeling/)
**Duração:** 1 hora | **Nível:** Intermediário

Aplicação da modelagem de ameaças antes de escrever código, integrando segurança no design da arquitetura.

**Tópicos abordados:**
- Criação de Diagramas de Fluxo de Dados (DFD)
- Metodologia **STRIDE** (Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege)
- Priorização de ameaças com **DREAD**
- Derivação de requisitos de segurança a partir de ameaças identificadas
- Integração do Threat Modeling no SDLC

**Ferramentas:** OWASP Threat Dragon

---

### Lab 3 — SAST: Static Application Security Testing

**Diretório:** [lab3-sast/](lab3-sast/)
**Duração:** 1,5 horas | **Nível:** Intermediário

Análise estática de código-fonte para identificar vulnerabilidades sem executar a aplicação — o "antivírus do código".

**Tópicos abordados:**
- Execução de análise estática com **Semgrep** e **SonarQube**
- Análise de código vulnerável em Python ([app.py](lab3-sast/app.py)), Java ([file-processor.java](lab3-sast/file-processor.java)) e PHP ([user-info.php](lab3-sast/user-info.php))
- Criação de regras SAST customizadas para padrões específicos da organização
- Integração do SAST em IDE e pipelines CI/CD
- Análise de falsos positivos e limitações do SAST

**Ferramentas:** Semgrep, SonarQube Community

---

### Lab 4 — SCA: Software Composition Analysis

**Diretório:** [lab4-sca/](lab4-sca/)
**Duração:** 1 hora | **Nível:** Intermediário

Identificação e gestão de vulnerabilidades em dependências de terceiros — componentes open source com CVEs conhecidos.

**Tópicos abordados:**
- Análise de dependências com **OWASP Dependency Check**
- Interpretação de CVEs e scores **CVSS**
- Geração e análise de **SBOM** (Software Bill of Materials)
- Monitoramento contínuo com **Dependency Track**
- Políticas de segurança para dependências
- Integração em pipelines CI/CD

**Artefatos incluídos:** Relatórios de exemplo do Dependency Check em múltiplos formatos (HTML, JSON, XML, SARIF, CSV) em [lab4-sca/odc-reports/](lab4-sca/odc-reports/)

**Ferramentas:** OWASP Dependency Check, Dependency Track

---

### Lab 5 — DAST: Dynamic Application Security Testing

**Diretório:** [lab5-dast/](lab5-dast/)
**Duração:** 1 hora | **Nível:** Intermediário

Testes de segurança em aplicações em execução, simulando o comportamento de um atacante contra o sistema completo.

**Tópicos abordados:**
- **ZAP Baseline Scan** — scan passivo rápido, ideal para CI/CD
- **ZAP Full Scan** — scan ativo completo com spider
- Scan com autenticação para cobrir áreas privadas da aplicação
- Análise de headers de segurança com **Nikto**
- Comparação prática entre SAST e DAST (o que cada um detecta)
- Integração em GitHub Actions e GitLab CI

**Ferramentas:** OWASP ZAP, Nikto

---

### Lab 6 — Segurança de IaC e Containers

**Diretório:** [lab6-iac-containers/](lab6-iac-containers/)
**Duração:** 1,5 horas | **Nível:** Intermediário

Segurança da infraestrutura declarada como código e das imagens de container antes de chegarem à produção.

**Tópicos abordados:**

**Infrastructure as Code (IaC):**
- Análise de Terraform vulnerável com **Checkov** e **TFSec**
- Vulnerabilidades comuns: S3 público, Security Groups abertos, RDS sem criptografia, IAM com wildcard, secrets hardcoded
- Criação de **Policy-as-Code** customizado para padrões organizacionais
- Exemplos de código Terraform inseguro vs seguro: [main.tf](lab6-iac-containers/main.tf) / [main1.tf](lab6-iac-containers/main1.tf) / [main2.tf](lab6-iac-containers/main2.tf) / [main3.tf](lab6-iac-containers/main3.tf)

**Container Security:**
- Análise de imagens Docker com **Trivy** (CVEs, secrets, misconfigurations)
- Boas práticas de Dockerfile: multi-stage build, usuário não-root, imagem base minimal
- Comparação de imagens base (Alpine vs Ubuntu)
- Integração em pipelines CI/CD com GitHub Actions e GitLab CI

**Ferramentas:** Checkov, TFSec, Trivy

---

### Lab 7 — IA e Desenvolvimento Seguro

**Diretório:** [lab7-ai/](lab7-ai/)

Utilização de Large Language Models (LLMs) como ferramenta auxiliar para revisão de código com foco em segurança.

**Tópicos abordados:**
- Prompt engineering para análise de vulnerabilidades com LLMs
- Identificação de vulnerabilidades (SQLi, XSS, Command Injection, XXE, Insecure Deserialization) assistida por IA
- Variações de prompt: foco em OWASP específico, análise comparativa antes/depois, threat modeling via código
- Comparação entre análise por IA e SAST automatizado
- Limitações e uso responsável de IA em segurança

**Exemplos de código vulnerável analisados:** Python/Flask, Node.js/Express, Java

---

## Pré-requisitos Gerais

- Docker instalado e em execução
- Python 3.x (para laboratórios SAST e IaC)
- Conhecimento básico de HTTP/APIs
- Acesso a terminal (Linux/macOS recomendado)

## Tecnologias e Ferramentas Utilizadas

| Categoria | Ferramenta |
|-----------|-----------|
| Aplicação vulnerável | OWASP Juice Shop, DVWA, WebGoat |
| Proxy / DAST | OWASP ZAP, Nikto |
| SAST | Semgrep, SonarQube |
| SCA | OWASP Dependency Check, Dependency Track |
| IaC Security | Checkov, TFSec |
| Container Security | Trivy |
| Threat Modeling | OWASP Threat Dragon |
| Metodologia | OWASP Top 10, STRIDE, DREAD, CVSS |
