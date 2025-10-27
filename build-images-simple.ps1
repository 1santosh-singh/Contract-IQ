# Simple Docker build script for Contract IQ
# Make sure Docker Desktop is running!

Write-Host "Building Contract IQ Docker Images" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
$dockerRunning = docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# Build Backend
Write-Host "Building backend image..." -ForegroundColor Yellow
cd packages\backend
docker build -t contract-iq-backend:latest .
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend image built successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Backend build failed" -ForegroundColor Red
    cd ..\..
    exit 1
}
cd ..\..

# Build Frontend
Write-Host "Building frontend image..." -ForegroundColor Yellow
cd packages\frontend

# Read from .env.local
$envContent = Get-Content .env.local | Where-Object { $_ -notmatch '^#' -and $_ -match '=' }
$supabaseUrl = ""
$supabaseKey = ""
$backendUrl = "http://localhost:8000"

foreach ($line in $envContent) {
    if ($line -match "NEXT_PUBLIC_SUPABASE_URL=(.+)") {
        $supabaseUrl = $matches[1].Trim()
    }
    if ($line -match "NEXT_PUBLIC_SUPABASE_ANON_KEY=(.+)") {
        $supabaseKey = $matches[1].Trim()
    }
    if ($line -match "NEXT_PUBLIC_BACKEND_URL=(.+)") {
        $backendUrl = $matches[1].Trim()
    }
}

Write-Host "Building with:"
Write-Host "  Supabase URL: $supabaseUrl"
Write-Host "  Backend URL: $backendUrl"

docker build --build-arg NEXT_PUBLIC_SUPABASE_URL="$supabaseUrl" --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="$supabaseKey" --build-arg NEXT_PUBLIC_BACKEND_URL="$backendUrl" -t contract-iq-frontend:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend image built successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend build failed" -ForegroundColor Red
    cd ..\..
    exit 1
}
cd ..\..

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "✅ All images built successfully!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Built images:" -ForegroundColor Yellow
docker images contract-iq-backend
docker images contract-iq-frontend
Write-Host ""
Write-Host "To run with Docker Compose:" -ForegroundColor Yellow
Write-Host "  docker-compose up --build" -ForegroundColor White
Write-Host ""


