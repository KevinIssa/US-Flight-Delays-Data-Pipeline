
USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Dim_Weather
    (   
        CALL_API_ID,
        HOUR_ID,
        WEATHER_DATE,
        TEMPERATURE_2M,
        RAIN,
        SNOWFALL_CM,
        SNOW_DEPTH_M,
        WIND_SPEED_10M,
        WIND_GUSTS_10M,
        LATITUDE,
        LONGITUDE
    )
    SELECT
         CALL_API_ID,
         HOUR_ID,
         WEATHER_DATE,
         TEMPERATURE_2M,
         RAIN,
         SNOWFALL_CM,
         SNOW_DEPTH_M,
         WIND_SPEED_10M,
         WIND_GUSTS_10M,
         LATITUDE,
         LONGITUDE

    FROM StagingSilver.dbo.Weather AS W
    
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Dim_Weather AS DW
        WHERE DW.CALL_API_ID = W.CALL_API_ID
    );


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
