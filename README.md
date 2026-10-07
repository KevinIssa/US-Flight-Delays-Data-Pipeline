# Data Engineering Project — Domestic Flight Delays

Data processing and analysis project using **PySpark**.

## 🛠️ Technologies

- Python 3.13
- PySpark 4.2.0
- Poetry
- SQL Server
- Java 21 JDK
- Git

## 📋 Requirements
- **32 go of ram to run the whole dataset locally** 
Before setting up the project, install:

- **Python 3.13** from the official Python website
- **Java JDK 21** or another Java version compatible with the project
- **Poetry** 
- **Git**
IF ON WINDOWS
- **Hadoop winutils.exe + hadoop.dll from https://github.com/zehelh/winutils**
- **HADOOP_HOME configured**
- **%HADOOP_HOME%\bin added to PATH**

Check that the required tools are available:

```bash
python --version
poetry --version
git --version
java --version
```

On Windows, you can also check which Python versions are installed with:

```bash
py -0p
```

If `poetry` is installed but the command is not recognized, verify that Poetry's installation directory is included in your system `PATH`.

---

## 📥 Project Setup

### 1. Clone the repository

```bash
git clone <REPOSITORY_URL>
```

Move into the project directory:

```bash
cd Data-Engineering-project
```

### 2. Configure Python

Check that Python 3.13 is available:

```bash
py -0p
```

### 3. Install dependencies

The repository already includes a `poetry.lock` file.

After cloning the project, you do **not** need to generate a new lock file.

Simply run:

```bash
poetry install
```

Verify the environment:

```bash
poetry env info
```

Poetry will create the virtual environment and install the dependency versions defined in `poetry.lock`.

Only run `poetry lock` if the project dependencies are modified.

---

## 🐍 Python Environment

Python dependencies are managed with Poetry.

Main versions used by the project:

```text
Python  : 3.13
PySpark : 4.2.0
pandas  : 2.2.3
```

To run Python inside the Poetry environment:

```bash
poetry run python
```

You can also execute project scripts with:

```bash
poetry run python path/to/script.py
```

---

## ☕ Java

PySpark requires Java to run.

Java is **not managed by Poetry** and must therefore be installed separately on the machine.

Check the installed Java version with:

```bash
java --version
```

If required, also verify that `JAVA_HOME` is correctly configured.

---

## 🧪 Environment Check

After running:

```bash
poetry install
```

verify that PySpark is correctly installed:

```bash
poetry run python -c "import pyspark; print('PySpark:', pyspark.__version__)"
```

Verify pandas:

```bash
poetry run python -c "import pandas; print('pandas:', pandas.__version__)"
```

---

## 🔐 Sensitive Data

Never commit sensitive information such as:

- `.env` files
- credentials
- passwords
- API keys
- SQL Server usernames or passwords

The `.env` file must be included in `.gitignore`.

Example:

```gitignore
.env
```

If environment variables are required by the project, create your own local `.env` file after cloning the repository.

If both commands work, the Python environment is correctly configured.
