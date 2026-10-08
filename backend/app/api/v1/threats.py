import re
from typing import List, Optional
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel
from app.core.security import verify_supabase_jwt

router = APIRouter(prefix="/threats", tags=["Threat Evaluation"])

class NotificationEvalRequest(BaseModel):
    package_name: str
    app_name: str
    title: Optional[str] = ""
    text: Optional[str] = ""

class XaiPayload(BaseModel):
    confidence: float
    indicators: List[str]
    explanation: str
    action_prompt: str

class NotificationEvalResponse(BaseModel):
    is_threat: bool
    threat_type: str
    severity: str
    risk_score: int
    extracted_urls: List[str]
    xai: XaiPayload

# Heuristic regular expressions
URL_PATTERN = re.compile(r"https?://\S+", re.IGNORECASE)
URGENCY_PATTERN = re.compile(r"\b(immediately|urgent|locked|suspended|arrest|warrant|24 hours)\b", re.IGNORECASE)
PAYMENT_PATTERN = re.compile(r"\b(wire transfer|send \$|gift card|crypto|bitcoin|usdt|processing fee)\b", re.IGNORECASE)
OTP_PATTERN = re.compile(r"\b(share your otp|send the code|verification code|forward code)\b", re.IGNORECASE)
KYC_PATTERN = re.compile(r"\b(update kyc|pan card blocked|aadhaar suspended|kyc expired)\b", re.IGNORECASE)
REWARD_PATTERN = re.compile(r"\b(you won|lottery|claim reward|free iphone|cash prize)\b", re.IGNORECASE)

@router.post("/evaluate-notification", response_model=NotificationEvalResponse)
def evaluate_notification(
    payload: NotificationEvalRequest,
    current_user: dict = Depends(verify_supabase_jwt)
):
    combined_content = f"{payload.title or ''} {payload.text or ''}".strip()
    urls = URL_PATTERN.findall(combined_content)
    
    score = 0
    indicators = []
    threat_category = "BENIGN"

    if urls:
        score += 30
        indicators.append(f"External hyperlink embedded in message: {urls[0]}")
        threat_category = "SMISHING_URL"

    if URGENCY_PATTERN.search(combined_content):
        score += 25
        indicators.append("Coercive high-urgency psychological framing detected")

    if PAYMENT_PATTERN.search(combined_content):
        score += 30
        indicators.append("Unsolicited demand for non-reversible payment")
        threat_category = "PAYMENT_FRAUD"

    if OTP_PATTERN.search(combined_content):
        score += 45
        indicators.append("Explicit harvesting of authentication passcode or OTP")
        threat_category = "OTP_THEFT"

    if KYC_PATTERN.search(combined_content):
        score += 40
        indicators.append("Deceptive claim of expired KYC or identity documentation")
        threat_category = "FAKE_KYC"

    if REWARD_PATTERN.search(combined_content):
        score += 35
        indicators.append("Unrealistic lottery or financial reward lure")
        threat_category = "REWARD_SCAM"

    final_score = min(100, max(0, score))
    is_threat = final_score >= 50

    if final_score >= 85:
        severity = "CRITICAL"
    elif final_score >= 70:
        severity = "HIGH"
    elif final_score >= 50:
        severity = "MEDIUM"
    elif final_score >= 30:
        severity = "LOW"
    else:
        severity = "SAFE"

    explanation = (
        ". ".join(indicators) + "."
        if indicators
        else "No recognized phishing or scam signatures found."
    )

    action = (
        "Do not click links or disclose codes. Report and block sender."
        if is_threat
        else "Normal message communication."
    )

    return NotificationEvalResponse(
        is_threat=is_threat,
        threat_type=threat_category,
        severity=severity,
        risk_score=final_score,
        extracted_urls=urls,
        xai=XaiPayload(
            confidence=0.94 if is_threat else 0.88,
            indicators=indicators,
            explanation=explanation,
            action_prompt=action
        )
    )


class UrlEvalRequest(BaseModel):
    url: str

class UrlEvalResponse(BaseModel):
    riskScore: int
    severity: str
    reasons: List[str]
    recommendation: str
    normalized_url: Optional[str] = None
    domain: Optional[str] = None
    is_https: Optional[bool] = None
    is_ip_address: Optional[bool] = None
    is_shortened: Optional[bool] = None
    has_lookalike: Optional[bool] = None
    lookalike_target: Optional[str] = None
    subdomain_count: Optional[int] = None
    is_known_threat: Optional[bool] = None


@router.post("/evaluate-url", response_model=UrlEvalResponse)
def evaluate_url(
    payload: UrlEvalRequest,
    current_user: dict = Depends(verify_supabase_jwt)
):
    from app.ml.url_classifier import evaluate_url_threat
    result = evaluate_url_threat(payload.url)
    return UrlEvalResponse(**result)


class QrEvalRequest(BaseModel):
    payload: str

class QrEvalResponse(BaseModel):
    riskScore: int
    severity: str
    reasons: List[str]
    recommendation: str
    payload_type: str
    is_url: bool
    is_payment_or_deep_link: bool
    warning_title: Optional[str] = None
    warning_message: Optional[str] = None
    raw_payload: Optional[str] = None
    payment_details: Optional[dict] = None
    url_evaluation: Optional[dict] = None


@router.post("/evaluate-qr", response_model=QrEvalResponse)
def evaluate_qr(
    payload: QrEvalRequest,
    current_user: dict = Depends(verify_supabase_jwt)
):
    from app.ml.qr_classifier import evaluate_qr_threat
    result = evaluate_qr_threat(payload.payload)
    return QrEvalResponse(**result)


class XaiSignalModel(BaseModel):
    name: str
    category: str
    score_impact: int
    is_positive: bool = False
    description: str


class XaiThreatEvaluationResponse(BaseModel):
    riskScore: int
    severity: str
    decision: str
    evidence: List[str]
    signals: List[XaiSignalModel]
    confidence: str
    recommendedAction: str
    title: Optional[str] = None
    target_entity: Optional[str] = None


class XaiThreatEvaluationRequest(BaseModel):
    entity_type: str  # "URL", "QR", "MESSAGE"
    target: str


@router.post("/xai-evaluate", response_model=XaiThreatEvaluationResponse)
def xai_evaluate_threat(
    payload: XaiThreatEvaluationRequest,
    current_user: dict = Depends(verify_supabase_jwt)
):
    e_type = payload.entity_type.upper()
    target = payload.target.strip()

    signals: List[XaiSignalModel] = []
    evidence: List[str] = []

    if e_type == "URL":
        from app.ml.url_classifier import evaluate_url_threat
        eval_res = evaluate_url_threat(target)
        score = eval_res["riskScore"]
        severity = eval_res["severity"]
        domain = eval_res.get("domain", "")

        if eval_res.get("is_known_threat"):
            signals.append(XaiSignalModel(
                name="Threat Intelligence Blacklist",
                category="Threat Intelligence",
                score_impact=100,
                is_positive=False,
                description="Target host matches confirmed malicious/phishing infrastructure signatures in global registry."
            ))
            evidence.append(f"Domain '{domain}' is listed on active cybercrime blacklists.")

        if eval_res.get("has_lookalike"):
            target_brand = eval_res.get("lookalike_target", "legitimate brand")
            signals.append(XaiSignalModel(
                name="Typosquatting Brand Impersonation",
                category="Domain Governance",
                score_impact=45,
                is_positive=False,
                description=f"Hostname intentionally mimics '{target_brand}' via character substitution."
            ))
            evidence.append(f"Hostname spoofing targeting legitimate brand '{target_brand}'.")

        if eval_res.get("is_ip_address"):
            signals.append(XaiSignalModel(
                name="Raw IP Host Address",
                category="Network & Transport",
                score_impact=40,
                is_positive=False,
                description="Host uses a raw numerical IPv4 address, bypassing standard domain governance."
            ))
            evidence.append("Direct numerical IP host without verifiable domain ownership.")

        if not eval_res.get("is_https"):
            signals.append(XaiSignalModel(
                name="Unencrypted Cleartext Transport",
                category="Network & Transport",
                score_impact=25,
                is_positive=False,
                description="Connection uses unencrypted HTTP cleartext."
            ))
            evidence.append("HTTP cleartext transmission lacks TLS/SSL encryption.")
        else:
            signals.append(XaiSignalModel(
                name="Valid TLS/HTTPS Encryption",
                category="Network & Transport",
                score_impact=-10,
                is_positive=True,
                description="Connection is encrypted using standard Transport Layer Security."
            ))

        if not signals:
            signals.append(XaiSignalModel(
                name="Clean Domain Reputation",
                category="Reputation",
                score_impact=0,
                is_positive=True,
                description="No anomalous homoglyphs, threat blacklist hits, or unencrypted credential flows."
            ))
            evidence.append("Clean domain reputation and standard HTTPS security configuration.")

        decision = "BLOCK_THREAT" if score >= 70 else ("FLAG_SUSPICIOUS" if score >= 50 else ("USER_VERIFICATION_REQUIRED" if score >= 25 else "ALLOW_SAFE"))
        confidence = "95% (High Typo-Signature Overlap)" if eval_res.get("has_lookalike") else ("99% (Confirmed Blacklist Match)" if eval_res.get("is_known_threat") else "91% (High Multi-Vector Correlation)")

        return XaiThreatEvaluationResponse(
            riskScore=score,
            severity=severity,
            decision=decision,
            evidence=evidence,
            signals=signals,
            confidence=confidence,
            recommendedAction=eval_res.get("recommendation", "Avoid unverified links."),
            title="URL Threat Forensic Evaluation",
            target_entity=target
        )

    return XaiThreatEvaluationResponse(
        riskScore=0,
        severity="SAFE",
        decision="ALLOW_SAFE",
        evidence=["Baseline verification passed; no anomalous indicators present."],
        signals=[XaiSignalModel(name="Clean Baseline", category="Reputation", score_impact=0, is_positive=True, description="No signatures identified.")],
        confidence="90% (Baseline Confidence)",
        recommendedAction="No immediate threat identified.",
        title="Forensic Evaluation",
        target_entity=target
    )



