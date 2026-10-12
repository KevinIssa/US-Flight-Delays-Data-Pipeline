import os

sql_user = os.getenv("SQLSERVER_USER")
sql_password = os.getenv("SQLSERVER_PASSWORD")
sql_database = os.getenv("SQLSERVER_DATABASE")
sql_table = os.getenv("SQL_SERVER_TABLE")
sql_second_table = os.getenv("SQL_SERVER_SECOND_TABLE")
sql_third_table = os.getenv("SQL_SERVER_THIRD_TABLE")
sql_server_url = (
    "jdbc:sqlserver://ICT-210-05;"
    "databaseName=StagingSilver;"
    "integratedSecurity=true;"
    "encrypt=true;"
    "trustServerCertificate=true;"
)