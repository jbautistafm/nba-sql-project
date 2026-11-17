"""
Descarga el dataset de la NBA desde Kaggle y lo deja en data/raw.

Dataset: NBA Stats (1947-present) de sumitrodatta
https://www.kaggle.com/datasets/sumitrodatta/nba-aba-baa-stats

Uso (desde la raiz del repo):
    python src/download_data.py
"""

import shutil
from pathlib import Path

import kagglehub

DATASET = "sumitrodatta/nba-aba-baa-stats"

# la carpeta data/raw la saco a partir de donde esta este archivo,
# asi funciona igual en el ordenador de Juan y en el de Jordi
RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"


def download_dataset(dataset=DATASET, raw_dir=RAW_DIR):
    """
    Descarga el dataset con kagglehub y copia los csv a data/raw.

    kagglehub lo guarda primero en su cache, por eso luego hay que copiarlo.

    Args:
        dataset (str): nombre del dataset en Kaggle ("usuario/dataset").
        raw_dir (Path): carpeta donde dejamos los csv.

    Returns:
        list: nombres de los archivos copiados.
    """
    cache_path = kagglehub.dataset_download(dataset)
    print("Descargado en la cache:", cache_path)

    raw_dir.mkdir(parents=True, exist_ok=True)

    copiados = []
    for archivo in Path(cache_path).glob("*.csv"):
        shutil.copy(archivo, raw_dir / archivo.name)
        copiados.append(archivo.name)

    print(f"{len(copiados)} archivos copiados en {raw_dir}")
    return copiados


if __name__ == "__main__":
    archivos = download_dataset()
    for nombre in sorted(archivos):
        print(" -", nombre)
