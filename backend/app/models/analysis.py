from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field

class SignalModel(BaseModel):
    name: str = Field(..., description="Signal or heuristic feature identifier")
    category: str = Field(..., description="Taxonomy classification category")
    score_impact: int = Field(..., description="Impact points added to risk score")
    is_positive: bool = Field(False, description="True if signal indicates safety/cleanliness")
    description: str = Field(..., description="Explainable description of forensic observation")

class AnalysisResponse(BaseModel):
    riskScore: int = Field(..., ge=0, le=100, description="Risk Score from 0 to 100")
    severity: str = Field(..., description="SAFE, LOW, MEDIUM, HIGH, or CRITICAL")
    decision: str = Field(..., description="ALLOW_SAFE, FLAG_SUSPICIOUS, BLOCK_THREAT, or USER_VERIFICATION_REQUIRED")
    signals: List[SignalModel] = Field(default_factory=list, description="Granular forensic signals")
    evidence: List[str] = Field(default_factory=list, description="Verifiable evidence strings")
    recommendation: str = Field(..., description="Actionable mitigation advice")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Confidence level from 0.0 to 1.0")
    metadata: Optional[Dict[str, Any]] = Field(default=None, description="Optional domain-specific details")

# Analysis Request Models
class UrlAnalysisRequest(BaseModel):
    url: str

class MessageAnalysisRequest(BaseModel):
    message: str
    sender: Optional[str] = ""
    package_name: Optional[str] = ""

class PhoneAnalysisRequest(BaseModel):
    phone_number: str
    call_type: Optional[str] = "INCOMING"
    caller_name: Optional[str] = ""

class QrAnalysisRequest(BaseModel):
    payload: str
    format: Optional[str] = "QR_CODE"

class DeepfakeAnalysisRequest(BaseModel):
    media_type: str = "IMAGE"  # "IMAGE", "VIDEO", "AUDIO"
    file_name: Optional[str] = "upload.jpg"
    file_size_bytes: Optional[int] = 0
    duration_seconds: Optional[float] = 0.0
    extracted_features: Optional[Dict[str, Any]] = None
    media_base64: Optional[str] = None
