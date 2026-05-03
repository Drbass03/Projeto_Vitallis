-- 01 Consulta para listar consultas marcadas por nome ou CPF

SELECT p.nome, p.CPF, c.diaHora, m.nome AS nome_medico, m.especialidade, p.idade
FROM sch_atendimento.consulta c
JOIN sch_adm_vitalis.medico m ON c.idMedico = m.id_medico 
JOIN sch_pacientes.paciente p ON c.idPaciente = p.id_paciente
WHERE p.cpf = @cpf
	AND c.diaHora >= @data_inicial 
	AND c.diaHora < DATEADD(DAY, 1, @data_final) 


UNION ALL -- UNION ALL utilizado para evitar o operador OR, sendo possível a utilização do indice em ambas as buscas 

SELECT p.nome, p.CPF,c.diaHora, m.nome AS nome_medico, m.especialidade,p.idade
FROM sch_atendimento.consulta c
JOIN sch_adm_vitalis.medico m ON c.idMedico = m.id_medico 
JOIN sch_pacientes.paciente p ON c.idPaciente = p.id_paciente
WHERE @cpf IS NULL AND p.nome = @nome
	AND c.diaHora <= @data_inicial 
	AND c.diaHora < DATEADD(DAY, 1, @data_final) 



-- 02 Consulta utilizada para listar atendimentos do médico na periodo selecionado

SELECT p.nome,
       c.diaHora,
       m.nome AS nome_medico,
       m.especialidade
FROM sch_atendimento.consulta c 

JOIN sch_adm_vitalis.medico   m 
	ON c.idMedico   = m.id_medico 
JOIN sch_pacientes.paciente  p 
	ON c.idPaciente = p.id_paciente

WHERE m.id_medico = @idMedico
  AND c.diaHora >= @data_inicial
  AND c.diaHora <  DATEADD(DAY, 1, @data_final); 




-- 03 Consulta para listar os pedidos de exames e resultados

DECLARE @nome VARCHAR (30) = 'Laura Cardoso'
DECLARE @cpf VARCHAR (11) = '42188602029'
DECLARE @pedido VARCHAR = 100 

SELECT p.id_paciente,
	   p.nome AS nome_paciente,
	   pd.numeroPedido AS numero_do_pedido,
	   pd.dataPedido AS data_do_pedido,
	   ag.dataAgendamento AS data_marcada,
	   e.nomeExame AS nome_do_exame,	
	   r.link_resultado, 
	   r.data_resultado

FROM sch_pacientes.paciente p 

LEFT JOIN sch_laboratorio.pedidoExame pd 
    ON p.id_paciente = pd.idPaciente

LEFT JOIN sch_laboratorio.agendamento ag
    ON pd.numeroPedido = ag.pedidoID

LEFT JOIN sch_laboratorio.result_exame r 
    ON pd.numeroPedido = r.idPedido

LEFT JOIN sch_laboratorio.exame e
    ON e.id_exame = ag.idExame

WHERE pd.numeroPedido = @pedido 
	
UNION ALL 

SELECT p.id_paciente,
	   p.nome AS nome_paciente,
	   pd.numeroPedido AS numero_do_pedido,
	   pd.dataPedido AS data_do_pedido,
	   ag.dataAgendamento AS data_marcada,
	   e.nomeExame AS nome_do_exame,	
	   r.link_resultado, 
	   r.data_resultado

FROM sch_pacientes.paciente p 

LEFT JOIN sch_laboratorio.pedidoExame pd 
    ON p.id_paciente = pd.idPaciente

LEFT JOIN sch_laboratorio.agendamento ag
    ON pd.numeroPedido = ag.pedidoID

LEFT JOIN sch_laboratorio.result_exame r 
    ON pd.numeroPedido = r.idPedido

LEFT JOIN sch_laboratorio.exame e
    ON e.id_exame = ag.idExame

WHERE p.CPF = @CPF 
	AND @pedido IS NULL 

UNION ALL 

SELECT p.id_paciente,
	   p.nome AS nome_paciente,
	   pd.numeroPedido AS numero_do_pedido,
	   pd.dataPedido AS data_do_pedido,
	   ag.dataAgendamento AS data_marcada,
	   e.nomeExame AS nome_do_exame,	
	   r.link_resultado, 
	   r.data_resultado

FROM sch_pacientes.paciente p 

LEFT JOIN sch_laboratorio.pedidoExame pd 
    ON p.id_paciente = pd.idPaciente

LEFT JOIN sch_laboratorio.agendamento ag
    ON pd.numeroPedido = ag.pedidoID

LEFT JOIN sch_laboratorio.result_exame r 
    ON pd.numeroPedido = r.idPedido

LEFT JOIN sch_laboratorio.exame e
    ON e.id_exame = ag.idExame

WHERE p.nome = @nome 
	AND @pedido IS NULL 
	AND @cpf IS NULL 



-- 4  Consulta para retornar historico de exames por data e paciente

;WITH historicoExames AS (

    SELECT  p.nome AS paciente,
			m.nome AS medico_solicitante,
            pd.dataPedido AS data_solicitacao,
            atd.data_atd AS data_realizado,
			pd.numeroPedido AS pedido,
			ex.nomeExame
    FROM sch_pacientes.paciente p 
    
	JOIN sch_laboratorio.atendimentos atd   
        ON p.id_paciente = atd.idPaciente 
    JOIN sch_laboratorio.pedidoExame pd
        ON pd.numeroPedido = atd.idPedido_ex 
    JOIN sch_adm_vitalis.medico m 
        ON m.id_medico = pd.idMedico 
	JOIN sch_laboratorio.exame ex
		ON ex.id_exame = pd.idExame
	
	WHERE pd.dataPedido >= @data_inicial 
			AND pd.dataPedido < @data_final
			AND p.id_paciente = @paciente
	) 

	SELECT he.paciente, 
		  he.medico_solicitante, 
		  he.data_solicitacao,
		  he.data_realizado,
		  he.nomeExame,
		  r.link_resultado
	FROM historicoExames he
	INNER JOIN sch_laboratorio.result_exame r 
		ON r.idPedido = he.pedido




















