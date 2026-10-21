def get_files(folder_path, extension="csv"):
    """
    Return the paths of all files matching the specified extension.
    """
    return [file.as_posix() for file in folder_path.glob(f"*.{extension}")]


def read_csv(spark, files, columns_to_keep=None, infer_schema=False):
    """
    Read CSV files into a Spark DataFrame and optionally select specific columns.
    """
    df = spark.read.csv(
        files,
        header=True,
        inferSchema=infer_schema
    )

    if columns_to_keep is not None:
        df = df.select(*columns_to_keep)

    return df
