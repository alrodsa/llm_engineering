from app.domain.repositories.profile_repository import ProfileRepository
from app.infrastructure.exporters.json_exporter import JsonExporter


class ExportProfilesToJsonUseCase:

    def __init__(self, repository: ProfileRepository, exporter: JsonExporter):
        self._repository = repository
        self._exporter = exporter

    def execute(self, output_path: str) -> str:
        profiles = self._repository.list_all()
        if not profiles:
            return ""

        self._exporter.export(profiles, output_path)
        return output_path
