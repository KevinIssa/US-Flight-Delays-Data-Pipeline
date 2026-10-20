USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Date_Flights
    (
        FLIGHT_DATE,
        [YEAR],
        [MONTH],
        [QUARTER],
        DAY_OF_MONTH,
        DAY_OF_WEEK
    )
    SELECT DISTINCT
        F.FLIGHT_DATE,
        F.[YEAR],
        F.[MONTH],
        F.[QUARTER],
        F.DAY_OF_MONTH,
        F.DAY_OF_WEEK

    FROM StagingSilver.dbo.Flights AS F

    WHERE F.FLIGHT_DATE IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM dbo.Dim_Date_Flights AS DF
        WHERE DF.FLIGHT_DATE = F.FLIGHT_DATE
    )

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

