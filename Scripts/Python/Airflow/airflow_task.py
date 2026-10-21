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
# Constants shared between tasks.

FIRST_COLUMNS = ["YEAR", "MONTH", "QUARTER"] #columns that i want to be in first positions for the arrange_column function
ENV_PATH = Path(__file__).resolve().parents[2] / ".env"

def get_spark():
    #Create or get a SparkSession
    os.environ["PYSPARK_SUBMIT_ARGS"] = "--driver-memory 18g pyspark-shell" #allow a number of memory to spark

    spark = (
        SparkSession.builder
        .master("local[*]") #use all computer cores
        .appName("DomesticFlightDelays")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.shuffle.partitions", "64")
        .config("spark.local.dir", "SparkTemp") #choose where spark need to store his temp files on the disk
        .config("spark.driver.extraClassPath", str(JDBC_DRIVER_PATH))#usage of JDBC driver to connect to sql
        .getOrCreate()
    )
    return spark


# --------------------------------------------------
# Scraping et extraction ZIP
# --------------------------------------------------

@task(retries=0)
def web_scraping():

    download_transtats_zip_files()


@task(retries=0)
def extract_zip_files():

    extract_flight_zip_files()


# --------------------------------------------------
# Preparation Silver
# --------------------------------------------------
"""
Having to create a Spark environment and close it at the end of each task to avoid Airflow bugs
that would prevent variables from being shared between different tasks. This could cause memory issues or conflicts between Spark sessions. 
By closing and recreating the session for each task, we make sure that each task starts with a clean, isolated environment,
which improves the stability and reliability of the data pipeline.
"""

@task(retries=0)
def prepare_flights_silver():

    spark = get_spark()
    try:
        #get the csv files
        flight_files = get_files(FLIGHT_BRONZE_PATH)
        runways_files = get_files(RUNWAYS_BRONZE_PATH)

        #read the csv files and assign it to a dataframe
        df_bronze_flights = read_csv(spark, flight_files, columns_to_keep = COLUMNS_TO_KEEP_FLIGHTS)
        df_bronze_runways = read_csv(spark, runways_files, columns_to_keep = COLUMNS_TO_KEEP_AIRPORTS, infer_schema=True)

        #filter and clean the dataframes
        df_silver_flights = df_flights_transformations(df_bronze_flights)
        df_silver_runways = df_runways_transformations(df_bronze_runways)
    
        df_silver_flights = join_df_flights_and_runways(df_silver_flights, df_silver_runways)

        df_silver_flights = add_row_hash(df_silver_flights)
        df_silver_runways = add_row_hash(df_silver_runways)


        create_partitioned_parquet(df_silver_flights, FLIGHT_SILVER_PATH)
        create_single_partition_parquet(df_silver_runways, RUNWAYS_SILVER_PATH)

    finally:
        spark.stop()
        
@task(retries=0)
def prepare_passengers_silver():
    #same structure as the function above
    spark = get_spark()
    try:
        passenger_files = get_files(PASSENGER_BRONZE_PATH)
        df_passengers = read_csv(spark, passenger_files, columns_to_keep = COLUMNS_TO_KEEP_PASSENGERS)

        df_passengers = df_passengers_transformations(df_passengers)
        df_passengers = add_row_hash(df_passengers)

        
        create_partitioned_parquet(df_passengers, PASSENGER_SILVER_PATH)

    finally:
        spark.stop()

@task(retries=0)
def prepare_weather_silver():

    spark = get_spark()
    try:
        weather_files = get_files(WEATHER_BRONZE_PATH)
        df_weather = read_csv(spark, weather_files, infer_schema=True)

        df_weather = add_row_hash(df_weather)

        create_single_partition_parquet(df_weather, WEATHER_SILVER_PATH)

    finally:
        spark.stop()


# --------------------------------------------------
# Insertion SQL Server
# --------------------------------------------------

@task(retries=0)
def insert_flights_to_sql():
    #get the needed environments variables
    sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_table = get_sql_env(sql_table_env_name="SQL_SERVER_TABLE")

    spark = get_spark()
    try:
        #number of lines in the table before the insertion
        before = get_sql_row_count(spark, sql_staging_url, sql_table, sql_user, sql_password)

        df_flights_silver = read_parquet(spark, FLIGHT_SILVER_PATH)
        #arrange the places of the columns to make the insert easier to build
        df_flights_silver = move_columns_to_front(df_flights_silver, FIRST_COLUMNS)
        insert_into_sql_table(df_flights_silver, spark, sql_staging_url, sql_table, sql_user, sql_password)

        after = get_sql_row_count(spark, sql_staging_url, sql_table, sql_user, sql_password)
        log_inserted_rows(sql_table, before, after) #monitor the number of rows inserted

    finally:
        spark.stop()


@task(retries=0)
def insert_passengers_to_sql():
    #Same as above
    sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_second_table = get_sql_env(sql_table_env_name="SQL_SERVER_SECOND_TABLE")

    spark = get_spark()
    try:
        before = get_sql_row_count(spark, sql_staging_url, sql_second_table, sql_user, sql_password)

        df_passengers_silver = read_parquet(spark, PASSENGER_SILVER_PATH)
        df_passengers_silver = move_columns_to_front(df_passengers_silver, FIRST_COLUMNS)
        insert_into_sql_table(df_passengers_silver, spark, sql_staging_url, sql_second_table, sql_user, sql_password)

        after = get_sql_row_count(spark, sql_staging_url, sql_second_table, sql_user, sql_password)
        log_inserted_rows(sql_second_table, before, after)

    finally:
        spark.stop()


@task(retries=0)
def insert_runways_to_sql():

    sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_third_table = get_sql_env(sql_table_env_name="SQL_SERVER_THIRD_TABLE")

    spark = get_spark()
    try:
        before = get_sql_row_count(spark, sql_staging_url, sql_third_table, sql_user, sql_password)

        df_runways_silver = read_parquet(spark, RUNWAYS_SILVER_PATH)
        insert_into_sql_table(df_runways_silver, spark, sql_staging_url, sql_third_table, sql_user, sql_password)

        after = get_sql_row_count(spark, sql_staging_url, sql_third_table, sql_user, sql_password)
        log_inserted_rows(sql_third_table, before, after)

    finally:
        spark.stop()

@task(retries=0)
def insert_weather_to_sql():

    sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_fourth_table = get_sql_env(sql_table_env_name="SQL_SERVER_FOURTH_TABLE")

    spark = get_spark()
    try:
        before = get_sql_row_count(spark, sql_staging_url, sql_fourth_table, sql_user, sql_password)

        df_weather = read_parquet(spark, WEATHER_SILVER_PATH)
        insert_into_sql_table(df_weather, spark, sql_staging_url, sql_fourth_table, sql_user, sql_password)

        after = get_sql_row_count(spark, sql_staging_url, sql_fourth_table, sql_user, sql_password)
        log_inserted_rows(sql_fourth_table, before, after)

    finally:
        spark.stop()

  
# --------------------------------------------------
# ETL SQL SERVER
# --------------------------------------------------


@task(retries=0)
def load_dim_tables():

    spark = get_spark()
    sql_files = {
        "Dim_Time.sql": "dbo.Dim_Time",
        "Dim_Date_Flights.sql": "dbo.Dim_Date_Flights",
        "Dim_Date_Passengers.sql": "dbo.Dim_Date_Passengers",
        "Dim_Airline.sql": "dbo.Dim_Airline",
        "Dim_Airport.sql": "dbo.Dim_Airport",
        "Dim_Weather.sql": "dbo.Dim_Weather"
    }

    try:
        sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_table = get_sql_env(sql_table_env_name = "SQL_DWH_URL")

        for sql_file, table in sql_files.items():

            before = get_sql_row_count(spark, sql_dwh_url, table, sql_user, sql_password)

            file_path = f"{SQL_ETL_FOLDER}/{sql_file}"

            execute_sql_file(spark, file_path, sql_dwh_url, sql_user, sql_password)

            after = get_sql_row_count(spark, sql_dwh_url, table, sql_user, sql_password)

            log_inserted_rows(table, before, after)

    finally:
        spark.stop()


@task(retries=0)
def load_fact_tables():

    spark = get_spark()
    sql_files = {"Fact_Passengers.sql" : "dbo.Fact_Passengers", "Fact_Flights.sql" : "dbo.Fact_Flights"}

    try:
        sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_table = get_sql_env(sql_table_env_name = "SQL_DWH_URL")

        for sql_file, table in sql_files.items():
        
            before = get_sql_row_count(spark, sql_dwh_url, table, sql_user, sql_password)

            file_path = f"{SQL_ETL_FOLDER}/{sql_file}"

            execute_sql_file(spark, file_path, sql_dwh_url, sql_user, sql_password)

            after = get_sql_row_count(spark, sql_dwh_url, table, sql_user, sql_password)

            log_inserted_rows(table, before, after)


    finally:
        spark.stop()