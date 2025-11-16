#!/bin/bash
# Wait for Docker services to be healthy before running tests

set -e

echo "⏳ Waiting for services to be ready..."
echo ""

# Configuration
MAX_WAIT=60  # Maximum wait time in seconds
SLEEP_INTERVAL=2

# Function to check if a service is responding
check_service() {
    local url=$1
    local name=$2
    
    if curl -f -s -o /dev/null "$url" 2>/dev/null; then
        echo "✅ ${name} is ready"
        return 0
    else
        return 1
    fi
}

# Wait for API service
echo "Checking API service..."
elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
    if check_service "http://localhost:9557/health" "API"; then
        break
    fi
    sleep $SLEEP_INTERVAL
    elapsed=$((elapsed + SLEEP_INTERVAL))
    echo "   Waiting... (${elapsed}s)"
done

if [ $elapsed -ge $MAX_WAIT ]; then
    echo "❌ API service did not become ready in time"
    echo "   Check logs with: make logs-api"
    exit 1
fi

# Wait for Web UI service
echo ""
echo "Checking Web UI service..."
elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
    if check_service "http://localhost:8501/_stcore/health" "Web UI"; then
        break
    fi
    sleep $SLEEP_INTERVAL
    elapsed=$((elapsed + SLEEP_INTERVAL))
    echo "   Waiting... (${elapsed}s)"
done

if [ $elapsed -ge $MAX_WAIT ]; then
    echo "❌ Web UI service did not become ready in time"
    echo "   Check logs with: make logs-web"
    exit 1
fi

echo ""
echo "✅ All services are ready!"
echo ""
