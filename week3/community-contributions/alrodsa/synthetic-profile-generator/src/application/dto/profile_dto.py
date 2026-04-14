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
    source_type: str = field(default="synthetic")

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
            "source_type": self.source_type,
        }
