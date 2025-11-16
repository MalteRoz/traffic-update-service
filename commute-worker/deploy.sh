#!/bin/bash
# Deploy Azure Function with the traffic_update_service package
# This deploys from the parent directory to include the shared package

set -e  # Exit on any error

# Get the script directory and parent directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKER_DIR="commute-worker"

# Check if function app name is provided
if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh <function-app-name>"
    echo "Example: ./deploy.sh commute-traffic-service"
    exit 1
fi

FUNCTION_APP_NAME="$1"

echo "📦 Preparing deployment package..."
echo "   Working from: $PARENT_DIR"
echo "   Function app directory: $WORKER_DIR"

# Change to parent directory so traffic_update_service is accessible
cd "$PARENT_DIR"

# Create temporary symlink in commute-worker if it doesn't exist
if [ ! -e "$WORKER_DIR/traffic_update_service" ]; then
    ln -s "$PARENT_DIR/traffic_update_service" "$WORKER_DIR/traffic_update_service"
    CREATED_SYMLINK=true
    echo "   ✓ Created temporary symlink to traffic_update_service"
fi

echo "🚀 Deploying to Azure Function App: $FUNCTION_APP_NAME"

# Deploy from the worker directory
cd "$WORKER_DIR"
func azure functionapp publish "$FUNCTION_APP_NAME" --python

# Clean up symlink if we created it
if [ "$CREATED_SYMLINK" = true ]; then
    rm -f traffic_update_service
    echo "   ✓ Cleaned up temporary symlink"
fi

echo "✅ Deployment complete!"


