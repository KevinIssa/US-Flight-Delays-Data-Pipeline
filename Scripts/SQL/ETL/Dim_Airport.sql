USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Airport
    (
       ORIGIN,
       AIRPORT_NAME,
       CITY,
       STATE_CODE,
       COUNTRY_CODE,
       LATITUDE,
       LONGITUDE
    )      

    SELECT DISTINCT ARPT_ID,
        ARPT_NAME,
        R.CITY,
        R.STATE_CODE,
        R.COUNTRY_CODE,
        R.LATITUDE,
        R.LONGITUDE
   
    FROM StagingSilver.dbo.Runways AS R

    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Dim_Airport AS DA
        WHERE DA.ORIGIN = R.ARPT_ID AND DA.LATITUDE = R.LATITUDE AND R.LONGITUDE = R.LONGITUDE

    );

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


