USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Time
    (
        HOUR_OF_THE_DAY
    )
    VALUES(0000, 100, 200, 300, 400, 500, 
           600, 700, 800, 900, 1000, 1100, 
           1200, 1300, 1400, 1500, 1600, 1700, 
           1800, 1900, 2000, 2100, 2200, 2300)


    COMMIT TRANSACTION;
    PRINT 'Chargement Dim_Time termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Dim_Time :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO