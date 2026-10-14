USE StagingSilver;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;
    
    DROP TABLE IF EXISTS Flights
    DROP TABLE IF EXISTS SegmentPassengers
    DROP TABLE IF EXISTS Runways

    /* ============================================================
       Table: Flights
       ============================================================ */

    CREATE TABLE Flights
    (
        FLIGHT_ID                  INT PRIMARY KEY IDENTITY(1,1),
        [YEAR]                     INT NOT NULL,
        [MONTH]                    INT NOT NULL,
        [QUARTER]                  INT,
        [DAY_OF_MONTH]             INT NOT NULL,
        [DAY_OF_WEEK]              INT,
        [FLIGHT_DATE]              DATE NOT NULL,
        [REPORTING_AIRLINE]        VARCHAR(10) NOT NULL,
        [DOT_ID_REPORTING_AIRLINE] INT NOT NULL,
        [ORIGIN_AIRPORT_ID]        INT NOT NULL,
        [ORIGIN]                   VARCHAR(10) NOT NULL,
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
        [CANCELLED]                DECIMAL(10, 2) NOT NULL,
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
        ROW_HASH                   VARCHAR(65) NOT NULL
    );


    /* ============================================================
       Table: Passengers
       ============================================================ */

    CREATE TABLE SegmentPassengers
    (
        
        [SEGMENT_PASSENGERS_ID]  INT PRIMARY KEY IDENTITY(1,1),
        [YEAR]                   INT NOT NULL,
        [MONTH]                  INT NOT NULL,
        [QUARTER]                INT,
        [DEPARTURES_SCHEDULED]   DECIMAL(12, 2),
        [DEPARTURES_PERFORMED]   DECIMAL(12, 2) NOT NULL,
        [PAYLOAD]                DECIMAL(18, 2),
        [SEATS]                  DECIMAL(12, 2),
        [PASSENGERS]             DECIMAL(12, 2) NOT NULL,
        [FREIGHT]                DECIMAL(18, 2),
        [MAIL]                   DECIMAL(18, 2),
        [DISTANCE]               DECIMAL(12, 2),
        [AIR_TIME]               DECIMAL(12, 2),
        [UNIQUE_CARRIER]         VARCHAR(10),
        [AIRLINE_ID]             INT,
        [CARRIER_NAME]           VARCHAR(200),
        [ORIGIN_AIRPORT_ID]      INT NOT NULL,
        [ORIGIN]                 VARCHAR(10) NOT NULL,
        [ORIGIN_CITY_NAME]       VARCHAR(100),
        [ORIGIN_STATE_ABR]       VARCHAR(10),
        [ORIGIN_STATE_NM]        VARCHAR(100),
        [DEST_AIRPORT_ID]        INT,
        [DEST]                   VARCHAR(10),
        [DEST_CITY_NAME]         VARCHAR(100),
        [DEST_STATE_ABR]         VARCHAR(10),
        [DEST_STATE_NM]          VARCHAR(100),
        [DISTANCE_GROUP]         INT,
        ROW_HASH                 VARCHAR(65) NOT NULL
    );


    /* ============================================================
       Table: Runways
       ============================================================ */

    CREATE TABLE Runways
    (
        [OID]           INT PRIMARY KEY IDENTITY(1,1),
        [STATE_CODE]    VARCHAR(10),
        [ARPT_ID]       VARCHAR(20) NOT NULL,
        [ARPT_NAME]     VARCHAR(200),
        [CITY]          VARCHAR(100),
        [COUNTRY_CODE]  VARCHAR(10),
        [LATITUDE]      DECIMAL(10, 6) NOT NULL,
        [LONGITUDE]     DECIMAL(10, 6) NOT NULL,
        ROW_HASH        VARCHAR(65) NOT NULL
    );
    

    -- 1. Table Flights
    CREATE UNIQUE INDEX UX_Flights_Hash
    ON dbo.Flights (ROW_HASH)
    WITH (IGNORE_DUP_KEY = OFF);
       
     -- 2. Table SegmentPassengers
    CREATE UNIQUE INDEX UX_SegmentPassengers_Hash
    ON dbo.SegmentPassengers (ROW_HASH)
    WITH (IGNORE_DUP_KEY = OFF);

    -- 3. Table Runways
    CREATE UNIQUE INDEX UX_Runways_Hash
    ON dbo.Runways (ROW_HASH)
    WITH (IGNORE_DUP_KEY = OFF); 


    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO