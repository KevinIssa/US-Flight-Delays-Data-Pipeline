
USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Aircraft
    (
       DOT_ID_Reporting_Airline,
       UNIQUE_CARRIER,
       PAYLOAD,
       SEATS
    )

    SELECT DISTINCT TOP (1000)

       DA.DOT_ID_REPORTING_AIRLINE,
       SP.UNIQUE_CARRIER,
       SP.PAYLOAD,
       SP.SEATS

    FROM StagingSilver.dbo.SegmentPassengers AS SP

    INNER JOIN dbo.Dim_Airline AS DA
        ON SP.AIRLINE_ID = DA.DOT_ID_REPORTING_AIRLINE

    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Dim_Aircraft AS AC
        WHERE AC.DOT_ID_Reporting_Airline = DA.DOT_ID_REPORTING_AIRLINE
          AND (AC.UNIQUE_CARRIER = SP.UNIQUE_CARRIER
               OR (AC.UNIQUE_CARRIER IS NULL AND SP.UNIQUE_CARRIER IS NULL))
          AND (AC.PAYLOAD = SP.PAYLOAD
               OR (AC.PAYLOAD IS NULL AND SP.PAYLOAD IS NULL))
          AND (AC.SEATS = SP.SEATS
               OR (AC.SEATS IS NULL AND SP.SEATS IS NULL))
    );

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
