from pydantic import BaseModel, Field
from typing import List, Optional

class TripLegModel(BaseModel):
    origin: str = Field(..., description="Name of the origin stop/station")
    destination: str = Field(..., description="Name of the destination stop/station")
    departure_time: str = Field(..., description="Departure time in HH:MM")
    arrival_time: str = Field(..., description="Arrival time in HH:MM")
    product_name: str = Field(..., description="Vehicle or line name, e.g., 'Mälartåg 1234'")
    duration: Optional[str] = Field(None, description="Duration of the leg")
    direction: Optional[str] = Field(None, description="Direction of travel")
    operator: Optional[str] = Field(None, description="Operator of the leg")
    track: Optional[str] = Field(None, description="Track number if available")
    transport_mode: Optional[str] = Field(None, description="Train, bus, walk, etc.")


class TripModel(BaseModel):
    origin: str = Field(..., description="Overall trip origin")
    destination: str = Field(..., description="Overall trip destination")
    departure_time: str = Field(..., description="Departure time of first leg")
    arrival_time: str = Field(..., description="Arrival time of last leg")
    total_duration: Optional[str] = Field(None, description="Total duration of trip")
    changes: Optional[int] = Field(None, description="Number of transfers/changes")
    legs: List[TripLegModel] = Field(default_factory=list)


# om det är tåg lägg till spår nmr
# operator för tåg och buss 
