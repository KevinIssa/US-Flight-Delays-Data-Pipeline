from dotenv import load_dotenv
from pathlib import Path
import os
import re
import logging

ENV_PATH = Path(__file__).resolve().parents[2] / ".env"


def get_sql_env(sql_table_env_name):

    #get variables in the .env and returning them into a tuple(some values will not be used depending on the functions)
    load_dotenv(dotenv_path=ENV_PATH, override=True)
    
    sql_staging_url = os.getenv("SQL_STAGING_URL")
    sql_user = os.getenv("SQL_SERVER_USER")
    sql_password = os.getenv("SQL_SERVER_PASSWORD")
    sql_dwh_url = os.getenv("SQL_DWH_URL")
    sql_table = os.getenv(sql_table_env_name)

    return sql_staging_url, sql_dwh_url, sql_user, sql_password, sql_table


def get_existing_rows(spark,  sql_server_url, sql_table, sql_user, sql_password):
    #gets the number of rows in the sql table by getting all the hashes from every column to compare them later with the new data arriving
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

    new_rows_df = df.join(exisiting_rows_df, on="ROW_HASH", how="left_anti")#filter only new column that does not match with the existing hashes

    (
        new_rows_df.write
            .format("jdbc")
            .option("url", sql_server_url)
            .option("dbtable", sql_table)
            .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
            .option("user", sql_user)
            .option("password", sql_password)
            .option("batchsize", "50000") #number of rows sent at once
            .option("numPartitions", "6")#number of simultaneous connections to sql server
            .mode("append")
            .save()
    )


def execute_sql_file(spark, file_path, sql_server_url, user, password):

    # Read the sql file
    sql = Path(file_path).read_text(encoding="utf-8-sig")

    # Separating GO statements (SQL Server)
    batches = re.split(r"(?im)^\s*GO\s*;?\s*$", sql)

    # Reuse the Microsoft JDBC driver
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
        connection.setAutoCommit(True)#allows jdbc to commit to sql server
        statement = connection.createStatement()

        for batch in batches:
            if not batch.strip():
                continue

            has_result = statement.execute(batch)

            # Consume all SQL results and errors
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
        finally: #if there is a problem to close the request, close the connection to prevent further bugs
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