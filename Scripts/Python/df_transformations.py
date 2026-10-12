import pyspark.sql.functions as F


def df_flights_transformations(df_flights):

    df_flights = df_flights.select(* [F.col(field.name).cast(field.dataType).alias(FLIGHT_COLUMN_MAPPING[field.name])for field in FLIGHT_SCHEMA.fields])

    df_flights = df_flights.drop_duplicates()

    first_condition = F.col("DEP_DELAY").isNull() | F.col("ARR_DELAY").isNull()
    second_condition = F.col("CRS_ELAPSED_TIME").isNull() | F.col("ACTUAL_ELAPSED_TIME").isNull()
    third_condition = F.col("CANCELLED") == 1.00

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

    df_flights = df_flights.join(df_runways, (df_flights["ORIGIN"] == df_runways["ARPT_ID"]) & (df_flights["ORIGIN_STATE"] == df_runways["STATE_CODE"]),
                                "inner").select(df_flights["*"], df_runways["LATITUDE"], df_runways["LONGITUDE"])

    return df_flights