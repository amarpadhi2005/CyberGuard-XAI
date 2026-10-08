from typing import Optional
from app.services.base import BaseAnalysisModel
from app.models.analysis import AnalysisResponse, SignalModel
from app.ml.url_classifier import evaluate_url_threat

class HeuristicUrlModel(BaseAnalysisModel):
    @property
    def model_name(self) -> str:
        return "CyberGuard Forensic URL Classifier"

    @property
    def model_version(self) -> str:
        return "1.2.0"

    async def analyze(self, target: str, **kwargs) -> AnalysisResponse:
        url = target.strip()
        eval_res = evaluate_url_threat(url)
        score = eval_res["riskScore"]
        severity = eval_res["severity"]
        domain = eval_res.get("domain", "")

        signals = []
        evidence = []

        if eval_res.get("is_known_threat"):
            signals.append(SignalModel(
                name="Threat Intelligence Blacklist",
                category="Threat Intelligence",
                score_impact=100,
                is_positive=False,
                description=f"Domain '{domain}' matches active cybercrime infrastructure in global blacklist."
            ))
            evidence.append(f"Confirmed blacklist match for domain '{domain}'.")

        if eval_res.get("has_lookalike"):
            target_brand = eval_res.get("lookalike_target", "legitimate brand")
            signals.append(SignalModel(
                name="Typosquatting Impersonation",
                category="Domain Governance",
                score_impact=45,
                is_positive=False,
                description=f"Hostname mimics legitimate brand '{target_brand}' via character substitution."
            ))
            evidence.append(f"Typosquatting spoof targeting '{target_brand}'.")

        if eval_res.get("is_ip_address"):
            signals.append(SignalModel(
                name="Direct IP Host",
                category="Network Transport",
                score_impact=40,
                is_positive=False,
                description="Raw IPv4 numerical host bypassing domain registry controls."
            ))
            evidence.append(f"Host uses raw numerical IP address ({domain}).")

        if not eval_res.get("is_https"):
            signals.append(SignalModel(
                name="Unencrypted Transport",
                category="Network Transport",
                score_impact=20,
                is_positive=False,
                description="Cleartext HTTP transmission lacks TLS/SSL cryptographic integrity."
            ))
            evidence.append("Unencrypted HTTP protocol.")
        else:
            signals.append(SignalModel(
                name="TLS Encryption",
                category="Network Transport",
                score_impact=-10,
                is_positive=True,
                description="Valid HTTPS transport protocol."
            ))

        if eval_res.get("subdomain_count", 0) >= 2:
            signals.append(SignalModel(
                name="Excessive Subdomains",
                category="Domain Governance",
                score_impact=25,
                is_positive=False,
                description=f"Subdomain depth ({eval_res['subdomain_count']}) used to obscure destination."
            ))
            evidence.append(f"Subdomain depth: {eval_res['subdomain_count']}.")

        if eval_res.get("is_shortened"):
            signals.append(SignalModel(
                name="URL Shortener Obfuscation",
                category="Obfuscation",
                score_impact=20,
                is_positive=False,
                description=f"Destination obscured via URL redirection service ({domain})."
            ))
            evidence.append(f"Shortened link via {domain}.")

        if not signals:
            signals.append(SignalModel(
                name="Clean Domain Baseline",
                category="Reputation",
                score_impact=0,
                is_positive=True,
                description="No homoglyphs, threat blacklist hits, or unencrypted credential flows."
            ))
            evidence.append("Clean domain reputation and standard HTTPS.")

        # Determine decision
        if score >= 70:
            decision = "BLOCK_THREAT"
        elif score >= 50:
            decision = "FLAG_SUSPICIOUS"
        elif score >= 25:
            decision = "USER_VERIFICATION_REQUIRED"
        else:
            decision = "ALLOW_SAFE"

        # Realistic confidence calculation
        confidence = 0.96 if eval_res.get("is_known_threat") else (0.91 if eval_res.get("has_lookalike") else 0.88)

        return AnalysisResponse(
            riskScore=score,
            severity=severity,
            decision=decision,
            signals=signals,
            evidence=evidence,
            recommendation=eval_res.get("recommendation", "Exercise caution when browsing."),
            confidence=confidence,
            metadata={
                "normalized_url": eval_res.get("normalized_url"),
                "domain": domain,
                "model": f"{self.model_name} v{self.model_version}"
            }
        )

class UrlService:
    def __init__(self, model: Optional[BaseAnalysisModel] = None):
        self._model = model or HeuristicUrlModel()

    def set_model(self, model: BaseAnalysisModel):
        """Allows runtime swapping of ML model"""
        self._model = model

    async def analyze_url(self, url: str) -> AnalysisResponse:
        return await self._model.analyze(url)

# Singleton service instance
url_service = UrlService()
