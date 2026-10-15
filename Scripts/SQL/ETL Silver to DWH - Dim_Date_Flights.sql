USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Date_Flights
    (
       [YEAR_MONTH]
      ,[FLIGHT_DATE]
      ,[YEAR]
      ,[MONTH]
      ,[QUARTER]
      ,[DAY_OF_MONTH]
      ,[DAY_OF_WEEK]
    )
    SELECT Top(1000)

        CONCAT("YEAR"+"MONTH)
       ,[FLIGHT_DATE]
       ,[YEAR]
       ,[MONTH]
       ,[QUARTER]
       ,[DAY_OF_MONTH]
       ,[DAY_OF_WEEK]
        

    FROM StagingSilver.dbo.Flights

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Dim_Date_Flights AS FI
    WHERE FI.InvoiceLineId = IL.InvoiceLineId)

    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Date_Flights termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Date_Flights :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
