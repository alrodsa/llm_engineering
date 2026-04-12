import re

from app.domain.entities.profile import Profile

EMAIL_PATTERN = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")


class ProfileValidator:

    def validate(self, profile: Profile) -> list[str]:
        errors = []

        if not profile.name or not profile.name.strip():
            errors.append("Name is required")

        if not isinstance(profile.age, int) or not (18 <= profile.age <= 80):
            errors.append("Age must be an integer between 18 and 80")

        if not profile.email or not EMAIL_PATTERN.match(profile.email):
            errors.append("Email must be a valid format")

        if not profile.interests or len(profile.interests) < 1:
            errors.append("At least 1 interest is required")

        if len(profile.interests) > 5:
            errors.append("Maximum 5 interests allowed")

        if not profile.country or not profile.country.strip():
            errors.append("Country is required")

        if not profile.city or not profile.city.strip():
            errors.append("City is required")

        if not profile.occupation or not profile.occupation.strip():
            errors.append("Occupation is required")

        if not profile.bio or not profile.bio.strip():
            errors.append("Bio is required")

        if profile.source_type != "synthetic":
            errors.append('source_type must be "synthetic"')

        return errors
