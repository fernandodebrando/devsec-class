# app.py - Aplicação Python Flask com vulnerabilidades
from flask import Flask, request, session, redirect, url_for
import sqlite3
import os

app = Flask(__name__)

# VULNERABILIDADE 1: Credencial Hardcoded
# Um segredo de sessão crucial está diretamente no código-fonte.
# O SAST deve identificar esta string de alta entropia.
app.secret_key = 'super_secret_key_de_producao_12345' 

DATABASE = 'app_data.db'

def get_db():
    db = sqlite3.connect(DATABASE)
    db.row_factory = sqlite3.Row
    return db

@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username')
    password = request.form.get('password')
    
    # VULNERABILIDADE 2: SQL Injection Clássica
    # A variável 'username' é inserida diretamente na string de consulta (query) SQL.
    # Isto permite que um atacante insira código SQL malicioso.
    query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
    
    db = get_db()
    cursor = db.execute(query) # O Bandit/Semgrep deve apontar esta linha!
    user = cursor.fetchone()
    db.close()

    if user:
        session['logged_in'] = True
        session['username'] = user['username']
        return redirect(url_for('profile'))
    else:
        return 'Login falhou', 401

@app.route('/profile')
def profile():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    return f"Bem-vindo, {session['username']}"

@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    session.pop('username', None)
    return redirect(url_for('login'))

if __name__ == '__main__':
    # Inicializa o banco de dados para o laboratório
    if not os.path.exists(DATABASE):
        conn = sqlite3.connect(DATABASE)
        conn.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT)")
        conn.execute("INSERT INTO users (username, password) VALUES ('admin', 'adminpass')")
        conn.commit()
        conn.close()
    
    app.run(debug=True)