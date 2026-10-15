USE DWH_DomesticFlights;
GO


BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Date_Passengers
    (
       [YEAR_MONTH]
      ,[YEAR]
      ,[MONTH]
      ,[QUARTER]
    )
    SELECT Top(1000)

        

    FROM 

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Dim_Date_Passengers AS FI
    WHERE FI.InvoiceLineId = IL.InvoiceLineId)

    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Date_Passengers termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Date_Passengers :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO

