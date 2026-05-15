CREATE OR ALTER PROCEDURE dbo.sp_audit_failed_login
    @LimiteTentativas INT = 5,
    @MinutosAtras INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Contador INT;
    DECLARE @CorpoEmail NVARCHAR(MAX);

    -- 1. Conta falhas de login nos últimos X minutos
    SELECT @Contador = COUNT(*)
    FROM sys.fn_get_audit_file('C:\SQLAudit\Audit_*', DEFAULT, DEFAULT) -- Ajuste seu path
    WHERE action_id IN ('LGFL', 'LGIF') -- Login Failed
      AND event_time > DATEADD(MINUTE, -@MinutosAtras, GETDATE());

    -- 2. Se ultrapassar o limite, dispara o alerta
    IF @Contador >= @LimiteTentativas
    BEGIN
        SET @CorpoEmail = 'ALERTA DE SEGURANÇA !! ' + CHAR(13) +
                          'Foram detectadas ' + CAST(@Contador AS VARCHAR) + 
                          'falhas de login nos últimos ' + CAST(@MinutosAtras AS VARCHAR) + ' minutos.' + CHAR(13) +
                          'Verifique os logs de auditoria imediatamente.';

        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'ASSISTENTE DBA II', -- Seu perfil do Database Mail
            @recipients = 'dba@assistente.com.br',
            @subject = '⚠️ Alerta de Intrusão: Múltiplas Falhas de Login',
            @body = @CorpoEmail;
            
        PRINT 'Alerta enviado!';
    END
END
GO 
