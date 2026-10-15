USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Aircraft
    (
       [FK_AIRLINE_ID]
      ,[UNIQUE_CARRIER]
      ,[CARRIER_NAME]
      ,[PAYLOAD]
      ,[SEATS]
      ,[PASSENGERS]
      ,[FREIGHT]
      ,[MAIL]
    )
    SELECT Top(1000)

       [AIRLINE_ID]
      ,[UNIQUE_CARRIER]
      ,[CARRIER_NAME]
      ,[PAYLOAD]
      ,[SEATS]
      ,[PASSENGERS]
      ,[FREIGHT]
      ,[MAIL]

    FROM StagingSilver.dbo.SegmentPassengers

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Dim_Aircraft AS FI
    WHERE FI.InvoiceLineId = IL.InvoiceLineId)

    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Aircraft termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Aircraft :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
