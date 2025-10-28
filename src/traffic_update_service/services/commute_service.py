from traffic_update_service.repositories.commute_repository import CommuteRepository

class CommuteService:
    def __init__(self):
        self.commute_repository = CommuteRepository()

    def get_traffic_data(self):
        return self.commute_repository.get_traffic_data()

