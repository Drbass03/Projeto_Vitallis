--Role criada para usuário médico, define quais tabelas pode ter acesso para operações de leitura e escrita

CREATE ROLE role_medico AUTHORIZATION dbo;

GRANT SELECT ON sch_laboratorio.exames TO role_medico;
GRANT SELECT ON sch_laboratorio.pedidoExame TO role_medico;
GRANT SELECT ON sch_laboratorio.resultado TO role_medico;
GRANT SELECT ON sch_atendimentos.prontuario TO role_medico;
GRANT SELECT ON sch_atendimentos.prontuarioEvolucao TO role_medico;

GRANT INSERT ON sch_laboratorio.pedidoexame TO role_medico;
GRANT UPDATE ON sch_laboratorio.pedidoexame TO role_medico;
GRANT DELETE ON sch_laboratorio.pedidoexame TO role_medico;



/* Função de Row-Level Security (RLS) que permite acesso apenas aos registros
 cujo id do médico corresponde ao usuário da sessão atual (SESSION_CONTEXT).*/ 

--Permite 
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




/* 
EXEC AS USER = 'user_medico';

EXEC sp_set_session_context 'idMedico',8;
EXEC sp_set_session_context 'perfil','Medico'

Comandos utilizados para simular contexto de sessão de usuário 

/* 

