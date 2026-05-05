ALTER PROCEDURE sp_manut_index
 @DB_name VARCHAR (30) = 'treinamento'
    
AS
BEGIN
    -- 1. Criação da tabela temporária (ajustado IDENTITY e vírgulas)
    CREATE TABLE #manut_idx (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        data_coleta DATE,
        nome_schema SYSNAME,
        nome_tabela SYSNAME,
        nome_indice SYSNAME, 
        tipo_indice VARCHAR(30),
        percent_frag DECIMAL(8,2), 
        processado BIT DEFAULT 0 
    );

    -- 2. Carga inicial (ajustado parâmetros da função e nomes de colunas)
    INSERT INTO #manut_idx (data_coleta, nome_schema, nome_tabela, nome_indice, tipo_indice, percent_frag)
    SELECT 
        CAST(GETDATE() AS DATE), 
        OBJECT_SCHEMA_NAME(ps.object_id, DB_ID(@DB_name)),
        OBJECT_NAME(ps.object_id, DB_ID(@DB_name)),
        i.name,
        ps.index_type_desc,
        ROUND(ps.avg_fragmentation_in_percent, 2)
    FROM sys.dm_db_index_physical_stats(DB_ID(@DB_name), NULL, NULL, NULL, 'SAMPLED') ps
    JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
    --WHERE ps.page_count > 1000 -- Boa prática: ignora tabelas pequenas
     WHERE i.name IS NOT NULL;  -- Ignora Heaps 


    -- 3 Construção da estrutura do email informativo

    IF NOT EXISTS (SELECT 1 FROM #manut_idx)
        RETURN; 
    
    DECLARE @HTML_LINHAS NVARCHAR(MAX)  

    SELECT @HTML_LINHAS = (

         SELECT 
            '<tr>' +
            '<td>' + CAST(ID AS VARCHAR) + '</td>' +
            '<td>' + CAST(data_coleta AS VARCHAR) + '</td>' +
            '<td>' + CAST(nome_schema AS VARCHAR) + '</td>' +
            '<td>' + CAST(nome_tabela AS VARCHAR) +'</td>' +
            '<td>' + CAST(nome_indice AS VARCHAR) + '</td>' +
            '<td>' + CAST(tipo_indice AS VARCHAR) + '</td>' +
            '<td>' + CAST(percent_frag AS VARCHAR) + '</td>' +
            '</tr>'
        FROM #manut_idx
      ORDER BY percent_frag 
     
    FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)')


    DECLARE @body NVARCHAR(MAX)

    SET @body = '
    <html>
    <body style="font-family: Arial; font-size: 12px;">
    <h3>🔧 Informativo de Índices - Rebuild ou Reorganize por Fragmentação</h3>

    <p>
    Este relatório apresenta os indices que passaram por REBIULD/REORGANIZE
    </p>

    <table border="1" cellspacing="0" cellpadding="5">
    <tr style="background-color:#2F4F4F;color:white;">
        <th>ID</th>
        <th>data da coleta</th>
        <th>Schema</th>
        <th>Tabela</th>
        <th>Nome do Índice</th>
        <th>Tipo do índice</th>
        <th>Percentual de Fragmentação</th>
    </tr>'
    + @HTML_LINHAS +
    '</table></body></html>'

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'Assistente DBA II',
        @recipients = 'gbarcelos.lg@gmail.com',
        @subject = '🔧 Manutenção índices',
        @body = @BODY,
        @body_format = 'HTML'




   -- 4. Declaração de variáveis para o loop
    DECLARE 
        @ID INT,
        @Schema SYSNAME,
        @Table SYSNAME,
        @Index SYSNAME,
        @Frag DECIMAL(8,2),
        @ComandoSQL NVARCHAR(MAX);

    -- 5. O Loop WHILE
    WHILE EXISTS (SELECT 1 FROM #manut_idx WHERE processado = 0)
    BEGIN 
        SELECT TOP 1 
            @ID = ID,
            @Schema = nome_schema,
            @Table = nome_tabela,
            @Index = nome_indice,
            @Frag = percent_frag
        FROM #manut_idx
        WHERE processado = 0;

        --6 Lógica dO SQL Dinamico 
        IF @Frag > 30.0
            SET @ComandoSQL = N'ALTER INDEX ' + QUOTENAME(@Index) + 
                              N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + 
                              N' REBUILD;';
        ELSE IF @Frag > 5.0
            SET @ComandoSQL = N'ALTER INDEX ' + QUOTENAME(@Index) + 
                              N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + 
                              N' REORGANIZE;';
        ELSE
            SET @ComandoSQL = NULL;
        
        --7 Execução
        IF @ComandoSQL IS NOT NULL
        BEGIN
            
            EXEC sp_executesql @ComandoSQL;
        END

        -- Atualiza para evitar loop infinito
        UPDATE #manut_idx 
        SET processado = 1 
        WHERE ID = @ID;

    END -- Fim do WHILE
END