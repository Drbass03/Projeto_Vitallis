-- Proc que irá mapear os índices pouco utilizados. 

-- Tabela que irá persistir os dados coletados
CREATE TABLE historico_index (
    nome_db SYSNAME,
    nome_schema SYSNAME,
    nome_tabela SYSNAME,
    nome_index SYSNAME,
    qtd_seeks INT, 
    qtd_scans INT,
    qtd_lookups INT, 
    qtd_leituras INT,
    qtd_updates INT, 
    ult_utilizacao DATE,
    data_coleta DATE DEFAULT (GETDATE())
);

CREATE PROCEDURE sp_historico_index
    @limite_leituras INT 
AS
SET NOCOUNT ON;

INSERT INTO  historico_index 
(
    nome_db, 
    nome_schema, 
    nome_tabela ,
    nome_index, 
    qtd_seeks,
    qtd_scans,
    qtd_lookups,
    qtd_leituras,
    qtd_updates,
    ult_utilizacao
    
) 
SELECT 
    DB_NAME() AS db_nome,
    s.name AS schema_nome,
    t.name AS tb_nome,
    i.name AS index_nome,
    ISNULL(us.user_seeks, 0) AS Seeks,
    ISNULL(us.user_scans, 0) AS Scans,
    ISNULL(us.user_lookups, 0) AS Lookups,
    -- Calcula o total de operações de leitura
    (ISNULL(us.user_seeks, 0) + ISNULL(us.user_scans, 0) + ISNULL(us.user_lookups, 0)) AS total_leituras,
    ISNULL(us.user_updates, 0) AS total_updates,
    -- Identifica a maior data entre os acessos para consolidar o último uso 
    (
        SELECT MAX(v) 
        FROM (VALUES (us.last_user_seek), (us.last_user_scan), (us.last_user_lookup)) AS value(v)
    ) AS ultimoAcesso
    
     

FROM sys.indexes i
INNER JOIN sys.tables t 
    ON i.object_id = t.object_id
INNER JOIN sys.schemas s 
    ON t.schema_id = s.schema_id
-- LEFT JOIN com a DMV de estatísticas para incluir também os índices que NUNCA foram usados
LEFT JOIN sys.dm_db_index_usage_stats us 
    ON i.object_id = us.object_id 
    AND i.index_id = us.index_id
    AND us.database_id = DB_ID()

WHERE 
    t.is_ms_shipped = 0          -- Filtra apenas tabelas criadas por usuários
    AND i.index_id > 1           -- Ignora Heaps (0) e Clustered Indexes (1) 
    AND i.is_primary_key = 0     -- Ignora chaves primárias
    AND i.is_unique_constraint = 0 -- Ignora restrições de unicidade
    
    -- Filtro lógico: Procura índices que possuem atualizações (escrita) mas nenhuma ou pouquíssimas leituras
    AND (
        (ISNULL(us.user_seeks, 0) + ISNULL(us.user_scans, 0) + ISNULL(us.user_lookups, 0)) = 0 
        OR 
        (ISNULL(us.user_seeks, 0) + ISNULL(us.user_scans, 0) + ISNULL(us.user_lookups, 0)) < @limite_leituras
    )

ORDER BY 
    total_leituras ASC, 
    total_updates DESC;
