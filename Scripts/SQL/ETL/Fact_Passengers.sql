USE DWH_DomesticFlights;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Fact_Passengers
    (
        SEGMENT_PASSENGERS_ID,
        DATE_ID,
        DOT_ID_REPORTING_AIRLINE,
        ORIGIN_AIRPORT_ID,
        DEST_AIRPORT_ID,
        PAYLOAD,
        SEATS,
        PASSENGERS,
        FREIGHT,
        MAIL,
        DEPARTURES_SCHEDULED,
        DEPARTURES_PERFORMED,
        DISTANCE,
        AIR_TIME,
        DISTANCE_GROUP
    )
    SELECT
        
        SP.SEGMENT_PASSENGERS_ID,
        DP.DATE_ID,
        DAL.DOT_ID_REPORTING_AIRLINE,
        DAIR.AIRPORT_ID,
        DA.AIRPORT_ID,
        SP.PAYLOAD,
        SP.SEATS,
        SP.PASSENGERS,
        SP.FREIGHT,
        SP.MAIL,
        SP.DEPARTURES_SCHEDULED,
        SP.DEPARTURES_PERFORMED,
        SP.DISTANCE,
        SP.AIR_TIME,
        SP.DISTANCE_GROUP

    FROM StagingSilver.dbo.SegmentPassengers AS SP
       
    INNER JOIN dbo.Dim_Airline AS DAL
        ON DAL.DOT_ID_REPORTING_AIRLINE = SP.AIRLINE_ID

    INNER JOIN dbo.Dim_Date_Passengers AS DP
        ON DP.[YEAR] = SP.[YEAR]
       AND DP.[MONTH] = SP.[MONTH]

    
    INNER JOIN dbo.Dim_Airport AS DAIR
        ON DAIR.ORIGIN = CASE SP.ORIGIN
            WHEN 'FCA' THEN 'GPI'
            WHEN 'AZA' THEN 'IWA'
            WHEN 'USA' THEN 'JQF'
            WHEN 'PBI' THEN 'DJT'
            WHEN 'HHH' THEN 'HXD'
            WHEN 'YUM' THEN 'NYL'
            WHEN 'MQT' THEN 'SAW'
            WHEN 'SCE' THEN 'UNV'
            WHEN 'SPN' THEN 'GSN'
            WHEN 'GUF' THEN 'JKA'
            WHEN 'RDB' THEN 'DGG'
            WHEN 'CLD' THEN 'CRQ'
            WHEN 'BKG' THEN 'BBG'
            ELSE SP.ORIGIN
        END

    LEFT JOIN dbo.Dim_Airport AS DA
        ON DA.ORIGIN = CASE SP.DEST
            WHEN 'FCA' THEN 'GPI'
            WHEN 'AZA' THEN 'IWA'
            WHEN 'USA' THEN 'JQF'
            WHEN 'PBI' THEN 'DJT'
            WHEN 'HHH' THEN 'HXD'
            WHEN 'YUM' THEN 'NYL'
            WHEN 'MQT' THEN 'SAW'
            WHEN 'SCE' THEN 'UNV'
            WHEN 'SPN' THEN 'GSN'
            WHEN 'GUF' THEN 'JKA'
            WHEN 'RDB' THEN 'DGG'
            WHEN 'CLD' THEN 'CRQ'
            WHEN 'BKG' THEN 'BBG'
            ELSE SP.DEST
        END


    
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
