USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Fact_Passengers
    (
       [SEGMENT_PASSENGERS_ID]
      ,[FK_ORIGIN_AIRPORT_ID]
      ,[FK_DEST_AIRPORT_ID]
      ,[DEPARTURES_SCHEDULED]
      ,[DEPARTURES_PERFORMED]
      ,[DISTANCE]
      ,[AIR_TIME]
      ,[DISTANCE_GROUP]
    )
    SELECT Top(1000)

        

    FROM 

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Fact_Passengers AS FI
    WHERE FI.InvoiceLineId = IL.InvoiceLineId)

    COMMIT TRANSACTION;
    PRINT 'Chargement Fact_Passengers termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Fact_Passengers :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
