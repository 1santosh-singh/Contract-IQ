# PowerShell script to build Contract IQ Docker images

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Building Contract IQ Images" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env files exist
if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found at project root" -ForegroundColor Red
    Write-Host "Please create .env file with backend environment variables" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "packages/frontend/.env")) {
    Write-Host "ERROR: packages/frontend/.env file not found" -ForegroundColor Red
    Write-Host "Please create packages/frontend/.env file with frontend environment variables" -ForegroundColor Yellow
    exit 1
}

# Load environment variables from .env file
Write-Host "Loading environment variables..." -ForegroundColor Yellow
$envVars = Get-Content .env | Where-Object { $_ -notmatch '^#' -and $_ -match '=' }
foreach ($line in $envVars) {
    if ($line -match "(.+?)=(.+)") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

$frontendEnvVars = Get-Content packages/frontend/.env | Where-Object { $_ -notmatch '^#' -and $_ -match '=' }
foreach ($line in $frontendEnvVars) {
    if ($line -match "(.+?)=(.+)") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

Write-Host "Building backend image..." -ForegroundColor Cyan
Set-Location packages/backend
docker build -t contract-iq-backend:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend image built successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Backend image build failed" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

Set-Location ../..

Write-Host ""
Write-Host "Building frontend image..." -ForegroundColor Cyan
Set-Location packages/frontend

$supabaseUrl = $env:NEXT_PUBLIC_SUPABASE_URL
$supabaseKey = $env:NEXT_PUBLIC_SUPABASE_ANON_KEY
$backendUrl = $env:NEXT_PUBLIC_BACKEND_URL
if ([string]::IsNullOrEmpty($backendUrl)) {
    $backendUrl = "http://localhost:8000"
}

docker build `
  --build-arg NEXT_PUBLIC_SUPABASE_URL="$supabaseUrl" `
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="$supabaseKey" `
  --build-arg NEXT_PUBLIC_BACKEND_URL="$backendUrl" `
  -t contract-iq-frontend:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend image built successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend image build failed" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

Set-Location ../..

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ All images built successfully!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Built images:" -ForegroundColor Yellow
docker images | Select-String "contract-iq"
Write-Host ""
Write-Host "To run locally:" -ForegroundColor Yellow
Write-Host "  docker-compose up --build"
Write-Host ""



