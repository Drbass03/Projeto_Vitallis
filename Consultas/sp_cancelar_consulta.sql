-- Proc utilizada para cancelar consultas 

CREATE PROCEDURE cancelar_consulta
    @id_agendamento INT
   
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE sch_atendimento.agConsulta
        SET status_consulta = 'Cancelada'
        WHERE id_agendamento = @id_agendamento
          AND status_consulta = 'Agendado';

       IF @@ROWCOUNT = 0 -- Se o update anterior não afetar nenhuma linha, o script entra nesta condição
            BEGIN
                THROW 50001, 'Consulta não encontrada ou já cancelada.', 1; 
            END
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 -- No momento da exceção o scrip identifica a transação aberta e então aplica o ROLLBACK   
            ROLLBACK;

        THROW;
    END CATCH
END