import re
from urllib.parse import urlparse, parse_qs
from typing import Dict, List, Optional
from app.ml.url_classifier import evaluate_url_threat, normalize_url

DECEPTIVE_PAYEE_KEYWORDS = [
    "support", "refund", "kyc", "prize", "cashback", "lottery",
    "security", "customercare", "verification", "claim", "reward",
    "officer", "helpdesk", "telecom", "bank"
]

CRYPTO_SCHEMES = ("bitcoin:", "ethereum:", "solana:", "bitcoincash:", "litecoin:", "usdt:")
WALLET_SCHEMES = ("paypal://", "venmo://", "cashme://", "gpay://", "phonepe://", "paytm://")

def is_url_payload(payload: str) -> bool:
    trimmed = payload.strip()
    if re.match(r"^(?i)(https?|ftp)://.+", trimmed):
        return True
    if re.match(r"^(?i)[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(/.*)?$", trimmed) and "://" not in trimmed:
        return True
    return False

def evaluate_qr_threat(raw_payload: str) -> Dict:
    trimmed = raw_payload.strip()
    if not trimmed:
        return {
            "riskScore": 0,
            "severity": "SAFE",
            "reasons": ["Empty payload"],
            "recommendation": "No action required.",
            "payload_type": "PLAIN_TEXT",
            "is_url": False,
            "is_payment_or_deep_link": False,
            "warning_title": None,
            "warning_message": None,
            "raw_payload": ""
        }

    # 1. URL Analysis
    if is_url_payload(trimmed):
        url_eval = evaluate_url_threat(trimmed)
        reasons = list(url_eval.get("reasons", []))
        extra_score = 0

        is_apk = trimmed.lower().endswith(".apk") or ".apk?" in trimmed.lower()
        if is_apk:
            extra_score += 30
            reasons.append("QR code initiates direct download of unsigned Android Package (.apk)")

        final_score = min(100, max(0, url_eval["riskScore"] + extra_score))

        if final_score >= 85:
            severity = "CRITICAL"
        elif final_score >= 70:
            severity = "HIGH"
        elif final_score >= 50:
            severity = "MEDIUM"
        elif final_score >= 25:
            severity = "LOW"
        else:
            severity = "SAFE"

        is_threat = final_score >= 50
        warning_title = "DANGEROUS QR LINK BLOCKED" if is_threat else "VERIFIED WEB LINK"
        warning_message = (
            "CyberGuard prevented automatic navigation. This QR link was flagged for malicious or phishing indicators. Never open unverified links."
            if is_threat else
            "Standard web hyperlink decoded. Confirm domain authenticity before proceeding."
        )

        recommendation = (
            "NEVER OPEN THIS URL. Discard this QR code and do not enter any credentials or download files."
            if is_threat else
            f"Review destination domain ({url_eval.get('domain', '')}) before opening in your browser."
        )

        return {
            "riskScore": final_score,
            "severity": severity,
            "reasons": reasons,
            "recommendation": recommendation,
            "payload_type": "URL",
            "is_url": True,
            "is_payment_or_deep_link": False,
            "url_evaluation": url_eval,
            "warning_title": warning_title,
            "warning_message": warning_message,
            "raw_payload": trimmed
        }

    # 2. UPI Payment Scheme
    if trimmed.lower().startswith("upi://pay"):
        parsed = urlparse(trimmed)
        params = parse_qs(parsed.query)

        payee_address = params.get("pa", [None])[0]
        payee_name = params.get("pn", [None])[0]
        amount = params.get("am", [None])[0]
        currency = params.get("cu", ["INR"])[0]

        score = 45
        reasons = ["UPI payment request decoded; will prompt your banking app to authorize money transfer"]
        is_deceptive = False

        if payee_name:
            lower_name = payee_name.lower()
            if any(k in lower_name for k in DECEPTIVE_PAYEE_KEYWORDS):
                is_deceptive = True
                score += 35
                reasons.append(f"Payee name '{payee_name}' mimics official support or verification departments (common imposter scam)")

        if amount:
            try:
                amt_val = float(amount)
                if amt_val > 0:
                    score += 20
                    reasons.append(f"Auto-filled debit transfer amount: {currency} {amount} (funds will be deducted upon PIN entry)")
            except ValueError:
                pass
        else:
            reasons.append("Open-amount transfer target: user input amount requested")

        final_score = min(100, max(0, score))
        severity = "CRITICAL" if final_score >= 80 else ("HIGH" if final_score >= 65 else "MEDIUM")

        return {
            "riskScore": final_score,
            "severity": severity,
            "reasons": reasons,
            "recommendation": f"WARNING: Verify payee details ({payee_name or payee_address or 'Unknown'}) thoroughly. Scammers use pre-filled UPI QRs to trick victims into entering UPI PINs to receive money.",
            "payload_type": "PAYMENT_UPI",
            "is_url": False,
            "is_payment_or_deep_link": True,
            "warning_title": "PAYMENT TRANSFER ALERT (UPI)",
            "warning_message": f"Scanning this QR code will initiate a financial transaction to '{payee_name or payee_address}'. Never enter your UPI PIN to receive money.",
            "raw_payload": trimmed,
            "payment_details": {
                "scheme": "UPI",
                "payee_address": payee_address,
                "payee_name": payee_name,
                "amount": amount,
                "currency": currency,
                "is_deceptive": is_deceptive
            }
        }

    # 3. Crypto Payment Scheme
    if any(trimmed.lower().startswith(s) for s in CRYPTO_SCHEMES):
        scheme = trimmed.split(":")[0].upper()
        return {
            "riskScore": 55,
            "severity": "MEDIUM",
            "reasons": [
                f"Cryptocurrency wallet address targeting {scheme} blockchain",
                "Transactions on public blockchains are permanent and irreversible",
                "Frequent target for clipboard-swapping and crypto-drainer malware"
            ],
            "recommendation": "Exercise extreme caution. Verify destination wallet address character-by-character before signing.",
            "payload_type": "PAYMENT_CRYPTO",
            "is_url": False,
            "is_payment_or_deep_link": True,
            "warning_title": "CRYPTOCURRENCY WALLET DETECTED",
            "warning_message": "Transferring assets to this address cannot be refunded, reversed, or charged back by any bank.",
            "raw_payload": trimmed
        }

    # 4. App Deep-Links / Intents
    if trimmed.lower().startswith("intent://") or trimmed.lower().startswith("market://"):
        is_intent = trimmed.lower().startswith("intent://")
        score = 75 if is_intent else 55
        severity = "HIGH" if is_intent else "MEDIUM"
        return {
            "riskScore": score,
            "severity": severity,
            "reasons": [
                "Full Android Intent URI detected; can expose vulnerable unexported components or trigger silent APK install" if is_intent else "External app store direct package installer link"
            ],
            "recommendation": "Do not allow unknown deep-links to launch external application processes.",
            "payload_type": "DEEP_LINK",
            "is_url": False,
            "is_payment_or_deep_link": True,
            "warning_title": "APP INTENT LAUNCH ATTEMPT",
            "warning_message": "This QR code attempts to launch an application deep-link. Unauthorized intents may bypass browser sandboxes.",
            "raw_payload": trimmed
        }

    # 5. Generic Text
    return {
        "riskScore": 0,
        "severity": "SAFE",
        "reasons": ["Standard text payload with no executable schemes or hyperlink routes"],
        "recommendation": "Payload contains plain text data.",
        "payload_type": "PLAIN_TEXT",
        "is_url": False,
        "is_payment_or_deep_link": False,
        "warning_title": "PLAIN TEXT CONTENT",
        "warning_message": "Decoded non-executable text content.",
        "raw_payload": trimmed
    }
