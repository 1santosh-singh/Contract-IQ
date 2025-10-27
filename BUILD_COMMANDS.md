# Docker Image Build Commands

This document provides step-by-step commands to build Docker images for Contract IQ.

## Prerequisites

Before building, ensure you have:
1. ✅ Created `.env` file at project root (backend variables)
2. ✅ Created `packages/frontend/.env` file (frontend variables)
3. ✅ Docker installed and running

See `ENV_EXAMPLES.md` for environment variable reference.

## Quick Build (Using Script)

```bash
# Make script executable (Linux/Mac)
chmod +x build-images.sh

# Run build script
./build-images.sh
```

## Manual Build Commands

### Step 1: Load Environment Variables

#### Windows (PowerShell):
```powershell
# Load backend variables
$backendEnv = Get-Content .env | ForEach-Object { $_ }
$backendEnv | ForEach-Object { if ($_ -match "^([^=]+)=(.*)$") { [Environment]::SetEnvironmentVariable($matches[1], $matches[2]) } }

# Load frontend variables
$frontendEnv = Get-Content packages/frontend/.env | ForEach-Object { $_ }
$frontendEnv | ForEach-Object { if ($_ -match "^([^=]+)=(.*)$") { [Environment]::SetEnvironmentVariable($matches[1], $matches[2]) } }
```

#### Linux/Mac:
```bash
# Load backend variables
export $(cat .env | grep -v '^#' | xargs)

# Load frontend variables
export $(cat packages/frontend/.env | grep -v '^#' | xargs)
```

### Step 2: Build Backend Image

```bash
cd packages/backend

docker build -t contract-iq-backend:latest .
```

**Verify build:**
```bash
docker images contract-iq-backend
```

**Expected output:**
```
REPOSITORY             TAG       IMAGE ID       CREATED          SIZE
contract-iq-backend    latest    <image-id>     <time>          <size>
```

### Step 3: Build Frontend Image

```bash
cd ../../packages/frontend

docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="your_supabase_url" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="your_anon_key" \
  --build-arg NEXT_PUBLIC_BACKEND_URL="http://localhost:8000" \
  -t contract-iq-frontend:latest .
```

**Or using environment variables** (if loaded):
```bash
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL}" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
  --build-arg NEXT_PUBLIC_BACKEND_URL="${NEXT_PUBLIC_BACKEND_URL:-http://localhost:8000}" \
  -t contract-iq-frontend:latest .
```

**Verify build:**
```bash
docker images contract-iq-frontend
```

## Run Images Locally

### Run Backend Container

```bash
docker run -d \
  --name contract-iq-backend \
  -p 8000:8000 \
  --env-file ../../.env \
  contract-iq-backend:latest
```

**Test backend:**
```bash
curl http://localhost:8000/health
```

### Run Frontend Container

```bash
docker run -d \
  --name contract-iq-frontend \
  -p 3000:3000 \
  --env-file .env \
  contract-iq-frontend:latest
```

**Test frontend:** Open http://localhost:3000

## Using Docker Compose (Recommended for Local)

```bash
cd ../..  # Back to project root
docker-compose up --build
```

## Commands Summary

```bash
# Build backend
cd packages/backend && docker build -t contract-iq-backend . && cd ../..

# Build frontend (replace with your actual values)
cd packages/frontend && docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="your_url" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="your_key" \
  --build-arg NEXT_PUBLIC_BACKEND_URL="http://localhost:8000" \
  -t contract-iq-frontend . && cd ../..

# View built images
docker images | grep contract-iq

# Remove old images (if rebuilding)
docker rmi contract-iq-backend contract-iq-frontend

# Remove all unused images
docker image prune -a
```

## Tag and Push to Registry (Optional)

If you want to push to a Docker registry:

```bash
# Tag images
docker tag contract-iq-backend:latest your-registry/contract-iq-backend:latest
docker tag contract-iq-frontend:latest your-registry/contract-iq-frontend:latest

# Push to registry
docker push your-registry/contract-iq-backend:latest
docker push your-registry/contract-iq-frontend:latest
```

## Troubleshooting

### Build fails with "ERROR: Could not find a file"
- Ensure you're in the correct directory
- Check that all files exist in the directory

### Build fails with "build arguments"
- Ensure all `--build-arg` values are provided
- Check for typos in environment variable names

### Image too large
- This is normal for ML models (backend includes PyTorch)
- Backend: ~2-3GB
- Frontend: ~200-300MB

### Permission denied
- On Linux/Mac, use `chmod +x build-images.sh`
- On Windows, PowerShell should work



