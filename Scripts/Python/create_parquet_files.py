
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

    df_runways = df_runways.repartition("OID")

    (df_runways.write
        .mode("overwrite")
        .partitionBy("OID")
        .parquet(runways_silver_path.as_posix())
    )