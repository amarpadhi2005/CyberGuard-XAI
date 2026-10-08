import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings
from app.services.url_service import url_service
from app.services.base import BaseAnalysisModel
from app.models.analysis import AnalysisResponse, SignalModel

client = TestClient(app)

AUTH_HEADERS = {
    "X-API-Key": settings.BACKEND_API_KEY
}

BEARER_HEADERS = {
    "Authorization": "Bearer demo_test_token_123"
}

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "POST /analyze/url" in data["endpoints"]
    assert "POST /analyze/message" in data["endpoints"]
    assert "POST /analyze/phone" in data["endpoints"]
    assert "POST /analyze/qr" in data["endpoints"]
    assert "POST /analyze/deepfake" in data["endpoints"]
    assert "POST /assistant/chat" in data["endpoints"]

def test_unauthenticated_request_rejected():
    response = client.post("/analyze/url", json={"url": "https://google.com"})
    assert response.status_code == 401
    assert "Authentication required" in response.json()["detail"]

def test_analyze_url_phishing():
    payload = {"url": "http://paypa1-account-update.top/login"}
    response = client.post("/analyze/url", json=payload, headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()

    # Verify all 7 required fields
    for field in ["riskScore", "severity", "decision", "signals", "evidence", "recommendation", "confidence"]:
        assert field in data

    assert data["riskScore"] >= 70
    assert data["decision"] in ["BLOCK_THREAT", "FLAG_SUSPICIOUS"]
    assert len(data["signals"]) > 0
    assert len(data["evidence"]) > 0
    assert isinstance(data["confidence"], float)

def test_analyze_url_safe():
    payload = {"url": "https://www.google.com"}
    response = client.post("/analyze/url", json=payload, headers=BEARER_HEADERS)
    assert response.status_code == 200
    data = response.json()
    assert data["riskScore"] < 30
    assert data["decision"] == "ALLOW_SAFE"
    assert data["severity"] == "SAFE"

def test_analyze_message_smishing():
    payload = {
        "message": "URGENT: Your account is locked immediately. Share your OTP passcode to avoid arrest.",
        "sender": "+18005550199"
    }
    response = client.post("/analyze/message", json=payload, headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()

    assert data["riskScore"] >= 70
    assert data["decision"] == "BLOCK_THREAT"
    assert any("OTP" in s["name"] or "Passcode" in s["name"] for s in data["signals"])

def test_analyze_phone_robocall():
    payload = {
        "phone_number": "+18005550199",
        "caller_name": "IRS Tax Enforcement"
    }
    response = client.post("/analyze/phone", json=payload, headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()

    assert data["riskScore"] >= 80
    assert data["decision"] == "BLOCK_THREAT"
    assert len(data["evidence"]) > 0

def test_analyze_qr_upi_deceptive():
    payload = {
        "payload": "upi://pay?pa=refund-agent@okaxis&pn=CustomerCareRefundSupport&am=5000&cu=INR"
    }
    response = client.post("/analyze/qr", json=payload, headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()

    assert data["riskScore"] >= 70
    assert any("Financial" in s["category"] or "Impersonation" in s["category"] for s in data["signals"])

def test_analyze_deepfake():
    payload = {
        "media_type": "AUDIO",
        "file_name": "urgent_voice_message.wav",
        "extracted_features": {
            "spectral_delta": 5.2,
            "cadence_regularity": 96
        }
    }
    response = client.post("/analyze/deepfake", json=payload, headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()

    assert data["riskScore"] >= 60
    assert data["metadata"]["is_prototype_analysis"] is True
    assert len(data["signals"]) >= 2

def test_assistant_chat():
    payload = {
        "question": "I received an SMS asking me to verify KYC for my SIM card. Is this dangerous?",
        "context_type": "SMS"
    }
    response = client.post("/assistant/chat", json=payload, headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()
    assert "response" in data
    assert "risk" in data["response"]
    assert "recommended_action" in data["response"]

def test_modular_model_replacement():
    """Demonstrates that individual ML models can be swapped out cleanly."""
    original_model = url_service._model

    class MockCustomTransformerUrlModel(BaseAnalysisModel):
        @property
        def model_name(self) -> str:
            return "CustomFineTunedRoBERTa"
        @property
        def model_version(self) -> str:
            return "3.0.0"

        async def analyze(self, target: str, **kwargs) -> AnalysisResponse:
            return AnalysisResponse(
                riskScore=99,
                severity="CRITICAL",
                decision="BLOCK_THREAT",
                signals=[SignalModel(
                    name="Transformer Neural Embedding Match",
                    category="Deep Learning",
                    score_impact=99,
                    description="High semantic embedding similarity to known malware C2."
                )],
                evidence=["Transformer classification logit: 0.998"],
                recommendation="Blocked via custom transformer model.",
                confidence=0.99
            )

    try:
        url_service.set_model(MockCustomTransformerUrlModel())
        response = client.post("/analyze/url", json={"url": "https://example.com"}, headers=AUTH_HEADERS)
        assert response.status_code == 200
        assert response.json()["riskScore"] == 99
        assert response.json()["confidence"] == 0.99
    finally:
        url_service.set_model(original_model)
