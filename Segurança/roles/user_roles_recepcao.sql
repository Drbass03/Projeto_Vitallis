--Role para usuários da recepção. Permissões básicas concedidas, como alterar datas de consultas agendadas, inserir novas consultas e visualizar dados dos pacientes.
CREATE ROLE role_recepcao AUTHORIZATION dbo;

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHMEMA :: sch_atendimento TO role_recepcao;

DENY DELETE, INSERT, UPDATE ON sch_atendimento.consulta TO role_recepcao;
DENY SELECT, INSERT, UPDATE, DELETE ON sch_atendimento.mainProntuario TO role_recepcao;
DENY SELECT, INSERT, UPDATE, DELETE ON sch_atendimento.ProntuarioEvolucao TO role_recepcao; 


GRANT SELECT ON SCHEMA :: sch_laboratorio TO role_recepcao;

GRANT SELECT ON SCHEMA :: sch_adm_vitalis 

GRANT SELECT, INSERT, UPDATE ON SCHEMA :: sch_pacientes TO role_recepcao
GRANT DELETE ON sch_pacientes.endereco  TO  role_recepcao





