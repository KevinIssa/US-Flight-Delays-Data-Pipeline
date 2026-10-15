USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Fact_Flights
    (
       [FK_ORIGIN_AIRPORT_ID]
      ,[FK_DEST_AIRPORT_ID]
      ,[CRS_DEP_TIME]
      ,[DEP_TIME]
      ,[DEP_DELAY]
      ,[TAXI_OUT]
      ,[WHEEL_OFF]
      ,[WHEEL_ON]
      ,[TAXI_IN]
      ,[CRS_ARR_TIME]
      ,[ARR_TIME]
      ,[ARR_DELAY]
      ,[CANCELLED]
      ,[CANCELLATION_CODE]
      ,[CRS_ELAPSED_TIME]
      ,[ACTUAL_ELAPSED_TIME]
      ,[AIR_TIME]
      ,[DISTANCE]
      ,[DISTANCE_GROUP]
      ,[CARRIER_DELAY]
      ,[WEATHER_DELAY]
      ,[NAS_DELAY]
      ,[SECURITY_DELAY]
      ,[LATE_AIRCRAFT_DELAY]
      ,[DIV_AIRPORT_LANDINGS]
      ,[DIV_REACHED_DEST]
      ,[DIV_ACTUAL_ELAPSED_TIME]
      ,[DIV_ARR_DELAY]
      ,[DIV_DISTANCE]
    )
    SELECT Top(1000)

       [ORIGIN_AIRPORT_ID]
      ,[DEST_AIRPORT_ID]
      ,[CRS_DEP_TIME]
      ,[DEP_TIME]
      ,[DEP_DELAY]
      ,[TAXI_OUT]
      ,[WHEEL_OFF]
      ,[WHEEL_ON]
      ,[TAXI_IN]
      ,[CRS_ARR_TIME]
      ,[ARR_TIME]
      ,[ARR_DELAY]
      ,[CANCELLED]
      ,[CANCELLATION_CODE]
      ,[CRS_ELAPSED_TIME]
      ,[ACTUAL_ELAPSED_TIME]
      ,[AIR_TIME]
      ,[DISTANCE]
      ,[DISTANCE_GROUP]
      ,[CARRIER_DELAY]
      ,[WEATHER_DELAY]
      ,[NAS_DELAY]
      ,[SECURITY_DELAY]
      ,[LATE_AIRCRAFT_DELAY]
      ,[DIV_AIRPORT_LANDINGS]
      ,[DIV_REACHED_DEST]
      ,[DIV_ACTUAL_ELAPSED_TIME]
      ,[DIV_ARR_DELAY]
      ,[DIV_DISTANCE]

    FROM StagingSilver.dbo.Flights AS Stg

    WHERE NOT EXISTS(
    SELECT 1 FROM DWH_DomesticFlights.dbo.Fact_Flights AS FF
    WHERE FF.FLIGHT_ID = Stg.FLIGHT_ID)

    COMMIT TRANSACTION;
    PRINT 'Chargement Fact_Flights termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Fact_Flights :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
