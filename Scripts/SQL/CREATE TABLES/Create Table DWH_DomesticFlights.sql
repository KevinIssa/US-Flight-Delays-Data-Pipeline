USE DWH_DomesticFlights;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;
       
    DROP TABLE IF EXISTS Fact_Flights
    DROP TABLE IF EXISTS Fact_Passengers
    DROP TABLE IF EXISTS Dim_Time
    DROP TABLE IF EXISTS Dim_Weather
    DROP TABLE IF EXISTS Dim_Date_Flights
    DROP TABLE IF EXISTS Dim_Airline
    DROP TABLE IF EXISTS Dim_Airport
    DROP TABLE IF EXISTS Dim_Date_Passengers


    /* ============================================================
       Table: Dim_Time
       ============================================================ */
    
    CREATE TABLE Dim_Time
    (
        HOUR_OF_THE_DAY            INT PRIMARY KEY --ddmm format
    );

    /* ============================================================
       Table: Dim_Weather
       ============================================================ */

    CREATE TABLE dbo.Dim_Weather
    (
        CALL_API_ID INT PRIMARY KEY,
        HOUR_ID TINYINT NOT NULL,
        WEATHER_DATE DATE NOT NULL,
        TEMPERATURE_2M DECIMAL(5,2) NULL,
        RAIN DECIMAL(8,2) NULL,
        SNOWFALL_CM DECIMAL(8,2) NULL,
        SNOW_DEPTH_M DECIMAL(8,3) NULL,
        WIND_SPEED_10M DECIMAL(7,2) NULL,
        WIND_GUSTS_10M DECIMAL(7,2) NULL,
        LATITUDE DECIMAL(9,6) NOT NULL,
        LONGITUDE DECIMAL(9,6) NOT NULL,

    );


    /* ============================================================
       Table: Dim_Date_Flights
       ============================================================ */

    CREATE TABLE Dim_Date_Flights
    (
        DATE_ID                  INT PRIMARY KEY IDENTITY(1,1),
        FLIGHT_DATE              DATE UNIQUE NOT NULL,
        [YEAR]                   INT NOT NULL,
        [MONTH]                  INT NOT NULL,
        [QUARTER]                INT,
        DAY_OF_MONTH             INT NOT NULL,
        DAY_OF_WEEK              INT

    );

    /* ============================================================
       Table: Dim_Airline
       ============================================================ */
    
    CREATE TABLE Dim_Airline
    (
        DOT_ID_REPORTING_AIRLINE INT PRIMARY KEY,
        REPORTING_AIRLINE        VARCHAR(10) NOT NULL,
        AIRLINE_NAME             VARCHAR(200) --Carrier Name in passengers

    );

    /* ============================================================
       Table: Dim_Airport
       ============================================================ */

    CREATE TABLE Dim_Airport
    (
        AIRPORT_ID      INT PRIMARY KEY IDENTITY(1,1),
        ORIGIN          VARCHAR(10) NOT NULL, --arpt_id from runways can be origin and dest for a flight
        AIRPORT_NAME    VARCHAR(200), --from runways
        CITY            VARCHAR(100),
        STATE_CODE      VARCHAR(10),
        COUNTRY_CODE    VARCHAR(10),
        LATITUDE        DECIMAL(10, 6) NOT NULL,
        LONGITUDE       DECIMAL(10, 6) NOT NULL
    );


    
    /* ============================================================
       Table: Dim_Date_Passengers
       ============================================================ */

    CREATE TABLE Dim_Date_Passengers
    (
        DATE_ID                INT PRIMARY KEY IDENTITY(1,1),
        [YEAR]                 INT NOT NULL,
        [MONTH]                INT NOT NULL,
        [QUARTER]              INT

        CONSTRAINT FK_DIM_DATE_FLIGHT FOREIGN KEY (YEAR,MONTH) REFERENCES Dim_Date_Flights((YEAR,MONTH))
    );


    /* ============================================================
       Table: Fact_Flights
       ============================================================ */

    CREATE TABLE Fact_Flights
    (
        FLIGHT_ID                INT PRIMARY KEY,
        DATE_ID                  INT NOT NULL,
        ORIGIN_AIRPORT_ID        INT NOT NULL,
        DEST_AIRPORT_ID          INT,
        API_ID                   INT,
        HOUR_OF_THE_DAY          INT,
        REPORTING_AIRLINE_ID     INT NOT NULL,
        CRS_DEP_TIME             INT,
        DEP_TIME                 INT,
        DEP_DELAY                DECIMAL(10, 2),
        TAXI_OUT                 DECIMAL(10, 2),
        WHEEL_OFF                INT,
        WHEEL_ON                 INT,
        TAXI_IN                  DECIMAL(10, 2),
        CRS_ARR_TIME             INT,
        ARR_TIME                 INT,
        ARR_DELAY                DECIMAL(10, 2),
        CANCELLED                DECIMAL(10, 2) NOT NULL,
        CANCELLATION_CODE        VARCHAR(10),
        CRS_ELAPSED_TIME         DECIMAL(10, 2),
        ACTUAL_ELAPSED_TIME      DECIMAL(10, 2),
        AIR_TIME                 DECIMAL(10, 2),
        DISTANCE                 DECIMAL(12, 2),
        DISTANCE_GROUP           INT,
        CARRIER_DELAY            DECIMAL(10, 2),
        WEATHER_DELAY            DECIMAL(10, 2),
        NAS_DELAY                DECIMAL(10, 2),
        SECURITY_DELAY           DECIMAL(10, 2),
        LATE_AIRCRAFT_DELAY      DECIMAL(10, 2),
        DIV_AIRPORT_LANDINGS     INT,
        DIV_REACHED_DEST         DECIMAL(10, 2),
        DIV_ACTUAL_ELAPSED_TIME  DECIMAL(10, 2),
        DIV_ARR_DELAY            DECIMAL(10, 2),
        DIV_DISTANCE             DECIMAL(12, 2)


        CONSTRAINT FK_DATE_FLIGHT_ID FOREIGN KEY(DATE_ID) REFERENCES Dim_Date_Flights(DATE_ID),

        CONSTRAINT FK_ORIGIN_FLIGHT_AIRPORT_ID FOREIGN KEY(ORIGIN_AIRPORT_ID) REFERENCES Dim_Airport(AIRPORT_ID),

        CONSTRAINT FK_DEST_FLIGHT_AIRPORT_ID FOREIGN KEY(DEST_AIRPORT_ID) REFERENCES Dim_Airport(AIRPORT_ID),

        CONSTRAINT FK_API_ID FOREIGN KEY (API_ID) REFERENCES Dim_Weather(CALL_API_ID),

        CONSTRAINT FK_HOUR_OF_THE_DAY FOREIGN KEY(HOUR_OF_THE_DAY) REFERENCES Dim_Time(HOUR_OF_THE_DAY),

        CONSTRAINT FK_REPORTING_AIRLINE_ID FOREIGN KEY(REPORTING_AIRLINE_ID) REFERENCES Dim_Airline(DOT_ID_REPORTING_AIRLINE)

    );

    /* ============================================================
       Table: Fact_Passengers
       ============================================================ */

    CREATE TABLE Fact_Passengers
    (
        SEGMENT_PASSENGERS_ID   INT PRIMARY KEY,
        DATE_ID                 INT NOT NULL,
        DOT_ID_REPORTING_AIRLINE INT NOT NULL,
        ORIGIN_AIRPORT_ID       INT NOT NULL,
        DEST_AIRPORT_ID         INT,
        PAYLOAD                 DECIMAL(18, 2),
        SEATS                   DECIMAL(12, 2),
        PASSENGERS              INT NOT NULL,
        FREIGHT                 DECIMAL(18, 2),
        MAIL                    DECIMAL(18, 2),
        DEPARTURES_SCHEDULED    DECIMAL(12, 2),
        DEPARTURES_PERFORMED    DECIMAL(12, 2) NOT NULL,
        DISTANCE                DECIMAL(12, 2),
        AIR_TIME                DECIMAL(12, 2),
        DISTANCE_GROUP          INT


        CONSTRAINT FK_DATE_PASSENGERS_ID FOREIGN KEY(DATE_ID) REFERENCES Dim_Date_Passengers(DATE_ID),

        CONSTRAINT FK_ORIGIN_PASSENGERS_AIRPORT_ID FOREIGN KEY(ORIGIN_AIRPORT_ID) REFERENCES Dim_Airport(AIRPORT_ID),

        CONSTRAINT FK_DEST_PASSENGERS_AIRPORT_ID FOREIGN KEY(DEST_AIRPORT_ID) REFERENCES Dim_Airport(AIRPORT_ID),

        CONSTRAINT FK_AIRLINE_ID FOREIGN KEY(DOT_ID_REPORTING_AIRLINE) REFERENCES Dim_Airline(DOT_ID_REPORTING_AIRLINE)

    );

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO