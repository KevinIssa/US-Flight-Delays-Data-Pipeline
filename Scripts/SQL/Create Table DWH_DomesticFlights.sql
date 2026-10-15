USE DWH_DomesticFlights;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;
    
    DROP TABLE IF EXISTS Dim_Time
    DROP TABLE IF EXISTS Dim_Weather
    DROP TABLE IF EXISTS Dim_Date_Flights
    DROP TABLE IF EXISTS Dim_Airline
    DROP TABLE IF EXISTS Dim_Airport
    DROP TABLE IF EXISTS Dim_Date_Passengers
    DROP TABLE IF EXISTS Dim_Aircraft
    DROP TABLE IF EXISTS Fact_Flights
    DROP TABLE IF EXISTS Fact_Passengers


    /* ============================================================
       Table: Dim_Time
       ============================================================ */
    
    CREATE TABLE Dim_Time
    (
        [TIME_OF_THE_DAY]            INT PRIMARY KEY
    );

    /* ============================================================
       Table: Dim_Weather
       ============================================================ */

    CREATE TABLE Dim_Weather
    (
        [CALL_API_ID]                INT PRIMARY KEY,
        [TEMPERATURE]                FLOAT,
        [SNOWFALL]                   FLOAT,
        [RAIN]                       FLOAT,
        [SNOW_DEPTH]                 FLOAT,
        [WIND_SPEED_10M]             FLOAT,
        [WIND_GUSTS_10M]             FLOAT
    );


    /* ============================================================
       Table: Dim_Date_Flights
       ============================================================ */

    CREATE TABLE Dim_Date_Flights
    (
        [YEAR_MONTH]               INT NOT NULL,
        [FLIGHT_DATE]              DATE NOT NULL,
        [YEAR]                     INT NOT NULL,
        [MONTH]                    INT NOT NULL,
        [QUARTER]                  INT,
        [DAY_OF_MONTH]             INT NOT NULL,
        [DAY_OF_WEEK]              INT
    );

    /* ============================================================
       Table: Dim_Airline
       ============================================================ */
    
    CREATE TABLE Dim_Airline
    (
        [DOT_ID_REPORTING_AIRLINE] INT PRIMARY KEY,
        [REPORTING_AIRLINE]        VARCHAR(10) NOT NULL,
    );

    /* ============================================================
       Table: Dim_Airport
       ============================================================ */

    CREATE TABLE Dim_Airport
    (
        [AIRPORT_ID]    VARCHAR(20) PRIMARY KEY,
        [ORIGIN]        VARCHAR(10) NOT NULL,
        [AIRPORT_NAME]  VARCHAR(200),
        [CITY]          VARCHAR(100),
        [STATE_CODE]    VARCHAR(10),
        [STATE_NAME]    VARCHAR(100),
        [COUNTRY_CODE]  VARCHAR(10),
        [LATITUDE]      DECIMAL(10, 6) NOT NULL,
        [LONGITUDE]     DECIMAL(10, 6) NOT NULL
    );


    
    /* ============================================================
       Table: Dim_Date_Passengers
       ============================================================ */

    CREATE TABLE Dim_Date_Passengers
    (
        [YEAR_MONTH]             INT NOT NULL,
        [YEAR]                   INT NOT NULL,
        [MONTH]                  INT NOT NULL,
        [QUARTER]                INT
    );

    
    /* ============================================================
       Table: Dim_Aircraft
       ============================================================ */

    CREATE TABLE Dim_Aircraft
    (
         [AIRCRAFT_ID]            INT PRIMARY KEY IDENTITY(1,1),
         [FK_AIRLINE_ID]          INT NOT NULL,
         [UNIQUE_CARRIER]         VARCHAR(10) NOT NULL,
         [CARRIER_NAME]           VARCHAR(200),
         [PAYLOAD]                DECIMAL(18, 2),
         [SEATS]                  DECIMAL(12, 2),
         [PASSENGERS]             DECIMAL(12, 2) NOT NULL,
         [FREIGHT]                DECIMAL(18, 2),
         [MAIL]                   DECIMAL(18, 2)
    );



    /* ============================================================
       Table: Fact_Flights
       ============================================================ */

    CREATE TABLE Fact_Flights
    (
        [FLIGHT_ID]                INT PRIMARY KEY IDENTITY(1,1),     
        [FK_ORIGIN_AIRPORT_ID]     INT NOT NULL,
        --[ORIGIN]                   VARCHAR(10) NOT NULL,
        --[ORIGIN_CITY_NAME]         VARCHAR(100),
        --[ORIGIN_STATE]             VARCHAR(10),
        --[ORIGIN_STATE_NAME]        VARCHAR(100),
        [FK_DEST_AIRPORT_ID]       INT,
        --[DEST]                     VARCHAR(10),
        --[DEST_CITY_NAME]           VARCHAR(100),
        --[DEST_STATE]               VARCHAR(10),
        --[DEST_STATE_NAME]          VARCHAR(100),
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
        [DIV_DISTANCE]             DECIMAL(12, 2)
    );

    /* ============================================================
       Table: Fact_Passengers
       ============================================================ */

    CREATE TABLE Fact_Passengers
    (
        [SEGMENT_PASSENGERS_ID]  INT PRIMARY KEY,
        [FK_ORIGIN_AIRPORT_ID]   INT NOT NULL,
        [FK_DEST_AIRPORT_ID]     INT,
        [DEPARTURES_SCHEDULED]   DECIMAL(12, 2),
        [DEPARTURES_PERFORMED]   DECIMAL(12, 2) NOT NULL,
        [DISTANCE]               DECIMAL(12, 2),
        [AIR_TIME]               DECIMAL(12, 2),
        --[ORIGIN]                 VARCHAR(10) NOT NULL,
        --[ORIGIN_CITY_NAME]       VARCHAR(100),
        --[ORIGIN_STATE_ABR]       VARCHAR(10),
        --[ORIGIN_STATE_NM]        VARCHAR(100),
        --[DEST]                   VARCHAR(10),
        --[DEST_CITY_NAME]         VARCHAR(100),
        --[DEST_STATE_ABR]         VARCHAR(10),
        --[DEST_STATE_NM]          VARCHAR(100),
        [DISTANCE_GROUP]         INT
    );


    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO