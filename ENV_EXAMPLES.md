# Environment Variables Examples

## Backend Environment Variables

Create a `.env` file at the root of the project (`Contract-IQ/.env`) with the following variables:

```env
# ============================================
# Supabase Configuration
# ============================================
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# ============================================
# API Keys
# ============================================
OPENROUTER_API_KEY=your_openrouter_api_key
HUGGINGFACE_API_KEY=your_huggingface_api_key

# ============================================
# Application Settings
# ============================================
APP_NAME=Contract IQ Backend
APP_VERSION=0.1.0
DEBUG=false

# ============================================
# CORS Origins (comma-separated)
# ============================================
# For local development:
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000

# For production, add your frontend URL:
# CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,https://yourdomain.com

# ============================================
# Port Configuration
# ============================================
# Default port: 8000
# Render will automatically set this
PORT=8000

# ============================================
# Model Settings
# ============================================
EMBEDDING_MODEL_NAME=nlpaueb/legal-bert-base-uncased
FALLBACK_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2

# ============================================
# Processing Settings
# ============================================
CHUNK_SIZE=800
CHUNK_OVERLAP=100
MAX_FILE_SIZE=10485760

# ============================================
# Rate Limiting
# ============================================
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=60
```

## Frontend Environment Variables

Create a `.env` file in `packages/frontend/.env` with the following variables:

```env
# ============================================
# Supabase Configuration (Client-side)
# ============================================
# These are PUBLIC variables and will be exposed to the client
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# ============================================
# Backend API URL
# ============================================
# For local development:
NEXT_PUBLIC_BACKEND_URL=http://localhost:8000

# For Docker:
# NEXT_PUBLIC_BACKEND_URL=http://localhost:8000

# For production (after deploying backend):
# NEXT_PUBLIC_BACKEND_URL=https://your-backend-api.com
```

## Getting Your Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to **Settings** → **API**
3. Copy the following:
   - **Project URL** → Use for `SUPABASE_URL`
   - **anon public** key → Use for `SUPABASE_ANON_KEY`
   - **service_role** key → Use for `SUPABASE_SERVICE_ROLE_KEY`

## Getting API Keys

### OpenRouter API Key

1. Visit https://openrouter.ai/
2. Sign up or log in
3. Go to **Keys** section
4. Create a new API key
5. Copy the key and use it for `OPENROUTER_API_KEY`

### Hugging Face API Key (Optional)

1. Visit https://huggingface.co/
2. Sign up or log in
3. Go to **Settings** → **Access Tokens**
4. Create a new token
5. Copy the token and use it for `HUGGINGFACE_API_KEY`

## Important Notes

### Security Warning

- ❌ **Never commit `.env` files to version control**
- ✅ Add `.env` to `.gitignore`
- ✅ Use `.env.example` files as templates (without real credentials)
- ✅ Keep `SUPABASE_SERVICE_ROLE_KEY` secret and server-side only

### Environment Variable Prefixes

- Variables starting with `NEXT_PUBLIC_` are exposed to the browser
- Variables without the prefix are server-side only
- Be careful not to expose sensitive keys with the `NEXT_PUBLIC_` prefix

### Production Deployment

When deploying to production:

#### Vercel (Frontend)
- Add environment variables in Vercel dashboard under **Settings** → **Environment Variables**
- Variables starting with `NEXT_PUBLIC_` are available to the client
- Build-time variables need to be set before deployment

#### Render (Backend)
- Add environment variables in Render dashboard under **Environment**
- All variables are server-side
- `PORT` is automatically set by Render
- Update `CORS_ORIGINS` to include your frontend domain

#### EC2 (Both Services)
- Use `.env` files or pass variables via Docker
- Ensure `.env` files are not committed to version control
- Use secrets management for production

## Quick Setup Checklist

- [ ] Create root `.env` file with backend variables
- [ ] Create `packages/frontend/.env` file with frontend variables
- [ ] Get Supabase credentials from dashboard
- [ ] Get OpenRouter API key
- [ ] Get Hugging Face API key (optional)
- [ ] Fill in all placeholder values
- [ ] Verify `.env` files are in `.gitignore`
- [ ] Never commit real credentials to Git

