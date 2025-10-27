# Simple Build Commands - One by One

## ⚠️ Prerequisites
- ✅ Docker Desktop is running
- ✅ .env.local files exist at root and in packages/frontend

## Quick Build (Easiest)

### Option 1: Using the Script
```powershell
# Run this single command from project root:
.\build-images-simple.ps1
```

## Manual Build (Step by Step)

### Step 1: Build Backend Image
```powershell
cd packages\backend
docker build -t contract-iq-backend:latest .
cd ..\..
```

### Step 2: Build Frontend Image
```powershell
cd packages\frontend

# Read your Supabase values from .env.local
# Then run (replace with your actual values):
docker build `
  --build-arg NEXT_PUBLIC_SUPABASE_URL="https://your-project.supabase.co" `
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="your-anon-key-here" `
  --build-arg NEXT_PUBLIC_BACKEND_URL="http://localhost:8000" `
  -t contract-iq-frontend:latest .

cd ..\..
```

**Or** to use values from your .env.local automatically:
```powershell
cd packages\frontend

# Read environment variables
$envContent = Get-Content .env.local
$supabaseUrl = ($envContent | Select-String "NEXT_PUBLIC_SUPABASE_URL=").ToString().Split('=')[1]
$supabaseKey = ($envContent | Select-String "NEXT_PUBLIC_SUPABASE_ANON_KEY=").ToString().Split('=')[1]

docker build `
  --build-arg NEXT_PUBLIC_SUPABASE_URL="$supabaseUrl" `
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="$supabaseKey" `
  --build-arg NEXT_PUBLIC_BACKEND_URL="http://localhost:8000" `
  -t contract-iq-frontend:latest .

cd ..\..
```

### Step 3: Verify Images
```powershell
docker images contract-iq-backend
docker images contract-iq-frontend
```

### Step 4: Run Locally
```powershell
# Using Docker Compose (recommended)
docker-compose up --build

# Or manually:
# Terminal 1 - Backend
docker run -p 8000:8000 --env-file .env.local contract-iq-backend

# Terminal 2 - Frontend  
docker run -p 3000:3000 --env-file packages\frontend\.env.local contract-iq-frontend
```

## Verify Images are Working

After building, you can view the images:
```powershell
docker images | findstr contract-iq
```

You should see:
```
contract-iq-backend     latest    <image-id>    <time>    <size>
contract-iq-frontend    latest    <image-id>    <time>    <size>
```

## Troubleshooting

**Docker not running?**
```powershell
# Start Docker Desktop first, then retry
```

**Build fails?**
```powershell
# Check you're in the right directory
cd "E:\Contract IQ\packages\backend"

# Build backend again
docker build -t contract-iq-backend:latest .
```

**Frontend build fails?**
- Make sure .env.local exists in packages/frontend
- Check that NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY are set
- Verify values don't have extra spaces or quotes



