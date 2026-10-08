from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="CyberGuard XAI - Real-time AI Cybersecurity Inference, Forensics & Explainability Gateway",
    version="1.0.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# CORS Middleware (securely configured)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.api.v1.analyze import router as analyze_router
from app.api.v1.assistant import router as assistant_router
from app.api.v1.threat_dna import router as threat_dna_router
from app.api.v1.threats import router as threats_router
from app.api.v1.score import router as score_router

# Direct Root Endpoints for Android & Client SDKs:
# /analyze/url, /analyze/message, /analyze/phone, /analyze/qr, /analyze/deepfake
app.include_router(analyze_router)

# /assistant/chat
app.include_router(assistant_router)

# /threat-dna/correlate, /threat-dna/campaigns
app.include_router(threat_dna_router)

# API Versioned Mounts (/api/v1/...)
app.include_router(analyze_router, prefix=settings.API_V1_STR)
app.include_router(assistant_router, prefix=settings.API_V1_STR)
app.include_router(threat_dna_router, prefix=settings.API_V1_STR)
app.include_router(threats_router, prefix=settings.API_V1_STR)
app.include_router(score_router, prefix=settings.API_V1_STR)

@app.get("/health", tags=["System"])
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": "1.0.0",
        "endpoints": [
            "POST /analyze/url",
            "POST /analyze/message",
            "POST /analyze/phone",
            "POST /analyze/qr",
            "POST /analyze/deepfake",
            "POST /assistant/chat",
            "GET /health"
        ],
        "rate_limiting_active": True,
        "auth_modes_supported": ["Bearer (Supabase JWT)", "X-API-Key"],
        "supabase_connected": bool(settings.SUPABASE_URL)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
