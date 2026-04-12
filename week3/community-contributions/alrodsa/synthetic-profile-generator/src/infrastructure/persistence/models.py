from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Table
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


profile_interests = Table(
    "profile_interests",
    Base.metadata,
    Column("profile_id", Integer, ForeignKey("profiles.id"), primary_key=True),
    Column("interest_id", Integer, ForeignKey("interests.id"), primary_key=True),
)


class ProfileModel(Base):
    __tablename__ = "profiles"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    age: Mapped[int] = mapped_column(Integer, nullable=False)
    country: Mapped[str] = mapped_column(String, nullable=False)
    city: Mapped[str] = mapped_column(String, nullable=False)
    occupation: Mapped[str] = mapped_column(String, nullable=False)
    email: Mapped[str] = mapped_column(String, nullable=False, unique=True)
    bio: Mapped[str] = mapped_column(String, nullable=False)
    source_type: Mapped[str] = mapped_column(String, nullable=False, default="synthetic")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    interests: Mapped[list["InterestModel"]] = relationship(
        secondary=profile_interests, back_populates="profiles",
    )


class InterestModel(Base):
    __tablename__ = "interests"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String, nullable=False, unique=True)

    profiles: Mapped[list["ProfileModel"]] = relationship(
        secondary=profile_interests, back_populates="interests",
    )
