from abc import ABC, abstractmethod

from app.domain.entities.profile import Profile


class ProfileRepository(ABC):

    @abstractmethod
    def save(self, profile: Profile) -> None:
        ...

    @abstractmethod
    def list_all(self) -> list[Profile]:
        ...

    @abstractmethod
    def count(self) -> int:
        ...
