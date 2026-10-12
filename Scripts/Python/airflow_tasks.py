#poetry run pip install "apache-airflow==3.3.2" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-3.3.2/constraints-3.13.txt"

from pyspark.sql import SparkSession
from Constants import *
from df_transformations import *
from df_bronze_setup import *
from df_silver_setup import *
from dotenv import load_dotenv

load_dotenv()
os.environ["PYSPARK_SUBMIT_ARGS"] = "--driver-memory 14g pyspark-shell"
os.environ["PATH"] = (str(SQLSERVER_NATIVE_PATH) + os.pathsep + os.environ["PATH"])

print(sql_password)


spark = (
    SparkSession.builder
    .master("local[*]")
    .appName("DomesticFlightDelays")
    .config("spark.sql.adaptive.enabled", "true")
    .config("spark.sql.shuffle.partitions", "64")
    .config("spark.driver.extraClassPath", str(JDBC_DRIVER_PATH))
    .getOrCreate()
)



first_columns = ["YEAR", "MONTH", "QUARTER"]
