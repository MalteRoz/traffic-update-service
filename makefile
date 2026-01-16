.PHONY: help setup-env setup-gcp run-local run-script run-docker build deploy test test-local logs clean install

# Variables
PROJECT_ID ?= traffic-update-svc
SERVICE_NAME = traffic-update-service
REGION = europe-west1
IMAGE_NAME = $(SERVICE_NAME)

help:
	@echo "🚀 Traffic Update Service - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make install       - Install dependencies with uv"
	@echo "  make setup-env     - Create environment variable template files"
	@echo "  make setup-gcp     - Set up Google Cloud Platform project"
	@echo ""
	@echo "Development:"
	@echo "  make run-local     - Run the API locally with uvicorn (port 8000)"
	@echo "  make run-script    - Run as a script locally"
	@echo "  make run-docker    - Build and run in Docker locally (port 8080)"
	@echo ""
	@echo "Testing:"
	@echo "  make test-local    - Run local test suite"
	@echo "  make test          - Test the deployed Cloud Run service"
	@echo ""
	@echo "Docker:"
	@echo "  make build         - Build Docker image"
	@echo "  make clean         - Remove local Docker images"
	@echo ""
	@echo "Cloud Run Deployment:"
	@echo "  make deploy        - Deploy to Cloud Run (requires .env.yaml)"
	@echo "  make logs          - View Cloud Run logs"
	@echo ""
	@echo "💡 First time? Run: make install && make setup-env && cp .env.example .env (then edit .env)"

install:
	@echo "📦 Installing dependencies with uv..."
	uv sync
	@echo "✅ Dependencies installed!"

setup-env:
	@echo "Creating environment template files..."
	@echo "# Local Development Environment Variables" > .env.example
	@echo "# Copy this file to .env and fill in your actual values" >> .env.example
	@echo "" >> .env.example
	@echo "RESROBOT_URL=https://api.resrobot.se/v2.1/trip" >> .env.example
	@echo "RESROBOT_API_KEY=your-resrobot-api-key-here" >> .env.example
	@echo "GTFS_API_KEY=your-gtfs-api-key-here" >> .env.example
	@echo "# Google Cloud Run Environment Variables" > .env.yaml.example
	@echo "# Copy this file to .env.yaml and fill in your actual values" >> .env.yaml.example
	@echo "" >> .env.yaml.example
	@echo 'RESROBOT_URL: "https://api.resrobot.se/v2.1/trip"' >> .env.yaml.example
	@echo 'RESROBOT_API_KEY: "your-resrobot-api-key-here"' >> .env.yaml.example
	@echo 'GTFS_API_KEY: "your-gtfs-api-key-here"' >> .env.yaml.example
	@echo "✅ Created .env.example and .env.yaml.example"
	@echo ""
	@echo "📝 Next steps:"
	@echo "  1. Copy .env.example to .env:        cp .env.example .env"
	@echo "  2. Copy .env.yaml.example to .env.yaml: cp .env.yaml.example .env.yaml"
	@echo "  3. Edit both files and add your real API keys"

setup-gcp:
	@echo "🚀 Setting up GCP project..."
	gcloud projects create $(PROJECT_ID) --name="Traffic Update Service" || true
	gcloud config set project $(PROJECT_ID)
	@echo ""
	@echo "⚠️  Important: Link a billing account at:"
	@echo "    https://console.cloud.google.com/billing"
	@echo ""
	@echo "Enabling required APIs..."
	gcloud services enable run.googleapis.com
	gcloud services enable cloudbuild.googleapis.com
	gcloud services enable cloudscheduler.googleapis.com
	@echo ""
	@echo "✅ Setup complete!"

run-local:
	uv run uvicorn traffic_update_service.api:app --reload --port 8000

run-script:
	uv run python traffic_update_service/main.py

run-docker: build
	@if [ ! -f .env ]; then echo "⚠️  .env file not found. Copy .env.example to .env and fill in your values."; exit 1; fi
	docker run -p 8080:8080 --env-file .env -e PORT=8080 $(IMAGE_NAME)

build:
	docker build -t $(IMAGE_NAME) .

deploy:
	@if [ ! -f .env.yaml ]; then echo "⚠️  .env.yaml not found"; exit 1; fi
	gcloud builds submit --tag $(REGION)-docker.pkg.dev/$(PROJECT_ID)/cloud-run-source-deploy/$(SERVICE_NAME)
	gcloud run deploy $(SERVICE_NAME) \
		--image $(REGION)-docker.pkg.dev/$(PROJECT_ID)/cloud-run-source-deploy/$(SERVICE_NAME) \
		--platform managed \
		--region $(REGION) \
		--env-vars-file .env.yaml \
		--project $(PROJECT_ID)

logs:
	gcloud run logs read $(SERVICE_NAME) --limit 50 --project $(PROJECT_ID)

test-local:
	@echo "🧪 Running local test suite..."
	uv run pytest tests/ -v

test:
	@echo "🧪 Testing deployed service endpoints..."
	@echo "\n📍 Health endpoint:"
	@curl -s $$(gcloud run services describe $(SERVICE_NAME) --region $(REGION) --format 'value(status.url)') | jq
	@echo "\n📍 Update commute endpoint:"
	@curl -X POST -s $$(gcloud run services describe $(SERVICE_NAME) --region $(REGION) --format 'value(status.url)')/update-commute | jq

clean:
	docker rmi $(IMAGE_NAME) || true

# Add to your variables section at top
MORNING_SCHEDULE = "0 7 * * 1-5"
EVENING_SCHEDULE = "0 18 * * 1-5"
TIMEZONE = "Europe/Stockholm"

# Add these new targets
setup-scheduler:
	@echo "🕐 Setting up Cloud Scheduler jobs..."
	@SERVICE_URL=$$(gcloud run services describe $(SERVICE_NAME) --region $(REGION) --format 'value(status.url)' --project $(PROJECT_ID)); \
	echo "Service URL: $$SERVICE_URL"; \
	gcloud scheduler jobs create http morning-commute \
		--location $(REGION) \
		--schedule $(MORNING_SCHEDULE) \
		--time-zone $(TIMEZONE) \
		--uri "$$SERVICE_URL/update-commute" \
		--http-method POST \
		--attempt-deadline 300s \
		--project $(PROJECT_ID) || echo "Job already exists"; \
	gcloud scheduler jobs create http evening-commute \
		--location $(REGION) \
		--schedule $(EVENING_SCHEDULE) \
		--time-zone $(TIMEZONE) \
		--uri "$$SERVICE_URL/update-commute" \
		--http-method POST \
		--attempt-deadline 300s \
		--project $(PROJECT_ID) || echo "Job already exists"
	@echo "✅ Scheduler jobs created!"

update-schedule:
	@echo "📝 Updating schedule times..."
	gcloud scheduler jobs update http morning-commute \
		--location $(REGION) \
		--schedule $(MORNING_SCHEDULE) \
		--project $(PROJECT_ID)
	gcloud scheduler jobs update http evening-commute \
		--location $(REGION) \
		--schedule $(EVENING_SCHEDULE) \
		--project $(PROJECT_ID)

trigger-morning:
	@echo "🌅 Triggering morning commute update..."
	gcloud scheduler jobs run morning-commute --location $(REGION) --project $(PROJECT_ID)

trigger-evening:
	@echo "🌆 Triggering evening commute update..."
	gcloud scheduler jobs run evening-commute --location $(REGION) --project $(PROJECT_ID)

list-jobs:
	@echo "📋 Scheduled jobs:"
	gcloud scheduler jobs list --location $(REGION) --project $(PROJECT_ID)

pause-scheduler:
	@echo "⏸️  Pausing scheduler jobs..."
	gcloud scheduler jobs pause morning-commute --location $(REGION) --project $(PROJECT_ID)
	gcloud scheduler jobs pause evening-commute --location $(REGION) --project $(PROJECT_ID)

resume-scheduler:
	@echo "▶️  Resuming scheduler jobs..."
	gcloud scheduler jobs resume morning-commute --location $(REGION) --project $(PROJECT_ID)
	gcloud scheduler jobs resume evening-commute --location $(REGION) --project $(PROJECT_ID)

delete-scheduler:
	@echo "🗑️  Deleting scheduler jobs..."
	gcloud scheduler jobs delete morning-commute --location $(REGION) --project $(PROJECT_ID) --quiet
	gcloud scheduler jobs delete evening-commute --location $(REGION) --project $(PROJECT_ID) --quiet