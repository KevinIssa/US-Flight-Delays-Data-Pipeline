USE StagingSilver;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    /* ============================================================
       Table: Flights
       ============================================================ */

    CREATE TABLE dbo.Flights
    (
        [QUARTER]                  INT,
        [DAY_OF_MONTH]             INT,
        [DAY_OF_WEEK]              INT,
        [FLIGHT_DATE]              DATE,
        [REPORTING_AIRLINE]        VARCHAR(10),
        [DOT_ID_REPORTING_AIRLINE] INT,
        [ORIGIN_AIRPORT_ID]        INT,
        [ORIGIN]                   VARCHAR(10),
        [ORIGIN_CITY_NAME]         VARCHAR(100),
        [ORIGIN_STATE]              VARCHAR(10),
        [ORIGIN_STATE_NAME]        VARCHAR(100),
        [DEST_AIRPORT_ID]          INT,
        [DEST]                     VARCHAR(10),
        [DEST_CITY_NAME]           VARCHAR(100),
        [DEST_STATE]               VARCHAR(10),
        [DEST_STATE_NAME]          VARCHAR(100),
        [CRS_DEP_TIME]             INT,
        [DEP_TIME]                 INT,
        [DEP_DELAY]                DECIMAL(10, 2),
        [TAXI_OUT]                 DECIMAL(10, 2),
        [WHEEL_OFF]                INT,
        [WHEEL_ON]                 INT,
        [TAXI_IN]                  DECIMAL(10, 2),
        [CRS_ARR_TIME]             INT,
        [ARR_TIME]                 INT,
        [ARR_DELAY]                DECIMAL(10, 2),
        [CANCELLED]                DECIMAL(10, 2),
        [CANCELLATION_CODE]        VARCHAR(10),
        [CRS_ELAPSED_TIME]         DECIMAL(10, 2),
        [ACTUAL_ELAPSED_TIME]      DECIMAL(10, 2),
        [AIR_TIME]                 DECIMAL(10, 2),
        [DISTANCE]                 DECIMAL(12, 2),
        [DISTANCE_GROUP]           DECIMAL(10, 2),
        [CARRIER_DELAY]            DECIMAL(10, 2),
        [WEATHER_DELAY]            DECIMAL(10, 2),
        [NAS_DELAY]                DECIMAL(10, 2),
        [SECURITY_DELAY]           DECIMAL(10, 2),
        [LATE_AIRCRAFT_DELAY]      DECIMAL(10, 2),
        [DIV_AIRPORT_LANDINGS]     INT,
        [DIV_REACHED_DEST]         DECIMAL(10, 2),
        [DIV_ACTUAL_ELAPSED_TIME]  DECIMAL(10, 2),
        [DIV_ARR_DELAY]            DECIMAL(10, 2),
        [DIV_DISTANCE]             DECIMAL(12, 2),
        [LATITUDE]                 DECIMAL(10, 6),
        [LONGITUDE]                DECIMAL(10, 6),
        [YEAR]                     INT,
        [MONTH]                    INT
    );


    /* ============================================================
       Table: Passengers
       ============================================================ */

    CREATE TABLE dbo.Passengers
    (
        [DEPARTURES_SCHEDULED]   DECIMAL(12, 2),
        [DEPARTURES_PERFORMED]   DECIMAL(12, 2),
        [PAYLOAD]                DECIMAL(18, 2),
        [SEATS]                  DECIMAL(12, 2),
        [PASSENGERS]             DECIMAL(12, 2),
        [FREIGHT]                DECIMAL(18, 2),
        [MAIL]                   DECIMAL(18, 2),
        [DISTANCE]               DECIMAL(12, 2),
        [AIR_TIME]               DECIMAL(12, 2),
        [UNIQUE_CARRIER]         VARCHAR(10),
        [AIRLINE_ID]             INT,
        [CARRIER_NAME]           VARCHAR(200),
        [ORIGIN_AIRPORT_ID]      INT,
        [ORIGIN]                 VARCHAR(10),
        [ORIGIN_CITY_NAME]       VARCHAR(100),
        [ORIGIN_STATE_ABR]       VARCHAR(10),
        [ORIGIN_STATE_NM]        VARCHAR(100),
        [DEST_AIRPORT_ID]        INT,
        [DEST]                   VARCHAR(10),
        [DEST_CITY_NAME]         VARCHAR(100),
        [DEST_STATE_ABR]         VARCHAR(10),
        [DEST_STATE_NM]          VARCHAR(100),
        [QUARTER]                INT,
        [DISTANCE_GROUP]         INT,
        [YEAR]                   INT,
        [MONTH]                  INT
    );


    /* ============================================================
       Table: Runways
       ============================================================ */

    CREATE TABLE dbo.Runways
    (
        [OID]           INT PRIMARY KEY,
        [STATE_CODE]    VARCHAR(10),
        [ARPT_ID]       VARCHAR(20),
        [ARPT_NAME]     VARCHAR(200),
        [CITY]          VARCHAR(100),
        [COUNTRY_CODE]  VARCHAR(10),
        [LATITUDE]      DECIMAL(10, 6),
        [LONGITUDE]     DECIMAL(10, 6)
    );


    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO



/* ============================================================
   Table: Runways
   ============================================================ */

CREATE TABLE dbo.Runways
(
    OID           INT PRIMARY KEY,
    STATE_CODE    VARCHAR(10),
    ARPT_ID       VARCHAR(20),
    ARPT_NAME     VARCHAR(200),
    CITY          VARCHAR(100),
    COUNTRY_CODE  VARCHAR(10),
    LATITUDE      DECIMAL(10,6),
    LONGITUDE     DECIMAL(10,6)
);
GO
