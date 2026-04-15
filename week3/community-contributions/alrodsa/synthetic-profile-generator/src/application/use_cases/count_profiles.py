from src.domain.repositories.profile_repository import ProfileRepository


class CountProfilesUseCase:

    def __init__(self, repository: ProfileRepository):
        self._repository = repository

    def execute(self) -> int:
        return self._repository.count()
