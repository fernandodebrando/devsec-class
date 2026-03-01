#####################################################################
# VULNERABILIDADE 3: CREDENCIAIS HARDCODED
# Nunca se deve criar ou armazenar chaves de acesso IAM diretamente no código-fonte.
#####################################################################

# 1. Criação de Usuário IAM
resource "aws_iam_user" "usuario_teste" {
  name = "dev-com-acesso-de-emergencia"
  # ...
}

# 2. Criação da Chave de Acesso no IaC
resource "aws_iam_access_key" "chave_secreta" {
  user    = aws_iam_user.usuario_teste.name
  # ESTE BLOCO GERA UMA VULNERABILIDADE CRÍTICA!
  # O Checkov/TFSec detectará esta prática como um erro grave, pois a chave
  # (Access Key ID e Secret Key) será escrita nos arquivos de estado do Terraform.
}