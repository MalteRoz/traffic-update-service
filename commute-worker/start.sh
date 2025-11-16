#!/bin/bash
# Start Azure Functions with the virtual environment activated

cd "$(dirname "$0")"

# Activate the virtual environment
source .venv/bin/activate

# Start Azure Functions
func start

