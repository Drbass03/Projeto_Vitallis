USE master;
GO

CREATE OR ALTER TRIGGER trg_alerta_role_server
ON ALL SERVER
FOR
    ADD_SERVER_ROLE_MEMBER,
    ALTER_SERVER_ROLE,
    CREATE_SERVER_ROLE,
    DROP_SERVER_ROLE,
    GRANT_SERVER,
    DENY_SERVER,
    REVOKE_SERVER,
    CREATE_LOGIN,
    ALTER_LOGIN,
    DROP_LOGIN
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------
    -- Captura EVENTDATA()
    -------------------------------------------------------

    DECLARE @EventData XML = EVENTDATA();

    DECLARE @EventType NVARCHAR(100);
    DECLARE @Executor NVARCHAR(128);
    DECLARE @ComandoSQL NVARCHAR(MAX);
    DECLARE @ComandoUpper NVARCHAR(MAX);

    SET @EventType =
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)');

    SET @Executor =
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'nvarchar(128)');

    SET @ComandoSQL =
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)');

    SET @ComandoUpper = UPPER(@ComandoSQL);

    -------------------------------------------------------
    -- Auditoria
    -------------------------------------------------------

    INSERT INTO master.dbo.Log_Auditoria_Seguranca
    (
        DataEvento,
        Servidor,
        EventType,
        Executor,
        HostName,
        AppName,
        ComandoSQL,
        EventXML
    )
    VALUES
    (
        SYSDATETIME(),
        @@SERVERNAME,
        @EventType,
        @Executor,
        HOST_NAME(),
        APP_NAME(),
        @ComandoSQL,
        @EventData
    );

    -------------------------------------------------------
    -- Verifica se é crítico
    -------------------------------------------------------

  IF EXISTS
(
    SELECT 1
    FROM master.dbo.PermissoesCriticasServidor
    WHERE @ComandoUpper LIKE '%' + UPPER(permissao) + '%'
)
    BEGIN

        DECLARE @Body NVARCHAR(MAX);

        SET @Body =
            'ALERTA DE SEGURANÇA' + CHAR(13)+CHAR(10)+
            CHAR(13)+CHAR(10)+
            'Servidor : ' + @@SERVERNAME + CHAR(13)+CHAR(10)+
            'Evento    : ' + @EventType + CHAR(13)+CHAR(10)+
            'Executor  : ' + @Executor + CHAR(13)+CHAR(10)+
            'Data      : ' + CONVERT(varchar(19),SYSDATETIME(),120) + CHAR(13)+CHAR(10)+
            'Host      : ' + HOST_NAME() + CHAR(13)+CHAR(10)+
            'Aplicação : ' + APP_NAME() + CHAR(13)+CHAR(10)+
            CHAR(13)+CHAR(10)+
            'Comando executado:' + CHAR(13)+CHAR(10)+ @ComandoSQL;

        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'ASSISTENTE DBA II',
            @recipients   = 'dba@empresa.com',
            @subject      = 'ALERTA - Alteração crítica no servidor',
            @body         = @Body;

    END

END;
GO
