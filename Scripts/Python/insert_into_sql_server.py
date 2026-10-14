from dotenv import dotenv_values, load_dotenv
from pathlib import Path
import os

ENV_PATH = Path(__file__).resolve().parents[2] / ".env"


def get_sql_env(sql_table_env_name):

    load_dotenv(dotenv_path=ENV_PATH, override=True)
    
    sql_server_url = os.getenv("SQL_SERVER_URL")
    sql_user = os.getenv("SQL_SERVER_USER")
    sql_password = os.getenv("SQL_SERVER_PASSWORD")
    sql_table = os.getenv(sql_table_env_name)

    return sql_server_url, sql_user, sql_password, sql_table


def get_existing_rows(spark,  sql_server_url, sql_table, sql_user, sql_password):

    df  = (
        spark.read
            .format("jdbc")
            .option("url", sql_server_url)
            .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
            .option("user", sql_user)
            .option("password", sql_password)
            .option("dbtable", f"(SELECT ROW_HASH FROM dbo.{sql_table}) AS existing_rows")
            .option("fetchsize", "10000")
            .load()
    )

    return df

def insert_into_sql_table(df, spark, sql_server_url, sql_table, sql_user, sql_password):


    exisiting_rows_df = get_existing_rows(spark, sql_server_url, sql_table, sql_user, sql_password)

    new_rows_df = df.join(exisiting_rows_df, on="ROW_HASH", how="left_anti")

    (
        new_rows_df.write
            .format("jdbc")
            .option("url", sql_server_url)
            .option("dbtable", sql_table)
            .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
            .option("user", sql_user)
            .option("password", sql_password)
            .option("batchsize", "50000")
            .option("numPartitions", "4")
            .mode("append")
            .save()
    )