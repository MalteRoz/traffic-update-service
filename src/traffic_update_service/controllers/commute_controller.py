from traffic_update_service.services.trafik_service import TrafikService


class CommuteController:
    """Handles the main workflow for fetching and sending commute updates."""

    def __init__(self):
        self.trafik_service = TrafikService()

    def run(self):
        data = self.trafik_service.get_traffic_data()
        print(data)
