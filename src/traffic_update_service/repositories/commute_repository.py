import requests
import os
from dotenv import load_dotenv

from traffic_update_service.models.timetable import ResRobotTripParams

load_dotenv()

class CommuteRepository:
    def __init__(self):
        self.resrobot_url = os.getenv("RESROBOT_URL")
        self.api_key = os.getenv("RESROBOT_API_KEY")

    def get_traffic_data(self):
        params = ResRobotTripParams(
            originId="740007480",
            destId="740000001",
            date="2025-10-28",
            time="08:40",
            searchForArrival=1,
            viaWaitTime=0,
            numB=0,
            numF=5,
            maxChange=3,
            minChangeTime=5,
            maxChangeTime=15,
            changeTimePercent=100,
            products=132,
            poly=0,
            passlist=0,
            unsharp=0,
            lang="sv",
            format="json",
            requestId="resrobot-request"
        )
        query_params = params.to_query_params(self.api_key)
        
        response = requests.get(f"{self.resrobot_url}", params=query_params)

        if response.status_code == 200:
            return response.json()
        else:
            response.raise_for_status()
            print(f"Error: HTTP {response.status_code}")
            return None


        
      
