USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Fact_Passengers
    (
        DATE_ID,
        ORIGIN_AIRPORT_ID,
        DEST_AIRPORT_ID,
        AIRCRAFT_ID,
        PASSENGERS,
        FREIGHT,
        MAIL,
        DEPARTURES_SCHEDULED,
        DEPARTURES_PERFORMED,
        DISTANCE,
        AIR_TIME,
        DISTANCE_GROUP
    )
    SELECT TOP (1000)
        DP.DATE_ID,
        DAIR.AIRPORT_ID,
        DA.AIRPORT_ID,
        AC.AIRCRAFT_ID,
        SP.PASSENGERS,
        SP.FREIGHT,
        SP.MAIL,
        SP.DEPARTURES_SCHEDULED,
        SP.DEPARTURES_PERFORMED,
        SP.DISTANCE,
        SP.AIR_TIME,
        SP.DISTANCE_GROUP

    FROM StagingSilver.dbo.SegmentPassengers AS SP

    INNER JOIN dbo.Dim_Date_Passengers AS DP
        ON DP.[YEAR] = SP.[YEAR]
       AND DP.[MONTH] = SP.[MONTH]

    INNER JOIN dbo.Dim_Airport AS DAIR
        ON DAIR.ORIGIN = SP.ORIGIN

    LEFT JOIN dbo.Dim_Airport AS DA
        ON DA.ORIGIN = SP.DEST

    INNER JOIN dbo.Dim_Aircraft AS AC
        ON AC.DOT_ID_Reporting_Airline = SP.AIRLINE_ID
       AND AC.UNIQUE_CARRIER = SP.UNIQUE_CARRIER
       AND AC.PAYLOAD IS NOT DISTINCT FROM SP.PAYLOAD
       AND AC.SEATS IS NOT DISTINCT FROM SP.SEATS

    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Fact_Passengers AS FP
        WHERE FP.SEGMENT_PASSENGERS_ID = SP.SEGMENT_PASSENGERS_ID
    );

    COMMIT TRANSACTION;
    PRINT 'Chargement Fact_Passengers termine avec succes.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erreur pendant le chargement de Fact_Passengers :';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
