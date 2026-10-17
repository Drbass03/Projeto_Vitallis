-- Proc responsável por inserir um registro no prontuário do paciente

CREATE OR ALTER PROCEDURE sch_atendimento.registro_prontuario
    @ID_prontuario INT,
    @ID_medico INT,
    @data SMALLDATETIME = NULL,
    @queixa VARCHAR(255),
    @exameFisico VARCHAR(1000),
    @diagnostico VARCHAR(500),
    @prescricao VARCHAR(1000),
    @idPaciente INT,
    @ID_consulta INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO sch_atendimento.ProntuarioEvolucao
    (
        IdProntuario,
        IdMedico,
        DataAtendimento,
        QueixaPrincipal,
        ExameFisico,
        Diagnostico,
        Prescricao,
        DataRegistro,
        IdPaciente,
        IDConsulta
    )
    SELECT
        @ID_prontuario,
        @ID_medico,
        COALESCE(@data, GETDATE()),
        @queixa,
        @exameFisico,
        @diagnostico,
        @prescricao,
        GETDATE(),
        @idPaciente,
        @ID_consulta
    
    WHERE EXISTS
    (
        SELECT 1
        FROM sch_atendimento.consulta
        WHERE id_consulta = @ID_consulta
    )
    AND EXISTS                                       ---> valida se a consulta e o prontuário existe 
    (
        SELECT 1
        FROM sch_atendimento.mainProntuario
        WHERE IdProntuario = @ID_prontuario
    );

    IF @@ROWCOUNT = 0  --> Em caso de nennhuma linha inserida o sql comunica o erro para a aplicação
    
        BEGIN  

            ;THROW 50001, 'Não foi possível realizar a operação consulta/prontuario invalidos', 1;

        END 



END; 
