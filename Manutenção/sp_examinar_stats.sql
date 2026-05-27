CREATE OR ALTER PROCEDURE sp_examinar_stats 

AS 
BEGIN
    SET NOCOUNT ON;

    --  Criação da tabela temporária 
    CREATE TABLE #check_stats (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        nome_stats SYSNAME, 
        nome_tabela SYSNAME, 
        num_linhas BIGINT,
        ultima_att DATETIME2, 
        num_modificacoes BIGINT,
        drift_percentual DECIMAL, 
        stats_check BIT DEFAULT 0 
    );

    -- Inserção dos dados
    INSERT INTO #check_stats (nome_stats, nome_tabela, num_linhas, ultima_att, num_modificacoes, drift_percentual)
    SELECT 
        s.name,
        OBJECT_NAME(s.object_id), 
        sp.rows, 
        sp.last_updated, 
        sp.modification_counter,
        CAST((sp.modification_counter * 100.00 / sp.rows)  AS DECIMAL (5,2)) AS percent_drift
    FROM sys.stats s 
    CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp 
    INNER JOIN sys.objects o ON s.object_id = o.object_id
    WHERE o.type = 'U' -- Apenas tabelas de usuário
      AND sp.modification_counter > (sp.rows * 0.10); -- Filtro de Drift de 10% 

    -- Adicionando os dados capturados em uma tabela de log para persistência das informações coletadas.
    INSERT INTO log_estatisticas_drift (StatsName, nome_tabela, num_linhas, ultima_att, DriftPercent,check_stats)

    SELECT nome_stats,
           nome_tabela,
           num_linhas,
           ultima_att,
           drift_percentual,
           stats_check
    
    FROM #check_stats 
           
    IF NOT EXISTS (SELECT 1 FROM #check_stats )
        RETURN;

    DECLARE @HTML_LINHAS NVARCHAR(MAX)
   
    SELECT @HTML_LINHAS =
(
    -- Criação da tabela que será enviada junto ao corpo do email disparado informando quais tabelas tiveram estatisticas atualizadas. 
    SELECT 
        '<tr>' +
        '<td>' + CAST(ID AS VARCHAR) + '</td>' +
        '<td>' + nome_stats + '</td>' +
        '<td>' + nome_tabela + '</td>' +
        '<td>' + CAST(num_linhas AS VARCHAR) + '</td>' +
        '<td>' + CONVERT(VARCHAR, ultima_att, 120) + '</td>' +
        '<td>' + CAST(num_modificacoes AS VARCHAR) + '</td>' +
        '<td>' + 
            CAST(
                CAST(num_modificacoes * 100.0 / NULLIF(num_linhas,0) AS DECIMAL(5,2))
            AS VARCHAR) + '%' +
        '</td>' +
        '</tr>'

    FROM #check_stats
    ORDER BY ultima_att DESC

    FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)')

    DECLARE @body NVARCHAR(MAX)
    SET @body = '
    <html>
<head>
<style>
body { font-family: Arial; font-size: 12px; color:#333; }

table { border-collapse: collapse; width: 100%; }

th {
    background-color: #4a6fa5;
    color: white;
    padding: 8px;
    border: 1px solid #ddd;
}

td {
    padding: 6px;
    border: 1px solid #ddd;
}

tr:nth-child(even) {
    background-color: #f9f9f9;
}

.destaque {
    background-color: #e6f2ff;
    font-weight: bold;
}

.moderado {
    background-color: #fff8e1;
}

</style>
</head>
<body>

<h3>📊 Relatório de Atualização de Estatísticas</h3>

<p>
Este relatório apresenta as estatísticas que foram atualizadas,
com base no volume de modificações identificado antes da manutenção.
</p>

<table>
<tr>
    <th>ID</th>
    <th>Estatística</th>
    <th>Tabela</th>
    <th>Linhas</th>
    <th>Última Atualização</th>
    <th>Modificações</th>
    <th>Drift percent (%)</th>
</tr>'
   + @HTML_LINHAS +
    '</table></body></html>'

      EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'Assistente DBA II',
        @recipients = 'dba@assitente.com.br',
        @subject = 'Informativo - Estatisticas Atualizadas',
        @body = @BODY,
        @body_format = 'HTML'




    --  Declaração de variáveis para o loop
    DECLARE @ID INT, @stats SYSNAME, @tabela SYSNAME, @comandoSQL NVARCHAR(MAX);

    -- Loop de Processamento
    WHILE EXISTS (SELECT 1 FROM #check_stats WHERE stats_check = 0)
    BEGIN
        SELECT TOP 1 
            @ID = ID,
            @stats = nome_stats,
            @tabela = nome_tabela
        FROM #check_stats 
        WHERE stats_check = 0; 

        -- Construção do SQL Dinâmico
        SET @comandoSQL =  N'UPDATE STATISTICS ' + QUOTENAME(@tabela) + ' (' + QUOTENAME(@stats) + ') 
                            WITH SAMPLE 50 PERCENT, PERSIST_SAMPLE_PERCENT = ON;';
        
        -- Execução
        PRINT 'Atualizando: ' + @stats + ' na tabela ' + @tabela;
        EXEC sp_executesql @comandoSQL;
        
        -- Marca como concluído
        UPDATE #check_stats     
        SET stats_check = 1 

        -- Atualiza a tabela que servirá como histórico de todas as operações de att de estatisticas. 
        UPDATE log_estatisticas_drift
        SET check_stats = 1     
    END 

END 
































































        



