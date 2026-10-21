import pyspark.sql.functions as F
from Constants import (FLIGHT_COLUMN_MAPPING,
                       FLIGHT_SCHEMA,
                       PASSENGERS_SCHEMA)

def df_flights_transformations(df_flights):

    #cast string to schema type and rename them
    df_flights = df_flights.select(* [F.col(field.name).cast(field.dataType).alias(FLIGHT_COLUMN_MAPPING[field.name])for field in FLIGHT_SCHEMA.fields])

    df_flights = df_flights.drop_duplicates()
    
    first_condition = F.col("DEP_DELAY").isNull() | F.col("ARR_DELAY").isNull()
    second_condition = F.col("CRS_ELAPSED_TIME").isNull() | F.col("ACTUAL_ELAPSED_TIME").isNull()
    third_condition = F.col("CANCELLED") == 1.00 

    #keep cancelled flights and those with at least enough delay and time data to be usable
    df_flights = df_flights.filter(third_condition | ~(first_condition & second_condition))
    
    return df_flights

def df_passengers_transformations(df_passengers):

    df_passengers = df_passengers.select(*[F.col(field.name)
                                        .cast(field.dataType)
                                        .alias(field.name) for field in PASSENGERS_SCHEMA.fields])


    df_passengers = df_passengers.filter(F.col("PASSENGERS") != 0.0).sort("PASSENGERS")
    df_passengers = df_passengers.drop_duplicates()

    return df_passengers

def df_runways_transformations(df_runways):
    
    df_runways = df_runways.drop_duplicates(["ARPT_ID"])
    rename_map = {
        "LAT1_DECIMAL": "LATITUDE",
        "LONG1_DECIMAL": "LONGITUDE"
    }
    df_runways = df_runways.withColumnsRenamed(rename_map)

    return df_runways

def join_df_flights_and_runways(df_flights, df_runways):

    #join runways and flights dataframes to have the localisation of departure to match them with the weather data
    df_flights = df_flights.join(df_runways, (df_flights["ORIGIN"] == df_runways["ARPT_ID"]) & (df_flights["ORIGIN_STATE"] == df_runways["STATE_CODE"]),
                                "inner").select(df_flights["*"], df_runways["LATITUDE"], df_runways["LONGITUDE"])

    return df_flights


def add_row_hash(df):

    """
    Add a ROW_HASH column containing a SHA-256 hash for each row of the DataFrame.

    The hash is generated from all columns, sorted alphabetically to ensure a consistent order.
    Values are converted to JSON before being hashed, explicitly including null values.

    This column allows you to identify data changes and compare rows between different versions of a DataFrame to insert only new rows easily.
    CAUTION: there are no primary keys in the dataframes, only the data column, primary keys are created automatically in sql

    Args:
        df (DataFrame): DataFrame PySpark to process.

    Returns:
        DataFrame: DataFrame PySpark with an extra column ROW_HASH.
    """

    return df.withColumn("ROW_HASH",F.sha2(
                                        F.to_json(
                                            F.struct(*[F.col(c) for c in sorted(df.columns)]), 
                                            {"ignoreNullFields": "false"}),  256))