from Scripts.Python.Scraping.webscrap_config import *
import zipfile
import re


def extract_flight_zip_files():

    for zip_path in OUTPUT_DIR.glob("*.zip"):

        print(f"Extraction : {zip_path.name}")

        with zipfile.ZipFile(zip_path, "r") as zip_file:

            for file_name in zip_file.namelist():

                if not file_name.lower().endswith(".csv"):
                    continue

                # Récupérer année et mois
                match = re.search(r"_(\d{4})_(\d{1,2})\.csv$", file_name, re.IGNORECASE)

                if not match:
                    continue

                year = match.group(1)
                month = match.group(2).zfill(2)
                destination = OUTPUT_DIR / new_name
                # Nouveau nom : YYYY_MM.csv
                new_name = f"{year}_{month}.csv"

                # Extraire directement avec le nouveau nom
                data = zip_file.read(file_name)

                with open(destination, "wb") as csv_file:
                    csv_file.write(data)

                print(f"  → {new_name}")

    print("Extraction terminée.")
