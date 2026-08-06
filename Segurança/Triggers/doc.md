# Alertas de segurança

Este diretório reúne um conjunto de **DDL Triggers** desenvolvidas para aumentar a segurança da instância do SQL Server por meio do monitoramento de alterações administrativas em tempo real.

O objetivo é detectar ações potencialmente críticas, registrar as informações para auditoria e, quando necessário, gerar alertas automáticos utilizando o **Database Mail**. Todas as soluções foram desenvolvidas utilizando apenas recursos nativos do SQL Server.


### `trg_alerta_role_server`

Monitora alterações relacionadas à segurança em nível de servidor, como inclusão de logins em **Server Roles**, concessão de permissões privilegiadas e demais eventos administrativos configurados na trigger.

Sempre que um evento monitorado ocorre, suas informações são registradas em uma tabela de auditoria. Caso a alteração envolva uma permissão considerada crítica, um alerta é enviado automaticamente aos administradores da instância.

## Tabelas de apoio

### `Log_Auditoria_Seguranca`

Responsável por armazenar o histórico dos eventos capturados pela trigger, incluindo data, executor, host de origem, aplicação utilizada, comando T-SQL executado e o XML completo retornado pela função `EVENTDATA()`.

### `PermissoesCriticasServidor`

Tabela de configuração que centraliza as permissões e Server Roles consideradas críticas. A trigger consulta essa tabela para determinar quando um evento deve gerar um alerta, permitindo adicionar ou remover itens monitorados sem necessidade de alterar o código da trigger.

---
