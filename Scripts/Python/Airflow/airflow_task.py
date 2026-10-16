import sys

from airflow.sdk import task
from pyspark.sql import SparkSession
from pathlib import Path

PYTHON_PATH = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PYTHON_PATH))
from Constants import *

from Scraping.flight_data_scraping import download_transtats_zip_files
from Scraping.extract_zip_files import extract_flight_zip_files
from df_bronze_setup import *
from df_transformations import *
from df_silver_setup import *
from create_parquet_files import *
from insert_into_sql_server import *
# Constantes partagees entre les tasks.

FIRST_COLUMNS = ["YEAR", "MONTH", "QUARTER"]
ENV_PATH = Path(__file__).resolve().parents[2] / ".env"

def get_spark():
    """Cree ou recupere une SparkSession dans le processus de la task."""
    os.environ["PYSPARK_SUBMIT_ARGS"] = "--driver-memory 14g pyspark-shell"

    spark = (
        SparkSession.builder
        .master("local[*]")
        .appName("DomesticFlightDelays")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.shuffle.partitions", "64")
        #.config("spark.local.dir", "SparkTemp") #choisir où spark doit stocker ses fichiers temporaires sur le disque
        .config("spark.driver.extraClassPath", str(JDBC_DRIVER_PATH))
        .getOrCreate()
    )
    return spark


# --------------------------------------------------
# DAG 1 : Scraping et extraction ZIP
# --------------------------------------------------

@task(retries=0)
def web_scraping():

    download_transtats_zip_files()


@task(retries=0)
def extract_zip_files():

    extract_flight_zip_files()


# --------------------------------------------------
# DAG 2 : Preparation Silver
# --------------------------------------------------
"""
obliger de créer un environnement spark et de le fermer à la fin de chaque task pour eviter des bugs de airflow qui feraient en sorte que la variable ne seraient pas partagés entre les differentes tasks.
Cela pourrait causer des problèmes de mémoire ou de conflits entre les sessions Spark. En fermant et recreant la session à chaque tasks,
on s'assure que chaque task commence avec un environnement propre et isolé, ce qui améliore la stabilité et la fiabilité du pipeline de données.
"""

@task(retries=0)
def prepare_flights_silver():

    spark = get_spark()
    try:
        flight_files = get_flight_files(FLIGHT_BRONZE_PATH)
        runways_files = get_runways_files(RUNWAYS_BRONZE_PATH)

        df_bronze_flights = read_flight_csv(spark, flight_files)
        df_bronze_runways = read_runways_csv(spark, runways_files)

        df_silver_flights = df_flights_transformations(df_bronze_flights)
        df_silver_runways = df_runways_transformations(df_bronze_runways)

        df_silver_flights = join_df_flights_and_runways(df_silver_flights, df_silver_runways)

        df_silver_flights = add_row_hash(df_silver_flights)
        df_silver_runways = add_row_hash(df_silver_runways)

        create_flights_parquet(df_silver_flights, FLIGHT_SILVER_PATH)
        create_runways_parquet(df_silver_runways, RUNWAYS_SILVER_PATH)

    finally:
        spark.stop()
        
@task(retries=0)
def prepare_passengers_silver():

    spark = get_spark()
    try:
        passenger_files = get_passenger_files(PASSENGER_BRONZE_PATH)
        df_passengers = read_passengers_csv(spark, passenger_files)

        df_passengers = df_passengers_transformations(df_passengers)
        df_passengers = add_row_hash(df_passengers)

        
        create_passengers_parquet(df_passengers, PASSENGER_SILVER_PATH)

    finally:
        spark.stop()

# --------------------------------------------------
# DAG 2 : Insertion SQL Server
# --------------------------------------------------

@task(retries=0)
def insert_flights_to_sql():

    sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_table = get_sql_env(sql_table_env_name = "SQL_SERVER_TABLE")


    spark = get_spark()
    try:
        df_flights_silver = read_flights_parquet(spark, FLIGHT_SILVER_PATH)
        df_flights_silver = arrange_parquet_columns_flights_silver(df_flights_silver, FIRST_COLUMNS)
        insert_into_sql_table(df_flights_silver, spark, sql_staging_url, sql_table, sql_user, sql_password)

    finally:
        spark.stop()


@task(retries=0)
def insert_passengers_to_sql():

    sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_second_table = get_sql_env(sql_table_env_name = "SQL_SERVER_SECOND_TABLE")

    spark = get_spark()
    try:
        df_passengers_silver = read_passengers_parquet(spark, PASSENGER_SILVER_PATH)
        df_passengers_silver = arrange_parquet_columns_passengers_silver(df_passengers_silver, FIRST_COLUMNS)
        insert_into_sql_table(df_passengers_silver, spark, sql_staging_url, sql_second_table, sql_user, sql_password)

    finally:
        spark.stop()


@task(retries=0)
def insert_runways_to_sql():

    sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_third_table = get_sql_env(sql_table_env_name ="SQL_SERVER_THIRD_TABLE")

    spark = get_spark()
    try:
        df_runways = read_runways_parquet(spark, RUNWAYS_SILVER_PATH)
        insert_into_sql_table(df_runways, spark, sql_staging_url, sql_third_table, sql_user, sql_password)

    finally:
        spark.stop()


@task(retries=0)
def load_dim_tables():

    spark = get_spark()
    sql_files = [ "Dim_Time.sql","Dim_Airline.sql", "Dim_Airport.sql", "Dim_Aircraft.sql", "Dim_Date_Flights.sql", "Dim_Date_Passengers.sql"]

    try:
        sql_staging_url, sql_dwh_url, sql_user, sql_password = get_sql_env(sql_table_env_name = "SQL_DWH_URL")

        for sql_file in sql_files:
            execute_sql_file(spark, f"{SQL_ETL_FOLDER}/{sql_file}", sql_dwh_url, sql_user, sql_password)

    finally:
        spark.stop()


@task(retries=0)
def load_fact_tables():

    spark = get_spark()
    sql_files = ["Fact_Flights.sql", "Fact_Passengers.sql"]

    try:
        sql_staging_url, sql_dwh_url, jdbc_user, jdbc_password = get_sql_env(sql_table_env_name = "SQL_DWH_URL")

        for sql_file in sql_files:
                    execute_sql_file(spark, f"{SQL_ETL_FOLDER}/{sql_file}", sql_dwh_url, jdbc_user, jdbc_password)

    finally:
        spark.stop()