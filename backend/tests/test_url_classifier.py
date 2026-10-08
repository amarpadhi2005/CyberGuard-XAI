import pytest
from app.ml.url_classifier import (
    normalize_url,
    levenshtein_distance,
    detect_lookalike_domain,
    evaluate_url_threat,
)

def test_url_normalization():
    raw = "  HTTP://Example.COM:80/path/test/#section1  "
    normalized = normalize_url(raw)
    assert normalized == "http://example.com/path/test/"

    no_scheme = "chase.com/login"
    assert normalize_url(no_scheme) == "https://chase.com/login"

def test_levenshtein_distance():
    assert levenshtein_distance("paypal", "paypa1") == 1
    assert levenshtein_distance("google", "goog1e") == 1
    assert levenshtein_distance("apple", "apple") == 0

def test_lookalike_detection():
    is_lookalike, target = detect_lookalike_domain("paypa1-security.com")
    assert is_lookalike is True
    assert target == "paypal"

    is_lookalike, target = detect_lookalike_domain("paypal.com.verify-identity.xyz")
    assert is_lookalike is True
    assert target == "paypal"

def test_https_check():
    eval_result = evaluate_url_threat("http://mybank-account.com/login")
    assert eval_result["is_https"] is False
    assert any("Unencrypted HTTP" in r for r in eval_result["reasons"])
    assert eval_result["riskScore"] >= 30

def test_suspicious_domain_detection():
    eval_result = evaluate_url_threat("https://fast-cash-reward.top")
    assert any(".top" in r for r in eval_result["reasons"])
    assert eval_result["riskScore"] >= 30

def test_excessive_subdomains_detection():
    eval_result = evaluate_url_threat("https://auth.login.verify.account.chase.fakehost.com")
    assert eval_result["subdomain_count"] >= 2
    assert any("Excessive subdomain depth" in r for r in eval_result["reasons"])

def test_suspicious_path_detection():
    eval_result = evaluate_url_threat("https://legitlookingdomain.org/account-update.php")
    assert any("authentication path keywords" in r for r in eval_result["reasons"])

def test_ip_address_detection():
    eval_result = evaluate_url_threat("http://192.168.1.100/admin/login")
    assert eval_result["is_ip_address"] is True
    assert any("raw IP address" in r for r in eval_result["reasons"])
    assert eval_result["riskScore"] >= 50

def test_url_shortening_detection():
    eval_result = evaluate_url_threat("https://bit.ly/3abc123")
    assert eval_result["is_shortened"] is True
    assert any("link shortener" in r for r in eval_result["reasons"])

def test_known_threat_lookup():
    eval_result = evaluate_url_threat("http://paypa1-verify.top/auth")
    assert eval_result["is_known_threat"] is True
    assert eval_result["riskScore"] == 100
    assert eval_result["severity"] == "CRITICAL"

def test_safe_clean_url():
    eval_result = evaluate_url_threat("https://www.google.com")
    assert eval_result["riskScore"] == 0
    assert eval_result["severity"] == "SAFE"
    assert eval_result["recommendation"].startswith("SAFE")
