def create_partitioned_parquet(df, file_path):

    df = df.repartition("YEAR", "MONTH")

    (df.write
        .mode("overwrite")
        .partitionBy("YEAR", "MONTH")
        .parquet(file_path.as_posix())
    )

def create_single_partition_parquet(df, file_path):

    (df.coalesce(1)
        .write
        .mode("overwrite")
        .parquet(file_path.as_posix())
    )