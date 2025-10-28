from traffic_update_service.services.commute_service import CommuteService


class CommuteController:
    """Handles the main workflow for fetching and sending commute updates."""

    def __init__(self):
        self.commute_service = CommuteService()

    def run(self):
        data = self.commute_service.get_traffic_data()
        print(data)
