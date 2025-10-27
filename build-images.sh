#!/bin/bash
# Build script for Contract IQ Docker images

echo "================================"
echo "Building Contract IQ Images"
echo "================================"
echo ""

# Load environment variables
if [ ! -f .env ]; then
    echo "ERROR: .env file not found at project root"
    echo "Please create .env file with backend environment variables"
    exit 1
fi

if [ ! -f packages/frontend/.env ]; then
    echo "ERROR: packages/frontend/.env file not found"
    echo "Please create packages/frontend/.env file with frontend environment variables"
    exit 1
fi

# Source environment variables
export $(cat .env | grep -v '^#' | xargs)
export $(cat packages/frontend/.env | grep -v '^#' | xargs)

echo "📦 Step 1: Building Backend Image..."
echo ""
cd packages/backend
docker build -t contract-iq-backend:latest .
if [ $? -eq 0 ]; then
    echo "✅ Backend image built successfully!"
else
    echo "❌ Backend image build failed"
    exit 1
fi
cd ../..

echo ""
echo "📦 Step 2: Building Frontend Image..."
echo ""
cd packages/frontend
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL}" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY}" \
  --build-arg NEXT_PUBLIC_BACKEND_URL="${NEXT_PUBLIC_BACKEND_URL:-http://localhost:8000}" \
  -t contract-iq-frontend:latest .

if [ $? -eq 0 ]; then
    echo "✅ Frontend image built successfully!"
else
    echo "❌ Frontend image build failed"
    exit 1
fi
cd ../..

echo ""
echo "================================"
echo "✅ All images built successfully!"
echo "================================"
echo ""
echo "Built images:"
docker images | grep contract-iq
echo ""
echo "To run locally:"
echo "  Backend:  docker run -p 8000:8000 --env-file .env contract-iq-backend"
echo "  Frontend: docker run -p 3000:3000 --env-file packages/frontend/.env contract-iq-frontend"



