from abc import ABC, abstractmethod

from src.domain.entities.profile import Profile


class ProfileGenerator(ABC):

    @abstractmethod
    def generate(self, num_profiles: int) -> list[Profile]:
        ...
