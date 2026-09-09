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