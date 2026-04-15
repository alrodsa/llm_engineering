from dataclasses import dataclass, field


@dataclass
class Profile:
    name: str
    age: int
    country: str
    city: str
    occupation: str
    email: str
    interests: list[str]
    bio: str
    source_type: str = field(default="synthetic")
