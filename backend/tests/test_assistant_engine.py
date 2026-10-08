import pytest
from app.ml.assistant_engine import generate_assistant_response

def test_url_context_is_this_safe():
    res = generate_assistant_response(
        question="Is this safe?",
        context_type="URL",
        context_content="http://paypa1-account-security.top/login"
    )

    assert "CRITICAL" in res["risk"] or "HIGH" in res["risk"]
    assert "No, this link is NOT safe" in res["explanation"]
    assert len(res["evidence"]) > 0
    assert "High" in res["confidence"]
    assert len(res["recommended_action"]) > 0

def test_pasted_message_why_is_this_suspicious():
    res = generate_assistant_response(
        question="Why is this suspicious?",
        context_type="PASTED_MESSAGE",
        context_content="URGENT: Your bank account is suspended immediately. Send your 6-digit OTP code to unlock."
    )

    assert any("OTP" in e or "passcode" in e for e in res["evidence"])
    assert any("urgency" in e for e in res["evidence"])
    assert "Suspicious" in res["risk"] or "CRITICAL" in res["risk"]

def test_qr_result_what_should_i_do():
    res = generate_assistant_response(
        question="What should I do?",
        context_type="QR_RESULT",
        context_content="upi://pay?pa=scam-support@upi&pn=Bank%20KYC%20Validation&am=5000"
    )

    assert "DO NOT enter your UPI PIN" in res["explanation"]
    assert "High" in res["confidence"]

def test_call_risk_how_serious():
    res = generate_assistant_response(
        question="How serious is this?",
        context_type="CALL_RISK",
        context_content="+1-800-424-9098",
        metadata={"riskScore": 85, "reasons": "VoIP origin;IRS imposter;Voice clone"}
    )

    assert "HIGH" in res["risk"] or "CRITICAL" in res["risk"]
    assert "IRS imposter" in res["explanation"]

def test_how_can_i_verify():
    res = generate_assistant_response(
        question="How can I verify this?",
        context_type="URL",
        context_content="https://suspicious-reward-portal.xyz/claim"
    )

    assert "WHOIS" in res["explanation"] or "official" in res["explanation"]

def test_never_claim_certainty_on_insufficient_evidence():
    res = generate_assistant_response(
        question="Is this safe?",
        context_type="PASTED_MESSAGE",
        context_content="Hello"
    )

    assert res["risk"] == "UNCERTAIN / INSUFFICIENT EVIDENCE"
    assert res["is_certainty_claimed"] is False
    assert "Low" in res["confidence"]
    assert "insufficient textual context" in res["explanation"]
