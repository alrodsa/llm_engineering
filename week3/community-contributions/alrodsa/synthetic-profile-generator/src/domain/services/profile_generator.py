from abc import ABC, abstractmethod

from app.domain.entities.profile import Profile


class ProfileGenerator(ABC):

    @abstractmethod
    def generate(self, num_profiles: int) -> list[Profile]:
        ...
