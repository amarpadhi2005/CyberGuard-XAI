import pytest
from app.ml.url_classifier import evaluate_url_threat

def test_xai_url_signals_and_evidence():
    target = "http://paypa1-account-security.top/login"
    res = evaluate_url_threat(target)

    assert res["riskScore"] >= 70
    assert len(res["reasons"]) > 0
    assert "CRITICAL" in res["severity"] or "HIGH" in res["severity"]

    # Verify no private chain of thought in returned reasons
    for reason in res["reasons"]:
        assert "chain of thought" not in reason.lower()
        assert "hidden reasoning" not in reason.lower()
        assert "prompt" not in reason.lower()
