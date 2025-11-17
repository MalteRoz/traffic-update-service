import requests
import os
from dotenv import load_dotenv

from traffic_update_service.models.timetable import ResRobotTripParams
from traffic_update_service.utils.exceptions import ExternalApiException

load_dotenv()

class CommuteRepository:
    def __init__(self):
        self.resrobot_url = os.getenv("RESROBOT_URL")
        self.api_key = os.getenv("RESROBOT_API_KEY")

    def get_traffic_data(self):

        params = ResRobotTripParams(
            originId="740007480",
            destId="740000001",
            date="2025-11-15",
            time="09:30",
            searchForArrival=1,
            viaWaitTime=0,
            numB=0,
            numF=5,
            maxChange=3,
            minChangeTime=5,
            maxChangeTime=15,
            changeTimePercent=100,
            products=132,
            operators=["251", "313"],
            poly=0,
            passlist=0,
            unsharp=0,
            lang="sv",
            format="json",
            requestId="resrobot-request"
        )
        params_home = ResRobotTripParams(
            originId="740000001",
            destId="740007480",
            date="2025-11-16",
            time="19:30",
            searchForArrival=1,
            viaWaitTime=0,
            numB=0,
            numF=5,
            maxChange=3,
            minChangeTime=5,
            maxChangeTime=15,
            changeTimePercent=100,
            products=132,
            operators=["251", "313"],
            poly=0,
            passlist=0,
            unsharp=0,
            lang="sv",
            format="json",
            requestId="resrobot-request"
        )
        
        try:
            query_params = params.to_query_params(self.api_key)
            query_params_home = params_home.to_query_params(self.api_key)

            response = requests.get(f"{self.resrobot_url}", params=query_params_home)
            # print(response.url)
            
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            response_status_code = response.status_code
            raise ExternalApiException(f"Error fetching traffic data: {e}", response_status_code)