import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from src.config.settings import DB_PATH, EXPORT_PATH, HF_TOKEN, LLM_MODEL_NAME, LLM_MAX_NEW_TOKENS
from src.infrastructure.llm.huggingface_profile_generator import (
    HuggingFaceProfileGenerator,
    DEFAULT_QUANT_CONFIG,
)
from src.infrastructure.persistence.sqlite_connection import SQLiteConnection
from src.infrastructure.persistence.sqlite_profile_repository import SQLiteProfileRepository
from src.infrastructure.exporters.json_exporter import JsonExporter
from src.infrastructure.validation.profile_validator import ProfileValidator
from src.application.use_cases.generate_profiles import GenerateProfilesUseCase
from src.application.use_cases.export_profiles_to_json import ExportProfilesToJsonUseCase
from src.application.use_cases.count_profiles import CountProfilesUseCase
from src.presentation.gradio_app import GradioApp


def main():
    # Infrastructure
    db = SQLiteConnection(DB_PATH)
    repository = SQLiteProfileRepository(db)
    generator = HuggingFaceProfileGenerator(
        LLM_MODEL_NAME, HF_TOKEN, LLM_MAX_NEW_TOKENS, quantization_config=DEFAULT_QUANT_CONFIG,
    )
    exporter = JsonExporter()
    validator = ProfileValidator()

    # Use cases
    generate_use_case = GenerateProfilesUseCase(generator, repository, validator)
    export_use_case = ExportProfilesToJsonUseCase(repository, exporter)
    count_use_case = CountProfilesUseCase(repository)

    # Presentation
    app = GradioApp(generate_use_case, export_use_case, count_use_case, EXPORT_PATH)
    ui = app.build()
    ui.launch()


if __name__ == "__main__":
    main()
