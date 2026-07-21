# --- STAGE 1: Build Stage ---
FROM python:3.11-slim AS builder

WORKDIR /build

# Install OS-level build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc && \
    rm -rf /var/lib/apt/lists/*

# Optmize layer caching
COPY requirements.txt .

RUN pip install --user --no-cache-dir -r requirements.txt


# --- STAGE 1b: Test Stage (Shift-Left Testing) ---
FROM builder AS tester

WORKDIR /build
COPY . .
RUN pip install --user --no-cache-dir pytest && \
    python -m pytest --maxfail=1 --disable-warnings -q


# --- STAGE 2: Runtime Stage ---
FROM python:3.11-slim AS runner

#Define non-root user
RUN groupadd -g 10001 appgroup && \
    useradd -u 10000 -g appgroup -m -s /bin/bash appuser

WORKDIR /app

# Copy only the installed dependencies from the builder stage
COPY --from=builder --chown=appuser:appgroup /root/.local /home/appuser/.local
COPY --chown=appuser:appgroup . .

# Ensure binaries are in the path for the non-root user
ENV PATH=/home/appuser/.local/bin:$PATH

USER appuser

EXPOSE 8000

ENTRYPOINT [ "python", "app.py" ]

