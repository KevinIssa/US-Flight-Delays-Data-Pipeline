def read_flights_parquet(spark, flight_silver_path):

    df_flights_silver = spark.read.parquet(flight_silver_path.as_posix())

    return df_flights_silver

def read_passengers_parquet(spark, passengers_silver_path):

    df_passengers_silver =  spark.read.parquet(passengers_silver_path.as_posix())

    return df_passengers_silver

def read_runways_parquet(spark, runways_silver_path):

    df_runways_silver = spark.read.parquet(runways_silver_path.as_posix())

    return df_runways_silver

def read_weather_parquet(spark, weather_silver_path):

    df_weather_silver = spark.read.parquet(weather_silver_path.as_posix())

    return df_weather_silver

def arrange_parquet_columns_flights_silver(df_flights_silver, first_columns):

    other_columns_flights = [
        col for col in df_flights_silver.columns
        if col not in first_columns
    ]

    df_flights_silver = df_flights_silver.select(*first_columns, *other_columns_flights)

    return df_flights_silver

def arrange_parquet_columns_passengers_silver(df_passengers_silver, first_columns):
        
    other_columns_passengers = [
        col for col in df_passengers_silver.columns
        if col not in first_columns
    ]

    df_passengers_silver = df_passengers_silver.select(*first_columns, *other_columns_passengers)

    return df_passengers_silver