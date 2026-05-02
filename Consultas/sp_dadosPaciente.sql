CREATE PROCEDURE cadastro_paciente 
	@paciente_id INT 
	
AS 
BEGIN 

SET NOCOUNT ON;


	WITH pacientes_geral AS (
		
		SELECT	
			p.id_paciente,
			p.nome,
			p.idade, 
			p.sexo, 
			p.tipo, 
			p.email,
			p.contato,
			p.dataCadastro, 
			d.nome   AS nome_dependente,
			d.idade  AS idade_dependente,
			cnv.nome AS nome_convenio,
			uc.UltimaConsulta AS ultima_consulta
		FROM sch_pacientes.paciente p 

		LEFT JOIN sch_pacientes.paciente d
			ON p.id_paciente = d.titular_id

		LEFT JOIN sch_adm_vitalis.convenio cnv
			ON p.idConvenio = cnv.id_convenio

		OUTER APPLY (
			SELECT TOP 1
				c.diaHora AS UltimaConsulta
			FROM sch_atendimento.consulta c
			WHERE c.idPaciente = p.id_paciente
			ORDER BY c.diaHora DESC
		) uc

		WHERE p.id_paciente = @paciente_id 
	)

	SELECT 
		pg.*,
		e.rua,
		e.numero,
		e.bairro, 
		e.cidade,
		e.estado
	FROM sch_pacientes.endereco e 

	LEFT JOIN pacientes_geral pg
		ON e.idPaciente = pg.id_paciente

	WHERE pg.id_paciente = @paciente_id

END 