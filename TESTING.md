# 🧪 Testing Guide for PsyDraw

## Quick Start - Test Everything at Once

```bash
make all
```

This command will:
1. ✅ Setup environment and check prerequisites
2. ✅ Build Docker images with all dependencies
3. ✅ Start API and Web UI services
4. ✅ Wait for services to become healthy
5. ✅ Run health checks
6. ✅ Execute HTP analysis tests on 4 example images
7. ✅ Generate detailed JSON reports

## Step-by-Step Testing

### 1. Rebuild Docker Images (if you made changes)

```bash
make rebuild
```

### 2. Start Services

```bash
make up
```

### 3. Wait for Services to be Ready

```bash
make wait-for-services
```

Expected output:
```
⏳ Waiting for services to be ready...

Checking API service...
✅ API is ready

Checking Web UI service...
✅ Web UI is ready

✅ All services are ready!
```

### 4. Run Quick Health Check

```bash
make test
```

Expected output:
```
🔍 Testing services...
✅ API is healthy
✅ Web UI is healthy
```

### 5. Run Full HTP Analysis Tests

```bash
make test-htp
```

This runs tests **inside the Docker container** where all dependencies are installed.

Expected output:
```
🧪 Running HTP analysis tests inside Docker container...

📝 Testing with example1.jpg...
✅ Example 1 passed

📝 Testing with example2.jpg...
✅ Example 2 passed

📝 Testing with example3.jpg...
✅ Example 3 passed

📝 Testing with example4.jpg...
✅ Example 4 passed

================================
📊 Test Results Summary:
   ✅ Passed: 4
   ❌ Failed: 0
   📁 Results saved to: report/
================================

🎉 All HTP tests passed!
```

### 6. Verify Test Results

```bash
ls -lh report/test_example*.json
```

Each file should be a valid JSON containing psychological analysis.

View a result:
```bash
cat report/test_example1_result.json | python3 -m json.tool | head -30
```

## Local Development (Without Docker)

If you want to run tests locally without Docker:

### 1. Install Dependencies Locally

```bash
make install-local
```

This installs all Python packages from `requirements.txt` to your system Python.

### 2. Run Tests Locally

```bash
make test-htp-local
```

⚠️ **Note:** You need to have:
- Python 3.11+ installed
- `.env` file with `GOOGLE_API_KEY` set

## Troubleshooting

### Issue: "No module named 'dotenv'" when running tests

**Cause:** You're running `make test-htp-local` without installing dependencies

**Solution:**
```bash
# Option 1: Use Docker (recommended)
make test-htp

# Option 2: Install dependencies locally
make install-local
make test-htp-local
```

### Issue: Tests fail with "API is not responding"

**Cause:** Services aren't fully started yet

**Solution:**
```bash
# Wait for services
make wait-for-services

# Then run tests
make test-htp
```

### Issue: "Connection refused" errors

**Cause:** Docker containers aren't running

**Solution:**
```bash
# Check container status
make status

# If not running, start them
make up

# Wait for readiness
make wait-for-services
```

### Issue: Tests timeout or take too long

**Cause:** Google API rate limiting or network issues

**Solution:**
1. Check your internet connection
2. Verify your `GOOGLE_API_KEY` in `.env` is valid
3. Check API quota: https://aistudio.google.com/app/apikey
4. View logs for details: `make logs-api`

### Issue: "Example X failed" but no error shown

**Cause:** API returned an error during analysis

**Solution:**
```bash
# View detailed API logs
make logs-api

# Run a single test manually
docker compose exec api python run.py \
  --image_file example/example1.jpg \
  --save_path report/debug_test.json \
  --language en
```

## Viewing Logs

```bash
# All logs
make logs

# Just API logs
make logs-api

# Just Web UI logs
make logs-web
```

## Useful Commands

```bash
make help              # Show all available commands
make status            # Check if containers are running
make restart           # Restart all services
make down              # Stop all services
make clean             # Stop and remove everything
```

## Success Criteria

After running `make all`, you should have:

✅ **Services Running:**
- Web UI accessible at http://localhost:8501
- API accessible at http://localhost:9557
- API docs accessible at http://localhost:9557/docs

✅ **Test Results:**
- 4 JSON files in `report/` directory
- Each file ~2-10KB in size
- Files contain valid JSON with analysis results

✅ **No Errors:**
- No "ModuleNotFoundError" messages
- No "Connection refused" errors
- No container restart loops

## Next Steps After Successful Tests

1. **Access the Web UI:**
   - Open http://localhost:8501
   - Navigate to "HTP Test" page
   - Upload your own drawing
   - Get psychological insights

2. **Use the API:**
   - Visit http://localhost:9557/docs
   - Try the interactive API documentation
   - Make POST requests to `/v1/predict`

3. **View Your Results:**
   ```bash
   # List all test results
   ls -lh report/

   # View a specific result (prettified)
   cat report/test_example1_result.json | python3 -m json.tool
   ```

4. **Stop Services When Done:**
   ```bash
   make down
   ```

5. **Restart Later:**
   ```bash
   make up
   make wait-for-services
   ```

## CI/CD Integration

To integrate these tests in CI/CD pipelines:

```bash
# In GitHub Actions, GitLab CI, etc.
make all

# Check exit code
if [ $? -eq 0 ]; then
  echo "All tests passed!"
else
  echo "Tests failed!"
  exit 1
fi
```

## Performance Benchmarks

Typical execution times on modern hardware:

- `make build`: 2-5 minutes (first time), 10-30s (cached)
- `make up`: 5-10 seconds
- `make wait-for-services`: 10-30 seconds
- `make test-htp`: 2-5 minutes (4 images × 30-60s each)

**Total for `make all`:** ~5-10 minutes (first run), ~3-5 minutes (subsequent)

## Support

If tests still fail after following this guide:

1. Check [DOCKER_GUIDE.md](DOCKER_GUIDE.md) for Docker-specific issues
2. Check [README.md](README.md) for general setup
3. View logs: `make logs`
4. Check GitHub issues
