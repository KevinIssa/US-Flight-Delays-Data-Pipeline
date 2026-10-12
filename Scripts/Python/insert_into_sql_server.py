
def insert_into_first_table(df_flights_silver, sql_server_url, sql_table):

    (
        df_flights_silver.write
            .format("jdbc")
            .option("url", sql_server_url)
            .option("dbtable", sql_table)
            .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
            .option("batchsize", "50000")
            .option("numPartitions", "4")
            .mode("append")
            .save()
    )

def insert_into_second_table(df_passengers_silver, sql_server_url, sql_second_table):

    (
    df_passengers_silver.write
        .format("jdbc")
        .option("url", sql_server_url)
        .option("dbtable", sql_second_table)
        .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
        .option("batchsize", "50000")
        .option("numPartitions", "4")
        .mode("append")
        .save()
    )


def insert_into_third_table(df_runways, sql_server_url, sql_third_table):

    (
    df_runways.write
        .format("jdbc")
        .option("url", sql_server_url)
        .option("dbtable", sql_third_table)
        .option("driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver")
        .option("batchsize", "50000")
        .option("numPartitions", "4")
        .mode("append")
        .save()
    )