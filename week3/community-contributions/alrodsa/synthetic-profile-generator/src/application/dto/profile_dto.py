from dataclasses import dataclass, field


@dataclass(frozen=True)
class ProfileDTO:
    name: str
    age: int
    country: str
    city: str
    occupation: str
    email: str
    interests: list[str]
    bio: str

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "age": self.age,
            "country": self.country,
            "city": self.city,
            "occupation": self.occupation,
            "email": self.email,
            "interests": list(self.interests),
            "bio": self.bio,
        }
