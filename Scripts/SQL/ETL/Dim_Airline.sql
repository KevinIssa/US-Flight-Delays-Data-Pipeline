USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Airline
    (
        DOT_ID_REPORTING_AIRLINE,
        AIRLINE_NAME
    )
    SELECT DISTINCT TOP (1000)
        F.DOT_ID_REPORTING_AIRLINE,
        F.REPORTING_AIRLINE

    FROM StagingSilver.dbo.Flights AS F

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

