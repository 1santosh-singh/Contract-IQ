# Contract IQ - AI-Powered Contract Analysis Platform

A modern, full-stack application for intelligent contract analysis using AI and machine learning. Built with Next.js, FastAPI, and Supabase.

## 🚀 Features

- **Document Upload & Processing**: Upload PDF and DOCX files for analysis
- **AI-Powered Summarization**: Get intelligent contract summaries
- **Risk Analysis**: Identify potential risks and issues
- **Smart Querying**: Ask questions about your contracts
- **Chat Interface**: Interactive AI assistant for contract insights
- **Modern UI**: Glassmorphic design with responsive layout

## 🏗️ Architecture

This is a monorepo containing:

- **Frontend** (`packages/frontend/`): Next.js 14 with TypeScript, Tailwind CSS
- **Backend** (`packages/backend/`): FastAPI with Python, AI/ML services
- **Database**: Supabase for authentication and data storage

## 🛠️ Tech Stack

### Frontend
- Next.js 14
- TypeScript
- Tailwind CSS
- Supabase Auth
- React Hook Form
- Lucide React Icons

### Backend
- FastAPI
- Python 3.11+
- Supabase
- OpenAI/OpenRouter
- Hugging Face Transformers
- LangChain
- PyPDF, python-docx

## 📦 Installation

### Prerequisites
- Node.js 18+
- Python 3.11+
- Supabase account

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd contract-iq
   ```

2. **Install dependencies**
   ```bash
   npm install
   cd packages/backend && pip install -r requirements.txt
   ```

3. **Environment Setup**
   Create `.env.local` in the root directory:
   ```env
   # Supabase Configuration
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   
   # API Keys
   OPENROUTER_API_KEY=your_openrouter_key
   HUGGINGFACE_API_KEY=your_huggingface_key
   ```

4. **Database Setup**
   Run the SQL script in `supabase-setup.sql` in your Supabase dashboard.

## 🚀 Development

### Start both frontend and backend:
```bash
npm run dev
```

### Start individually:
```bash
# Frontend only
npm run dev:frontend

# Backend only  
npm run dev:backend
```

## 📁 Project Structure

```
contract-iq/
├── packages/
│   ├── frontend/          # Next.js frontend
│   │   ├── src/
│   │   │   ├── app/       # App router pages
│   │   │   ├── components/ # React components
│   │   │   ├── hooks/     # Custom hooks
│   │   │   └── lib/       # Utilities
│   │   └── package.json
│   └── backend/           # FastAPI backend
│       ├── routes/        # API routes
│       ├── services/      # Business logic
│       ├── models/        # Data models
│       └── utils/         # Utilities
├── public/                # Static assets
└── package.json          # Root package.json
```

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/signup` - User registration

### Documents
- `POST /api/upload` - Upload document
- `POST /api/process-document` - Process document

### Analysis
- `POST /api/summarize` - Generate summary
- `POST /api/risk-analysis` - Risk analysis
- `POST /api/query` - Query document

### Chat
- `POST /api/chat` - Chat with AI

## 🚀 Deployment

### Docker Deployment (Recommended)

For containerized deployment with Docker and Docker Compose:

📖 **Quick Start:** See [DOCKER_QUICK_START.md](DOCKER_QUICK_START.md)  
📖 **Full Guide:** See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md)  
📖 **Environment Variables:** See [ENV_EXAMPLES.md](ENV_EXAMPLES.md)

**Quick commands:**
```bash
# Build and run locally
docker-compose up --build

# Backend: http://localhost:8000
# Frontend: http://localhost:3000
```

### Cloud Deployment

#### Frontend (Vercel)
1. Connect your GitHub repository to Vercel
2. Set environment variables in Vercel dashboard
3. Deploy automatically on push

#### Backend (Render)
1. Connect your repository
2. Set environment variables
3. Deploy with Python runtime

#### Full Stack (EC2)
1. Follow the Docker deployment guide
2. Set up EC2 instance with Docker
3. Deploy using Docker Compose

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For support, email support@contractiq.com or create an issue in the repository.
