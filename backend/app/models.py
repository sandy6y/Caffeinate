import uuid

from sqlalchemy import CheckConstraint, Column, DateTime, Integer, String, Text
from sqlalchemy.dialects.sqlite import REAL
from sqlalchemy.sql import func

from .database import Base


DRINK_TYPES = (
    "espresso",
    "americano",
    "latte",
    "mocha",
    "flatWhite",
    "cappuccino",
    "matcha",
    "tea",
    "boba",
    "energydrink",
    "other",
)

DRINK_SIZES = ("small", "medium", "large", "XL")
DRINK_TEMPERATURES = ("hot", "iced")


class DrinkLog(Base):
    __tablename__ = "drink_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False, default="")
    time = Column(DateTime(timezone=True), nullable=False)
    type = Column(String, nullable=False)
    size = Column(String, nullable=False)
    temperature = Column(String, nullable=False)
    caffeine = Column(Integer, nullable=False, default=0)
    sugar = Column(Integer, nullable=False, default=0)
    price = Column(REAL, nullable=True)
    rating = Column(Integer, nullable=True)
    note = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    __table_args__ = (
        CheckConstraint(
            f"type IN {DRINK_TYPES}",
            name="drink_logs_type_check",
        ),
        CheckConstraint(
            f"size IN {DRINK_SIZES}",
            name="drink_logs_size_check",
        ),
        CheckConstraint(
            f"temperature IN {DRINK_TEMPERATURES}",
            name="drink_logs_temperature_check",
        ),
        CheckConstraint("caffeine >= 0", name="drink_logs_caffeine_non_negative"),
        CheckConstraint("sugar >= 0", name="drink_logs_sugar_non_negative"),
        CheckConstraint("price IS NULL OR price >= 0", name="drink_logs_price_non_negative"),
        CheckConstraint(
            "rating IS NULL OR (rating >= 1 AND rating <= 5)",
            name="drink_logs_rating_range",
        ),
    )
