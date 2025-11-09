import json
from traffic_update_service.services.commute_service import CommuteService
from traffic_update_service.utils.exceptions import TrafficServiceException


class CommuteController:
    """Handles the main workflow for fetching and sending commute updates."""

    def __init__(self):
        self.commute_service = CommuteService()

    def run(self):

        try:
            data = self.commute_service.get_traffic_data()
            data_dict = [trip.model_dump() for trip in data]

            print(json.dumps(data_dict, indent=2, ensure_ascii=False))
        except TrafficServiceException as e:
            print(f"Error fetching traffic data: {e}")
            return 
