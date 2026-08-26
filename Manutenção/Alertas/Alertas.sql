
EXEC msdb.dbo.sp_add_alert
    @name = N'PLE abaixo de 600',
    @message_id = 0,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 300,
    @performance_condition = N'SQLServer:Buffer Manager|Page life expectancy||<|600',
    @notification_message = N'Atenção: PLE abaixo de 600! Verifique memória, índices e queries que podem estar consumindo buffer.';

-- Notificação
EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Page Life Expectancy Below 600',
    @operator_name = N'DBA Operator',
    @notification_method = 1;


-- Criar alerta Deadlock 
EXEC msdb.dbo.sp_add_alert
    @name = N'Deadlock Detectado',
    @performance_condition = N'SQLServer:Locks|Number of Deadlocks/sec|_Total|>|0',
    @enabled = 1,
    @delay_between_responses = 60,
    @include_event_description_in = 1,
    @notification_message = N'Alerta: Deadlock detectado no ambiente SQL Server!';
GO

-- Notificação
EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Deadlock Detectado',
    @operator_name = N'DBA Operator',
    @notification_method = 1; -- email



-- Alerta: TempDB Data Files > 500 MB (ajuste conforme seu ambiente)
EXEC msdb.dbo.sp_add_alert
    @name = N'TempDB Data Files Growth Detected',
    @message_id = 0,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 300,
    @performance_condition =
        N'SQLServer:Databases|Data File(s) Size (KB)|tempdb|>|8192000',
    @notification_message =
        N'ALERTA: O TempDB ultrapassou o tamanho inicial planejado de 8 GB. '
        + N'Verifique possíveis spills, queries com Sort/Hash, tabelas temporárias '
        + N'e outras operações que possam estar provocando crescimento do TempDB.';

-- Notificação
EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Crescimento do TempDB Detectado',
    @operator_name = N'DBA Operator',
    @notification_method = 1;

    






