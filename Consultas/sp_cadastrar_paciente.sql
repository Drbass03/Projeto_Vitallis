CREATE OR ALTER PROCEDURE sch_pacientes.cadastrar_paciente
    @nome              VARCHAR(30),
    @sexo              CHAR(1),
    @dt_Nasc           DATE,
    @email             VARCHAR(30),
    @contato           VARCHAR(13),
    @CPF               VARCHAR(11),
    @convenio          BIT,
    @nomeMae           VARCHAR(30),
    @nomeEmergencia    VARCHAR(30),
    @cttEmergencia     VARCHAR(11),
    @tipo              VARCHAR(12),
    @titular_ID        INT,
    @idConvenio        INT,
    @rua               VARCHAR(30),
    @numero            VARCHAR(11),
    @bairro            VARCHAR(30),
    @cidade            VARCHAR(30),
    @estado            CHAR(2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ID_NovoPaciente INT;

    BEGIN TRY

        BEGIN TRAN;

        -- 1. Cadastro do paciente
        INSERT INTO sch_pacientes.paciente
        (
            nome,
            sexo,
            dt_Nasc,
            dataCadastro,
            email,
            contato,
            CPF,
            convenio,
            nomeMae,
            nomeEmergencia,
            cttEmergencia,
            tipo,
            titular_ID,
            idConvenio
        )
        VALUES
        (
            @nome,
            @sexo,
            @dt_Nasc,
            GETDATE(),
            @email,
            @contato,
            @CPF,
            @convenio,
            @nomeMae,
            @nomeEmergencia,
            @cttEmergencia,
            @tipo,
            @titular_ID,
            @idConvenio
        );

        -- 2. Recupera ID gerado
        SET @ID_NovoPaciente =
            CONVERT(INT, SCOPE_IDENTITY());

        -- 3. Cadastro do endereço
        INSERT INTO sch_pacientes.endereco
        (
            idPaciente,
            rua,
            numero,
            bairro,
            cidade,
            estado
        )
        VALUES
        (
            @ID_NovoPaciente,
            @rua,
            @numero,
            @bairro,
            @cidade,
            @estado
        );

        INSERT INTO sch_atendimento.mainProntuario 
        (
            IdPaciente,
            DataCriacao
        )
        VALUES
        (
            @ID_NovoPaciente,
            GETDATE()
        );
        

        -- 4. Confirma as duas operações
        COMMIT TRANSACTION;


    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;;

    END CATCH;
END;
