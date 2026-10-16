from datetime import datetime, timezone
from airflow_task import *
from airflow.sdk import dag

# Configuration des chemins d'import
AIRFLOW_PATH = Path(__file__).resolve().parent
PYTHON_PATH = AIRFLOW_PATH.parent

sys.path.insert(0, str(PYTHON_PATH))
sys.path.insert(0, str(AIRFLOW_PATH))


@dag(
    dag_id="Data-Scraping-Processing-DAG",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["domestic Flights", "python", "data scraping"]
)

def data_scraping_processing_dag():

    web_scraping_task = web_scraping()
    extract_zip_files_task = extract_zip_files()

    web_scraping_task >> extract_zip_files_task

@dag(
    dag_id="Domestic-Flights-Bronze-To-Silver-DAG",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["domestic Flights", "pyspark", "sql-server"]
)

def bronze_to_silver_processing_dag():

    flights = prepare_flights_silver()
    passengers = prepare_passengers_silver()

    flights >> passengers



@dag(
    dag_id="Domestic-Flights-Silver-To-Sql-DAG",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["domestic Flights", "pyspark", "sql-server"]
)

def insert_data_to_sql_dag():

    flights_to_sql = insert_flights_to_sql()
    passengers_to_sql = insert_passengers_to_sql()
    runways_to_sql = insert_runways_to_sql()

    runways_to_sql >> passengers_to_sql >> flights_to_sql

@dag(
    dag_id="Domestic-Flights-load-Dim-Tables-DAG",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["domestic Flights", "etl", "sql-server", "sql"]
)

def load_dim_tables():

    dim_table_load = load_dim_tables()

    dim_table_load

@dag(
    dag_id="Domestic-Flights-load-Fact-Tables-DAG",
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["domestic Flights", "etl", "sql-server", "sql"]
)

def load_fact_tables():

    fact_table_load = load_fact_tables()

    fact_table_load

bronze_to_silver_processing_dag()
data_scraping_processing_dag()
insert_data_to_sql_dag()
#load_dim_tables()
#load_fact_tables()