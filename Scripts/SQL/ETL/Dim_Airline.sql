
USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    WITH Airlines_Flights AS (
        SELECT
            DOT_ID_REPORTING_AIRLINE,
            MAX(REPORTING_AIRLINE) AS REPORTING_AIRLINE
        FROM StagingSilver.dbo.Flights
        GROUP BY DOT_ID_REPORTING_AIRLINE
    ),

    Airlines_Passengers AS (
        SELECT
            AIRLINE_ID,
            MAX(CARRIER_NAME) AS AIRLINE_NAME
        FROM StagingSilver.dbo.SegmentPassengers
        GROUP BY AIRLINE_ID
    )

    INSERT INTO dbo.Dim_Airline
    (
        DOT_ID_REPORTING_AIRLINE,
        REPORTING_AIRLINE,
        AIRLINE_NAME
    )
    SELECT
        F.DOT_ID_REPORTING_AIRLINE,
        F.REPORTING_AIRLINE,
        SP.AIRLINE_NAME

    FROM Airlines_Flights AS F

    INNER JOIN Airlines_Passengers AS SP
        ON F.DOT_ID_REPORTING_AIRLINE = SP.AIRLINE_ID

    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Dim_Airline AS DA
        WHERE DA.DOT_ID_REPORTING_AIRLINE = F.DOT_ID_REPORTING_AIRLINE
    );

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

