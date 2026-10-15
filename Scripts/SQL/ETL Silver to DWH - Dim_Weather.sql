USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Weather
    (
       [CALL_API_ID]
      ,[TEMPERATURE]
      ,[SNOWFALL]
      ,[RAIN]
      ,[SNOW_DEPTH]
      ,[WIND_SPEED_10M]
      ,[WIND_GUSTS_10M]
    )
    SELECT Top(1000)

        

    FROM 

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Dim_Weather AS FI
    WHERE FI.InvoiceLineId = IL.InvoiceLineId)

    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Weather termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Weather :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO