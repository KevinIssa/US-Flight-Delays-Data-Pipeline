from config import *
import zipfile

# Chercher tous les fichiers ZIP du dossier
zip_files = OUTPUT_DIR.glob("*.zip")


for zip_path in zip_files:

    print(f"Extraction de : {zip_path.name}")

    # Ouvrir le fichier ZIP
    with zipfile.ZipFile(zip_path, "r") as zip_file:

        # Regarder tous les fichiers contenus dans le ZIP
        for file_name in zip_file.namelist():

            # Extraire uniquement les fichiers CSV
            if file_name.lower().endswith(".csv"):

                zip_file.extract(file_name, OUTPUT_DIR)

                print(f"CSV extrait : {file_name}")


print("Extraction terminée.")