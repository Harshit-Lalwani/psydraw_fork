# ⚡ PsyDraw - Ultra Quick Start

## One Command to Rule Them All! 🚀

```bash
make all
```

**That's literally it!**

This command will:
1. ✅ Check if Docker is installed and running
2. ✅ Create `.env` file from template
3. ✅ Build Docker images
4. ✅ Start both API and Web UI services

---

## First Time Setup

### Prerequisites
- Docker Desktop installed ([Get it here](https://www.docker.com/products/docker-desktop))
- Google API key ([Get one here](https://makersuite.google.com/app/apikey))

### Step 1: Get Your API Key
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google
3. Click "Create API Key"
4. Copy the key (starts with `AIza...`)

### Step 2: Add API Key to .env
```bash
# Edit the .env file
nano .env

# Or use any editor
code .env
```

Replace this line:
```
GOOGLE_API_KEY=your_google_api_key_here
```

With your actual key:
```
GOOGLE_API_KEY=AIzaSyC-xxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Save and close.

### Step 3: Run Everything
```bash
make all
```

Wait 3-10 minutes for first-time build...

---

## Access Your Application

Once you see "🎉 PsyDraw is now running!", open:

- **Web UI:** http://localhost:8501
- **API:** http://localhost:9557
- **API Docs:** http://localhost:9557/docs

---

## Common Commands

```bash
make all        # Setup + build + start (do everything!)
make up         # Start services
make down       # Stop services
make logs       # View logs
make status     # Check what's running
make restart    # Restart everything
make clean      # Stop and remove everything
make help       # Show all commands
```

---

## Troubleshooting

### "docker: command not found"
- Install Docker Desktop: https://www.docker.com/products/docker-desktop
- Or use Homebrew: `brew install --cask docker`

### "Cannot connect to Docker daemon"
- Open Docker Desktop and wait for it to start
- Look for Docker icon in menu bar (Mac) or system tray (Windows)

### "Port already in use"
Edit `.env` and change ports:
```bash
API_PORT=9558
STREAMLIT_PORT=8502
```

### "GOOGLE_API_KEY not set"
- Make sure `.env` file exists
- Make sure you added your actual API key (not the placeholder)
- Restart: `make restart`

### Services crash/restart
Check logs:
```bash
make logs
```

---

## Need More Help?

- **Complete guide:** See `DOCKER_GUIDE.md`
- **Docker basics:** See `README.Docker.md`
- **View all commands:** `make help`

---

**That's all you need to know! Just run `make all` and you're good to go! 🎉**
