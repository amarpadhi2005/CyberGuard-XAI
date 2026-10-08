import re
from typing import Optional
from app.services.base import BaseAnalysisModel
from app.models.analysis import AnalysisResponse, SignalModel
from app.ml.url_classifier import evaluate_url_threat

URL_PATTERN = re.compile(r"https?://\S+", re.IGNORECASE)
URGENCY_PATTERN = re.compile(r"\b(immediately|urgent|locked|suspended|arrest|warrant|24 hours|legal action|final notice)\b", re.IGNORECASE)
PAYMENT_PATTERN = re.compile(r"\b(wire transfer|send \$|gift card|crypto|bitcoin|usdt|processing fee|western union)\b", re.IGNORECASE)
OTP_PATTERN = re.compile(r"\b(share your otp|send the code|verification code|forward code|passcode|one-time password)\b", re.IGNORECASE)
KYC_PATTERN = re.compile(r"\b(update kyc|pan card blocked|aadhaar suspended|kyc expired|bank account blocked|sim deactivation)\b", re.IGNORECASE)
REWARD_PATTERN = re.compile(r"\b(you won|lottery|claim reward|free iphone|cash prize|congratulations winner)\b", re.IGNORECASE)

class RuleBasedMessageModel(BaseAnalysisModel):
    @property
    def model_name(self) -> str:
        return "CyberGuard Phishing & Smishing NLP Engine"

    @property
    def model_version(self) -> str:
        return "1.1.0"

    async def analyze(self, target: str, **kwargs) -> AnalysisResponse:
        message = target.strip()
        sender = kwargs.get("sender", "")
        package_name = kwargs.get("package_name", "")

        score = 0
        signals = []
        evidence = []
        urls = URL_PATTERN.findall(message)

        if urls:
            url_res = evaluate_url_threat(urls[0])
            url_score = url_res["riskScore"]
            added_impact = max(35, int(url_score * 0.5))
            score += added_impact
            signals.append(SignalModel(
                name="Embedded Hyperlink Risk",
                category="Hyperlink Analysis",
                score_impact=added_impact,
                is_positive=False,
                description=f"Message contains embedded link ({urls[0]}), evaluated risk: {url_score}/100."
            ))
            evidence.append(f"Embedded external link: {urls[0]}")

        if URGENCY_PATTERN.search(message):
            score += 25
            signals.append(SignalModel(
                name="Urgent Psychological Framing",
                category="Social Engineering",
                score_impact=25,
                is_positive=False,
                description="Coercive language inducing panic or artificial time limits to bypass critical thinking."
            ))
            evidence.append("High urgency extortion language ('immediately', 'suspended', '24 hours').")

        if OTP_PATTERN.search(message):
            score += 45
            signals.append(SignalModel(
                name="Authentication Passcode Harvesting",
                category="Credential Harvesting",
                score_impact=45,
                is_positive=False,
                description="Explicit request to disclose one-time passwords (OTP) or authentication codes."
            ))
            evidence.append("Explicit request to disclose OTP or authentication secret.")

        if KYC_PATTERN.search(message):
            score += 40
            signals.append(SignalModel(
                name="Fake Identity / KYC Suspension Threat",
                category="Impersonation",
                score_impact=40,
                is_positive=False,
                description="Deceptive claim regarding expired identity credentials or banking freeze."
            ))
            evidence.append("Deceptive KYC / identity card suspension framing.")

        if PAYMENT_PATTERN.search(message):
            score += 35
            signals.append(SignalModel(
                name="Irreversible Payment Demand",
                category="Financial Fraud",
                score_impact=35,
                is_positive=False,
                description="Unsolicited demand for payments using non-reversible channels (wire, crypto, gift cards)."
            ))
            evidence.append("Demand for non-reversible funds transfer.")

        if REWARD_PATTERN.search(message):
            score += 30
            signals.append(SignalModel(
                name="Unrealistic Lottery / Prize Lure",
                category="Financial Fraud",
                score_impact=30,
                is_positive=False,
                description="Advance-fee lure promising unearned prizes or lottery winnings."
            ))
            evidence.append("Lottery / reward lure identified.")

        if not signals:
            signals.append(SignalModel(
                name="Normal Communication Baseline",
                category="Reputation",
                score_impact=0,
                is_positive=True,
                description="No recognized social engineering, smishing, or credential harvesting signatures."
            ))
            evidence.append("Standard conversational or transactional text.")

        final_score = min(100, max(0, score))

        if final_score >= 80:
            severity = "CRITICAL"
            decision = "BLOCK_THREAT"
            rec = "CRITICAL PHISHING ALERT: Do not disclose codes or click links. Report and block sender immediately."
        elif final_score >= 60:
            severity = "HIGH"
            decision = "BLOCK_THREAT"
            rec = "HIGH RISK: Message exhibits strong smishing markers. Avoid interaction."
        elif final_score >= 40:
            severity = "MEDIUM"
            decision = "FLAG_SUSPICIOUS"
            rec = "SUSPICIOUS: Unsolicited request containing external references. Verify via official app."
        elif final_score >= 20:
            severity = "LOW"
            decision = "USER_VERIFICATION_REQUIRED"
            rec = "LOW RISK: Minor heuristic indicators present. Exercise standard caution."
        else:
            severity = "SAFE"
            decision = "ALLOW_SAFE"
            rec = "SAFE: No malicious indicators detected."

        confidence = 0.94 if (OTP_PATTERN.search(message) or urls) else 0.86

        return AnalysisResponse(
            riskScore=final_score,
            severity=severity,
            decision=decision,
            signals=signals,
            evidence=evidence,
            recommendation=rec,
            confidence=confidence,
            metadata={
                "extracted_urls": urls,
                "sender": sender,
                "model": f"{self.model_name} v{self.model_version}"
            }
        )

class MessageService:
    def __init__(self, model: Optional[BaseAnalysisModel] = None):
        self._model = model or RuleBasedMessageModel()

    def set_model(self, model: BaseAnalysisModel):
        self._model = model

    async def analyze_message(self, message: str, sender: str = "", package_name: str = "") -> AnalysisResponse:
        return await self._model.analyze(message, sender=sender, package_name=package_name)

# Singleton service instance
message_service = MessageService()
