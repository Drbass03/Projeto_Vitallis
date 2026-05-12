CREATE PROCEDURE dbo.sp_audit_change
    @MinutosAtras INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Contador INT;
    DECLARE @CorpoEmail NVARCHAR(MAX);
    DECLARE @DetalhesEventos NVARCHAR(MAX) = '';

    -- 1. Captura eventos de alteração de auditoria
    -- Action_ID 'AUDG' refere-se ao Audit Group Change
    SELECT @Contador = COUNT(*)
    FROM sys.fn_get_audit_file('C:\Auditoria_Vitallis\mod1*', DEFAULT, DEFAULT)
    WHERE (action_id = 'AUDG' OR class_type = 'AU') -- AUDG: Audit Change | AU: Audit
      AND event_time > DATEADD(MINUTE, -@MinutosAtras, GETDATE());

    -- 2. Se houver qualquer evento (mesmo que seja apenas 1), dispara o alerta 
    IF @Contador > 0
    BEGIN
        -- Opcional: Captura o comando exato para colocar no e-mail
        SELECT TOP 5 @DetalhesEventos = @DetalhesEventos + 
            'Data: ' + CAST(event_time AS VARCHAR) + 
            ' | Usuário: ' + server_principal_name + 
            ' | Comando: ' + statement + CHAR(13) + CHAR(10)
        FROM sys.fn_get_audit_file('C:\AuditLogs\*', DEFAULT, DEFAULT)
        WHERE (action_id = 'AUDG' OR class_type = 'AU')
          AND event_time > DATEADD(MINUTE, -@MinutosAtras, GETDATE())
        ORDER BY event_time DESC;

        SET @CorpoEmail = '⚠️ ALERTA CRÍTICO DE SEGURANÇA ⚠️' + CHAR(13) + CHAR(10) +
                          'Detectada alteração nas configurações de Auditoria do Servidor !' + CHAR(13) + CHAR(10) +
                          'Verifique os logs de auditoria imediatamente.' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                          'Últimos eventos detectados:' + CHAR(13) + CHAR(10) +
                          @DetalhesEventos;

        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'Perfil_Email_Vitallis',
            @recipients = 'seu-email@dominio.com',
            @subject = '🚨 URGENTE: Alteração na Auditoria do Sistema',
            @body = @CorpoEmail,
            @importance = 'HIGH'; -- Define o e-mail como prioritário 
            
        PRINT 'Alerta de integridade enviado!';
    END
END
GO 