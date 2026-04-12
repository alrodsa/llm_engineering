from app.domain.repositories.profile_repository import ProfileRepository
from app.domain.services.profile_generator import ProfileGenerator
from app.infrastructure.validation.profile_validator import ProfileValidator
from app.application.dto.profile_dto import ProfileDTO

@dataclass(frozen=True, slots=True)
class GenerateProfilesUseCase:
    _generator: ProfileGenerator
    _repository: ProfileRepository
    _validator: ProfileValidator

    def execute(self, num_profiles: int) -> dict:
        profiles = self._generator.generate(num_profiles)

        saved = []
        errors = []

        for profile in profiles:
            validation_errors = self._validator.validate(profile)
            if validation_errors:
                errors.append({"name": profile.name, "errors": validation_errors})
                continue

            self._repository.save(profile)
            dto = ProfileDTO(
                name=profile.name,
                age=profile.age,
                country=profile.country,
                city=profile.city,
                occupation=profile.occupation,
                email=profile.email,
                interests=profile.interests,
                bio=profile.bio,
                source_type=profile.source_type,
            )
            saved.append(dto.to_dict())

        return {
            "generated": len(profiles),
            "saved": len(saved),
            "errors": errors,
            "profiles": saved,
        }
