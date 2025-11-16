import azure.functions as func
import datetime
import logging
import sys
from pathlib import Path

# Add parent directory to sys.path so we can import traffic_update_service
parent_dir = Path(__file__).parent.parent
if str(parent_dir) not in sys.path:
    sys.path.insert(0, str(parent_dir))

app = func.FunctionApp()

@app.function_name(name="commute-worker")
@app.schedule(schedule="0 0 * * *", arg_name="myTimer", run_on_startup=True, use_monitor=False)
def commute_worker(myTimer: func.TimerRequest) -> None:
    """Timer trigger to run the commute worker logic."""

    
    utc_timestamp = datetime.datetime.utcnow().isoformat()
    logging.info(f"[CommuteWorker] Triggered at {utc_timestamp}")
    
    try:
        from traffic_update_service.controllers.commute_controller import CommuteController
        logging.info(f"[CommuteWorker] Importing CommuteController at {utc_timestamp}")

        controller = CommuteController()
        logging.info(f"[CommuteWorker] Running CommuteController at {utc_timestamp}")

        controller.run()
        logging.info(f"[CommuteWorker] CommuteController completed at {utc_timestamp}")
    except Exception as e:
        logging.error(f"CommuteController failed: {e}")
        raise