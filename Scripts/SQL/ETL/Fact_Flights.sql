
USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Fact_Flights
    (
        FLIGHT_ID,
        DATE_ID,
        ORIGIN_AIRPORT_ID,
        DEST_AIRPORT_ID,
        API_ID,
        HOUR_OF_THE_DAY,
        REPORTING_AIRLINE_ID,
        CRS_DEP_TIME,
        DEP_TIME,
        DEP_DELAY,
        TAXI_OUT,
        WHEEL_OFF,
        WHEEL_ON,
        TAXI_IN,
        CRS_ARR_TIME,
        ARR_TIME,
        ARR_DELAY,
        CANCELLED,
        CANCELLATION_CODE,
        CRS_ELAPSED_TIME,
        ACTUAL_ELAPSED_TIME,
        AIR_TIME,
        DISTANCE,
        DISTANCE_GROUP,
        CARRIER_DELAY,
        WEATHER_DELAY,
        NAS_DELAY,
        SECURITY_DELAY,
        LATE_AIRCRAFT_DELAY,
        DIV_AIRPORT_LANDINGS,
        DIV_REACHED_DEST,
        DIV_ACTUAL_ELAPSED_TIME,
        DIV_ARR_DELAY,
        DIV_DISTANCE
    )
    SELECT TOP (1000)
        F.FLIGHT_ID,
        DF.DATE_ID,
        AO.AIRPORT_ID AS ORIGIN_AIRPORT_ID ,
        AD.AIRPORT_ID AS DEST_AIRPORT_ID,
        CAST(NULL AS INT),
        DT.HOUR_OF_THE_DAY,
        AL.DOT_ID_REPORTING_AIRLINE,
        F.CRS_DEP_TIME,
        F.DEP_TIME,
        F.DEP_DELAY,
        F.TAXI_OUT,
        F.WHEEL_OFF,
        F.WHEEL_ON,
        F.TAXI_IN,
        F.CRS_ARR_TIME,
        F.ARR_TIME,
        F.ARR_DELAY,
        F.CANCELLED,
        F.CANCELLATION_CODE,
        F.CRS_ELAPSED_TIME,
        F.ACTUAL_ELAPSED_TIME,
        F.AIR_TIME,
        F.DISTANCE,
        F.DISTANCE_GROUP,
        F.CARRIER_DELAY,
        F.WEATHER_DELAY,
        F.NAS_DELAY,
        F.SECURITY_DELAY,
        F.LATE_AIRCRAFT_DELAY,
        F.DIV_AIRPORT_LANDINGS,
        F.DIV_REACHED_DEST,
        F.DIV_ACTUAL_ELAPSED_TIME,
        F.DIV_ARR_DELAY,
        F.DIV_DISTANCE

    FROM StagingSilver.dbo.Flights AS F

    INNER JOIN dbo.Dim_Date_Flights AS DF
        ON DF.FLIGHT_DATE = F.FLIGHT_DATE

    INNER JOIN dbo.Dim_Airport AS AO
        ON AO.ORIGIN = F.ORIGIN

    LEFT JOIN dbo.Dim_Airport AS AD
        ON AD.ORIGIN = F.DEST

    INNER JOIN dbo.Dim_Airline AS AL
        ON AL.DOT_ID_REPORTING_AIRLINE = F.DOT_ID_REPORTING_AIRLINE

    LEFT JOIN dbo.Dim_Time AS DT
        ON DT.HOUR_OF_THE_DAY = CASE
            WHEN F.CRS_DEP_TIME = 2400 THEN 0
            ELSE CAST(FLOOR(F.CRS_DEP_TIME / 100.0) * 100 AS INT)
        END

    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Fact_Flights AS FF
        WHERE FF.FLIGHT_ID = F.FLIGHT_ID
    );

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
