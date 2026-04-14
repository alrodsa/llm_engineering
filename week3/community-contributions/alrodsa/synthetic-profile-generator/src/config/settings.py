import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

HF_TOKEN = os.environ.get("HF_TOKEN", "")

DB_PATH = str(PROJECT_ROOT / "data" / "app.db")
EXPORT_PATH = str(PROJECT_ROOT / "data" / "exports" / "profiles.json")

LLM_MODEL_NAME = "meta-llama/Llama-3.2-1B-Instruct"
LLM_MAX_NEW_TOKENS = 2048
