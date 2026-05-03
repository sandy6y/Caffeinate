from datetime import datetime, timezone
from enum import Enum
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_serializer


class DrinkType(str, Enum):
    espresso = "espresso"
    americano = "americano"
    latte = "latte"
    mocha = "mocha"
    flatWhite = "flatWhite"
    cappuccino = "cappuccino"
    matcha = "matcha"
    tea = "tea"
    boba = "boba"
    energydrink = "energydrink"
    other = "other"


class DrinkSize(str, Enum):
    small = "small"
    medium = "medium"
    large = "large"
    XL = "XL"


class DrinkTemperature(str, Enum):
    hot = "hot"
    iced = "iced"


class LogBase(BaseModel):
    name: str = ""
    time: datetime
    type: DrinkType
    size: DrinkSize
    temperature: DrinkTemperature
    caffeine: int = Field(ge=0)
    sugar: int = Field(ge=0)
    price: Optional[float] = Field(default=None, ge=0)
    rating: Optional[int] = Field(default=None, ge=1, le=5)
    note: Optional[str] = None


class LogCreate(LogBase):
    pass


class LogUpdate(BaseModel):
    name: Optional[str] = None
    time: Optional[datetime] = None
    type: Optional[DrinkType] = None
    size: Optional[DrinkSize] = None
    temperature: Optional[DrinkTemperature] = None
    caffeine: Optional[int] = Field(default=None, ge=0)
    sugar: Optional[int] = Field(default=None, ge=0)
    price: Optional[float] = Field(default=None, ge=0)
    rating: Optional[int] = Field(default=None, ge=1, le=5)
    note: Optional[str] = None


class LogResponse(LogBase):
    id: UUID

    model_config = ConfigDict(from_attributes=True)

    @field_serializer("time")
    def serialize_time(self, value: datetime) -> str:
        if value.tzinfo is None:
            value = value.replace(tzinfo=timezone.utc)
        return value.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")
