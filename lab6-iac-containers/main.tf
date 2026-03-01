# main.tf - Arquivo Terraform Intencionalmente Inseguro

#####################################################################
# VULNERABILIDADE 1: EXPOSIÇÃO DE DADOS (Bucket S3 Público)
# O Checkov/TFSec deve identificar que 'acl' e 'block_public_acls' 
# estão configurados de forma insegura, permitindo acesso público.
#####################################################################

resource "aws_s3_bucket" "dados_sensivies" {
  bucket = "minha-aplicacao-dados-sensivies-global"
  acl    = "public-read" # ACL INSEGURA! Permite leitura pública
  
  # A política padrão para bloquear acesso público está desabilitada ou configurada incorretamente
  # Note que block_public_acls é 'false' (padrão em alguns casos, mas inseguro)
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.dados_sensivies.id
  block_public_acls       = false  # Configuração INSEGURA - DEVERIA SER TRUE
  block_public_policy     = false  # Configuração INSEGURA - DEVERIA SER TRUE
  ignore_public_acls      = false
  restrict_public_buckets = false
}

#####################################################################
# VULNERABILIDADE 2: ACESSO DE REDE PERMISSIVO (Security Group Inseguro)
# O Security Group está abrindo o acesso a portas críticas (22 e 80)
# para qualquer lugar na Internet (0.0.0.0/0).
#####################################################################

resource "aws_security_group" "sg_web_inseguro" {
  name_prefix = "sg-web-inseguro-"
  description = "Security Group muito permissivo"
  # VPC ID seria definido aqui em um ambiente real

  ingress {
    description = "Acesso SSH Inseguro"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # INSEGURO! Acesso SSH aberto para o mundo.
  }

  ingress {
    description = "Acesso HTTP Inseguro"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # INSEGURO! Acesso HTTP aberto para o mundo.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}