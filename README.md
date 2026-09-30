# Data-Engineering-project
Domestic Flight Delays

Data processing and analysis project using PySpark.

🛠️ Technologies

Python 3.13

PySpark 4.2.0

Poetry

SQL Server

📋 Requirements

Before starting, install:

Python 3.13 via the official site otherwise poetry may not recognize it

Java 21 JDK or any versions compatible with the project

Poetry

Git

Check your installations:

python --version
poetry --version
git --version

If poetry is not recognised, verify that it is set in your system variables

📥 Project Setup

Clone the repository:

git clone <REPOSITORY_URL>

Move into the project directory:

cd domestic-flight-delays

Configure Python

Check that Python 3.13 is available:

py -0p


Tell Poetry to use Python 3.13:

poetry env use 3.13


Check the configured environment:

poetry env info

Install dependencies
poetry install


This creates the virtual environment and installs the dependencies defined in:

pyproject.toml
poetry.lock

🐍 Python Environment

Python dependencies are managed with Poetry.

The main versions are pinned to ensure a reproducible environment:

Python  : 3.13
PySpark : 4.2.0
pandas  : 2.2.3

☕ Java

PySpark requires Java.

Java is not managed by Poetry and must be installed separately on the machine.

🔐 Sensitive Data

Never commit the following files or information:

.env
credentials
passwords
API keys
SQL Server credentials


The .env file should be added to .gitignore.

🧪 Environment Check

After installation, verify PySpark:

poetry run python -c "import pyspark; print('PySpark:', pyspark.__version__)"


Verify pandas:

poetry run python -c "import pandas; print('pandas:', pandas.__version__)"


If both commands work, the Python environment is correctly configured.