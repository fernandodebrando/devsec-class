#####################################################################
# VULNERABILIDADE 4: RDS SEM CRIPTOGRAFIA EM REPOUSO
# Bancos de dados devem ser sempre criptografados usando KMS.
#####################################################################

resource "aws_db_instance" "db_nao_criptografada" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "dados_nao_protegidos"
  username             = "admin"
  password             = "Password123" # Outra falha: senha hardcoded
  
  # A flag 'storage_encrypted' está ausente ou definida como 'false' (padrão)
  storage_encrypted    = false # Configuração INSEGURA!
  skip_final_snapshot  = true  # Outra falha de backup/recuperação
}