from traffic_update_service.repositories.trafikverket_repository import TrafikverketRepository


class TrafikService:
    def __init__(self):
        self.trafikverket_repository = TrafikverketRepository()

    def get_traffic_data(self):
        return self.trafikverket_repository.get_traffic_data()