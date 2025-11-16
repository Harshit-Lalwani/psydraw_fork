.PHONY: help all setup setup-auto build up down restart logs status clean test-htp test-htp-local install-local

# Default target - Full setup and test
all: setup-auto build up test-htp
	@echo ""
	@echo "🎉 PsyDraw is fully operational!"
	@echo "================================"
	@echo ""
	@echo "✅ Container is ready for direct invocation"
	@echo "✅ HTP analysis tests completed!"
	@echo ""
	@echo "📊 View test results:"
	@echo "   ls report/test_example*.json"
	@echo ""
	@echo "📋 Useful commands:"
	@echo "   make logs       - View container logs"
	@echo "   make status     - Check container status"
	@echo "   make down       - Stop container"
	@echo "   make restart    - Restart container"
	@echo "   make test-htp   - Run HTP analysis tests again"
	@echo ""
	@echo "💡 Run analysis:"
	@echo "   docker compose exec psydraw python run.py --image_file example/example1.jpg --save_path report/output.json --language en"
	@echo ""

help:
	@echo "PsyDraw Docker Commands"
	@echo "======================="
	@echo ""
	@echo "🚀 Quick Start:"
	@echo "  make all             - Do everything: setup, build, start, and run HTP tests"
	@echo ""
	@echo "Setup & Build:"
	@echo "  make setup           - Run initial setup (checks Docker, creates .env)"
	@echo "  make build           - Build Docker image"
	@echo "  make install-local   - Install Python deps locally (for development)"
	@echo ""
	@echo "Running:"
	@echo "  make up              - Start container"
	@echo "  make down            - Stop container"
	@echo "  make restart         - Restart container"
	@echo ""
	@echo "Testing:"
	@echo "  make test-htp        - Run HTP analysis tests (in Docker)"
	@echo "  make test-htp-local  - Run HTP tests locally (requires install-local)"
	@echo ""
	@echo "Monitoring:"
	@echo "  make logs            - View container logs"
	@echo "  make status          - Show container status"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean           - Stop and remove container, volumes"
	@echo "  make rebuild         - Clean rebuild from scratch"
	@echo ""
	@echo "⚡ Quick Start (Easiest):"
	@echo "  1. make all          - Does everything in one command!"
	@echo ""
	@echo "📝 Manual Steps:"
	@echo "  1. make setup        - Initial setup"
	@echo "  2. Edit .env and add your GOOGLE_API_KEY"
	@echo "  3. make build        - Build image"
	@echo "  4. make up           - Start container"
	@echo "  5. make test-htp     - Run HTP tests"
	@echo ""
	@echo "💻 Local Development (without Docker):"
	@echo "  1. make install-local - Install dependencies"
	@echo "  2. Edit .env and add your GOOGLE_API_KEY"
	@echo "  3. make test-htp-local - Run tests locally"
	@echo ""
	@echo "💡 Direct Invocation:"
	@echo "  docker compose exec psydraw python run.py --image_file example/example1.jpg --save_path report/output.json --language en"

# Run setup script (non-interactive for 'make all')
setup-auto:
	@bash setup.sh --non-interactive

# Run setup script (interactive)
setup:
	@bash setup.sh

# Build images
build:
	docker compose build

# Start container
up:
	@echo "🚀 Starting PsyDraw container..."
	docker compose up -d
	@echo ""
	@echo "✅ Container started!"
	@echo "   Container: psydraw"
	@echo ""
	@echo "💡 Run analysis:"
	@echo "   docker compose exec psydraw python run.py --image_file example/example1.jpg --save_path report/output.json --language en"
	@echo "   Or use 'make test-htp' to run test suite"

# Stop services
down:
	docker compose down

# Restart services
restart:
	docker compose restart

# View logs
logs:
	docker compose logs -f

# Show container status
status:
	docker compose ps

# Clean up everything
clean:
	docker compose down -v
	@echo "✅ Container and volumes removed"

# Rebuild from scratch
rebuild: clean
	docker compose build --no-cache
	@echo "✅ Rebuild complete. Run 'make up' to start."

# Run HTP analysis tests inside Docker container (recommended)
test-htp:
	@chmod +x scripts/run-htp-tests.sh
	@docker compose exec -T psydraw bash /app/scripts/run-htp-tests.sh

# Run HTP tests locally (requires local Python dependencies)
test-htp-local:
	@echo "🧪 Running HTP analysis tests locally..."
	@echo "⚠️  Warning: This requires local Python dependencies"
	@echo "   Install with: make install-local"
	@echo ""
	@mkdir -p report
	@echo "📝 Testing with example1.jpg..."
	@python3 run.py --image_file example/example1.jpg --save_path report/test_example1_result.json --language en && echo "✅ Example 1 passed" || echo "❌ Example 1 failed"
	@echo "📝 Testing with example2.jpg..."
	@python3 run.py --image_file example/example2.jpg --save_path report/test_example2_result.json --language en && echo "✅ Example 2 passed" || echo "❌ Example 2 failed"
	@echo "📝 Testing with example3.jpg..."
	@python3 run.py --image_file example/example3.jpg --save_path report/test_example3_result.json --language en && echo "✅ Example 3 passed" || echo "❌ Example 3 failed"
	@echo ""
	@echo "✅ HTP tests completed! Check report/ directory for results."

# Install dependencies locally (for development without Docker)
install-local:
	@echo "📦 Installing Python dependencies locally..."
	@pip3 install -r requirements.txt
	@echo "✅ Dependencies installed!"
	@echo ""
	@echo "💡 You can now run: make test-htp-local"
