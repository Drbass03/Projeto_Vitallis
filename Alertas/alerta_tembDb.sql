SET NOCOUNT ON;

-- ====================================================================
-- CONFIGURAÇÕES
-- ====================================================================
DECLARE @ThresholdPercent INT = 95;           -- Limite para disparar o alerta (%)
DECLARE @CooldownMinutes INT = 60;             -- Intervalo mínimo entre e-mails (em minutos)
DECLARE @MailProfileName NVARCHAR(128) = 'SeuPerfilDBMail';
DECLARE @Recipients NVARCHAR(MAX) = 'equipe-dba@suaempresa.com';
-- ====================================================================

DECLARE @TotalPages BIGINT;
DECLARE @UsedPages BIGINT;
DECLARE @PercentUsed DECIMAL(5,2);
DECLARE @LastAlertSent DATETIME;

-- 1. Calcula o espaço total e utilizado do TempDB
SELECT 
    @TotalPages = SUM(user_object_reserved_page_count + internal_object_reserved_page_count + mixed_extent_page_count + unallocated_extent_page_count),
    @UsedPages = SUM(user_object_reserved_page_count + internal_object_reserved_page_count + mixed_extent_page_count)
FROM tempdb.sys.dm_db_file_space_usage;

SET @PercentUsed = ISNULL(CAST((@UsedPages * 100.0) / NULLIF(@TotalPages, 0) AS DECIMAL(5,2)), 0);

-- 2. Verifica quando foi enviado o último alerta
SELECT TOP 1 @LastAlertSent = LastAlertSent 
FROM msdb.dbo.TempDB_Alert_History;

-- 3. Valida se o uso atingiu o limite E se o tempo de cooldown já passou
IF @PercentUsed >= @ThresholdPercent 
   AND (@LastAlertSent IS NULL OR DATEDIFF(MINUTE, @LastAlertSent, GETDATE()) >= @CooldownMinutes)
BEGIN
    DECLARE @Subject NVARCHAR(255) = CONCAT('ALERTA: Uso do TempDB em ', @PercentUsed, '% no servidor ', @@SERVERNAME);
    
    DECLARE @Body NVARCHAR(MAX) = CONCAT(
        'Atenção,', CHAR(13), CHAR(10), CHAR(13), CHAR(10),
        'O consumo do TempDB no servidor ', @@SERVERNAME, ' atingiu o limite crítico.', CHAR(13), CHAR(10),
        '- Limite configurado: ', @ThresholdPercent, '%', CHAR(13), CHAR(10),
        '- Uso atual: ', @PercentUsed, '%', CHAR(13), CHAR(10),
        '- Próxima notificação permitida em: ', @CooldownMinutes, ' minutos.', CHAR(13), CHAR(10), CHAR(13), CHAR(10),
        'Verifique sessões ativas e transações abertas no TempDB.'
    );

    -- Dispara o e-mail
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = @MailProfileName,
        @recipients = @Recipients,
        @subject = @Subject,
        @body = @Body,
        @importance = 'High';

    -- Atualiza ou insere o registro do último e-mail enviado
    IF EXISTS (SELECT 1 FROM msdb.dbo.TempDB_Alert_History)
        UPDATE msdb.dbo.TempDB_Alert_History SET LastAlertSent = GETDATE();
    ELSE
        INSERT INTO msdb.dbo.TempDB_Alert_History (LastAlertSent) VALUES (GETDATE());
END