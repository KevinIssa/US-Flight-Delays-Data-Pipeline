from Constants import (COLUMNS_TO_KEEP_FLIGHTS,
    COLUMNS_TO_KEEP_PASSENGERS,
    COLUMNS_TO_KEEP_AIRPORTS
)

def get_flight_files(flight_folder_path):
    
    flight_files = [
        file.as_posix()
        for file in flight_folder_path.glob("*.csv")
    ]
    
    return flight_files

def get_passenger_files(passenger_folder_path):

    passenger_files = [
        file.as_posix()
        for file in passenger_folder_path.glob("*.csv")
    ]

    return passenger_files

def get_runways_files(runways_folder_path):
    
    runways_files = [
        file.as_posix()
        for file in runways_folder_path.glob("*.csv")
    ]

    return runways_files

def get_weather_files(weather_folder_path):

    weather_files = [
        file.as_posix()
        for file in weather_folder_path.glob("*.csv")
    ]

    return weather_files

def get_sql_files(sql_etl_folder_path):

    sql_files = [
        file.as_posix()
        for file in sql_etl_folder_path.glob("*.sql")
    ]

    return sql_files

def read_flight_csv(spark, flight_files):

    df_flights = (spark.read.csv(
            flight_files,
            header=True,
            inferSchema=False
        )
        .select(COLUMNS_TO_KEEP_FLIGHTS)
    )

    return df_flights


def read_passengers_csv(spark, passenger_files):

    df_passengers = (spark.read.csv(
            passenger_files,
            header=True,
            inferSchema=False,
        ).select(COLUMNS_TO_KEEP_PASSENGERS)
    )

    return df_passengers

def read_runways_csv(spark, runways_files):

    df_runways = spark.read.csv(runways_files, inferSchema= True, header= True).select(COLUMNS_TO_KEEP_AIRPORTS)

    return df_runways

def read_weather_csv(spark, weather_files):
    
    df_weather = spark.read.csv(weather_files, inferSchema= True, header= True)

    return df_weather