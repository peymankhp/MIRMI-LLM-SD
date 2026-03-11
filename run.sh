#!/bin/bash

# Stop manually started containers if they exist
docker stop mirmi-llm ollama 2>/dev/null || true
docker rm mirmi-llm ollama 2>/dev/null || true

# Start everything with docker compose
docker compose up -d --build

# Optional: prune images to save space
docker image prune -f
