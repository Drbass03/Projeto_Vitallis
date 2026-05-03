CREATE PROCEDURE dbo.rotina_bkp
     @DBname SYSNAME,
     @tipo CHAR (1),
     @path NVARCHAR (255)

AS 
BEGIN
    SET NOCOUNT ON 

	
    IF @tipo NOT IN ('F','D','L')
    BEGIN
      RAISERROR('Tipo de backup inválido. Use F, D ou L.', 16, 1);
      RETURN;
    END

    IF DB_ID(@DBname) IS NULL
    BEGIN
     RAISERROR('Banco de dados não existe.', 16, 1);
     RETURN;
    END


    DECLARE @arquivo_bkp NVARCHAR (255)
    DECLARE @DataString NVARCHAR(20) = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');

	 SET @arquivo_bkp = @path + '\' + @DBname + '_' + 
        CASE @tipo 
            WHEN 'F' THEN 'full'
            WHEN 'D' THEN 'diff'
            ELSE 'log'
        END + '_' + @DataString + (CASE WHEN @tipo = 'L' THEN '.trn' ELSE '.bak' END);


    IF @tipo = 'F'
    BEGIN 

        BACKUP DATABASE @DBname 
        TO DISK =  @arquivo_bkp
        WITH COMPRESSION, CHECKSUM 
    END

    IF @tipo = 'D'
    BEGIN 

        BACKUP DATABASE @DBname 
        TO DISK = @arquivo_bkp
        WITH DIFFERENTIAL, COMPRESSION, CHECKSUM 
    END

    IF @tipo = 'L'
    BEGIN
	DECLARE	@arquivo_log NVARCHAR(255) 
        BACKUP LOG @DBname
        TO DISK = @arquivo_log
        WITH COMPRESSION 
    END

	IF @@ERROR = 0 
		BEGIN
			PRINT 'Iniciando validação do arquivo de backup: ' + @arquivo_bkp;
        
			RESTORE VERIFYONLY FROM DISK = @arquivo_bkp;
        
			IF @@ERROR = 0 
				PRINT 'Arquivo validado com sucesso.';
			ELSE 
				PRINT 'Erro na validação de backup.';
		END
		ELSE 
		BEGIN
			PRINT 'Erro na execução do backup. A validação foi abortada.';
		END
END
GO




