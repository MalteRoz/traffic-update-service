# Traffic Update Service

A FastAPI service for fetching and managing traffic/commute updates using ResRobot API.

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) package manager
- Docker (for containerized deployment)
- Google Cloud SDK (for Cloud Run deployment)

## Setup

### 1. Install Dependencies

```bash
uv sync
```

### 2. Configure Environment Variables

First, create the environment template files:

```bash
make setup-env
```

Then create your local environment files:

```bash
# For local development
cp .env.example .env

# For Cloud Run deployment
cp .env.yaml.example .env.yaml
```

Edit both files and add your actual API keys:

**`.env`** (for local development):
```
RESROBOT_URL=https://api.resrobot.se/v2.1/trip
RESROBOT_API_KEY=your-actual-api-key
GTFS_API_KEY=your-actual-gtfs-key
```

**`.env.yaml`** (for Cloud Run):
```yaml
RESROBOT_URL: "https://api.resrobot.se/v2.1/trip"
RESROBOT_API_KEY: "your-actual-api-key"
GTFS_API_KEY: "your-actual-gtfs-key"
```

## Running Locally

### Run with uvicorn (API mode)

```bash
make run-local
```

This starts the FastAPI server at `http://localhost:8000`

### Run as a script

```bash
make run-script
```

### Run with Docker

```bash
make run-docker
```

This builds the Docker image and runs it on port 8080 with your `.env` variables.

## Deployment to Google Cloud Run

### Initial Setup

```bash
make setup-gcp
```

This will:
- Create a GCP project
- Enable required APIs (Cloud Run, Cloud Build, Cloud Scheduler)
- Prompt you to link a billing account

### Deploy

```bash
make deploy
```

This deploys your service to Cloud Run using the environment variables from `.env.yaml`.

### View Logs

```bash
make logs
```

### Test Deployed Service

```bash
make test
```

## Available Commands

Run `make help` to see all available commands:

```
make setup-env     - Create environment variable template files
make run-local     - Run the API locally with uvicorn
make run-script    - Run as a script locally
make run-docker    - Build and run in Docker locally
make build         - Build Docker image
make deploy        - Deploy to Cloud Run
make logs          - View Cloud Run logs
make test          - Test the deployed service
make clean         - Remove local Docker images
```

## Project Structure

```
traffic_update_service/
├── api.py                    # FastAPI application
├── main.py                   # Script entry point
├── controllers/
│   └── commute_controller.py
├── services/
│   ├── commute_service.py
│   └── notifier_service.py
├── repositories/
│   └── commute_repository.py
├── models/
│   ├── timetable.py
│   └── trip_model.py
└── utils/
    ├── exceptions.py
    ├── operators_service.py
    ├── rate_limit.py
    └── retry.py
```

## API Endpoints

- `GET /` - Health check endpoint
- `POST /update-commute` - Fetch and process commute updates

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `RESROBOT_URL` | ResRobot API base URL | Yes |
| `RESROBOT_API_KEY` | API key for ResRobot | Yes |
| `GTFS_API_KEY` | GTFS API key | Yes |
| `PORT` | Server port (default: 8080 for Docker/Cloud Run) | No |

## Security Notes

- Never commit `.env` or `.env.yaml` files to version control
- These files are already in `.gitignore`
- For production, consider using Google Cloud Secret Manager instead of `.env.yaml`

## Troubleshooting

### Port Already in Use

If you get "Address already in use" error:

```bash
# Find process using port 8000
lsof -i :8000

# Kill the process
kill <PID>

# Or use a different port
uv run uvicorn traffic_update_service.api:app --reload --port 8001
```

### Missing Environment Variables

If deployment fails with missing env vars:

1. Ensure `.env.yaml` exists and has all required variables
2. Check that values are properly quoted in YAML format
3. Verify the file is in the project root directory

