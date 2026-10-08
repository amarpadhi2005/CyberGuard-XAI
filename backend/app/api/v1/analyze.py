from fastapi import APIRouter, Depends
from app.core.security import verify_auth
from app.core.rate_limiter import default_rate_limiter
from app.models.analysis import (
    AnalysisResponse,
    UrlAnalysisRequest,
    MessageAnalysisRequest,
    PhoneAnalysisRequest,
    QrAnalysisRequest,
    DeepfakeAnalysisRequest
)
from app.services.url_service import url_service
from app.services.message_service import message_service
from app.services.phone_service import phone_service
from app.services.qr_service import qr_service
from app.services.deepfake_service import deepfake_service

router = APIRouter(tags=["AI Forensic Analysis"])

@router.post("/analyze/url", response_model=AnalysisResponse, summary="Analyze URL for Phishing & Malicious Domains")
async def analyze_url_endpoint(
    payload: UrlAnalysisRequest,
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    return await url_service.analyze_url(payload.url)

@router.post("/analyze/message", response_model=AnalysisResponse, summary="Analyze SMS & Messages for Smishing & Social Engineering")
async def analyze_message_endpoint(
    payload: MessageAnalysisRequest,
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    return await message_service.analyze_message(
        message=payload.message,
        sender=payload.sender or "",
        package_name=payload.package_name or ""
    )

@router.post("/analyze/phone", response_model=AnalysisResponse, summary="Analyze Phone Number for VoIP Robocall Spoofing")
async def analyze_phone_endpoint(
    payload: PhoneAnalysisRequest,
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    return await phone_service.analyze_phone(
        phone_number=payload.phone_number,
        call_type=payload.call_type or "INCOMING",
        caller_name=payload.caller_name or ""
    )

@router.post("/analyze/qr", response_model=AnalysisResponse, summary="Analyze QR Code for Exploit Payloads & Fraud QRs")
async def analyze_qr_endpoint(
    payload: QrAnalysisRequest,
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    return await qr_service.analyze_qr(
        payload=payload.payload,
        format_type=payload.format or "QR_CODE"
    )

@router.post("/analyze/deepfake", response_model=AnalysisResponse, summary="Analyze Media for Synthetic GAN & Deepfake Artifacts")
async def analyze_deepfake_endpoint(
    payload: DeepfakeAnalysisRequest,
    current_user: dict = Depends(verify_auth),
    _rate_limit: None = Depends(default_rate_limiter)
):
    return await deepfake_service.analyze_media(
        media_type=payload.media_type,
        file_name=payload.file_name or "uploaded_media",
        file_size_bytes=payload.file_size_bytes or 0,
        duration_seconds=payload.duration_seconds or 0.0,
        extracted_features=payload.extracted_features,
        media_base64=payload.media_base64
    )
