USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Airport
    (
       [AIRPORT_ID]
      ,[ORIGIN]
      ,[AIRPORT_NAME]
      ,[CITY]
      ,[STATE_CODE]
      ,[STATE_NAME]
      ,[COUNTRY_CODE]
      ,[LATITUDE]
      ,[LONGITUDE]
    )
    SELECT Top(1000)

        

    FROM 

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Dim_Airport AS FI
    WHERE FI.InvoiceLineId = IL.InvoiceLineId)

    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Airport termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Airport :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO


