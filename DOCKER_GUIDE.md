# PsyDraw Docker Guide

## 📚 Table of Contents

1. [Quick Start (TL;DR)](#quick-start-tldr)
2. [What is Docker & Why Use It?](#what-is-docker--why-use-it)
3. [How the Dockerization Works](#how-the-dockerization-works)
4. [Step-by-Step Setup Guide](#step-by-step-setup-guide)
5. [Using the Application](#using-the-application)
6. [Common Commands](#common-commands)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Usage](#advanced-usage)

---

## Quick Start (TL;DR)

For experienced users who just want to get started:

```bash
# Super Quick - ONE COMMAND to do everything!
make all

# If .env doesn't exist or needs your API key:
# 1. Edit .env and add GOOGLE_API_KEY
# 2. Run: make all
```

**That's it!** Access at:
- Web UI: http://localhost:8501
- API: http://localhost:9557

### Alternative (Manual steps):

```bash
# 1. Run setup script
./setup.sh

# 2. Edit .env and add your GOOGLE_API_KEY
nano .env

# 3. Start services
make up

# 4. Access the application
# Web UI: http://localhost:8501
# API: http://localhost:9557
```

---

## What is Docker & Why Use It?

### What is Docker?

Docker is a platform that packages your application and all its dependencies into a "container" - think of it as a lightweight, portable box that contains everything needed to run the application.

### Why We Dockerized PsyDraw?

**Without Docker:**
- ❌ Users need to install Python 3.11+
- ❌ Install 30+ Python packages manually
- ❌ Worry about conflicting package versions
- ❌ Different behavior on Mac/Windows/Linux
- ❌ "It works on my machine" problems

**With Docker:**
- ✅ One-command setup
- ✅ All dependencies bundled
- ✅ Same behavior everywhere
- ✅ Isolated from other projects
- ✅ Easy to share and deploy

---

## How the Dockerization Works

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Host (Your Computer)          │
│                                                          │
│  ┌────────────────────┐      ┌────────────────────┐   │
│  │  Container: API    │      │  Container: Web UI │   │
│  │                    │      │                    │   │
│  │  - Python 3.11     │      │  - Python 3.11     │   │
│  │  - FastAPI         │      │  - Streamlit       │   │
│  │  - Port 9557       │      │  - Port 8501       │   │
│  │  - Google Gemini   │      │  - Drawing UI      │   │
│  └─────────┬──────────┘      └─────────┬──────────┘   │
│            │                            │               │
│            └────────────┬───────────────┘               │
│                         │                               │
│                    ┌────▼────┐                          │
│                    │ Volumes │                          │
│                    │         │                          │
│                    │ ./report│  ← Analysis results      │
│                    │ ./.cache│  ← LLM response cache    │
│                    └─────────┘                          │
└─────────────────────────────────────────────────────────┘
```

### Key Components Explained

#### 1. **Dockerfile** (Blueprint)

The `Dockerfile` is like a recipe that tells Docker how to build the application:

```dockerfile
FROM python:3.11-slim           # Start with Python 3.11
WORKDIR /app                    # Set working directory
COPY requirements.txt .         # Copy dependency list
RUN pip install -r requirements.txt  # Install Python packages
COPY . /app                     # Copy application code
EXPOSE 9557 8501                # Declare ports to use
CMD ["python", "deploy.py"]     # Default command to run
```

**What happens when building:**
1. Downloads Python 3.11 base image (~200 MB)
2. Installs system libraries (for image processing)
3. Installs all Python packages from `requirements.txt`
4. Copies your application code
5. Creates a ready-to-run image (~1.5 GB total)

#### 2. **docker-compose.yml** (Orchestrator)

This file defines and manages multiple services (containers) together:

```yaml
services:
  api:                          # First service: FastAPI backend
    build: .                    # Build from Dockerfile
    command: python deploy.py   # Run API server
    ports:
      - "9557:9557"            # Map container port to host
    env_file: .env             # Load environment variables
    volumes:
      - ./report:/app/report   # Share files with host
      
  web:                         # Second service: Streamlit UI
    build: .                   # Same image as API
    command: streamlit run src/main.py
    ports:
      - "8501:8501"
    env_file: .env
    volumes:
      - ./report:/app/report
```

**What it does:**
- Defines 2 containers (API + Web)
- Both use the same base image
- Each runs a different command
- Shares the `./report` folder between containers and your computer
- Loads API keys from `.env` file

#### 3. **.dockerignore** (Efficiency)

Tells Docker which files to ignore during build:

```
myenv/              # Don't copy virtual environment
__pycache__/        # Don't copy Python cache
.git/               # Don't copy git history
.env                # Don't copy secrets into image
```

**Why this matters:**
- Faster builds (less data to copy)
- Smaller images (no unnecessary files)
- Security (API keys not baked into image)

#### 4. **Volumes** (Data Persistence)

Volumes connect folders on your computer to folders inside containers:

```yaml
volumes:
  - ./report:/app/report    # Host folder : Container folder
  - ./.cache:/app/.cache
```

**How it works:**
```
Your Computer                    Container
─────────────                    ─────────
./report/                   →    /app/report/
├── analysis1.json               ├── analysis1.json
└── analysis2.json               └── analysis2.json

Changes in either location appear in both!
```

**Benefits:**
- Data survives container restarts
- Easy access to generated reports
- Cache improves performance and reduces API costs

#### 5. **Environment Variables** (Configuration)

The `.env` file stores configuration and secrets:

```bash
GOOGLE_API_KEY=AIzaSyC...    # Required for AI analysis
API_PORT=9557                # Change if port conflicts
STREAMLIT_PORT=8501
```

**How it's loaded:**
1. Docker reads `.env` file
2. Variables injected into containers
3. Python code accesses via `os.getenv("GOOGLE_API_KEY")`

**Security note:** `.env` is in `.gitignore` so API keys never get committed to git.

---

## Step-by-Step Setup Guide

### Prerequisites

**1. Install Docker Desktop**

Choose your platform:

- **macOS:** https://docs.docker.com/desktop/install/mac-install/
- **Windows:** https://docs.docker.com/desktop/install/windows-install/
- **Linux:** https://docs.docker.com/engine/install/

Or use Homebrew (macOS):
```bash
brew install --cask docker
```

**2. Verify Docker Installation**

```bash
# Check Docker version
docker --version
# Output: Docker version 24.0.x

# Check Docker Compose
docker compose version
# Output: Docker Compose version v2.x.x

# Check Docker is running
docker ps
# Should show empty list (no error)
```

### Setup Process

#### Step 1: Navigate to Project

```bash
cd /path/to/psydraw_fork-main
```

#### Step 2: Run Automated Setup

```bash
./setup.sh
```

**What this script does:**
1. ✅ Checks if Docker is installed
2. ✅ Verifies Docker daemon is running
3. ✅ Creates `.env` file from template
4. ✅ Prompts you to add API key
5. ✅ Builds Docker images

**Expected output:**
```
🚀 PsyDraw Docker Setup
=======================

✅ Docker is installed: Docker version 24.0.7
✅ Docker daemon is running
✅ Docker Compose is available: Docker Compose version v2.23.0

📝 Creating .env file from template...
✅ .env file created

⚠️  IMPORTANT: Edit .env and add your GOOGLE_API_KEY
   Get your key from: https://makersuite.google.com/app/apikey

Press Enter after you've added your API key to .env...
```

#### Step 3: Add Your API Key

**Get a Google API Key:**
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key (starts with `AIza...`)

**Edit `.env` file:**
```bash
nano .env
# or
code .env
# or use any text editor
```

**Replace the placeholder:**
```bash
# Before
GOOGLE_API_KEY=your_google_api_key_here

# After
GOOGLE_API_KEY=AIzaSyC-xxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Save and close** the file.

#### Step 4: Build Images (if not done by setup.sh)

```bash
make build
# or
docker compose build
```

**What happens during build:**
```
[+] Building 245.3s (12/12) FINISHED
 => [internal] load build definition
 => [internal] load .dockerignore
 => [1/7] FROM docker.io/library/python:3.11-slim
 => [2/7] RUN apt-get update && apt-get install...
 => [3/7] COPY requirements.txt /app/requirements.txt
 => [4/7] RUN pip install --upgrade pip...
 => [5/7] RUN pip install --no-cache-dir -r requirements.txt
 => [6/7] COPY . /app
 => [7/7] RUN mkdir -p /app/report /app/.cache
 => exporting to image
```

This takes 3-10 minutes on first build (downloads and installs everything).

#### Step 5: Start Services

```bash
make up
# or
docker compose up -d
```

**Expected output:**
```
🚀 Starting PsyDraw services...
[+] Running 2/2
 ✔ Container psydraw-api   Started
 ✔ Container psydraw-web   Started

✅ Services started!
   Web UI:   http://localhost:8501
   API:      http://localhost:9557
   API Docs: http://localhost:9557/docs
```

#### Step 6: Verify Services

```bash
make status
# or
docker compose ps
```

**Should show:**
```
NAME              IMAGE              STATUS         PORTS
psydraw-api       psydraw-api        Up 30 seconds  0.0.0.0:9557->9557/tcp
psydraw-web       psydraw-web        Up 30 seconds  0.0.0.0:8501->8501/tcp
```

**Check logs:**
```bash
make logs
# or
docker compose logs -f
```

---

## Using the Application

### Access Points

Once services are running:

#### 1. **Web UI (Streamlit)** - User-Friendly Interface

**URL:** http://localhost:8501

**Features:**
- 🎨 **Online Board:** Draw HTP (House-Tree-Person) images directly in browser
- 📤 **Upload Drawings:** Analyze existing images
- 📊 **Batch Processing:** Analyze multiple drawings at once
- 📝 **View Results:** Interactive reports with mental health insights

**How to use:**
1. Open http://localhost:8501 in your browser
2. Navigate to "HTP Test" or "Online Board" from sidebar
3. Upload or draw your HTP images
4. Click "Analyze"
5. View generated psychological analysis

#### 2. **REST API (FastAPI)** - Programmatic Access

**Base URL:** http://localhost:9557

**API Documentation:** http://localhost:9557/docs (interactive Swagger UI)

**Example API call:**

```bash
# Using curl
curl -X POST "http://localhost:9557/v1/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "image_base64": "base64_encoded_image_here",
    "language": "en"
  }'
```

```python
# Using Python
import requests
import base64

# Read and encode image
with open("drawing.jpg", "rb") as f:
    image_data = base64.b64encode(f.read()).decode()

# Send to API
response = requests.post(
    "http://localhost:9557/v1/analyze",
    json={
        "image_base64": image_data,
        "language": "en"
    }
)

result = response.json()
print(result)
```

**Available endpoints:**
- `POST /v1/analyze` - Analyze HTP drawing
- `GET /v1/methods` - List available analysis methods
- `GET /health` - Health check endpoint
- `GET /docs` - Interactive API documentation

### Output and Results

**Report Location:**
- All analysis results saved to `./report/` directory
- Persists even if containers are stopped/removed
- Contains JSON files with detailed psychological analysis

**Cache Location:**
- LLM responses cached in `./.cache/` directory
- Speeds up repeated analysis
- Reduces API costs

---

## Common Commands

### Using Makefile (Recommended)

```bash
# Get help (shows all commands)
make help

# Setup and building
make setup          # Initial setup with checks
make build          # Build Docker images

# Running services
make up             # Start all services (detached mode)
make down           # Stop all services
make restart        # Restart all services

# Monitoring
make logs           # View logs from all services (live)
make logs-api       # View only API logs
make logs-web       # View only Web UI logs
make status         # Show container status

# Maintenance
make clean          # Stop and remove containers + volumes
make rebuild        # Clean rebuild from scratch
make test           # Test if services are responding
```

### Using Docker Compose Directly

```bash
# Start services
docker compose up -d                    # Detached mode (background)
docker compose up                       # Attached mode (see logs)

# Stop services
docker compose down                     # Stop and remove containers
docker compose down -v                  # Also remove volumes

# View logs
docker compose logs                     # All logs
docker compose logs -f                  # Follow logs (live)
docker compose logs -f api              # Only API logs
docker compose logs -f --tail=100 web   # Last 100 lines from web

# Container management
docker compose ps                       # List containers
docker compose restart api              # Restart specific service
docker compose stop                     # Stop without removing
docker compose start                    # Start stopped containers

# Execute commands in containers
docker compose exec api bash            # Open bash in API container
docker compose exec web python --version # Run command in web container

# Building
docker compose build                    # Build/rebuild images
docker compose build --no-cache         # Build from scratch
docker compose up --build               # Build and start in one command
```

### Using Docker Commands Directly

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View logs
docker logs psydraw-api
docker logs -f psydraw-web              # Follow logs

# Execute commands
docker exec -it psydraw-api bash        # Interactive shell
docker exec psydraw-api python --version

# Stop/start containers
docker stop psydraw-api psydraw-web
docker start psydraw-api psydraw-web

# Remove containers
docker rm psydraw-api psydraw-web

# List images
docker images

# Remove images
docker rmi psydraw_fork-main-api
docker rmi psydraw_fork-main-web

# View resource usage
docker stats                            # Live stats
docker system df                        # Disk usage
```

---

## Troubleshooting

### Docker Not Installed

**Symptom:**
```bash
bash: docker: command not found
```

**Solution:**
1. Install Docker Desktop from https://www.docker.com/products/docker-desktop
2. Or use Homebrew: `brew install --cask docker`
3. Verify: `docker --version`

### Docker Daemon Not Running

**Symptom:**
```bash
Cannot connect to the Docker daemon
```

**Solution:**
1. Open Docker Desktop application
2. Wait for Docker icon to appear in menu bar (Mac) or system tray (Windows)
3. Verify: `docker ps` should work without error

### Port Already in Use

**Symptom:**
```
Error: bind: address already in use
```

**Solution:**

**Option 1: Change ports in `.env`**
```bash
# Edit .env
API_PORT=9558          # Changed from 9557
STREAMLIT_PORT=8502    # Changed from 8501
```

**Option 2: Find and stop conflicting process**
```bash
# macOS/Linux
lsof -i :9557
lsof -i :8501

# Kill the process
kill -9 <PID>
```

### Missing API Key

**Symptom:**
```
Error: GOOGLE_API_KEY environment variable not set
```

**Solution:**
1. Check `.env` file exists: `ls -la .env`
2. Open and edit: `nano .env`
3. Ensure line reads: `GOOGLE_API_KEY=AIza...` (your actual key)
4. Restart services: `make restart`

### Build Failures

**Symptom:**
```
ERROR [5/7] RUN pip install -r requirements.txt
```

**Solution:**
```bash
# Clean rebuild
make rebuild

# Or manually
docker compose down -v
docker system prune -a
docker compose build --no-cache
docker compose up -d
```

### Container Crashes Immediately

**Check logs:**
```bash
docker compose logs api
docker compose logs web
```

**Common issues:**
- Invalid API key
- Port conflicts
- Missing dependencies (rebuild image)

**Solution:**
```bash
# View detailed logs
docker compose logs --tail=100

# Check container status
docker compose ps

# Restart with logs visible
docker compose up
```

### Services Not Responding

**Symptom:**
```bash
curl http://localhost:9557/health
# curl: (7) Failed to connect
```

**Diagnosis:**
```bash
# Check if containers are running
docker compose ps

# Check logs for errors
make logs

# Test from inside container
docker compose exec api curl localhost:9557/health
```

**Solution:**
```bash
# Restart services
make restart

# Or full reset
make clean
make up
```

### Slow Performance / High Resource Usage

**Check resource usage:**
```bash
docker stats
```

**Solutions:**
1. Increase Docker Desktop resource limits (Preferences → Resources)
2. Clear cache: `rm -rf ./.cache/*`
3. Limit concurrent requests in batch processing

### Permission Denied on ./setup.sh

**Symptom:**
```bash
bash: ./setup.sh: Permission denied
```

**Solution:**
```bash
chmod +x setup.sh
./setup.sh
```

### Network Issues (Can't Access API)

**From host machine:**
```bash
# Should work
curl http://localhost:9557/health
```

**From inside container:**
```bash
# Enter container
docker compose exec api bash

# Test internally
curl http://localhost:9557/health
```

**If external access fails but internal works:**
- Check firewall settings
- Verify port mapping in `docker-compose.yml`
- Try `http://127.0.0.1:9557` instead of `localhost`

---

## Advanced Usage

### Running Specific Services

```bash
# Start only API
docker compose up api -d

# Start only Web UI
docker compose up web -d
```

### Custom Ports

Edit `.env`:
```bash
API_PORT=8000
STREAMLIT_PORT=8080
```

Then restart:
```bash
make restart
```

### Development Mode (Live Code Updates)

Edit `docker-compose.yml` to add volume mounts:

```yaml
services:
  api:
    volumes:
      - ./src:/app/src:ro         # Mount source code (read-only)
      - ./report:/app/report
      
  web:
    volumes:
      - ./src:/app/src            # Mount source code (read-write)
      - ./assets:/app/assets
      - ./report:/app/report
```

**Benefits:**
- Code changes reflected immediately
- No need to rebuild image for Python changes
- Faster development iteration

**Restart to apply:**
```bash
docker compose down
docker compose up -d
```

### Viewing Resource Usage

```bash
# Live stats
docker stats

# Disk usage
docker system df

# Detailed info
docker system df -v
```

### Cleaning Up Disk Space

```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a --volumes

# Be careful with this! It removes ALL Docker data
```

### Accessing Container Shell

```bash
# Open bash in API container
docker compose exec api bash

# Now you're inside the container
root@abc123:/app# ls
root@abc123:/app# python --version
root@abc123:/app# pip list
root@abc123:/app# exit
```

### Running Tests Inside Container

```bash
# Run Python tests
docker compose exec api python -m pytest

# Check Python environment
docker compose exec api pip list

# Run specific script
docker compose exec api python run.py --help
```

### Backup and Restore Data

**Backup reports:**
```bash
# Reports are already on your host machine in ./report/
tar -czf reports-backup.tar.gz ./report/
```

**Restore reports:**
```bash
tar -xzf reports-backup.tar.gz
```

### Production Deployment

For production use:

1. **Use Docker secrets** instead of `.env` file
2. **Add nginx reverse proxy** for SSL/TLS
3. **Implement health checks** in docker-compose.yml
4. **Set resource limits:**

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

5. **Enable logging driver:**

```yaml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Multi-Architecture Builds

For deployment on different CPU architectures (e.g., ARM-based servers):

```bash
# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 -t psydraw:latest .
```

---

## Summary

### What You've Learned

✅ **What Docker is** and why it's useful  
✅ **How PsyDraw is dockerized** (architecture, components)  
✅ **How to set up** the Docker environment  
✅ **How to use** the API and Web UI  
✅ **Common commands** for daily operations  
✅ **How to troubleshoot** common issues  
✅ **Advanced techniques** for development and production  

### Quick Reference Card

```bash
# Setup (once)
./setup.sh
# Edit .env with your GOOGLE_API_KEY

# Daily use
make up              # Start
make logs            # Watch logs
make down            # Stop

# Access
http://localhost:8501    # Web UI
http://localhost:9557    # API
```

### Getting Help

- **View all commands:** `make help`
- **Check Docker docs:** https://docs.docker.com
- **View API docs:** http://localhost:9557/docs (when running)
- **Check container logs:** `make logs`

---

## Additional Resources

- **Docker Documentation:** https://docs.docker.com
- **Docker Compose Documentation:** https://docs.docker.com/compose
- **Google Gemini API:** https://ai.google.dev/docs
- **FastAPI Documentation:** https://fastapi.tiangolo.com
- **Streamlit Documentation:** https://docs.streamlit.io

---

**Happy Dockerizing! 🐳**
