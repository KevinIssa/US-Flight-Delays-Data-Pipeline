def read_parquet(spark, file_path):
    """
    Read a Parquet dataset into a Spark DataFrame.
    """
    return spark.read.parquet(file_path.as_posix())


def move_columns_to_front(df, first_columns):
    """
    Move the specified columns to the beginning of the DataFrame,
    preserving the order of all remaining columns that were moved after the parquet partitioning.
    """
    other_columns = [
        column for column in df.columns
        if column not in first_columns
    ]

    return df.select(*first_columns, *other_columns)
