USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Airline
    (
       [DOT_ID_REPORTING_AIRLINE]
      ,[REPORTING_AIRLINE]
    )
    SELECT Top(1000)

        

    FROM 

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Dim_Airline AS FI
    WHERE FI.InvoiceLineId = IL.InvoiceLineId)

    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Airline termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Airline :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO

