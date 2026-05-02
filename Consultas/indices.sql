CREATE INDEX idx_paciente_cpf ON sch_pacientes.paciente (cpf) 
INCLUDE (nome, dt_Nasc);

CREATE INDEX idx_consulta_medico_data ON sch_atendimento.consulta (idMedico, diaHora) 
INCLUDE (idPaciente);

CREATE INDEX idx_endereco_idPaciente ON sch_pacientes.endereco (idPaciente)
INCLUDE (logradouro, numero, bairro, cidade, estado);

CREATE INDEX ix_agconsulta_data ON sch_atendimento.agConsulta (dt_consulta) 

CREATE INDEX IX_dataPedido ON sch_laboratorio.atendimentos (idPaciente, data_atd)

CREATE INDEX IX_dataResultado ON sch_laboratorio.result_exame (idPedido, link_resultado)
