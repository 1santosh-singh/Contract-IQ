"""
Chat and AI routes.
"""
from typing import List
from fastapi import APIRouter, Depends, HTTPException

from routes.auth import get_token, get_authenticated_supabase
from services.ai_service import ai_service
from models.schemas import ChatRequest, ChatResponse
from utils.decorators import require_auth, handle_unicode_errors
from exceptions import AIServiceError

router = APIRouter(prefix="/api", tags=["chat"])


@router.post("/chat", response_model=ChatResponse)
@require_auth
@handle_unicode_errors
async def chat_endpoint(
    request: ChatRequest,
    token: str = Depends(get_token),
    user = None  # Added by require_auth decorator
):
    """
    Chat with AI assistant.
    
    Args:
        request: Chat request with messages
        token: Authentication token
        
    Returns:
        AI response
    """
    try:
        # Map roles: 'bot' to 'assistant'
        api_messages = []
        for msg in request.messages:
            role = "assistant" if msg.role == "bot" else msg.role
            api_messages.append({"role": role, "content": msg.content})
        
        # Generate response using AI service
        response_content = await ai_service.chat_completion(
            messages=api_messages,
            model="openai/gpt-oss-20b:free",
            max_tokens=500,
            temperature=0.7
        )
        
        return ChatResponse(
            success=True,
            response=response_content,
            model_used="openai/gpt-oss-20b:free"
        )
        
    except AIServiceError as e:
        # Return fallback response for AI service errors
        fallback_response = "I'm sorry, but I'm currently unable to access the AI model due to authentication or rate limit issues. Please check your API key on OpenRouter. For now, here's a sample response: **Key Advice:** Review all clauses carefully, especially termination and liability sections."
        
        return ChatResponse(
            success=True,
            response=fallback_response,
            model_used="fallback"
        )
    except Exception as e:
        print(f"[ERROR] Chat endpoint error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate response: {str(e)}")
