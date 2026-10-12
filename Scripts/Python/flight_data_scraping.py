from pathlib import Path
from urllib.request import Request, urlopen, urlretrieve
from urllib.parse import urljoin
from Scripts.Python.webscrap_config import *
import re
# Page contenant tous les ZIP TranStats
BASE_URL = "https://transtats.bts.gov/PREZIP/"

# Dossier où tous les ZIP seront téléchargés
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# --------------------------------------------------
# 1. Lire la page TranStats
# --------------------------------------------------

request = Request(
    BASE_URL,
    headers={"User-Agent": "Mozilla/5.0"}
)

with urlopen(request) as response:
    html = response.read().decode("utf-8", errors="ignore")


# --------------------------------------------------
# 2. Récupérer uniquement les fichiers voulus
# --------------------------------------------------

pattern = re.compile(
    r'href=["\']([^"\']*'
    r'On_Time_Reporting_Carrier_On_Time_Performance_1987_present_'
    r'(\d{4})_(\d{1,2})\.zip'
    r')["\']',
    re.IGNORECASE
)

files = []

for match in pattern.finditer(html):

    href = match.group(1)
    year = int(match.group(2))
    month = int(match.group(3))

    if START_YEAR <= year <= END_YEAR:
        files.append((year, month, href))


# Trier correctement par année puis par mois
files.sort(key=lambda x: (x[0], x[1]))

print(f"{len(files)} fichiers trouvés.\n")


# --------------------------------------------------
# 3. Télécharger les fichiers
# --------------------------------------------------

for index, (year, month, href) in enumerate(files, start=1):

    url = urljoin(BASE_URL, href)

    # Nom du fichier uniquement
    filename = href.split("/")[-1]

    destination = OUTPUT_DIR / filename

    print(f"[{index}/{len(files)}] "
        f"{year}-{month:02d} -> {filename}")

    # Ne pas retélécharger un fichier déjà présent
    if destination.exists():
        print("Fichier déjà présent, ignoré.")
        continue

    try:
        urlretrieve(url, destination)
        print("OK")

    except Exception as e:
        print(f"ERREUR : {e}")

        # En cas de téléchargement incomplet
        if destination.exists():
            destination.unlink()


print("\nTéléchargement terminé.")