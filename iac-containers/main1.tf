#####################################################################
# VULNERABILIDADE 5: LOGS DE ACESSO DESABILITADOS EM ELB/ALB
# Logs devem ser habilitados e armazenados em um bucket seguro para auditoria.
#####################################################################

resource "aws_lb" "alb_sem_logs" {
  name               = "alb-aplicacao-sem-auditoria"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_web_inseguro.id] # Referencia o SG inseguro do primeiro exemplo!

  # O bloco de logs está ausente ou configurado incorretamente.
  # A ausência deste bloco é uma falha que impede a auditoria.
  # access_logs {
  #   bucket = "..."
  #   enabled = true
  # }
}