CREATE OR ALTER PROCEDURE sp_log_monitor 
    @thresholdPercent INT 
AS 
BEGIN
    SET NOCOUNT ON;

    IF (@thresholdPercent < 0 OR @thresholdPercent > 100)
    BEGIN 
        THROW 50000, 'Valor de Threshold inválido. Insira entre 0 e 100.', 1;
    END

    CREATE TABLE #log_view (
        idLog INT IDENTITY(1,1) PRIMARY KEY,
        databaseID INT,
        nome_db SYSNAME,
        caminho NVARCHAR(MAX),
        tamanhoTotal DECIMAL (12,2),
        espacoUtilizado DECIMAL (12,2),
        espacoLivre DECIMAL (12,2),
        tipoGrowth VARCHAR (15),
        configGrowth VARCHAR (30),
        maxSize VARCHAR (30), 
        WAIT_desc VARCHAR (50),
        RECOVERY_desc VARCHAR (20),
        dataExecucao SMALLDATETIME DEFAULT GETDATE()
    )

    INSERT INTO #log_view 
    (
        databaseID,caminho,tamanhoTotal,espacoUtilizado,espacoLivre,
        tipoGrowth,configGrowth,maxSize,WAIT_desc,RECOVERY_desc
    )
    SELECT 
        ms.database_id,
        ms.name,
        ms.physical_name,
        CAST(ls.total_log_size_in_bytes / 1024.0 / 1024 AS DECIMAL(12,2)),
        CAST(ls.used_log_space_in_bytes / 1024.0 / 1024 AS DECIMAL(12,2)),
        CAST((ls.total_log_size_in_bytes - ls.used_log_space_in_bytes) / 1024.0 / 1024 AS DECIMAL(12,2)),

        CASE WHEN ms.growth = 0 THEN 'Fixo' ELSE 'AutoGrow' END,
        CASE WHEN ms.is_percent_growth = 1 THEN 'Crescimento %' ELSE 'Crescimento MB' END,

        CASE
            WHEN ms.max_size = -1 THEN 'Ilimitado'
            ELSE CAST(CAST(ms.max_size AS BIGINT) * 8 / 1024 AS VARCHAR)
        END,

        sb.log_reuse_wait_desc,
        sb.recovery_model_desc

    FROM sys.master_files ms
    JOIN sys.dm_db_log_space_usage ls ON ms.database_id = ls.database_id
    JOIN sys.databases sb ON sb.database_id = ms.database_id

    WHERE ms.type_desc = 'LOG'
      AND sb.state_desc = 'ONLINE'
      AND ls.used_log_space_in_percent >= @thresholdPercent
      AND sb.log_reuse_wait_desc NOT IN ('NOTHING','CHECKPOINT')

    
    IF NOT EXISTS (SELECT 1 FROM #log_view)
        RETURN;

    DECLARE @HTML_LINHAS NVARCHAR(MAX)

    SELECT @HTML_LINHAS =
    (
        SELECT 
            '<tr>' +
            '<td>' + CAST(idLog AS VARCHAR) + '</td>' +
            '<td>' + CAST(databaseID AS VARCHAR) + '</td>' +
            '<td>' + CAST(nome_db AS VARCHAR) + '</td>' +
            '<td>' + caminho + '</td>' +
            '<td>' + CAST(tamanhoTotal AS VARCHAR) + '</td>' +
            '<td>' + CAST(espacoUtilizado AS VARCHAR) + '</td>' +
            '<td>' + CAST(espacoLivre AS VARCHAR) + '</td>' +
            '<td>' + tipoGrowth + '</td>' +
            '<td>' + configGrowth + '</td>' +
            '<td>' + maxSize + '</td>' +
            '<td>' + WAIT_desc + '</td>' +
            '<td>' + RECOVERY_desc + '</td>' +
            '<td>' + CONVERT(VARCHAR, dataExecucao, 120) + '</td>' +
            '</tr>'
        FROM #log_view
        ORDER BY espacoLivre ASC
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)')

    DECLARE @BODY NVARCHAR(MAX)
    
    SET @BODY = '
    <html>
    <body style="font-family: Arial; font-size: 12px;">
    <h3>🚨 Alerta de Log - Espaço Crítico</h3>

    <table border="1" cellspacing="0" cellpadding="5">
    <tr style="background-color:#2F4F4F;color:white;">
        <th>ID</th>
        <th>id_DB</th>
        <th>nome_DB</th>
        <th>Caminho</th>
        <th>Espaço Total</th>
        <th>Espaço Usado</th>
        <th>Espaço Livre</th>
        <th>Tipo de Growth</th>
        <th>Crescimento em</th>
        <th>Tamanho Maximo</th>
        <th>Wait</th>
        <th>Recovery</th>
        <th>Data de execução</th>
    </tr>'
    + @HTML_LINHAS +
    '</table></body></html>'

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'Assistente DBA II',
        @recipients = 'gbarcelos.lg@gmail.com',
        @subject = ' Alerta de Log Crítico',
        @body = @BODY,
        @body_format = 'HTML'
END
