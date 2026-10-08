from typing import Optional
from app.services.base import BaseAnalysisModel
from app.models.analysis import AnalysisResponse, SignalModel
from app.ml.qr_classifier import evaluate_qr_threat

class HeuristicQrModel(BaseAnalysisModel):
    @property
    def model_name(self) -> str:
        return "CyberGuard Optical QR & Reverse Exploit Detector"

    @property
    def model_version(self) -> str:
        return "1.1.0"

    async def analyze(self, target: str, **kwargs) -> AnalysisResponse:
        payload = target.strip()
        eval_res = evaluate_qr_threat(payload)
        score = eval_res["riskScore"]
        severity = eval_res["severity"]
        payload_type = eval_res.get("payload_type", "PLAIN_TEXT")

        signals = []
        evidence = []

        if payload_type == "URL":
            url_info = eval_res.get("url_evaluation", {})
            domain = url_info.get("domain", "")
            signals.append(SignalModel(
                name="QR Hyperlink Redirection",
                category="Hyperlink Routing",
                score_impact=min(score, 60),
                is_positive=False,
                description=f"Decoded QR routes to external domain '{domain}' with risk {url_info.get('riskScore', 0)}/100."
            ))
            evidence.append(f"External domain destination: {domain}")
            if ".apk" in payload.lower():
                signals.append(SignalModel(
                    name="Unsigned APK Download",
                    category="Executable Payload",
                    score_impact=30,
                    is_positive=False,
                    description="QR payload triggers direct download of unverified Android Application Package (.apk)."
                ))
                evidence.append("Direct APK package download trigger.")

        elif payload_type == "PAYMENT_UPI":
            details = eval_res.get("payment_details", {})
            payee = details.get("payee_name") or details.get("payee_address") or "Unknown"
            signals.append(SignalModel(
                name="Financial Transfer Trigger (UPI)",
                category="Financial Exploitation",
                score_impact=45,
                is_positive=False,
                description=f"Pre-configured debit request prompting financial transfer authorization to '{payee}'."
            ))
            evidence.append(f"UPI payment payload targeting payee: {payee}")
            if details.get("is_deceptive"):
                signals.append(SignalModel(
                    name="Deceptive Payee Impersonation",
                    category="Impersonation",
                    score_impact=35,
                    is_positive=False,
                    description="Payee name mimics official customer support or lottery department."
                ))
                evidence.append("Deceptive support/lottery payee title detected.")

        elif payload_type == "PAYMENT_CRYPTO":
            signals.append(SignalModel(
                name="Irreversible Crypto Wallet Address",
                category="Financial Risk",
                score_impact=55,
                is_positive=False,
                description="Target is a public blockchain wallet address; transactions are non-reversible and non-refundable."
            ))
            evidence.append("Decoded cryptocurrency wallet address.")

        elif payload_type == "DEEP_LINK":
            signals.append(SignalModel(
                name="Application Intent Launch",
                category="Application Security",
                score_impact=60,
                is_positive=False,
                description="Custom URI scheme intended to invoke local application intents or app store installations."
            ))
            evidence.append("Application deep-link intent detected.")

        else:
            signals.append(SignalModel(
                name="Plain Text Content",
                category="Data Format",
                score_impact=0,
                is_positive=True,
                description="QR code decodes to non-executable plain text."
            ))
            evidence.append("Benign plain text content.")

        if score >= 70:
            decision = "BLOCK_THREAT"
        elif score >= 50:
            decision = "FLAG_SUSPICIOUS"
        elif score >= 25:
            decision = "USER_VERIFICATION_REQUIRED"
        else:
            decision = "ALLOW_SAFE"

        confidence = 0.95 if eval_res.get("is_payment_or_deep_link") else 0.89

        return AnalysisResponse(
            riskScore=score,
            severity=severity,
            decision=decision,
            signals=signals,
            evidence=evidence,
            recommendation=eval_res.get("recommendation", "Exercise caution before navigating QR links."),
            confidence=confidence,
            metadata={
                "payload_type": payload_type,
                "raw_payload": payload,
                "model": f"{self.model_name} v{self.model_version}"
            }
        )

class QrService:
    def __init__(self, model: Optional[BaseAnalysisModel] = None):
        self._model = model or HeuristicQrModel()

    def set_model(self, model: BaseAnalysisModel):
        self._model = model

    async def analyze_qr(self, payload: str, format_type: str = "QR_CODE") -> AnalysisResponse:
        return await self._model.analyze(payload, format=format_type)

# Singleton service instance
qr_service = QrService()
