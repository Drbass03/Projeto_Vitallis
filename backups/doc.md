#  Estratégia de Backup - Vitallis

Esta pasta contém os scripts responsáveis pela política de **backup e recuperação** do banco de dados do projeto **Vitallis**.

##  Objetivo

Garantir a **disponibilidade**, **integridade** e **recuperabilidade** dos dados, atendendo aos requisitos definidos de:

- **RPO (Recovery Point Objective):** até 15 minutos  
- **RTO (Recovery Time Objective):** até 5 minutos  

##  Janela de Operação

A estratégia foi definida considerando o horário de utilização do sistema:

-  Início: 07:00  
-  Término: 20:00  

##  Política de Backups

A arquitetura de backups segue o modelo tradicional baseado em **Full + Differential + Transaction Log**.

###  Backups de Log
- Frequência: a cada **10 minutos**
- Objetivo: garantir granularidade na recuperação e atender o RPO de 15 minutos

###  Backups Diferenciais
- Horários:
  - 08:00  
  - 12:00  
  - 15:00  
  - 18:00  
  - 20:00  
- Objetivo: reduzir o tempo de restauração ao evitar a aplicação de múltiplos logs desde o último full

###  Backup Completo (Full)
- Frequência: semanal
- Execução: **domingo às 22:00**
- Objetivo: estabelecer uma nova base para a cadeia de backups

##  Agendamento (SQL Server Agent)

Os jobs foram configurados respeitando:

- Distribuição equilibrada ao longo do dia
- Minimização de impacto durante horários críticos
- Garantia de que o **RTO de 15 minutos** seja viável

##  Considerações Técnicas

- A estratégia permite recuperação **point-in-time**
- Os backups de log evitam perda significativa de dados
- Os diferenciais reduzem o tempo de restore em cenários de desastre
- O full semanal reinicia a cadeia de backups, facilitando manutenção
