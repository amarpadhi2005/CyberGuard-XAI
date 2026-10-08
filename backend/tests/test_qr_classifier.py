import pytest
from app.ml.qr_classifier import evaluate_qr_threat

def test_phishing_url_qr():
    payload = "http://paypa1-account-security.top/login"
    result = evaluate_qr_threat(payload)

    assert result["is_url"] is True
    assert result["is_payment_or_deep_link"] is False
    assert result["payload_type"] == "URL"
    assert result["riskScore"] >= 70
    assert result["severity"] in ["HIGH", "CRITICAL"]
    assert "DANGEROUS QR LINK" in result["warning_title"]
    assert "NEVER OPEN THIS URL" in result["recommendation"]

def test_direct_apk_download_qr():
    payload = "https://unverified-app-store.xyz/download/update_patch.apk"
    result = evaluate_qr_threat(payload)

    assert result["is_url"] is True
    assert any("unsigned Android Package (.apk)" in r for r in result["reasons"])
    assert result["riskScore"] >= 60

def test_deceptive_upi_payment_qr():
    payload = "upi://pay?pa=scam-support@upi&pn=Bank%20KYC%20Validation%20Officer&am=8500&cu=INR&tn=Urgent%20KYC%20Reversal"
    result = evaluate_qr_threat(payload)

    assert result["is_url"] is False
    assert result["is_payment_or_deep_link"] is True
    assert result["payload_type"] == "PAYMENT_UPI"
    assert result["riskScore"] >= 75
    assert any("imposter scam" in r for r in result["reasons"])
    assert "PAYMENT TRANSFER ALERT" in result["warning_title"]
    assert result["payment_details"]["is_deceptive"] is True

def test_crypto_wallet_qr():
    payload = "bitcoin:1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa?amount=1.2"
    result = evaluate_qr_threat(payload)

    assert result["is_url"] is False
    assert result["is_payment_or_deep_link"] is True
    assert result["payload_type"] == "PAYMENT_CRYPTO"
    assert any("irreversible" in r for r in result["reasons"])
    assert "CRYPTOCURRENCY WALLET" in result["warning_title"]

def test_deep_link_intent_qr():
    payload = "intent://scan/#Intent;scheme=maliciousapp;package=com.victim.app;end"
    result = evaluate_qr_threat(payload)

    assert result["is_url"] is False
    assert result["is_payment_or_deep_link"] is True
    assert result["payload_type"] == "DEEP_LINK"
    assert result["riskScore"] >= 70
    assert any("Android Intent URI" in r for r in result["reasons"])

def test_clean_safe_url_qr():
    payload = "https://www.google.com/search?q=cyberguard"
    result = evaluate_qr_threat(payload)

    assert result["is_url"] is True
    assert result["riskScore"] == 0
    assert result["severity"] == "SAFE"
    assert result["warning_title"] == "VERIFIED WEB LINK"
