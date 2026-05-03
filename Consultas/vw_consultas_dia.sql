--Esta view é utilizada para retornar todas as consultas agendadas no dia. Informando qual especialidade, medico e dados do paciente. 

CREATE VIEW dbo.vw_consultas_dia 
AS 

	SELECT  p.nome AS paciente, 
			p.idade,
			p.contato,
			m.nome AS medico,
			m.especialidade,
			ag.dt_consulta AS horario,
			CASE 
				WHEN p.titular_id IS NULL THEN 'Titular'
				ELSE 'Dependente'
			END AS tipo_vinculo,
			CASE 
            WHEN DATEDIFF(YEAR, p.dt_nasc, GETDATE()) >= 80 THEN 'Prioridade Especial (80+)'
            WHEN DATEDIFF(YEAR, p.dt_nasc, GETDATE()) >= 60 THEN 'Preferencial (60+)'
            WHEN DATEDIFF(YEAR, p.dt_nasc, GETDATE()) < 10 THEN 'Preferencial (Criança)'
            ELSE 'Fluxo Normal'
        END AS classificacao_atendimento 

	FROM sch_pacientes.paciente p
	
	JOIN sch_atendimento.agConsulta ag
		ON p.id_paciente = ag.idPaciente
	JOIN sch_adm_vitalis.medico m
		ON m.id_medico = ag.idMedico
	
	WHERE ag.dt_consulta >= CAST(GETDATE() AS DATE)
  		AND ag.dt_consulta <  DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) 
