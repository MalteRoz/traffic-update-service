from  traffic_update_service.controllers.commute_controller import CommuteController


def main():
    controller = CommuteController()
    controller.run()


if __name__ == "__main__":
    main()
