--Configurações do arquivo de auditoria. 

CREATE SERVER AUDIT [Audit_Vitallis]
TO FILE 
(	FILEPATH = N'C:\SQLAudit\audit_vitallis\',
	MAXSIZE = 300 MB,
	MAX_FILES = 50,
	RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 3000, ON_FAILURE = CONTINUE)
ALTER SERVER AUDIT [Audit_Vitallis] WITH (STATE = ON)
GO


--AUDITORIA NÍVEL SERVIDOR

CREATE SERVER AUDIT SPECIFICATION [ServerAuditSpecification]
FOR SERVER AUDIT [Audit_Vitallis]
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (BACKUP_RESTORE_GROUP),
ADD (AUDIT_CHANGE_GROUP),
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP),
ADD (LOGOUT_GROUP),
ADD (SERVER_PRINCIPAL_CHANGE_GROUP),
ADD (SERVER_STATE_CHANGE_GROUP),
ADD (TRACE_CHANGE_GROUP)
WITH (STATE = ON)
GO 


    /* 1. Gestão de Acesso e Autenticação

    FAILED_LOGIN_GROUP: Registra todas as tentativas de login sem sucesso. É o principal indicador de ataques externos.

    SUCCESSFUL_LOGIN_GROUP: Monitora quem acessou o sistema. Essencial para rastreabilidade em caso de incidentes.

    LOGOUT_GROUP: Útil para determinar a duração das sessões e conciliar com logs de atividades.


    2. Mudanças de Configuração e Segurança

    AUDIT_CHANGE_GROUP: Registra se alguém desativou ou modificou os logs de auditoria. Se um invasor ganhar acesso, este será o primeiro rastro que ele tentará apagar.

    SERVER_STATE_CHANGE_GROUP: Monitora quando o servidor é iniciado, parado ou pausado.

    TRACE_CHANGE_GROUP: Registra alterações em rastreamentos (traces) do SQL Server.


    3. Gestão de Privilégios (Controle de Admin)

    Em uma base de dados, pouquíssimas pessoas devem ter poder de "superusuário". Estes eventos vigiam os administradores.

    SERVER_ROLE_MEMBER_CHANGE_GROUP: Alerta quando alguém é adicionado a roles poderosas como sysadmin ou securityadmin.

    SERVER_PRINCIPAL_CHANGE_GROUP: Registra a criação, alteração ou exclusão de Logins de servidor.

    SERVER_PERMISSION_CHANGE_GROUP: Monitora a concessão de permissões globais (ex: VIEW ANY DEFINITION).

    4. Operações de Backup e Manutenção 

    Garante que a política de disaster recovery não seja violada.

    BACKUP_RESTORE_GROUP: Registra quando um backup é feito ou, mais criticamente, 
    quando um Restore é realizado (o que pode indicar exfiltração de dados para outro ambiente). */


--AUDITORIA NÍVEL BANCO DE DADOS

CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification]
FOR SERVER AUDIT [Audit_Vitallis]
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_OBJECT_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (UPDATE ON OBJECT::[sch_laboratorio].[pedidoExame] BY [public]),
ADD (DELETE ON OBJECT::[sch_atendimento].[ProntuarioEvolucao] BY [public]),
ADD (UPDATE ON OBJECT::[sch_atendimento].[ProntuarioEvolucao] BY [public]),
ADD (DELETE ON OBJECT::[sch_pacientes].[paciente] BY [public]),
ADD (UPDATE ON OBJECT::[sch_pacientes].[paciente] BY [public]),
ADD (DELETE ON OBJECT::[sch_laboratorio].[pedidoExame] BY [public]),
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (UPDATE ON OBJECT::[sch_laboratorio].[result_exame] BY [public]),
ADD (DELETE ON OBJECT::[sch_laboratorio].[result_exame] BY [public])
WITH (STATE = ON)
GO 

/*
SCHEMA_OBJECT_CHANGE_GROUP: Registra qualquer criação (CREATE), alteração (ALTER) ou exclusão (DROP) de objetos como tabelas, views e stored procedures. 
Fundamental para evitar alterações não autorizadas na estrutura do sistema.

DATABASE_OBJECT_CHANGE_GROUP: Foca em alterações em objetos do próprio banco de dados, 
garantindo que a lógica de negócio e os índices de performance não sejam comprometidos. 

DATABASE_PERMISSION_CHANGE_GROUP: Monitora os comandos GRANT, REVOKE e DENY. Monitora privilégios indevidos a usuários comuns.

DATABASE_ROLE_MEMBER_CHANGE_GROUP: Alerta quando um usuário é adicionado ou removido de uma Role (ex: tornar um usuário db_owner). 
Essencial para prevenir a escalação de privilégios.

As demais são para monitorar updates e deletes em tabelas críticas. */

