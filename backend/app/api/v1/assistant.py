from typing import List, Optional, Dict
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from app.core.security import verify_auth
from app.core.rate_limiter import default_rate_limiter
from app.ml.assistant_engine import generate_assistant_response

router = APIRouter(prefix="/assistant", tags=["CyberGuard AI Assistant"])

class ChatRequest(BaseModel):
    conversation_id: Optional[str] = None
    question: str
    context_type: Optional[str] = "NONE"
    context_content: Optional[str] = ""
    metadata: Optional[Dict] = {}

class StructuredResponse(BaseModel):
    risk: str
    evidence: List[str]
    explanation: str
    recommended_action: str
    confidence: str
    is_certainty_claimed: bool

class ChatResponse(BaseModel):
    conversation_id: str
    question: str
    response: StructuredResponse

@router.post("/chat", response_model=ChatResponse, summary="Interactive Cybersecurity AI Assistant")
def assistant_chat(
    payload: ChatRequest,
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    import uuid
    conversation_id = payload.conversation_id or str(uuid.uuid4())

    structured = generate_assistant_response(
        question=payload.question,
        context_type=payload.context_type,
        context_content=payload.context_content,
        metadata=payload.metadata
    )

    return ChatResponse(
        conversation_id=conversation_id,
        question=payload.question,
        response=StructuredResponse(**structured)
    )
