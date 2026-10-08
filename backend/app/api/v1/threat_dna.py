from fastapi import APIRouter, Depends, Query
from app.core.security import verify_auth
from app.core.rate_limiter import default_rate_limiter
from app.models.threat_dna import (
    ThreatDnaCorrelationRequest,
    ThreatDnaCorrelationResponse
)
from app.services.threat_dna_engine import threat_dna_engine

router = APIRouter(prefix="/threat-dna", tags=["Threat DNA Correlation Engine"])

@router.post("/correlate", response_model=ThreatDnaCorrelationResponse, summary="Correlate Multi-Vector Security Events into Threat Campaigns")
async def correlate_threat_dna(
    payload: ThreatDnaCorrelationRequest,
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    user_id = current_user.get("sub") or payload.user_id or "usr_demo_12345"
    return threat_dna_engine.correlate_events(
        events=payload.events,
        time_window_hours=payload.time_window_hours,
        user_id=user_id
    )

@router.get("/campaigns", response_model=ThreatDnaCorrelationResponse, summary="Fetch Active Threat Campaigns for Authenticated User")
async def get_active_campaigns(
    time_window_hours: int = Query(24, ge=1, le=168, description="Time window in hours"),
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    user_id = current_user.get("sub") or "usr_demo_12345"
    return threat_dna_engine.correlate_events(
        events=None,
        time_window_hours=time_window_hours,
        user_id=user_id
    )
