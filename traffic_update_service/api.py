from fastapi import FastAPI, BackgroundTasks
from traffic_update_service.controllers.commute_controller import CommuteController
import logging

app = FastAPI()
logger = logging.getLogger(__name__)

@app.get("/")
def health_check():
    return {"status": "healthy", "service": "traffic-update-service"}

@app.post("/update-commute")
def update_commute(background_tasks: BackgroundTasks):
    """
    Triggers your existing controller.run() method
    """
    logger.info("Triggering commute update")
    
    # Run your existing code in the background
    background_tasks.add_task(run_controller)
    # Return the result of the run_controller method
    # result = run_controller()
    
    return {"status": "triggered"}

def run_controller():
    """Runs your existing script logic"""
    controller = CommuteController()
    result = controller.run()
    return result

