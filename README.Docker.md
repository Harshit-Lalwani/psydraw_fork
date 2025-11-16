# Docker / Docker Compose — Quick Start

## 🚀 Super Easy Setup (ONE COMMAND!)

**Just run:**

```bash
make all
```

This single command will:
- ✅ Check Docker installation
- ✅ Create `.env` from template
- ✅ Build Docker images
- ✅ Start all services

**⚠️ Important:** Make sure you've added your `GOOGLE_API_KEY` to the `.env` file first!

## Automated Setup (Recommended)

Just run the setup script:

```bash
./setup.sh
```

This will:
- Check if Docker is installed and running
- Create `.env` from template
- Prompt you to add your API key
- Build the Docker images

Then start the services:

```bash
make up
```

## Manual Setup

1. Copy the example env file and fill in your API keys:

```bash
cp .env.example .env
# then edit .env and set GOOGLE_API_KEY (and others as needed)
```

2. Build and start services with Docker Compose:

```bash
docker compose up --build -d
```

## Available Commands (via Makefile)

```bash
make help       # Show all available commands
make setup      # Run initial setup
make up         # Start services
make down       # Stop services
make logs       # View all logs
make logs-api   # View API logs only
make logs-web   # View Web UI logs only
make status     # Show container status
make restart    # Restart services
make clean      # Remove all containers and volumes
make rebuild    # Clean rebuild from scratch
make test       # Test if services are responding
```

## Available Commands (via Makefile)

```bash
make help       # Show all available commands
make setup      # Run initial setup
make up         # Start services
make down       # Stop services
make logs       # View all logs
make logs-api   # View API logs only
make logs-web   # View Web UI logs only
make status     # Show container status
make restart    # Restart services
make clean      # Remove all containers and volumes
make rebuild    # Clean rebuild from scratch
make test       # Test if services are responding
```

## What You Get

This will start two containers:
- API: `http://localhost:9557` (FastAPI)
- Web UI: `http://localhost:8501` (Streamlit)
- API Documentation: `http://localhost:9557/docs`

## Get Your Google API Key

1. Visit https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key and paste it in your `.env` file

## Usage Examples

```bash
# View logs from both services
make logs

# Check if everything is running
make status

# Restart just the API
docker compose restart api

# Stop everything
make down
```

4. Persistent data:
- Analysis reports are stored in the host `./report` directory (mounted into the container).
- Optional cache is stored in `./.cache`.

5. Notes and troubleshooting:
- If ports conflict, override `API_PORT` and `STREAMLIT_PORT` in your `.env` file.
- For production, pass credentials with Docker secrets or a secrets manager instead of plain `.env`.
- The app calls external AI services (Google Gemini). Ensure `GOOGLE_API_KEY` is valid and outbound network access is available.
