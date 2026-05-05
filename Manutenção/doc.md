#  Manutenção e Monitoramento - Vitallis

Esta pasta contém scripts responsáveis pela **manutenção preventiva** e **monitoramento contínuo** do ambiente de banco de dados.

O objetivo é garantir **performance**, **estabilidade** e **alta disponibilidade**, atuando de forma proativa na prevenção de incidentes.

##  Escopo

As rotinas implementadas contemplam:

-  Monitoramento do crescimento do log de transações  
-  Atualização inteligente de estatísticas  
-  Manutenção de índices com base em fragmentação  

---

##  `sp_log_monitor`

Esta procedure automatiza a coleta de métricas a partir de **DMVs (Dynamic Management Views)** para monitorar o crescimento do arquivo de log de transações.

### Objetivo
Prevenir indisponibilidade causada por **log full**, garantindo ação proativa do administrador.

### Funcionalidades

- Coleta periódica de métricas de uso do log
- Definição de limites críticos para alerta
- Integração com **Database Mail**
- Envio automático de alertas via `sp_send_dbmail`

### Benefícios

-  Detecção antecipada de problemas
-  Resposta rápida a eventos críticos
-  Monitoramento contínuo sem intervenção manual

---

##  `sp_examinar_stats`

Responsável por identificar e corrigir **data drift** nas estatísticas das tabelas de usuário.

### Estratégia

A procedure avalia a necessidade de atualização com base na seguinte lógica:


Caso o percentual ultrapasse o limite definido em `@thresholdPercent`, a estatística é atualizada automaticamente.

### Características

- Execução diária via **SQL Server Agent Job**
- Agendada para horários de baixa utilização
- Foco em tabelas com alta taxa de modificação

### Benefícios

-  Melhoria na qualidade dos planos de execução
-  Otimização de queries
  
---

##  `sp_manut_index`

Procedure responsável pela manutenção de índices com base no nível de fragmentação.

### Estratégia

A rotina analisa os índices e aplica ações corretivas conforme melhores práticas:

- **REORGANIZE** → Fragmentação moderada  
- **REBUILD** → Fragmentação elevada  

Considerando o reorganize acima de 30% de fragmentação e acima de 50% rebiuld

### Implementação

- Integrada a um **Job do SQL Server Agent**
- Execução em janelas controladas para evitar impacto em produção

### Benefícios

-  Melhoria de performance em operações de leitura
-  Otimização de I/O
-  Redução de fragmentação

---

##  Automação e Alertas

O **SQL Server Agent** atua como peça central da automação, sendo responsável por:

- Orquestrar a execução de todas as rotinas
- Garantir periodicidade e controle das tarefas
- Integrar-se ao **Database Mail** para envio de notificações

Os alertas são disparados em cenários como:

- Crescimento crítico do log de transações
- Falhas na execução de jobs
- Situações que possam comprometer a disponibilidade

---

##  Considerações Finais

- As rotinas seguem boas práticas de administração de banco de dados
- O ambiente é monitorado de forma proativa
- A manutenção é orientada por métricas reais 
- A automação reduz dependência operacional e aumenta a confiabilidade




