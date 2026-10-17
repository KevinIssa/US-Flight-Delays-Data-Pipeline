def create_flights_parquet(df_flights, flight_silver_path):

    df_flights = df_flights.repartition("YEAR", "MONTH")

    (df_flights.write
        .mode("overwrite")
        .partitionBy("YEAR", "MONTH")
        .parquet(flight_silver_path.as_posix())
    )


def create_passengers_parquet(df_passengers, passengers_silver_path):

    df_passengers = df_passengers.repartition("YEAR", "MONTH")

    (df_passengers.write
        .mode("overwrite")
        .partitionBy("YEAR", "MONTH")
        .parquet(passengers_silver_path.as_posix())
    )

def create_runways_parquet(df_runways, runways_silver_path):

    (df_runways.coalesce(1)
        .write
        .mode("overwrite")
        .parquet(runways_silver_path.as_posix())
    )

def create_weather_parquet(df_weather, weather_silver_path):

    (df_weather.coalesce(1)
        .write
        .mode("overwrite")
        .parquet(weather_silver_path.as_posix())
    )