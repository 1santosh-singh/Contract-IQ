# Docker Deployment Guide for Contract IQ

This guide provides instructions for building, running, and deploying the Contract IQ application using Docker.

## Project Structure

```
Contract-IQ/
├── packages/
│   ├── frontend/       # Next.js app
│   └── backend/        # FastAPI app
├── docker-compose.yml  # Local development setup
├── .env                # Backend environment variables (create this)
└── packages/frontend/.env  # Frontend environment variables (create this)
```

## Prerequisites

1. Install Docker and Docker Compose
2. Create required `.env` files (see below)
3. Ensure you have Supabase credentials ready

## Environment Variables

### Backend (.env at root)

Create a `.env` file at the root of the project with the following structure:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# API Keys
OPENROUTER_API_KEY=your_openrouter_api_key
HUGGINGFACE_API_KEY=your_huggingface_api_key

# Application Settings
APP_NAME=Contract IQ Backend
APP_VERSION=0.1.0
DEBUG=false

# CORS Origins (comma-separated)
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000

# Port (default: 8000, Render will override this)
PORT=8000

# Model Settings
EMBEDDING_MODEL_NAME=nlpaueb/legal-bert-base-uncased
FALLBACK_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2

# Processing Settings
CHUNK_SIZE=800
CHUNK_OVERLAP=100
MAX_FILE_SIZE=10485760

# Rate Limiting
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=60
```

### Frontend (packages/frontend/.env)

Create a `.env` file in `packages/frontend/` with the following structure:

```env
# Supabase Configuration (Client-side)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Backend API URL
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000
```

## Local Development with Docker

### Option 1: Using Docker Compose (Recommended)

1. **Ensure `.env` files are created** as described above

2. **Start both services:**
   ```bash
   docker-compose up --build
   ```

   Or run in detached mode:
   ```bash
   docker-compose up -d --build
   ```

3. **Access the applications:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - Backend Health Check: http://localhost:8000/health

4. **View logs:**
   ```bash
   docker-compose logs -f
   ```

5. **Stop the services:**
   ```bash
   docker-compose down
   ```

### Option 2: Using Docker Run (Manual)

#### Build Backend Image

```bash
cd packages/backend
docker build -t contract-iq-backend .
```

#### Run Backend Container

```bash
docker run -d \
  --name contract-iq-backend \
  -p 8000:8000 \
  --env-file ../../.env \
  contract-iq-backend
```

Or with inline environment variables:

```bash
docker run -d \
  --name contract-iq-backend \
  -p 8000:8000 \
  -e SUPABASE_URL="your_supabase_url" \
  -e SUPABASE_ANON_KEY="your_anon_key" \
  -e SUPABASE_SERVICE_ROLE_KEY="your_service_role_key" \
  -e OPENROUTER_API_KEY="your_openrouter_key" \
  contract-iq-backend
```

#### Build Frontend Image

```bash
cd packages/frontend
docker build \
  --build-arg NEXT_PUBLIC_SUPABASE_URL="your_supabase_url" \
  --build-arg NEXT_PUBLIC_SUPABASE_ANON_KEY="your_anon_key" \
  --build-arg NEXT_PUBLIC_BACKEND_URL="http://localhost:8000" \
  -t contract-iq-frontend .
```

#### Run Frontend Container

```bash
docker run -d \
  --name contract-iq-frontend \
  -p 3000:3000 \
  --env-file .env \
  contract-iq-frontend
```

## Production Deployment

### Deploy to Vercel (Frontend)

1. **Connect your repository to Vercel**
2. **Set environment variables in Vercel dashboard:**
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_BACKEND_URL` (your backend URL)

3. **Deploy:** Vercel will automatically detect and build your Next.js app

### Deploy to Render (Backend)

1. **Create a new Web Service on Render**
2. **Connect your repository**
3. **Set build command:** `pip install -r packages/backend/requirements.txt`
4. **Set start command:** `cd packages/backend && uvicorn main:app --host 0.0.0.0 --port ${PORT}`
5. **Add environment variables in Render dashboard:**
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `OPENROUTER_API_KEY`
   - `HUGGINGFACE_API_KEY`
   - `CORS_ORIGINS` (your frontend URL)
   - `PORT` (automatically set by Render)

### Deploy to EC2 (Both Services)

#### Setup EC2 Instance

1. **Launch an EC2 instance** (Ubuntu recommended)
2. **Install Docker:**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   sudo usermod -aG docker ubuntu
   ```
3. **Install Docker Compose:**
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

#### Deploy Application

1. **Clone your repository:**
   ```bash
   git clone <your-repo-url>
   cd Contract-IQ
   ```

2. **Create `.env` files** as described above

3. **Build and run with Docker Compose:**
   ```bash
   docker-compose up -d --build
   ```

4. **Configure Security Groups:**
   - Allow inbound traffic on ports 3000 (frontend) and 8000 (backend)
   - For HTTPS, set up a reverse proxy like Nginx

#### Optional: Set Up Nginx Reverse Proxy

```bash
sudo apt-get update
sudo apt-get install nginx

# Create nginx config
sudo nano /etc/nginx/sites-available/contract-iq
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

server {
    listen 80;
    server_name api.your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/contract-iq /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Verification

### Check Backend Health

```bash
curl http://localhost:8000/health
```

### Check Backend Root

```bash
curl http://localhost:8000/
```

### Test Frontend

Open your browser and navigate to:
- Frontend: http://localhost:3000
- Check browser console for any errors

## Troubleshooting

### Backend not responding

1. Check if the container is running:
   ```bash
   docker ps
   ```

2. Check logs:
   ```bash
   docker logs contract-iq-backend
   ```

3. Verify environment variables are set:
   ```bash
   docker exec contract-iq-backend env | grep SUPABASE
   ```

### Frontend build errors

1. Ensure all environment variables starting with `NEXT_PUBLIC_` are set at build time
2. Check build logs:
   ```bash
   docker logs contract-iq-frontend
   ```

### CORS errors

1. Update `CORS_ORIGINS` in backend `.env` to include your frontend URL
2. Restart the backend container

### Port already in use

Change the port mapping in docker-compose.yml or use different ports when running containers

## Docker Image Optimization

### Multi-stage Builds

Both Dockerfiles use multi-stage builds to minimize final image size:
- Backend: Uses `python:3.11-slim` for smaller size
- Frontend: Uses `node:18-alpine` for minimal base image

### Health Checks

Both containers include health checks:
- Backend: Checks `/health` endpoint
- Frontend: Next.js includes built-in health monitoring

## Next Steps

- Set up CI/CD pipeline for automatic deployments
- Configure domain and SSL certificates
- Set up monitoring and logging (e.g., Datadog, New Relic)
- Implement backup strategies for your Supabase database

## Support

For issues or questions:
1. Check container logs: `docker logs <container-name>`
2. Verify environment variables are correct
3. Ensure all dependencies are properly installed
4. Check network connectivity between containers


