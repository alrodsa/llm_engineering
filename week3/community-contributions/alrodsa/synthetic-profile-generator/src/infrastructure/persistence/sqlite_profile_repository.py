from sqlalchemy import func, select

from app.domain.entities.profile import Profile
from app.domain.repositories.profile_repository import ProfileRepository
from src.infrastructure.persistence.models import InterestModel, ProfileModel
from src.infrastructure.persistence.sqlite_connection import SQLiteConnection


class SQLiteProfileRepository(ProfileRepository):

    def __init__(self, connection: SQLiteConnection):
        self._connection = connection

    def save(self, profile: Profile) -> None:
        session = self._connection.create_session()
        try:
            interests = [
                self._get_or_create_interest(session, name)
                for name in profile.interests
            ]

            profile_model = ProfileModel(
                name=profile.name,
                age=profile.age,
                country=profile.country,
                city=profile.city,
                occupation=profile.occupation,
                email=profile.email,
                bio=profile.bio,
                source_type=profile.source_type,
                interests=interests,
            )
            session.add(profile_model)
            session.commit()
        except Exception:
            session.rollback()
            raise
        finally:
            session.close()

    def list_all(self) -> list[Profile]:
        session = self._connection.create_session()
        try:
            rows = session.execute(
                select(ProfileModel).order_by(ProfileModel.id)
            ).scalars().all()

            return [self._to_domain(row) for row in rows]
        finally:
            session.close()

    def count(self) -> int:
        session = self._connection.create_session()
        try:
            return session.execute(
                select(func.count(ProfileModel.id))
            ).scalar_one()
        finally:
            session.close()

    def _get_or_create_interest(self, session, name: str) -> InterestModel:
        existing = session.execute(
            select(InterestModel).where(InterestModel.name == name)
        ).scalar_one_or_none()

        if existing:
            return existing

        interest = InterestModel(name=name)
        session.add(interest)
        session.flush()
        return interest

    def _to_domain(self, model: ProfileModel) -> Profile:
        return Profile(
            name=model.name,
            age=model.age,
            country=model.country,
            city=model.city,
            occupation=model.occupation,
            email=model.email,
            interests=[i.name for i in model.interests],
            bio=model.bio,
            source_type=model.source_type,
        )
