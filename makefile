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