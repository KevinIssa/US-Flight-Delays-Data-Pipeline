from pyspark.sql.types import *


COLUMNS_TO_KEEP_FLIGHTS = [
    "Year",
    "Quarter",
    "Month",
    "DayofMonth",
    "DayOfWeek",
    "FlightDate",
    "Reporting_Airline",
    "DOT_ID_Reporting_Airline",
    "OriginAirportID",
    "Origin",
    "OriginCityName",
    "OriginState",
    "DestAirportID",
    "Dest",
    "DestCityName",
    "DestState",
    "DestStateName",
    "CRSDepTime",
    "DepTime",
    "DepDelay",
    "TaxiOut",
    "WheelsOff",
    "WheelsOn",
    "TaxiIn",
    "CRSArrTime",
    "ArrTime",
    "ArrDelay",
    "Cancelled",
    "CancellationCode",
    "CRSElapsedTime",
    "ActualElapsedTime",
    "AirTime",
    "Distance",
    "DistanceGroup",
    "CarrierDelay",
    "WeatherDelay",
    "NASDelay",
    "SecurityDelay",
    "LateAircraftDelay",
    "DivAirportLandings",
    "DivReachedDest",
    "DivActualElapsedTime",
    "DivArrDelay",
    "DivDistance"
]


FLIGHT_SCHEMA = StructType([

    StructField("Year", IntegerType(), True),
    StructField("Quarter", IntegerType(), True),
    StructField("Month", IntegerType(), True),
    StructField("DayofMonth", IntegerType(), True),
    StructField("DayOfWeek", IntegerType(), True),
    StructField("FlightDate", DateType(), True),

    StructField("Reporting_Airline", StringType(), True),
    StructField("DOT_ID_Reporting_Airline", IntegerType(), True),

    StructField("OriginAirportID", IntegerType(), True),
    StructField("Origin", StringType(), True),
    StructField("OriginCityName", StringType(), True),
    StructField("OriginState", StringType(), True),

    StructField("DestAirportID", IntegerType(), True),
    StructField("Dest", StringType(), True),
    StructField("DestCityName", StringType(), True),
    StructField("DestState", StringType(), True),
    StructField("DestStateName", StringType(), True),

    StructField("CRSDepTime", IntegerType(), True),
    StructField("DepTime", IntegerType(), True),
    StructField("DepDelay", DoubleType(), True),

    StructField("TaxiOut", DoubleType(), True),
    StructField("WheelsOff", IntegerType(), True),
    StructField("WheelsOn", IntegerType(), True),
    StructField("TaxiIn", DoubleType(), True),

    StructField("CRSArrTime", IntegerType(), True),
    StructField("ArrTime", IntegerType(), True),
    StructField("ArrDelay", DoubleType(), True),

    StructField("Cancelled", DoubleType(), True),
    StructField("CancellationCode", StringType(), True),

    StructField("CRSElapsedTime", DoubleType(), True),
    StructField("ActualElapsedTime", DoubleType(), True),
    StructField("AirTime", DoubleType(), True),

    StructField("Distance", DoubleType(), True),
    StructField("DistanceGroup", DoubleType(), True),

    StructField("CarrierDelay", DoubleType(), True),
    StructField("WeatherDelay", DoubleType(), True),
    StructField("NASDelay", DoubleType(), True),
    StructField("SecurityDelay", DoubleType(), True),
    StructField("LateAircraftDelay", DoubleType(), True),

    StructField("DivAirportLandings", IntegerType(), True),
    StructField("DivReachedDest", DoubleType(), True),
    StructField("DivActualElapsedTime", DoubleType(), True),
    StructField("DivArrDelay", DoubleType(), True),
    StructField("DivDistance", DoubleType(), True)
])


FLIGHT_COLUMN_MAPPING = {
    "Year": "YEAR",
    "Quarter": "QUARTER",
    "Month": "MONTH",
    "DayofMonth": "DAY_OF_MONTH",
    "DayOfWeek": "DAY_OF_WEEK",
    "FlightDate": "FLIGHT_DATE",

    "Reporting_Airline": "REPORTING_AIRLINE",
    "DOT_ID_Reporting_Airline": "DOT_ID_REPORTING_AIRLINE",

    "OriginAirportID": "ORIGIN_AIRPORT_ID",
    "Origin": "ORIGIN",
    "OriginCityName": "ORIGIN_CITY_NAME",
    "OriginState": "ORIGIN_STATE",

    "DestAirportID": "DEST_AIRPORT_ID",
    "Dest": "DEST",
    "DestCityName": "DEST_CITY_NAME",
    "DestState": "DEST_STATE",
    "DestStateName": "DEST_STATE_NAME",

    "CRSDepTime": "CRS_DEP_TIME",
    "DepTime": "DEP_TIME",
    "DepDelay": "DEP_DELAY",

    "TaxiOut": "TAXI_OUT",
    "WheelsOff": "WHEEL_OFF",
    "WheelsOn": "WHEEL_ON",
    "TaxiIn": "TAXI_IN",

    "CRSArrTime": "CRS_ARR_TIME",
    "ArrTime": "ARR_TIME",
    "ArrDelay": "ARR_DELAY",

    "Cancelled": "CANCELLED",
    "CancellationCode": "CANCELLATION_CODE",

    "CRSElapsedTime": "CRS_ELAPSED_TIME",
    "ActualElapsedTime": "ACTUAL_ELAPSED_TIME",
    "AirTime": "AIR_TIME",

    "Distance": "DISTANCE",
    "DistanceGroup": "DISTANCE_GROUP",

    "CarrierDelay": "CARRIER_DELAY",
    "WeatherDelay": "WEATHER_DELAY",
    "NASDelay": "NAS_DELAY",
    "SecurityDelay": "SECURITY_DELAY",
    "LateAircraftDelay": "LATE_AIRCRAFT_DELAY",

    "DivAirportLandings": "DIV_AIRPORT_LANDINGS",
    "DivReachedDest": "DIV_REACHED_DEST",
    "DivActualElapsedTime": "DIV_ACTUAL_ELAPSED_TIME",
    "DivArrDelay": "DIV_ARR_DELAY",
    "DivDistance": "DIV_DISTANCE"
}