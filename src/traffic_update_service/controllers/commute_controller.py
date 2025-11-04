import json
from traffic_update_service.services.commute_service import CommuteService


class CommuteController:
    """Handles the main workflow for fetching and sending commute updates."""

    def __init__(self):
        self.commute_service = CommuteService()

    def run(self):
        data = self.commute_service.get_traffic_data()
        
        # Convert Pydantic models to dictionaries
        data_dict = [trip.model_dump() for trip in data]
        
        # Pretty print as JSON
        print(json.dumps(data_dict, indent=2, ensure_ascii=False))
