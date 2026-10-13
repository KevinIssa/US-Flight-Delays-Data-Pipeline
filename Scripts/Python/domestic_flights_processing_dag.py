import sys
from pathlib import Path
from datetime import datetime, timezone
from Scripts.Python.airflow_task import *
from airflow.sdk import dag
from Scripts.Python.airflow_tasks import (
    prepare_flights_silver,
    prepare_passengers_silver,
    insert_flights_sql,
    insert_passengers_sql,
    insert_runways_sql,
    PROJECT_PATH
)

sys.path.insert(0, str(PROJECT_PATH))


@dag(
    dag_id="Domestic Flights Processing DAG",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["domestic Flights", "pyspark", "sql-server"]
)


def project_processing_dag():

    flights = prepare_flights_silver()
    passengers = prepare_passengers_silver()

    flights_sql = insert_flights_sql()
    passengers_sql = insert_passengers_sql()
    runways_sql = insert_runways_sql()

    # Change uniquement ces dependances pour choisir l'ordre.
    # flights doit rester avant flights_sql.
    # passengers doit rester avant passengers_sql.
    flights >> passengers >> runways_sql >> passengers_sql >> flights_sql


@dag(
    dag_id="Data Scraping Processing DAG",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["domestic Flights", "python", "data scraping"]
)

def data_scraping_processing_dag():

    web_scraping() >> extract_zip_files() 


    
project_processing_dag()
data_scraping_processing_dag()