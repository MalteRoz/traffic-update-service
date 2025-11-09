from typing import List
from traffic_update_service.models.trip_model import TripLegModel, TripModel
from traffic_update_service.repositories.commute_repository import CommuteRepository
from traffic_update_service.utils.exceptions import EmptyDataException

class CommuteService:
    def __init__(self):
        self.commute_repository = CommuteRepository()

    def get_traffic_data(self):
        dirty_data = self.commute_repository.get_traffic_data()

        if dirty_data.get("Trip") is None:
            raise EmptyDataException()
        
        clean_data =self._parse_traffic_data(dirty_data)

        return clean_data

    def _parse_traffic_data(self, dirty_data):

        # 1. lägga in alla resultat i en array av TripModel
        # 2. gå igen första lagret som är Trip och lägga in i arrayen som TripModel objekt 
        # 3. gå igenom LegList och lägga tillhörande data in i arrayen som TripLegModel objekt 
        # 4. kalla på _rank_trips för att sortera arrayen efter tid som matchar bäst med arrival
        # 5. returnera den sorterade arrayen
    
        trips = [
            TripModel(
                origin=trip.get("Origin").get("name"),
                destination=trip.get("Destination").get("name"),
                departure_time=trip.get("Origin").get("time"),
                arrival_time=trip.get("Destination").get("time"),
                total_duration=trip.get("duration"), 
                changes=trip.get("transferCount"),
                legs=[
                    TripLegModel(
                        origin=leg.get("Origin").get("name"),
                        destination=leg.get("Destination").get("name"),
                        departure_time=leg.get("Origin").get("time"),
                        arrival_time=leg.get("Destination").get("time"),
                        product_name=leg.get("name"),
                        duration=leg.get("duration"),
                        direction=leg.get("direction"),
                        operator=leg.get("Product", [{}])[0].get("operatorInfo", {}).get("name") if leg.get("Product") else None,
                        track=leg.get("number"),
                        transport_mode=leg.get("name"),
                    ) 
                    for leg in trip["LegList"]["Leg"]
                ]
            )
            for trip in dirty_data["Trip"]
        ]

        ranked_trips = self._rank_trips(trips)
        return ranked_trips

    def _rank_trips(self, trips: List[TripModel]):

        # 1. gå igenom alla trips och lägg till i en array
        # 2. sortera arrayen efter tid som matchar bäst med arrival
        # 3. returna den sorterade arrayen

        target_time = self._time_to_minutes("09:30")

        target_time_home = self._time_to_minutes("19:30")

        sorted_trips = sorted(trips,
        key=lambda trip: abs(self._time_to_minutes(trip.arrival_time) - target_time_home)
        )

        return sorted_trips

    def _time_to_minutes(self, time: str):
        
        # 1. split time into hours and minutes variables
        # 2. convert hours and minutes to minutes
        # 3. return the total minutes

        parts = time.split(":")
        hours = int(parts[0])
        minutes = int(parts[1])

        return hours * 60 + minutes