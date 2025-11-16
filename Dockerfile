FROM python:3.11-slim

# Keep Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies required by some Python packages (Pillow, numpy, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install --no-cache-dir -r /app/requirements.txt

# Copy application source
COPY . /app

# Create directories for outputs and cache
RUN mkdir -p /app/report /app/.cache /app/scripts

# Make scripts executable
RUN chmod +x /app/scripts/*.sh 2>/dev/null || true

# Default command - ready for direct invocation
CMD ["bash"]
