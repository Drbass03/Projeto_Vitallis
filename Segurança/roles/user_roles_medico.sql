--Role criada para o usuário médico, define quais tabelas pode ter acesso para operações de leitura e escrita

CREATE OR ALTER AUTHORIZATION ON ROLE:: role_medico TO dbo;


GRANT SELECT,INSERT, UPDATE, DELETE ON SCHEMA ::sch_laboratorio TO role_medico;
DENY INSERT,DELETE, UPDATE ON sch_laboratorio.result_exame TO role_medico;
DENY INSERT,DELETE, UPDATE ON sch_laboratorio.exame TO role_medico;
DENY INSERT,DELETE, UPDATE ON sch_laboratorio.agendamento TO role_medico;
DENY INSERT,DELETE, UPDATE ON sch_laboratorio.atendimentos TO role_medico;


GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA ::sch_atendimento TO role_medico;
DENY DELETE ON sch_atendimento.ProntuarioEvolucao TO role_medico;
DENY DELETE ON sch_atendimento.mainProntuario TO role_medico; 
DENY DELETE, UPDATE ON sch_atendimento.agConsulta TO role_medico; 
DENY INSERT, UPDATE, DELETE ON sch_atendimento.consulta TO role_medico;


GRANT SELECT, INSERT,UPDATE ON SCHEMA ::sch_pacientes TO role_medico; 

GRANT SELECT ON SCHEMA ::sch_adm_vitalis TO role_medico; 


/* Função de Row-Level Security (RLS) que permite acesso apenas aos registros
 cujo id do médico corresponde ao usuário da sessão atual (SESSION_CONTEXT).*/ 

-- Função RLS para escrita 
CREATE OR ALTER FUNCTION fn_rls_medico_write (@idMedico INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS Permitido
    WHERE @idMedico = TRY_CAST(SESSION_CONTEXT(N'idMedico') AS INT)
    OR IS_MEMBER('db_owner') = 1 
);

--Função RLS para leitura
CREATE OR ALTER FUNCTION fn_rls_medico_read (@idMedico INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS Permitido
    WHERE CAST(SESSION_CONTEXT(N'perfil') AS VARCHAR(20)) = 'MEDICO'
    OR IS_MEMBER('db_owner') = 1
);


-- Esta policy certifica que apenas os registros criados cujo id do médico corresponde ao usuário da sessão atual (SESSION_CONTEXT) logado possa ser alterado 

CREATE SECURITY POLICY pl_medico 
ADD FILTER PREDICATE dbo.fn_rls_medico_read  (idMedico)
ON sch_laboratorio.pedidoExame,

ADD BLOCK PREDICATE dbo.fn_rls_medico_write (idMedico)
ON sch_laboratorio.pedidoExame AFTER UPDATE,

ADD BLOCK PREDICATE dbo.fn_rls_medico_write (idMedico)
ON sch_laboratorio.pedidoExame AFTER INSERT 

-- A policy garante que por exemplo, um pedido de exame possa ser alterado pelo médico que o criou, mas outros médicos podem visualizar. 


/* 
EXEC AS USER = 'user_medico';

EXEC sp_set_session_context 'idMedico',8;
EXEC sp_set_session_context 'perfil','Medico'

Comandos utilizados para simular contexto de sessão de usuário 

/* 

