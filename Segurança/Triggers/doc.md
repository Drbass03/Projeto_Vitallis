# Auditoria de Elevação de Privilégios no Servidor

## Objetivo

Esta solução implementa uma **DDL Trigger em nível de servidor** responsável por monitorar alterações relacionadas à segurança da instância do SQL Server.

O objetivo é detectar, registrar e notificar imediatamente eventos que possam representar uma **elevação de privilégios**, como concessão de permissões críticas ou inclusão de logins em Server Roles privilegiadas.

---

## Funcionamento

A trigger é criada utilizando:

```sql
ON ALL SERVER
```

e monitora eventos de segurança como:

- ADD_SERVER_ROLE_MEMBER
- ALTER_SERVER_ROLE
- CREATE_SERVER_ROLE
- DROP_SERVER_ROLE
- CREATE_LOGIN
- ALTER_LOGIN
- DROP_LOGIN
- GRANT_SERVER
- DENY_SERVER
- REVOKE_SERVER

Sempre que um desses eventos ocorre, a trigger utiliza a função `EVENTDATA()` para capturar todas as informações da operação executada.

Entre os dados coletados estão:

- Tipo do evento
- Login responsável pela alteração
- Nome do servidor
- Host de origem
- Aplicação utilizada
- Comando T-SQL executado
- XML completo retornado pelo `EVENTDATA()`

---

# Registro em tabela de auditoria

Independentemente do evento ser considerado crítico ou não, todas as alterações monitoradas são registradas na tabela:

```text
master.dbo.Log_Auditoria_Seguranca
```

Essa tabela funciona como um histórico permanente das alterações administrativas realizadas na instância.

Os principais campos armazenados são:

| Campo | Descrição |
|--------|-----------|
| DataEvento | Data e hora da alteração |
| Servidor | Nome da instância |
| EventType | Tipo do evento DDL |
| Executor | Login responsável pela execução |
| HostName | Máquina de origem |
| AppName | Aplicação utilizada (SSMS, ADS, etc.) |
| ComandoSQL | Comando T-SQL executado |
| EventXML | XML completo retornado pelo EVENTDATA() |

O armazenamento do XML completo permite futuras análises forenses sem perda de informações.

---

# Tabela de Permissões Críticas

Para evitar alterações constantes na trigger, as permissões consideradas críticas são armazenadas em uma tabela de configuração:

```text
master.dbo.PermissoesCriticasServidor
```

Essa tabela contém palavras-chave relacionadas a permissões e Server Roles privilegiadas, como por exemplo:

- SYSADMIN
- SECURITYADMIN
- SERVERADMIN
- DBCREATOR
- CONTROL SERVER
- ALTER ANY LOGIN
- ALTER ANY SERVER ROLE
- SHUTDOWN
- IMPERSONATE
- VIEW SERVER STATE

Durante a execução da trigger, o comando T-SQL capturado é comparado com os registros dessa tabela.

Caso alguma correspondência seja encontrada, o evento é classificado como uma alteração crítica de segurança.

Essa abordagem torna a solução flexível, permitindo adicionar ou remover permissões monitoradas sem necessidade de modificar ou recriar a trigger.

---

# Alerta em Tempo Real

Quando uma alteração crítica é identificada, a trigger envia automaticamente uma notificação utilizando o **Database Mail**.

O e-mail contém informações como:

- Servidor afetado
- Tipo do evento
- Login responsável
- Data e hora
- Host de origem
- Aplicação utilizada
- Comando T-SQL executado

Dessa forma, administradores podem ser notificados imediatamente sobre alterações potencialmente sensíveis na instância.

---

# Benefícios da solução

- Auditoria automática de alterações administrativas.
- Registro permanente das operações de segurança.
- Notificação em tempo real de elevação de privilégios.
- Utilização do `EVENTDATA()` para obtenção detalhada dos eventos.
- Armazenamento do XML original para análise forense.
- Lista de permissões críticas configurável por tabela, sem necessidade de alterar a trigger.
- Solução baseada exclusivamente em recursos nativos do SQL Server.



