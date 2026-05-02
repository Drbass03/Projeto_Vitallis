
CREATE VIEW vw_exames_dia 
AS 

    SELECT  p.nome AS paciente, 
			p.idade,
			p.contato,
			e.nomeExame,
			pd.dataPedido AS 'solicitado em',
			pd.numeroPedido, 
			
			
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
	
	JOIN sch_laboratorio.agendamento ag
		ON p.id_paciente = ag.idPaciente
	JOIN sch_laboratorio.exame e
		ON e.id_exame = ag.idExame
	JOIN sch_laboratorio.pedidoExame pd
		ON pd.numeroPedido = ag.pedidoID
	
	WHERE  ag.dataAgendamento  >= CAST(GETDATE() AS DATE)
  		AND ag.dataAgendamento <  DATEADD(DAY, 1, CAST(GETDATE() AS DATE)) 