# Docker Quick Start Guide

## Prerequisites

✅ Docker installed  
✅ Docker Compose installed  
✅ Environment variables configured (see `ENV_EXAMPLES.md`)

## Quick Start

### 1. Create Environment Files

**Backend** - Create `Contract-IQ/.env`:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
OPENROUTER_API_KEY=your_openrouter_key
CORS_ORIGINS=http://localhost:3000
PORT=8000
```

**Frontend** - Create `packages/frontend/.env`:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000
```

### 2. Build and Run

```bash
# Build and start both services
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build
```

### 3. Access the Applications

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000
- **Health Check:** http://localhost:8000/health

### 4. Stop the Services

```bash
docker-compose down
```

## Troubleshooting

### Port Already in Use

If ports 3000 or 8000 are already in use, you can modify them in `docker-compose.yml`:

```yaml
ports:
  - "3001:3000"  # Change 3000 to 3001 or another port
```

### Check Logs

```bash
# All logs
docker-compose logs

# Specific service
docker-compose logs backend
docker-compose logs frontend

# Follow logs
docker-compose logs -f
```

### Rebuild After Changes

```bash
# Rebuild and restart
docker-compose up --build --force-recreate
```

## Production Commands

### Build Only

```bash
# Backend
docker build -t contract-iq-backend ./packages/backend

# Frontend
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="your_url" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="your_key" \
  --build-arg NEXT_PUBLIC_BACKEND_URL="http://localhost:8000" \
  -t contract-iq-frontend ./packages/frontend
```

### Run Individual Containers

```bash
# Backend
docker run -p 8000:8000 --env-file .env contract-iq-backend

# Frontend
docker run -p 3000:3000 --env-file packages/frontend/.env contract-iq-frontend
```

## Next Steps

📖 Read `DOCKER_DEPLOYMENT.md` for detailed deployment instructions  
📖 Read `ENV_EXAMPLES.md` for complete environment variable reference

