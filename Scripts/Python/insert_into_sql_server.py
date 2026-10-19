from dotenv import load_dotenv
from pathlib import Path
import os
import re
import logging

ENV_PATH = Path(__file__).resolve().parents[2] / ".env"


def get_sql_env(sql_table_env_name):

    load_dotenv(dotenv_path=ENV_PATH, override=True)
    
    sql_staging_url = os.getenv("SQL_STAGING_URL")
    sql_user = os.getenv("SQL_SERVER_USER")
    sql_password = os.getenv("SQL_SERVER_PASSWORD")
    sql_dwh_url = os.getenv("SQL_DWH_URL")
    sql_table = os.getenv(sql_table_env_name)

    return sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_table


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
            .option("batchsize", "25000")
            .option("numPartitions", "8")
            .mode("append")
            .save()
    )


def execute_sql_file(spark, file_path, sql_server_url, user, password):

    # Lire le fichier SQL
    sql = Path(file_path).read_text(encoding="utf-8-sig")

    # Séparer les instructions GO (SQL Server)
    batches = re.split(r"(?im)^\s*GO\s*;?\s*$", sql)

    # Réutiliser le driver JDBC Microsoft
    jvm = spark._jvm

    properties = jvm.java.util.Properties()
    properties.setProperty("user", user)
    properties.setProperty("password", password)

    driver = jvm.com.microsoft.sqlserver.jdbc.SQLServerDriver()
    connection = driver.connect(sql_server_url, properties)

    if connection is None:
        raise RuntimeError("Connexion JDBC impossible")

    statement = None

    try:
        connection.setAutoCommit(True)
        statement = connection.createStatement()

        for batch in batches:
            if not batch.strip():
                continue

            has_result = statement.execute(batch)

            # Consommer tous les résultats et erreurs SQL
            while True:
                if has_result:
                    result = statement.getResultSet()
                    if result is not None:
                        result.close()
                elif statement.getUpdateCount() == -1:
                    break

                has_result = statement.getMoreResults()

    finally:
        try:
            if statement is not None:
                statement.close()
        finally:
            connection.close()


def get_sql_row_count(spark, sql_url, table, user, password):

    query = f"""
        SELECT
            COALESCE(SUM(row_count), 0) AS TOTAL_ROWS
        FROM sys.dm_db_partition_stats
        WHERE object_id = OBJECT_ID('{table}')
          AND index_id IN (0, 1)
    """

    result = (
        spark.read
        .format("jdbc")
        .option("url", sql_url)
        .option("query", query)
        .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
        .option("user", user)
        .option("password", password)
        .load()
        .first()
    )

    return int(result["TOTAL_ROWS"])

def log_inserted_rows(table, before, after):
    inserted_rows = after - before

    logging.info(
        f"Table: {table} | Rows before task: {before} | "
        f"Rows after task: {after} | Rows inserted: {inserted_rows}"
    )

    return inserted_rows