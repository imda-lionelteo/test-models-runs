#!/bin/bash

# LiteLLM Docker Entrypoint Script
# This script sets up environment variables and starts the LiteLLM proxy

set -e

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting LiteLLM container..."

# Validate required environment variables
if [ -z "$DATABASE_URL" ]; then
    log "ERROR: DATABASE_URL environment variable is required"
    exit 1
fi

if [ -z "$LITELLM_MASTER_KEY" ]; then
    log "WARNING: LITELLM_MASTER_KEY not set, using default"
    export LITELLM_MASTER_KEY="sk-litellm-default"
fi

# Set default values if not provided
export STORE_MODEL_IN_DB=${STORE_MODEL_IN_DB:-"True"}

# Log configuration (without secrets)
log "Configuration:"
log "  - Database: ${DATABASE_URL%:*}:***@${DATABASE_URL##*@}"
log "  - Store models in DB: ${STORE_MODEL_IN_DB}"
log "  - Master key: ${LITELLM_MASTER_KEY:0:10}***"

# Wait for database to be ready
log "Checking database connection..."
python3 -c "
import os
import time
import psycopg2
from urllib.parse import urlparse

def wait_for_db():
    db_url = os.environ['DATABASE_URL']
    parsed = urlparse(db_url)
    
    max_retries = 30
    for i in range(max_retries):
        try:
            conn = psycopg2.connect(
                host=parsed.hostname,
                port=parsed.port,
                database=parsed.path[1:],
                user=parsed.username,
                password=parsed.password
            )
            conn.close()
            print(f'Database is ready after {i+1} attempts')
            return True
        except Exception as e:
            print(f'Attempt {i+1}: Database not ready - {str(e)}')
            time.sleep(2)
    
    print('Database failed to become ready')
    return False

if not wait_for_db():
    exit(1)
"

log "Database connection successful!"

# Start LiteLLM with provided arguments
log "Starting LiteLLM proxy with args: $@"
exec litellm "$@"

