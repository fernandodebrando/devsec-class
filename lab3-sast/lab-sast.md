# Laboratório Prático: SAST - Static Application Security Testing
## Módulo 3 - O Antivírus do Código-Fonte

---

## 🎯 OBJETIVOS DO LABORATÓRIO

Ao final deste laboratório, você será capaz de:

1. ✅ Executar análise estática de código com Semgrep
2. ✅ Identificar vulnerabilidades sem executar a aplicação
3. ✅ Criar regras customizadas para padrões específicos
4. ✅ Integrar SAST em IDE e pipelines CI/CD
5. ✅ Comparar SAST com revisão manual de código
6. ✅ Validar correções de vulnerabilidades
7. ✅ Entender limitações e falsos positivos do SAST

**Duração:** 1.5 horas  
**Nível:** Intermediário  
**Pré-requisitos:** Python/JavaScript/Java básico, conhecimento de Git

---

## 📚 PARTE 1: CONFIGURAÇÃO DO AMBIENTE (10 minutos)

### 🛠️ Instalação das Ferramentas

#### Opção 1: Semgrep (Recomendado)

```bash
# Instalação via pip
pip install semgrep --break-system-packages

# Verificar instalação
semgrep --version

# OU via Homebrew (macOS)
brew install semgrep

# OU via Docker
docker pull returntocorp/semgrep:latest
alias semgrep='docker run --rm -v $(pwd):/src returntocorp/semgrep semgrep'
```

---

#### Opção 2: SonarQube Community (Opcional - Análise Complementar)

```bash
# Subir SonarQube com Docker
docker run -d --name sonarqube \
  -p 9000:9000 \
  sonarqube:community

# Aguardar inicialização (pode levar 2-3 minutos)
echo "Aguardando SonarQube inicializar..."
sleep 180

# Acessar: http://localhost:9000
# Login padrão: admin / Admin123456&
echo "✅ SonarQube disponível em: http://localhost:9000"
```

---

#### Configuração do IDE (VS Code)

```bash
# Instalar extensão Semgrep para VS Code
code --install-extension semgrep.semgrep

# OU manualmente:
# 1. Abrir VS Code
# 2. Extensions (Ctrl+Shift+X)
# 3. Buscar "Semgrep"
# 4. Instalar
```

---

### 📦 Código Vulnerável para Análise

#### Projeto 1: Python Flask - Aplicação Web Vulnerável

```bash
# Criar diretório do projeto
mkdir vulnerable-flask-app
cd vulnerable-flask-app

# Criar aplicação vulnerável app.py
cat > app.py << 'EOF'
# app.py - CÓDIGO INTENCIONALMENTE VULNERÁVEL PARA APRENDIZADO

from flask import Flask, request, render_template_string, redirect
import sqlite3
import os
import subprocess
import pickle
import yaml

app = Flask(__name__)

# VULNERABILIDADE #1: Secret Key Hardcoded
app.config['SECRET_KEY'] = 'super-secret-key-123'  # SAST deve detectar!

# VULNERABILIDADE #2: Debug Mode em Produção
app.config['DEBUG'] = True  # SAST deve detectar!

# VULNERABILIDADE #3: SQL Injection
@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    
    # String concatenation direta - SQL Injection!
    query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
    
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute(query)  # VULNERÁVEL!
    user = cursor.fetchone()
    
    if user:
        return "Login successful"
    return "Login failed"

# VULNERABILIDADE #4: SQL Injection (outra variante)
@app.route('/user/<user_id>')
def get_user(user_id):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    
    # String formatting - SQL Injection!
    cursor.execute("SELECT * FROM users WHERE id = " + user_id)  # VULNERÁVEL!
    user = cursor.fetchone()
    
    return str(user)

# VULNERABILIDADE #5: XSS (Cross-Site Scripting)
@app.route('/search')
def search():
    query = request.args.get('q', '')
    
    # Template injection - XSS!
    template = f"<h1>Resultados para: {query}</h1>"  # VULNERÁVEL!
    return render_template_string(template)

# VULNERABILIDADE #6: XSS (outra variante)
@app.route('/comment', methods=['POST'])
def comment():
    user_comment = request.form['comment']
    
    # Renderização direta sem escape - XSS!
    return render_template_string(f"<p>Comentário: {user_comment}</p>")  # VULNERÁVEL!

# VULNERABILIDADE #7: Command Injection
@app.route('/ping')
def ping():
    host = request.args.get('host', 'localhost')
    
    # Comando shell com input do usuário - Command Injection!
    result = os.system(f"ping -c 4 {host}")  # VULNERÁVEL!
    return f"Ping result: {result}"

# VULNERABILIDADE #8: Command Injection (subprocess)
@app.route('/dig')
def dig():
    domain = request.args.get('domain')
    
    # subprocess com shell=True - Command Injection!
    output = subprocess.check_output(f"dig {domain}", shell=True)  # VULNERÁVEL!
    return output

# VULNERABILIDADE #9: Path Traversal
@app.route('/download')
def download():
    filename = request.args.get('file')
    
    # Path traversal - leitura de arquivos arbitrários!
    with open(f"/var/www/uploads/{filename}", 'r') as f:  # VULNERÁVEL!
        content = f.read()
    return content

# VULNERABILIDADE #10: Insecure Deserialization
@app.route('/load', methods=['POST'])
def load_data():
    data = request.data
    
    # pickle.loads sem validação - RCE (Remote Code Execution)!
    obj = pickle.loads(data)  # VULNERÁVEL!
    return str(obj)

# VULNERABILIDADE #11: YAML Deserialization
@app.route('/config', methods=['POST'])
def load_config():
    config_data = request.data
    
    # yaml.load sem Loader seguro - RCE!
    config = yaml.load(config_data)  # VULNERÁVEL! (deve usar safe_load)
    return str(config)

# VULNERABILIDADE #12: Weak Cryptography
@app.route('/hash')
def hash_password():
    password = request.args.get('password')
    
    # MD5 é criptograficamente quebrado!
    import hashlib
    hashed = hashlib.md5(password.encode()).hexdigest()  # VULNERÁVEL!
    return hashed

# VULNERABILIDADE #13: Hardcoded Credentials
DB_PASSWORD = "admin123"  # VULNERÁVEL!
API_KEY = "sk-1234567890abcdef"  # VULNERÁVEL!

# VULNERABILIDADE #14: Eval Usage
@app.route('/calc')
def calculator():
    expression = request.args.get('expr')
    
    # eval() com input do usuário - Code Injection!
    result = eval(expression)  # VULNERÁVEL!
    return str(result)

# VULNERABILIDADE #15: SSRF (Server-Side Request Forgery)
@app.route('/fetch')
def fetch_url():
    url = request.args.get('url')
    
    import urllib.request
    # Requisição sem validação - SSRF!
    response = urllib.request.urlopen(url)  # VULNERÁVEL!
    return response.read()

# VULNERABILIDADE #16: Open Redirect
@app.route('/redirect')
def redirect_user():
    target = request.args.get('url')
    
    # Redirect sem validação - Open Redirect!
    return redirect(target)  # VULNERÁVEL!

# VULNERABILIDADE #17: Regex DoS (ReDoS)
@app.route('/validate')
def validate_email():
    import re
    email = request.args.get('email')
    
    # Regex vulnerável a ReDoS!
    pattern = r'^([a-zA-Z0-9]+)*@([a-zA-Z0-9]+)*\.com$'  # VULNERÁVEL!
    if re.match(pattern, email):
        return "Valid"
    return "Invalid"

if __name__ == '__main__':
    # VULNERABILIDADE #18: Servidor rodando em 0.0.0.0
    app.run(host='0.0.0.0', port=5000, debug=True)  # VULNERÁVEL!
EOF

# Criar requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.0
PyYAML==6.0
EOF

echo "✅ Aplicação Python vulnerável criada!"
```

---

#### Projeto 2: Node.js/Express - API Vulnerável

```bash
# Criar diretório do projeto
mkdir vulnerable-node-api
cd vulnerable-node-api

# Criar package.json
cat > package.json << 'EOF'
{
  "name": "vulnerable-node-api",
  "version": "1.0.0",
  "description": "API Node.js vulnerável para demonstração de SAST",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.2",
    "mysql": "^2.18.1",
    "jsonwebtoken": "^9.0.0"
  }
}
EOF

# Criar servidor vulnerável
cat > server.js << 'EOF'
// server.js - CÓDIGO INTENCIONALMENTE VULNERÁVEL

const express = require('express');
const mysql = require('mysql');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { exec } = require('child_process');
const fs = require('fs');

const app = express();
app.use(express.json());

// VULNERABILIDADE #1: Hardcoded Secrets
const JWT_SECRET = 'my-secret-key-123';  // SAST deve detectar!
const DB_PASSWORD = 'admin123';  // SAST deve detectar!

// VULNERABILIDADE #2: SQL Injection
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    
    const connection = mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: DB_PASSWORD,
        database: 'users'
    });
    
    // String concatenation - SQL Injection!
    const query = "SELECT * FROM users WHERE username = '" + username + 
                  "' AND password = '" + password + "'";
    
    connection.query(query, (err, results) => {  // VULNERÁVEL!
        if (err) throw err;
        res.json(results);
    });
});

// VULNERABILIDADE #3: SQL Injection (template literals)
app.get('/user/:id', (req, res) => {
    const userId = req.params.id;
    
    const connection = mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: DB_PASSWORD
    });
    
    // Template literals - SQL Injection!
    const query = `SELECT * FROM users WHERE id = ${userId}`;  // VULNERÁVEL!
    
    connection.query(query, (err, results) => {
        if (err) throw err;
        res.json(results);
    });
});

// VULNERABILIDADE #4: NoSQL Injection (MongoDB style)
app.post('/find', (req, res) => {
    const { username } = req.body;
    
    // Objeto direto do req.body - NoSQL Injection!
    db.collection('users').find({ username: username }).toArray((err, docs) => {
        // Se username for: { $ne: null }, retorna todos os usuários!
        res.json(docs);
    });
});

// VULNERABILIDADE #5: Command Injection
app.get('/ping', (req, res) => {
    const host = req.query.host;
    
    // exec com input não sanitizado - Command Injection!
    exec(`ping -c 4 ${host}`, (error, stdout, stderr) => {  // VULNERÁVEL!
        res.send(stdout);
    });
});

// VULNERABILIDADE #6: Path Traversal
app.get('/file', (req, res) => {
    const filename = req.query.name;
    
    // Path traversal - leitura de arquivos arbitrários!
    const filePath = `./uploads/${filename}`;  // VULNERÁVEL!
    
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            res.status(404).send('File not found');
            return;
        }
        res.send(data);
    });
});

// VULNERABILIDADE #7: Regex DoS
app.get('/validate', (req, res) => {
    const email = req.query.email;
    
    // Regex vulnerável a ReDoS!
    const emailRegex = /^([a-zA-Z0-9]+)*@([a-zA-Z0-9]+)*\.com$/;  // VULNERÁVEL!
    
    if (emailRegex.test(email)) {
        res.send('Valid email');
    } else {
        res.send('Invalid email');
    }
});

// VULNERABILIDADE #8: Weak JWT
app.post('/token', (req, res) => {
    const { userId } = req.body;
    
    // Algoritmo fraco (HS256) com secret hardcoded
    const token = jwt.sign(
        { userId: userId },
        JWT_SECRET,  // VULNERÁVEL!
        { algorithm: 'HS256' }  // Algoritmo fraco
    );
    
    res.json({ token });
});

// VULNERABILIDADE #9: JWT com algorithm: 'none'
app.post('/unsafe-token', (req, res) => {
    const { userId } = req.body;
    
    // algorithm: 'none' permite bypass de assinatura!
    const token = jwt.sign(
        { userId: userId },
        '',
        { algorithm: 'none' }  // VULNERÁVEL!
    );
    
    res.json({ token });
});

// VULNERABILIDADE #10: Weak Crypto
app.get('/encrypt', (req, res) => {
    const data = req.query.data;
    
    // DES é algoritmo fraco!
    const cipher = crypto.createCipher('des', 'password');  // VULNERÁVEL!
    let encrypted = cipher.update(data, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    res.send(encrypted);
});

// VULNERABILIDADE #11: Eval Usage
app.post('/calculate', (req, res) => {
    const { expression } = req.body;
    
    // eval() com input do usuário - Code Injection!
    const result = eval(expression);  // VULNERÁVEL!
    
    res.json({ result });
});

// VULNERABILIDADE #12: SSRF
app.get('/fetch', (req, res) => {
    const url = req.query.url;
    
    const https = require('https');
    
    // Requisição sem validação - SSRF!
    https.get(url, (response) => {  // VULNERÁVEL!
        let data = '';
        response.on('data', (chunk) => { data += chunk; });
        response.on('end', () => { res.send(data); });
    });
});

// VULNERABILIDADE #13: Prototype Pollution
app.post('/merge', (req, res) => {
    const userInput = req.body;
    const target = {};
    
    // Merge sem proteção - Prototype Pollution!
    Object.assign(target, userInput);  // VULNERÁVEL se userInput tiver __proto__
    
    res.json(target);
});

// VULNERABILIDADE #14: XSS (em API que retorna HTML)
app.get('/search', (req, res) => {
    const query = req.query.q;
    
    // HTML injection - XSS!
    res.send(`<h1>Results for: ${query}</h1>`);  // VULNERÁVEL!
});

// VULNERABILIDADE #15: Insecure Random
app.get('/token-gen', (req, res) => {
    // Math.random() não é criptograficamente seguro!
    const token = Math.random().toString(36).substring(7);  // VULNERÁVEL!
    
    res.json({ token });
});

// Iniciar servidor
app.listen(3000, '0.0.0.0', () => {  // VULNERÁVEL: 0.0.0.0
    console.log('Server running on port 3000');
});
EOF

echo "✅ API Node.js vulnerável criada!"
```

---

#### Projeto 3: Java Spring - Aplicação Vulnerável

```bash
# Criar diretório do projeto
mkdir vulnerable-java-app
cd vulnerable-java-app

# Criar UserController.java
cat > UserController.java << 'EOF'
// UserController.java - CÓDIGO INTENCIONALMENTE VULNERÁVEL

package com.example.vulnerable;

import org.springframework.web.bind.annotation.*;
import java.sql.*;
import java.io.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import java.security.MessageDigest;

@RestController
@RequestMapping("/api")
public class UserController {
    
    // VULNERABILIDADE #1: Hardcoded Credentials
    private static final String DB_PASSWORD = "admin123";  // SAST deve detectar!
    private static final String API_KEY = "sk-1234567890abcdef";  // SAST deve detectar!
    
    // VULNERABILIDADE #2: SQL Injection
    @PostMapping("/login")
    public String login(@RequestParam String username, @RequestParam String password) {
        try {
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/users", 
                "root", 
                DB_PASSWORD
            );
            
            // String concatenation - SQL Injection!
            String query = "SELECT * FROM users WHERE username='" + username + 
                          "' AND password='" + password + "'";
            
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(query);  // VULNERÁVEL!
            
            if (rs.next()) {
                return "Login successful";
            }
            return "Login failed";
            
        } catch (SQLException e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #3: Command Injection
    @GetMapping("/ping")
    public String ping(@RequestParam String host) {
        try {
            // Runtime.exec com input não sanitizado - Command Injection!
            Process process = Runtime.getRuntime().exec("ping -c 4 " + host);  // VULNERÁVEL!
            
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream())
            );
            
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            
            return output.toString();
            
        } catch (IOException e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #4: Path Traversal
    @GetMapping("/download")
    public String downloadFile(@RequestParam String filename) {
        try {
            // Path traversal - leitura de arquivos arbitrários!
            File file = new File("/var/www/uploads/" + filename);  // VULNERÁVEL!
            
            BufferedReader reader = new BufferedReader(new FileReader(file));
            StringBuilder content = new StringBuilder();
            String line;
            
            while ((line = reader.readLine()) != null) {
                content.append(line).append("\n");
            }
            
            reader.close();
            return content.toString();
            
        } catch (IOException e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #5: Weak Cryptography - MD5
    @GetMapping("/hash")
    public String hashPassword(@RequestParam String password) {
        try {
            // MD5 é criptograficamente quebrado!
            MessageDigest md = MessageDigest.getInstance("MD5");  // VULNERÁVEL!
            byte[] hash = md.digest(password.getBytes());
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            return hexString.toString();
            
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #6: Weak Cryptography - DES
    @GetMapping("/encrypt")
    public String encrypt(@RequestParam String data) {
        try {
            // DES é algoritmo fraco!
            SecretKeySpec key = new SecretKeySpec("12345678".getBytes(), "DES");  // VULNERÁVEL!
            Cipher cipher = Cipher.getInstance("DES");
            cipher.init(Cipher.ENCRYPT_MODE, key);
            
            byte[] encrypted = cipher.doFinal(data.getBytes());
            return new String(encrypted);
            
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #7: XXE (XML External Entity)
    @PostMapping("/parse-xml")
    public String parseXml(@RequestBody String xmlContent) {
        try {
            javax.xml.parsers.DocumentBuilderFactory factory = 
                javax.xml.parsers.DocumentBuilderFactory.newInstance();
            
            // XXE não está desabilitado!
            // Deveria ter: factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            
            javax.xml.parsers.DocumentBuilder builder = factory.newDocumentBuilder();  // VULNERÁVEL!
            org.w3c.dom.Document doc = builder.parse(
                new java.io.ByteArrayInputStream(xmlContent.getBytes())
            );
            
            return "XML parsed successfully";
            
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #8: Insecure Deserialization
    @PostMapping("/deserialize")
    public String deserializeObject(@RequestBody byte[] data) {
        try {
            // Deserialização sem validação - RCE!
            ObjectInputStream ois = new ObjectInputStream(
                new ByteArrayInputStream(data)
            );
            
            Object obj = ois.readObject();  // VULNERÁVEL!
            return obj.toString();
            
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #9: LDAP Injection
    @GetMapping("/ldap-search")
    public String ldapSearch(@RequestParam String username) {
        try {
            javax.naming.directory.DirContext ctx = 
                new javax.naming.directory.InitialDirContext();
            
            // LDAP injection - input não sanitizado!
            String filter = "(uid=" + username + ")";  // VULNERÁVEL!
            
            ctx.search("ou=users,dc=example,dc=com", filter, null);
            return "Search completed";
            
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }
    
    // VULNERABILIDADE #10: Insecure Random
    @GetMapping("/generate-token")
    public String generateToken() {
        // java.util.Random não é criptograficamente seguro!
        java.util.Random random = new java.util.Random();  // VULNERÁVEL!
        long token = random.nextLong();
        
        return String.valueOf(token);
    }
}
EOF

echo "✅ Aplicação Java vulnerável criada!"
```

---

## 🔍 PARTE 2: SEMGREP - ANÁLISE BÁSICA (20 minutos)

### 📝 EXERCÍCIO 2.1: Primeiro Scan com Semgrep

```bash
cd vulnerable-flask-app

# Scan básico com regras automáticas
semgrep --config=auto app.py

# Scan com output colorido e detalhado
semgrep --config=auto app.py --verbose

# Scan com métricas
semgrep --config=auto app.py --metrics=on
```

**Saída Esperada:**

```
┌─────────────────┐
│ 17 Code Findings │
└─────────────────┘

  app.py
  ❯❯❱ dangerous-template-string
       Template string with user input detected. This can lead to XSS.

       19┆ template = f"<h1>Resultados para: {query}</h1>"

  ❯❯❱ sql-injection
       SQL injection detected. Use parameterized queries.

       11┆ query = f"SELECT * FROM users WHERE username='{username}'"

  [... mais findings ...]
```

---

### 📊 TAREFA 1: Categorizar Vulnerabilidades Encontradas

Preencha a tabela com os resultados do Semgrep:

| Tipo de Vulnerabilidade | Quantidade | Severidade | CWE | Linha(s) |
|-------------------------|------------|------------|-----|----------|
| SQL Injection | _____ | _____ | CWE-89 | _____ |
| XSS | _____ | _____ | CWE-79 | _____ |
| Command Injection | _____ | _____ | CWE-78 | _____ |
| Hardcoded Secrets | _____ | _____ | CWE-798 | _____ |
| Weak Crypto | _____ | _____ | CWE-327 | _____ |
| Insecure Deserialization | _____ | _____ | CWE-502 | _____ |
| Path Traversal | _____ | _____ | CWE-22 | _____ |
| Code Injection (eval) | _____ | _____ | CWE-95 | _____ |

---

### 📝 EXERCÍCIO 2.2: Scan com Rulesets Específicos

```bash
# Scan focado em OWASP Top 10
semgrep --config=p/owasp-top-ten app.py

# Scan focado em Security
semgrep --config=p/security-audit app.py

# Scan focado em Python
semgrep --config=p/python app.py

# Scan focado em CWE Top 25
semgrep --config=p/cwe-top-25 app.py

# Scan com múltiplos rulesets
semgrep --config=p/owasp-top-ten --config=p/security-audit app.py

# Listar todos os rulesets disponíveis
semgrep --config=auto --list
```

**Rulesets Disponíveis:**

```
p/owasp-top-ten      - OWASP Top 10 2021
p/security-audit     - Auditoria de segurança abrangente
p/cwe-top-25         - CWE Top 25 Most Dangerous
p/python             - Python security patterns
p/flask              - Flask specific vulnerabilities
p/django             - Django specific
p/r2c-security-audit - Regras mantidas pela r2c
```

---

### 📝 EXERCÍCIO 2.3: Output em Diferentes Formatos

```bash
# JSON (para integração CI/CD)
semgrep --config=auto app.py --json > semgrep-results.json

# SARIF (GitHub Security)
semgrep --config=auto app.py --sarif > semgrep-results.sarif

# JUnit XML (para relatórios CI)
semgrep --config=auto app.py --junit-xml > semgrep-results.xml

# GitLab SAST format
semgrep --config=auto app.py --gitlab-sast > gl-sast-report.json

# Texto formatado para humanos
semgrep --config=auto app.py --text > semgrep-report.txt

# HTML (não nativo, mas pode converter JSON)
semgrep --config=auto app.py --json | \
  python -c "import json, sys; print(json.dumps(json.load(sys.stdin), indent=2))" > report.json
```

---

## 🔧 PARTE 3: CORREÇÃO DE VULNERABILIDADES (20 minutos)

### 📝 EXERCÍCIO 3.1: Corrigir SQL Injection

**Código Vulnerável:**
```python
# ANTES (Vulnerável)
query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
cursor.execute(query)  # SQL Injection!
```

**Código Corrigido:**
```python
# DEPOIS (Seguro)
query = "SELECT * FROM users WHERE username = ? AND password = ?"
cursor.execute(query, (username, password))  # Prepared statement
```

**Criar app_secure.py:**

```bash
cat > app_secure.py << 'EOF'
# app_secure.py - VERSÃO CORRIGIDA

from flask import Flask, request, render_template, redirect, url_for
import sqlite3
import os
import subprocess
import hashlib
import secrets
from werkzeug.security import check_password_hash
from markupsafe import escape

app = Flask(__name__)

# CORREÇÃO #1: Secret key de variável de ambiente
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', secrets.token_hex(32))

# CORREÇÃO #2: Debug mode apenas em desenvolvimento
app.config['DEBUG'] = os.environ.get('FLASK_ENV') == 'development'

# CORREÇÃO #3: SQL Injection corrigido com prepared statements
@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    
    # Prepared statement - SEGURO!
    query = "SELECT * FROM users WHERE username = ? AND password = ?"
    cursor.execute(query, (username, password))
    user = cursor.fetchone()
    
    if user:
        return "Login successful"
    return "Login failed"

# CORREÇÃO #4: XSS corrigido com escape automático
@app.route('/search')
def search():
    query = request.args.get('q', '')
    
    # Usando template com auto-escape
    return render_template('search.html', query=escape(query))

# CORREÇÃO #5: Command Injection prevenido com lista de argumentos
@app.route('/ping')
def ping():
    host = request.args.get('host', 'localhost')
    
    # Validação de input
    if not host.replace('.', '').replace('-', '').isalnum():
        return "Invalid host", 400
    
    # Lista de argumentos ao invés de shell command
    try:
        result = subprocess.run(
            ['ping', '-c', '4', host],
            capture_output=True,
            text=True,
            timeout=10,
            check=False
        )
        return result.stdout
    except subprocess.TimeoutExpired:
        return "Timeout", 408

# CORREÇÃO #6: Path Traversal prevenido
@app.route('/download')
def download():
    filename = request.args.get('file')
    
    # Validar filename (apenas alfanuméricos e extensões permitidas)
    if not filename or '..' in filename or '/' in filename:
        return "Invalid filename", 400
    
    allowed_extensions = {'.txt', '.pdf', '.jpg'}
    if not any(filename.endswith(ext) for ext in allowed_extensions):
        return "File type not allowed", 400
    
    # Base path segura
    safe_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    safe_path = os.path.abspath(safe_path)
    
    # Verificar que path está dentro do diretório permitido
    if not safe_path.startswith(os.path.abspath(app.config['UPLOAD_FOLDER'])):
        return "Access denied", 403
    
    try:
        with open(safe_path, 'r') as f:
            content = f.read()
        return content
    except FileNotFoundError:
        return "File not found", 404

# CORREÇÃO #7: Criptografia forte
@app.route('/hash')
def hash_password():
    password = request.args.get('password')
    
    # Usar bcrypt ou argon2 em produção
    # Por simplicidade, usando SHA-256 + salt
    salt = secrets.token_hex(16)
    hashed = hashlib.sha256((password + salt).encode()).hexdigest()
    
    return f"{salt}:{hashed}"

# CORREÇÃO #8: Remover eval completamente
# Se realmente precisar de cálculos, usar biblioteca segura
@app.route('/calc')
def calculator():
    # OPÇÃO 1: Não implementar
    return "Feature removed for security", 501
    
    # OPÇÃO 2: Usar biblioteca segura (simpleeval, asteval)
    # from simpleeval import simple_eval
    # result = simple_eval(expression)

if __name__ == '__main__':
    # CORREÇÃO #9: Bind apenas em localhost em desenvolvimento
    app.run(host='127.0.0.1', port=5000, debug=False)
EOF

echo "✅ Versão segura criada!"
```

---

### 📊 TAREFA 2: Validar Correções com Semgrep

```bash
# Scan na versão vulnerável
echo "=== VERSÃO VULNERÁVEL ===" > comparison.txt
semgrep --config=auto app.py --json | \
  jq '.results | length' >> comparison.txt

# Scan na versão corrigida
echo "=== VERSÃO CORRIGIDA ===" >> comparison.txt
semgrep --config=auto app_secure.py --json | \
  jq '.results | length' >> comparison.txt

# Mostrar comparação
cat comparison.txt

# Verificar se vulnerabilidades específicas foram corrigidas
semgrep --config=auto app_secure.py | grep -i "sql-injection"
semgrep --config=auto app_secure.py | grep -i "command-injection"
semgrep --config=auto app_secure.py | grep -i "xss"
```

**Resultados Esperados:**

| Métrica | app.py (Vulnerável) | app_secure.py (Corrigido) |
|---------|---------------------|---------------------------|
| Total de findings | 17-20 | 0-2 |
| SQL Injection | 2 | 0 |
| XSS | 2 | 0 |
| Command Injection | 2 | 0 |
| Hardcoded Secrets | 3 | 0 |

---

## 🎨 PARTE 4: REGRAS CUSTOMIZADAS (15 minutos)

### 📝 EXERCÍCIO 4.1: Criar Regra Customizada

Semgrep usa YAML para definir regras. Vamos criar regras específicas para nosso contexto.

```bash
# Criar diretório de regras
mkdir semgrep-rules
cd semgrep-rules

# Criar regra para detectar uso de pickle
cat > detect-pickle.yaml << 'EOF'
rules:
  - id: dangerous-pickle-usage
    pattern: pickle.loads($DATA)
    message: |
      Uso de pickle.loads() detectado. Pickle pode executar código arbitrário
      durante desserialização. Use json.loads() ou outro formato seguro.
    languages: [python]
    severity: ERROR
    metadata:
      cwe: "CWE-502: Deserialization of Untrusted Data"
      owasp: "A08:2021 - Software and Data Integrity Failures"
      references:
        - https://owasp.org/www-community/vulnerabilities/Deserialization_of_untrusted_data
    fix: json.loads($DATA)
EOF

# Criar regra para detectar yaml.load inseguro
cat > detect-unsafe-yaml.yaml << 'EOF'
rules:
  - id: yaml-load-unsafe
    patterns:
      - pattern: yaml.load($DATA)
      - pattern-not: yaml.load($DATA, Loader=yaml.SafeLoader)
      - pattern-not: yaml.safe_load($DATA)
    message: |
      yaml.load() sem SafeLoader é inseguro e pode executar código arbitrário.
      Use yaml.safe_load() ou yaml.load() com Loader=yaml.SafeLoader.
    languages: [python]
    severity: ERROR
    metadata:
      cwe: "CWE-502"
    fix: yaml.safe_load($DATA)
EOF

# Criar regra para detectar MD5/SHA1
cat > detect-weak-hash.yaml << 'EOF'
rules:
  - id: weak-hash-md5
    patterns:
      - pattern-either:
          - pattern: hashlib.md5(...)
          - pattern: hashlib.sha1(...)
    message: |
      MD5 e SHA1 são algoritmos de hash criptograficamente quebrados.
      Use SHA-256, SHA-384 ou SHA-512 para segurança.
    languages: [python]
    severity: WARNING
    metadata:
      cwe: "CWE-327: Use of a Broken or Risky Cryptographic Algorithm"
    fix: hashlib.sha256(...)
EOF

# Criar regra customizada para seu framework interno
cat > company-specific-rule.yaml << 'EOF'
rules:
  - id: company-forbidden-import
    pattern: |
      import legacy_framework
    message: |
      O framework 'legacy_framework' está deprecated e tem vulnerabilidades conhecidas.
      Use 'modern_framework' ao invés.
    languages: [python]
    severity: WARNING
    metadata:
      category: "company-policy"
EOF
```

---

### 📝 EXERCÍCIO 4.2: Executar Regras Customizadas

```bash
cd ..

# Executar apenas regras customizadas
semgrep --config=semgrep-rules/ app.py

# Combinar regras padrão com customizadas
semgrep --config=auto --config=semgrep-rules/ app.py

# Executar regra específica
semgrep --config=semgrep-rules/detect-pickle.yaml app.py
```

---

### 📝 EXERCÍCIO 4.3: Regra com Múltiplos Padrões

Regras podem ser complexas. Vamos criar uma para detectar SQL injection considerando diferentes variações:

```bash
cat > semgrep-rules/advanced-sqli.yaml << 'EOF'
rules:
  - id: sql-injection-advanced
    mode: taint
    pattern-sources:
      - patterns:
          - pattern-either:
              - pattern: request.form[$KEY]
              - pattern: request.args[$KEY]
              - pattern: request.json[$KEY]
              - pattern: request.data
    pattern-sinks:
      - patterns:
          - pattern-either:
              - pattern: cursor.execute($QUERY, ...)
              - pattern: cursor.executemany($QUERY, ...)
              - pattern: connection.execute($QUERY, ...)
          - pattern-not: cursor.execute("...", (...))
          - pattern-not: cursor.execute($QUERY, $PARAMS)
    message: |
      Possível SQL Injection detectado. Input do usuário sendo usado em query SQL.
      SEMPRE use prepared statements com placeholders (?) ou named parameters.
    languages: [python]
    severity: ERROR
    metadata:
      cwe: "CWE-89"
      owasp: "A03:2021 - Injection"
      confidence: "HIGH"
EOF

# Executar regra avançada
semgrep --config=semgrep-rules/advanced-sqli.yaml app.py
```

---

## 🔄 PARTE 5: INTEGRAÇÃO COM IDE E CI/CD (15 minutos)

### 📝 EXERCÍCIO 5.1: Integração com VS Code

```bash
# A extensão Semgrep já deve estar instalada

# Criar arquivo de configuração do workspace
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
  "semgrep.scan": {
    "configuration": ["auto"],
    "exclude": ["node_modules", "venv", "*.min.js"],
    "jobs": 4
  },
  "semgrep.scanOnSave": true,
  "semgrep.severity": {
    "error": "error",
    "warning": "warning"
  }
}
EOF

# Abrir projeto no VS Code
code .

# Ao salvar arquivos, Semgrep executa automaticamente
# Vulnerabilidades aparecem como "squiggly lines" no editor
```

---

### 📝 EXERCÍCIO 5.2: Pre-commit Hook

```bash
# Instalar pre-commit
pip install pre-commit --break-system-packages

# Criar .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/returntocorp/semgrep
    rev: v1.45.0
    hooks:
      - id: semgrep
        args: ['--config=auto', '--error', '--skip-unknown-extensions']
        # Falha em vulnerabilidades de severidade ERROR
EOF

# Instalar hook
pre-commit install

# Testar (tente fazer commit do código vulnerável)
git init
git add app.py
git commit -m "Test commit"

# Semgrep vai bloquear o commit se encontrar vulnerabilidades!
```

---

### 📝 EXERCÍCIO 5.3: GitHub Actions

```bash
mkdir -p .github/workflows

cat > .github/workflows/semgrep.yml << 'EOF'
name: SAST - Semgrep Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  semgrep:
    name: Semgrep SAST Scan
    runs-on: ubuntu-latest
    
    container:
      image: returntocorp/semgrep
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run Semgrep
        run: |
          semgrep scan \
            --config=auto \
            --sarif \
            --output=semgrep.sarif
      
      - name: Upload SARIF to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: semgrep.sarif
      
      - name: Upload Semgrep results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: semgrep-results
          path: semgrep.sarif

  semgrep-full:
    name: Full Semgrep Scan (All Rules)
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install Semgrep
        run: pip install semgrep
      
      - name: Run comprehensive scan
        run: |
          semgrep scan \
            --config=p/owasp-top-ten \
            --config=p/security-audit \
            --config=p/cwe-top-25 \
            --json \
            --output=semgrep-full.json
      
      - name: Check for critical findings
        run: |
          CRITICAL=$(jq '[.results[] | select(.extra.severity == "ERROR")] | length' semgrep-full.json)
          
          echo "Critical findings: $CRITICAL"
          
          if [ "$CRITICAL" -gt 0 ]; then
            echo "❌ Found $CRITICAL critical vulnerabilities!"
            jq -r '.results[] | select(.extra.severity == "ERROR") | 
                   "\(.check_id): \(.path):\(.start.line)"' semgrep-full.json
            exit 1
          fi
          
          echo "✅ No critical vulnerabilities found"
      
      - name: Upload full results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: semgrep-full-results
          path: semgrep-full.json

  code-quality-gate:
    name: Code Quality Gate
    runs-on: ubuntu-latest
    needs: [semgrep, semgrep-full]
    if: always()
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Aggregate results
        run: |
          echo "# SAST Security Report" > report.md
          echo "" >> report.md
          
          if [ -f semgrep-full-results/semgrep-full.json ]; then
            TOTAL=$(jq '.results | length' semgrep-full-results/semgrep-full.json)
            CRITICAL=$(jq '[.results[] | select(.extra.severity == "ERROR")] | length' semgrep-full-results/semgrep-full.json)
            HIGH=$(jq '[.results[] | select(.extra.severity == "WARNING")] | length' semgrep-full-results/semgrep-full.json)
            
            echo "## Summary" >> report.md
            echo "- Total findings: $TOTAL" >> report.md
            echo "- Critical (ERROR): $CRITICAL" >> report.md
            echo "- High (WARNING): $HIGH" >> report.md
          fi
          
          cat report.md
      
      - name: Comment PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('report.md', 'utf8');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
EOF

echo "✅ GitHub Actions workflow criado!"
```

---

### 📝 EXERCÍCIO 5.4: GitLab CI

```bash
cat > .gitlab-ci.yml << 'EOF'
stages:
  - sast
  - report

variables:
  SEMGREP_RULES: "auto"

semgrep-sast:
  stage: sast
  image: returntocorp/semgrep:latest
  script:
    - semgrep scan --config=${SEMGREP_RULES} --gitlab-sast > gl-sast-report.json
  artifacts:
    reports:
      sast: gl-sast-report.json
  allow_failure: false

semgrep-detailed:
  stage: sast
  image: returntocorp/semgrep:latest
  script:
    - |
      semgrep scan \
        --config=p/owasp-top-ten \
        --config=p/security-audit \
        --json \
        --output=semgrep-results.json
  artifacts:
    paths:
      - semgrep-results.json
    expire_in: 1 week

security-report:
  stage: report
  image: python:3.11-alpine
  needs:
    - semgrep-detailed
  before_script:
    - apk add --no-cache jq
  script:
    - |
      echo "# SAST Security Report" > security-report.md
      echo "" >> security-report.md
      
      TOTAL=$(jq '.results | length' semgrep-results.json)
      CRITICAL=$(jq '[.results[] | select(.extra.severity == "ERROR")] | length' semgrep-results.json)
      
      echo "Total findings: $TOTAL" >> security-report.md
      echo "Critical: $CRITICAL" >> security-report.md
      
      if [ "$CRITICAL" -gt 0 ]; then
        echo "" >> security-report.md
        echo "## Critical Vulnerabilities" >> security-report.md
        jq -r '.results[] | select(.extra.severity == "ERROR") | 
               "- \(.check_id) in \(.path):\(.start.line)"' \
               semgrep-results.json >> security-report.md
        
        exit 1
      fi
  artifacts:
    paths:
      - security-report.md
EOF

echo "✅ GitLab CI pipeline criado!"
```

---

## 📊 PARTE 6: COMPARAÇÃO SAST VS REVISÃO MANUAL (10 minutos)

### 📝 EXERCÍCIO 6.1: Revisão Manual vs SAST

Vamos comparar tempo e eficácia:

**Revisão Manual:**

```bash
# Cronometrar revisão manual
echo "Iniciando revisão manual de app.py..."
echo "Tempo: $(date)"

# Revisar manualmente app.py procurando por:
# 1. SQL Injection
# 2. XSS
# 3. Command Injection
# 4. Hardcoded secrets
# 5. Weak crypto

# Após completar, anotar tempo gasto
echo "Tempo gasto: _____ minutos"
```

**SAST Automatizado:**

```bash
# Cronometrar SAST
echo "Iniciando SAST com Semgrep..."
time semgrep --config=auto app.py
```

---

### 📊 TAREFA 3: Comparação Detalhada

| Critério | Revisão Manual | SAST (Semgrep) |
|----------|---------------|----------------|
| Tempo para analisar 200 linhas | _____ min | _____ min |
| Vulnerabilidades encontradas | _____ | _____ |
| Falsos positivos | _____ | _____ |
| Falsos negativos | _____ | _____ |
| Consistência entre revisores | ⚠️  Baixa | ✅ Alta |
| Escalabilidade | ❌ Difícil | ✅ Fácil |
| Contexto de negócio | ✅ Considera | ❌ Não considera |
| Lógica de negócio | ✅ Detecta | ⚠️  Parcial |

**Observações:**

1. **SAST é melhor para:**
   - Detectar padrões conhecidos
   - Escalar para grandes codebases
   - Consistência e reprodutibilidade
   - Feedback rápido (segundos)

2. **Revisão Manual é melhor para:**
   - Lógica de negócio específica
   - Contexto da aplicação
   - Vulnerabilidades complexas
   - Decisões arquiteturais

3. **Abordagem Ideal:**
   - **SAST automático** em cada commit
   - **Revisão manual** em PRs importantes
   - **Combinação** para melhor cobertura

---

## 📋 ENTREGÁVEIS DO LABORATÓRIO

### 1. Relatório de Análise SAST

```markdown
# Relatório - Static Application Security Testing

**Aluno:** [Nome]
**Data:** [Data]
**Projeto Analisado:** [Aplicação Flask / Node.js / Java]

## 1. Análise Inicial - Código Vulnerável

### Scan Executado
```bash
semgrep --config=auto app.py
```

### Resumo de Resultados
- **Total de findings:** _____
- **Distribuição por severidade:**
  - ERROR (Critical): _____
  - WARNING (High): _____
  - INFO (Medium): _____

### Top 10 Vulnerabilidades Encontradas

| # | Tipo | Severidade | CWE | Linha | Descrição |
|---|------|------------|-----|-------|-----------|
| 1 | SQL Injection | ERROR | CWE-89 | 11 | String concatenation em query |
| 2 | XSS | ERROR | CWE-79 | 19 | Template string sem escape |
| ... | ... | ... | ... | ... | ... |

## 2. Correção de Vulnerabilidades

### Vulnerabilidade #1: SQL Injection (Linha 11)

**Código Vulnerável:**
```python
query = f"SELECT * FROM users WHERE username='{username}'"
```

**Código Corrigido:**
```python
query = "SELECT * FROM users WHERE username = ?"
cursor.execute(query, (username,))
```

**Explicação da Correção:**
Uso de prepared statements evita interpretação do input como parte da query SQL.

[Repetir para 5 vulnerabilidades principais]

## 3. Validação das Correções

### Scan Pós-Correção
```bash
semgrep --config=auto app_secure.py
```

### Comparação

| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| Total findings | 17 | 2 | 88% |
| Critical | 10 | 0 | 100% |
| High | 5 | 2 | 60% |

### Findings Restantes
- [Descrever findings que ainda permanecem e justificar]

## 4. Regras Customizadas

### Regras Criadas
1. **detect-pickle.yaml**
   - Objetivo: Detectar uso inseguro de pickle
   - Padrão: `pickle.loads($DATA)`
   - Severidade: ERROR

2. **detect-unsafe-yaml.yaml**
   - Objetivo: Detectar yaml.load sem SafeLoader
   - Padrão: `yaml.load($DATA)` sem SafeLoader
   - Severidade: ERROR

### Execução de Regras Customizadas
```bash
semgrep --config=semgrep-rules/ app.py
```

Findings adicionais encontrados: _____

## 5. Integração CI/CD

### Pipeline Implementado
- [ ] GitHub Actions
- [ ] GitLab CI
- [ ] Pre-commit Hook

### Testes Realizados
- Commit bloqueado com código vulnerável: [Sim/Não]
- SARIF upload para GitHub Security: [Sim/Não]
- Relatório gerado corretamente: [Sim/Não]

### Exemplo de Execução
[Screenshot ou log do pipeline]

## 6. Comparação SAST vs Revisão Manual

### Experimento Realizado
- Código analisado: app.py (200 linhas)
- Tempo de revisão manual: _____ minutos
- Tempo de SAST: _____ segundos
- Vulnerabilidades encontradas manualmente: _____
- Vulnerabilidades encontradas pelo SAST: _____

### Conclusões
[Análise sobre quando usar cada abordagem]

## 7. Lições Aprendidas

1. [Insight 1]
2. [Insight 2]
3. [Insight 3]

## 8. Limitações do SAST Observadas

- [Limitação 1: ex: não detecta lógica de negócio]
- [Limitação 2: ex: alguns falsos positivos]
- [Limitação 3]

## 9. Recomendações para Produção

1. Executar SAST em todos os PRs
2. Bloquear merge se Critical findings
3. Revisar manualmente WARNING findings
4. Criar regras customizadas para padrões internos
5. Combinar com DAST para cobertura completa
```

---

### 2. Evidências Práticas

Incluir nos entregáveis:

- ✅ Output completo do Semgrep (texto)
- ✅ Arquivo JSON com resultados (semgrep-results.json)
- ✅ SARIF file (para GitHub Security)
- ✅ Código vulnerável original (app.py)
- ✅ Código corrigido (app_secure.py)
- ✅ Regras customizadas criadas (*.yaml)
- ✅ Arquivo de configuração CI/CD (.github/workflows ou .gitlab-ci.yml)
- ✅ Screenshot do pipeline executando
- ✅ Tabela comparativa SAST vs Manual preenchida

---

## 🎯 CHECKLIST DE VERIFICAÇÃO

### Semgrep Básico ✅
- [ ] Instalei Semgrep (pip ou docker)
- [ ] Executei primeiro scan com --config=auto
- [ ] Analisei output e identifiquei tipos de vulnerabilidades
- [ ] Testei diferentes rulesets (owasp-top-ten, security-audit)
- [ ] Gerei output em JSON, SARIF e texto
- [ ] Categorizei findings por CWE e severidade

### Correção de Vulnerabilidades ✅
- [ ] Criei versão corrigida do código (app_secure.py)
- [ ] Corrigi pelo menos SQL Injection
- [ ] Corrigi pelo menos XSS
- [ ] Corrigi pelo menos Command Injection
- [ ] Corrigi hardcoded secrets
- [ ] Validei correções com novo scan
- [ ] Comparei métricas antes/depois

### Regras Customizadas ✅
- [ ] Criei pelo menos 2 regras customizadas
- [ ] Testei regras customizadas no código
- [ ] Entendi estrutura YAML das regras
- [ ] Criei regra com pattern-either
- [ ] Criei regra modo taint (opcional)

### Integração CI/CD ✅
- [ ] Configurei pre-commit hook
- [ ] Testei hook bloqueando commit vulnerável
- [ ] Criei workflow GitHub Actions OU pipeline GitLab CI
- [ ] Pipeline executa scan automaticamente
- [ ] Pipeline falha com findings críticos
- [ ] SARIF é enviado para GitHub Security (se GitHub)
- [ ] Testei pelo menos 1 execução completa

### IDE Integration ✅
- [ ] Instalei extensão Semgrep no VS Code
- [ ] Configurei scan on save
- [ ] Visualizei vulnerabilidades inline no editor
- [ ] Usei quick fixes sugeridos (se disponível)

### Comparação e Análise ✅
- [ ] Fiz revisão manual do código vulnerável
- [ ] Cronometrei tempo de revisão manual
- [ ] Comparei com tempo do SAST
- [ ] Preenchi tabela comparativa
- [ ] Identifiquei vantagens e limitações de cada abordagem
- [ ] Documentei conclusões

---

## 📚 RECURSOS ADICIONAIS

### Documentação Oficial
- **Semgrep:** https://semgrep.dev/docs/
- **Semgrep Rules:** https://semgrep.dev/explore
- **Semgrep Playground:** https://semgrep.dev/playground
- **Semgrep Registry:** https://semgrep.dev/r

### Rulesets Públicos
- **OWASP Top 10:** https://semgrep.dev/p/owasp-top-ten
- **CWE Top 25:** https://semgrep.dev/p/cwe-top-25
- **Security Audit:** https://semgrep.dev/p/security-audit
- **CI:** https://semgrep.dev/p/ci

### Criação de Regras
- **Rule Syntax:** https://semgrep.dev/docs/writing-rules/rule-syntax/
- **Pattern Examples:** https://semgrep.dev/docs/writing-rules/pattern-examples/
- **Testing Rules:** https://semgrep.dev/docs/writing-rules/testing-rules/

### Integrações
- **GitHub Actions:** https://github.com/marketplace/actions/semgrep-action
- **GitLab CI:** https://semgrep.dev/docs/semgrep-ci/running-semgrep-ci-with-gitlab-ci/
- **VS Code Extension:** https://marketplace.visualstudio.com/items?itemName=semgrep.semgrep

### Comparação de Ferramentas SAST
- **SonarQube:** https://www.sonarqube.org/
- **CodeQL:** https://codeql.github.com/
- **Checkmarx:** https://www.checkmarx.com/
- **Veracode:** https://www.veracode.com/

---

## 💡 DICAS E TROUBLESHOOTING

### Problemas Comuns

**Semgrep muito lento:**
```bash
# Usar cache
semgrep --config=auto . --use-git-ignore

# Excluir diretórios grandes
semgrep --config=auto . --exclude="node_modules" --exclude="venv"

# Limitar jobs paralelos
semgrep --config=auto . --jobs=2
```

**Muitos falsos positivos:**
```bash
# Usar severity mais alta
semgrep --config=auto . --severity=ERROR

# Criar arquivo de baseline (ignorar findings existentes)
semgrep --config=auto . --baseline-commit=main

# Usar nosemgrep comment para ignorar linha específica
# nosemgrep: rule-id
vulnerable_code_here()
```

**Regra customizada não funciona:**
```bash
# Validar sintaxe YAML
semgrep --validate --config=my-rule.yaml

# Testar regra em código específico
semgrep --config=my-rule.yaml test-file.py --verbose

# Usar Semgrep Playground para debug
# https://semgrep.dev/playground
```

**CI/CD muito lento:**
```bash
# Usar apenas regras essenciais em CI
semgrep --config=p/owasp-top-ten . # Ao invés de --config=auto

# Scan incremental (apenas arquivos modificados)
semgrep --config=auto $(git diff --name-only main..HEAD)

# Usar cache do CI
# GitHub Actions: actions/cache
# GitLab: cache: paths:
```

---

## 🏆 DESAFIOS EXTRAS

### Desafio 1: Regra Avançada com Taint Analysis
Crie regra que rastreie dados de fonte não confiável até sink perigoso:
- Source: request.args, request.form
- Sink: subprocess.call, os.system
- Deve ignorar se input foi validado

### Desafio 2: Integração Completa DevSecOps
Configure pipeline completo:
1. Pre-commit hook (SAST local)
2. PR checks (SAST + revisão manual)
3. Main branch (SAST + DAST + SCA)
4. Deploy gates (SAST + policy checks)

### Desafio 3: Falsos Positivos e Negativos
Encontre:
- 3 falsos positivos do Semgrep (flagged incorretamente)
- 3 falsos negativos (vulnerabilidades não detectadas)
- Crie issues no Semgrep Registry ou regras customizadas

### Desafio 4: Benchmark de Ferramentas
Compare:
- Semgrep
- SonarQube
- Bandit (Python)
- ESLint security plugin (JavaScript)

Métricas:
- Tempo de scan
- Vulnerabilidades encontradas
- Falsos positivos
- Facilidade de integração

---

## 📊 MÉTRICAS DE SUCESSO

Ao final do laboratório, você deve ser capaz de:

- ✅ Executar scan SAST em < 30 segundos
- ✅ Identificar e categorizar 10+ tipos de vulnerabilidades
- ✅ Criar pelo menos 2 regras customizadas funcionais
- ✅ Integrar SAST em IDE com feedback em tempo real
- ✅ Configurar pipeline CI/CD com SAST automatizado
- ✅ Corrigir 90%+ das vulnerabilidades críticas
- ✅ Entender limitações e complementaridade com outras ferramentas

**Benchmark de Redução de Vulnerabilidades:**
- Alvo: Reduzir 100% das vulnerabilidades Critical (ERROR)
- Alvo: Reduzir 80%+ das vulnerabilidades High (WARNING)
- Alvo: Documentar 100% dos findings restantes

---

**FIM DO LABORATÓRIO**

Este material foi desenvolvido para o Módulo 3 - "SAST - Static Application Security Testing" do curso de Pós-Graduação em Cibersegurança Defensiva.

Professor: Fernando Silva - Engenheiro de Segurança de Aplicações

⏱️ **Tempo Total:** 1.5 horas (podendo estender com desafios extras)
