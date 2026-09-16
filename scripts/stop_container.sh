#!/bin/bash
set -e

echo "Checking for existing containers on port 5000..."

# Find any container (running or stopped) publishing host port 5000
EXISTING_CONTAINERS=$(docker ps -aq --filter "publish=5000")

if [ -n "$EXISTING_CONTAINERS" ]; then
  echo "Found existing container(s) using port 5000: $EXISTING_CONTAINERS"
  docker rm -f $EXISTING_CONTAINERS
  echo "Removed."
else
  echo "No existing container found on port 5000. Nothing to clean up."
fi
