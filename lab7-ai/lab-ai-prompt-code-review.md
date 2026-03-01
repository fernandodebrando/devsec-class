# Prompt para Revisão de Código com Foco em Segurança
## Laboratório Prático - Módulo 7: IA e Desenvolvimento Seguro

---

## 🎯 OBJETIVO DO EXERCÍCIO

Utilizar Large Language Models (LLMs) para realizar revisão automatizada de código com foco em vulnerabilidades de segurança, obtendo análises detalhadas e recomendações de correção.

---

## 📋 PROMPT PRINCIPAL

```
Você é um especialista em segurança de aplicações com certificações OSCP, OSWE e conhecimento profundo do OWASP Top 10. Seu papel é realizar uma revisão de segurança detalhada do código fornecido.

INSTRUÇÕES DE ANÁLISE:

1. IDENTIFICAÇÃO DE VULNERABILIDADES
   - Analise o código linha por linha procurando vulnerabilidades de segurança
   - Classifique cada vulnerabilidade encontrada segundo o OWASP Top 10 (2021)
   - Identifique a severidade usando o CVSS 3.1 (Crítico/Alto/Médio/Baixo)

2. PARA CADA VULNERABILIDADE ENCONTRADA, FORNEÇA:
   a) Nome da Vulnerabilidade: Classificação OWASP (ex: A03:2021 - Injection)
   b) Localização: Número da linha e trecho de código vulnerável
   c) Severidade: Crítica/Alta/Média/Baixa com justificativa
   d) Descrição do Problema: Explique o que está errado e por quê
   e) Cenário de Exploração: Como um atacante poderia explorar isso
   f) Impacto Potencial: Quais dados/sistemas estariam em risco
   g) Código Corrigido: Forneça o código seguro com comentários explicativos
   h) Explicação da Correção: Por que essa abordagem é segura
   i) Controles Adicionais: Outras medidas de defesa em profundidade

3. FORMATO DE RESPOSTA:
   - Use markdown para formatação clara
   - Numere as vulnerabilidades encontradas
   - Destaque trechos de código com syntax highlighting
   - Seja específico e técnico, mas também didático

4. RESUMO EXECUTIVO:
   - No final, forneça um resumo das principais vulnerabilidades
   - Priorize as correções por severidade
   - Sugira melhorias gerais de segurança para o código

CÓDIGO PARA ANÁLISE:
[Cole aqui o código vulnerável]
```

---

## 🔍 EXEMPLOS DE CÓDIGO VULNERÁVEL PARA PRÁTICA

### Exemplo 1: Python - SQL Injection e XSS

```python
from flask import Flask, request, render_template_string
import sqlite3

app = Flask(__name__)

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    
    # Vulnerabilidade aqui
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
    cursor.execute(query)
    user = cursor.fetchone()
    
    if user:
        return f"Bem-vindo, {username}!"
    else:
        return "Login falhou"

@app.route('/search')
def search():
    query = request.args.get('q', '')
    # Vulnerabilidade aqui
    return render_template_string(f"<h1>Resultados para: {query}</h1>")

if __name__ == '__main__':
    app.run(debug=True)  # Vulnerabilidade aqui
```

### Exemplo 2: JavaScript/Node.js - Command Injection e Path Traversal

```javascript
const express = require('express');
const { exec } = require('child_process');
const fs = require('fs');
const app = express();

app.use(express.json());

// Endpoint vulnerável a Command Injection
app.post('/ping', (req, res) => {
    const host = req.body.host;
    
    // Vulnerabilidade aqui
    exec(`ping -c 4 ${host}`, (error, stdout, stderr) => {
        if (error) {
            return res.status(500).send(error.message);
        }
        res.send(stdout);
    });
});

// Endpoint vulnerável a Path Traversal
app.get('/download', (req, res) => {
    const filename = req.query.file;
    
    // Vulnerabilidade aqui
    const filepath = `./uploads/${filename}`;
    
    if (fs.existsSync(filepath)) {
        res.download(filepath);
    } else {
        res.status(404).send('Arquivo não encontrado');
    }
});

// Armazenamento inseguro de credenciais
const DB_PASSWORD = 'admin123';  // Vulnerabilidade aqui
const API_KEY = 'sk-1234567890abcdef';  // Vulnerabilidade aqui

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
```

### Exemplo 3: Java - XXE e Insecure Deserialization

```java
import javax.xml.parsers.*;
import org.w3c.dom.*;
import java.io.*;

public class VulnerableXMLParser {
    
    // Vulnerável a XXE (XML External Entity)
    public static void parseXML(String xmlContent) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        // Vulnerabilidade: XXE não está desabilitado
        DocumentBuilder builder = factory.newDocumentBuilder();
        
        InputStream is = new ByteArrayInputStream(xmlContent.getBytes());
        Document doc = builder.parse(is);
        
        System.out.println("XML parsed successfully");
    }
    
    // Vulnerável a Insecure Deserialization
    public static Object deserializeObject(byte[] data) throws Exception {
        ByteArrayInputStream bis = new ByteArrayInputStream(data);
        ObjectInputStream ois = new ObjectInputStream(bis);
        
        // Vulnerabilidade: Deserialização sem validação
        return ois.readObject();
    }
    
    // Vulnerável a Hard-coded Credentials
    private static final String DB_URL = "jdbc:mysql://localhost:3306/mydb";
    private static final String DB_USER = "admin";
    private static final String DB_PASS = "P@ssw0rd123";  // Vulnerabilidade aqui
}
```

---

## 🎓 VARIAÇÕES DO PROMPT PARA DIFERENTES CENÁRIOS

### Variação 1: Foco em OWASP Top 10 Específico

```
Analise o código fornecido EXCLUSIVAMENTE procurando por vulnerabilidades relacionadas a:
- [A03:2021 - Injection]

Para cada ocorrência encontrada:
1. Identifique o tipo específico de injeção (SQL, Command, LDAP, etc.)
2. Mostre o payload que um atacante usaria
3. Demonstre o código corrigido com prepared statements/parametrização
4. Explique as diferenças de segurança entre a versão vulnerável e corrigida

CÓDIGO:
[Cole o código aqui]
```

### Variação 2: Análise Comparativa (Antes vs Depois)

```
Você receberá duas versões do mesmo código:
1. VERSÃO VULNERÁVEL (original)
2. VERSÃO CORRIGIDA (tentativa de correção)

Sua tarefa:
1. Identifique as vulnerabilidades que ainda permanecem na versão "corrigida"
2. Avalie se as correções foram implementadas corretamente
3. Sugira melhorias adicionais
4. Classifique a eficácia da correção: Completa/Parcial/Insuficiente

VERSÃO VULNERÁVEL:
[Cole código vulnerável]

VERSÃO CORRIGIDA:
[Cole código corrigido]
```

### Variação 3: Code Review com Contexto de Framework

```
Você está revisando código [Python Flask / Node.js Express / Spring Boot / etc.].

Analise considerando:
1. Vulnerabilidades específicas deste framework
2. Uso incorreto de recursos de segurança do framework
3. Configurações de segurança ausentes ou mal implementadas
4. Melhores práticas do framework que não estão sendo seguidas

Forneça exemplos de código usando recursos nativos do framework para correção.

FRAMEWORK: [Nome do framework]
CÓDIGO:
[Cole o código aqui]
```

### Variação 4: Threat Modeling via Código

```
Analise o código fornecido e crie um modelo de ameaças aplicando STRIDE:

1. SPOOFING: Possibilidades de falsificação de identidade
2. TAMPERING: Pontos onde dados podem ser adulterados
3. REPUDIATION: Ações sem logging/auditoria adequados
4. INFORMATION DISCLOSURE: Vazamento de informações sensíveis
5. DENIAL OF SERVICE: Vetores de negação de serviço
6. ELEVATION OF PRIVILEGE: Possibilidades de escalação de privilégios

Para cada categoria STRIDE encontrada:
- Identifique o código vulnerável
- Explique o cenário de ameaça
- Forneça mitigações específicas

CÓDIGO:
[Cole o código aqui]
```

---

## 📊 CHECKLIST DE VULNERABILIDADES PARA OS ALUNOS

Ao usar o prompt, certifique-se de que a IA verificou:

### Injeções
- [ ] SQL Injection
- [ ] Command Injection
- [ ] LDAP Injection
- [ ] XPath Injection
- [ ] NoSQL Injection
- [ ] Template Injection

### Autenticação e Sessão
- [ ] Credenciais hardcoded
- [ ] Senhas em texto claro
- [ ] Tokens fracos ou previsíveis
- [ ] Session fixation
- [ ] Timeout inadequado

### Criptografia
- [ ] Algoritmos fracos (MD5, SHA1)
- [ ] Chaves hardcoded
- [ ] Dados sensíveis sem criptografia
- [ ] Geração insegura de números aleatórios
- [ ] IV/Salt fixos ou ausentes

### Controle de Acesso
- [ ] IDOR (Insecure Direct Object Reference)
- [ ] Path Traversal
- [ ] Falta de autorização
- [ ] Privilege escalation
- [ ] CORS mal configurado

### Validação de Entrada
- [ ] XSS (Cross-Site Scripting)
- [ ] Input não sanitizado
- [ ] Falta de validação de tipo
- [ ] Regex bypass
- [ ] File upload sem restrições

### Configuração
- [ ] Debug mode em produção
- [ ] Informações sensíveis em logs
- [ ] Headers de segurança ausentes
- [ ] Diretórios/arquivos expostos
- [ ] Stack traces detalhados

### Dados Sensíveis
- [ ] PII sem proteção
- [ ] Logs com informações sensíveis
- [ ] Backup/cache inseguros
- [ ] Transmissão sem HTTPS
- [ ] Armazenamento inseguro

---

## 🚀 EXERCÍCIO PRÁTICO PASSO A PASSO

### PASSO 1: Escolha um código vulnerável
Selecione um dos exemplos fornecidos ou use código do OWASP Juice Shop / WebGoat.

### PASSO 2: Aplique o prompt principal
Cole o código no prompt e execute com um LLM (Claude, GPT-4, Gemini, etc.).

### PASSO 3: Analise a resposta
Verifique se a IA identificou:
- Todas as vulnerabilidades presentes
- Classificação OWASP correta
- Severidade adequada
- Código de correção funcional

### PASSO 4: Valide as correções
- Teste o código corrigido
- Execute SAST (Semgrep) no código original e corrigido
- Compare os resultados

### PASSO 5: Itere e refine
Se a IA não encontrou todas as vulnerabilidades:
- Refine o prompt com instruções mais específicas
- Use prompts de variação focados
- Peça análise mais profunda de áreas específicas

---

## 💡 DICAS PARA MAXIMIZAR RESULTADOS

### ✅ BOAS PRÁTICAS
1. **Seja específico**: Mencione linguagem, framework e contexto
2. **Divida códigos grandes**: Analise módulos separadamente
3. **Peça exemplos**: Solicite payloads de exploração e PoCs
4. **Iteração**: Refine com base nas respostas anteriores
5. **Validação**: Sempre valide com ferramentas SAST/DAST

### ❌ ARMADILHAS A EVITAR
1. Não confie cegamente na IA - sempre valide
2. Não use para código de produção sem revisão humana
3. Não compartilhe código proprietário com LLMs públicos
4. Não assuma que a IA encontrou todas as vulnerabilidades
5. Não ignore o contexto de negócio e arquitetura

---

## 📚 RECURSOS COMPLEMENTARES

### Onde Obter Código Vulnerável para Prática
- OWASP Juice Shop: https://owasp.org/www-project-juice-shop/
- OWASP WebGoat: https://owasp.org/www-project-webgoat/
- DVWA: http://www.dvwa.co.uk/
- NodeGoat: https://github.com/OWASP/NodeGoat
- SecurityShepherd: https://owasp.org/www-project-security-shepherd/

### Validação de Resultados
- Semgrep Playground: https://semgrep.dev/playground
- SonarQube: https://www.sonarqube.org/
- OWASP Dependency Check: https://owasp.org/www-project-dependency-check/

---

## 🎯 ENTREGÁVEL DO EXERCÍCIO

Ao final do laboratório, cada aluno deve produzir:

1. **Relatório de Análise** contendo:
   - Código vulnerável original
   - Lista de vulnerabilidades encontradas pela IA
   - Classificação OWASP de cada vulnerabilidade
   - Código corrigido com comentários
   - Validação com ferramenta SAST

2. **Comparação IA vs SAST**:
   - Vulnerabilidades que a IA encontrou mas o SAST não
   - Vulnerabilidades que o SAST encontrou mas a IA não
   - Falsos positivos de cada abordagem
   - Conclusões sobre quando usar cada ferramenta

3. **Prompt Refinado**:
   - Versão otimizada do prompt que gerou melhores resultados
   - Explicação das modificações feitas
   - Casos de uso específicos para o prompt customizado

---

## ⚠️ CONSIDERAÇÕES DE SEGURANÇA E ÉTICA

### Uso Responsável de IA em Segurança
- ✅ Use para aprendizado e treinamento
- ✅ Use em código de teste e laboratório
- ✅ Valide sempre com ferramentas especializadas
- ❌ Não envie código proprietário para LLMs públicos
- ❌ Não confie apenas na IA para decisões de segurança críticas
- ❌ Não use para burlar controles de segurança

### Privacidade de Dados
- Remova dados sensíveis antes de enviar código para análise
- Substitua credenciais reais por placeholders
- Anonimize informações de negócio
- Use LLMs locais/privados quando lidar com código sensível

---

## 📝 TEMPLATE DE RELATÓRIO PARA OS ALUNOS

```markdown
# Relatório de Análise de Código Vulnerável com IA

**Aluno:** [Nome]
**Data:** [Data]
**Código Analisado:** [Nome/Fonte do código]

## 1. Código Original
```[linguagem]
[Cole o código vulnerável original]
```

## 2. Prompt Utilizado
```
[Cole o prompt usado]
```

## 3. Vulnerabilidades Identificadas pela IA

### Vulnerabilidade #1: [Nome]
- **OWASP:** [Classificação]
- **Severidade:** [Crítica/Alta/Média/Baixa]
- **Linha:** [Número]
- **Descrição:** [Explicação]
- **Exploração:** [Como atacar]
- **Impacto:** [Consequências]

### Vulnerabilidade #2: [Nome]
[Repetir estrutura acima]

## 4. Código Corrigido
```[linguagem]
[Cole o código corrigido pela IA]
```

## 5. Validação com SAST
- **Ferramenta:** [Semgrep/SonarQube/etc]
- **Vulnerabilidades no código original:** [Número]
- **Vulnerabilidades no código corrigido:** [Número]
- **Comparação:**
  - IA encontrou mas SAST não: [Lista]
  - SAST encontrou mas IA não: [Lista]

## 6. Análise Crítica
- O que a IA fez bem?
- O que a IA deixou passar?
- As correções propostas são adequadas?
- Melhorias sugeridas?

## 7. Conclusões
[Suas conclusões sobre o uso de IA para code review]
```

---

**FIM DO DOCUMENTO**

Este material foi desenvolvido para o Módulo 7 - "IA e Desenvolvimento Seguro" do curso de Pós-Graduação em Cibersegurança Defensiva.

Professor: Fernando Silva - Engenheiro de Segurança de Aplicações
