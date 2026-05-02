
CREATE PROCEDURE agendar_consulta
    @idPaciente INT, 
    @idMedico INT, 
    @data_ag DATETIME2(0) --Declaração de variáveis 
AS 
BEGIN 
    SET NOCOUNT ON;
	

    DECLARE @status VARCHAR (12) = 'Agendado' 

    INSERT INTO sch_atendimento.agConsulta (dt_criacao, idPaciente, idMedico, dt_consulta, status_consulta) -- Insert na tabela de agendamentos
    SELECT 
        GETDATE(),
        @idPaciente,
        @idMedico,
        @data_ag,
        @status
    WHERE NOT EXISTS ( -- Validação de disponibilidade de horário 
        SELECT 1 
        FROM sch_atendimento.agConsulta  
      
        WHERE dt_consulta = @data_ag 
          AND idMedico = @idMedico 
		  AND status_consulta = 'Agendado'
    );

    IF @@ROWCOUNT = 0  -- Verifica se houve alguma linha inserida na tabela de agendamentos (agConsulta), caso o rowcont retorne 0, o horário já está preenchido.
    BEGIN 
        RAISERROR('Horário indisponível', 16, 1) 
        RETURN; 
    END
    ELSE
    BEGIN
        PRINT 'Consulta agendada com sucesso!';
    END

END 
GO 