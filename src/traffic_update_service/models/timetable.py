from datetime import date
from pydantic import BaseModel, Field


class ResRobotTripParams(BaseModel):
    originId: str = Field(..., description="Origin station ID or coordinates")
    destId: str = Field(..., description="Destination station ID")
    date: str = Field(..., description="Date in YYYY-MM-DD format")
    time: str = Field(..., description="Time in HH:MM format")
    searchForArrival: int = Field(1, description="1 if searching by arrival time")
    viaWaitTime: int = 0
    numB: int = 0
    numF: int = 5
    maxChange: int = 3
    minChangeTime: int = 5
    maxChangeTime: int = 15
    changeTimePercent: int = 100
    products: int = Field(132, description="Transport modes (sum of mode flags)")
    poly: int = 0
    passlist: int = 0
    unsharp: int = 0
    lang: str = "sv"
    format: str = "json"
    requestId: str = "resrobot-request"


    def to_query_params(self, access_id: str): 
        """Convert model to query dict for requests.get"""
        params = self.model_dump()
        params["accessId"] = access_id
        return params