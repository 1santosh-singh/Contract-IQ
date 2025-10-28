# Pull the prebuilt backend image from Docker Hub
FROM santoshdev10/contract-iq-backend:latest

# Expose the port (Render sets $PORT)
EXPOSE 8000

# Health check (optional, Render can use /api/health)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:${PORT:-8000}/api/health || exit 1

# Run FastAPI app using uvicorn with dynamic PORT
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}

