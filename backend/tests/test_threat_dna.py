from fastapi.testclient import TestClient
from app.main import app
from app.core.config import settings

client = TestClient(app)
AUTH_HEADERS = {"X-API-Key": settings.BACKEND_API_KEY}

def test_threat_dna_correlation():
    payload = {
        "time_window_hours": 24
    }
    response = client.post("/threat-dna/correlate", json=payload, headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()

    assert data["total_events_evaluated"] == 4
    assert len(data["campaigns"]) == 1

    campaign = data["campaigns"][0]
    assert campaign["campaign_id"].startswith("DNA-CMP-")
    assert campaign["threat_dna_fingerprint"].startswith("DNA:")
    assert campaign["correlation_status"] == "POSSIBLE_RELATED_ACTIVITY"

    # Multi-vector escalation check
    assert campaign["escalated_risk_score"] > campaign["baseline_risk_score"]
    assert campaign["escalated_risk_score"] >= 90
    assert "multi-vector convergence" in campaign["escalation_reason"].lower()

    # Timeline check
    timeline = campaign["timeline"]
    assert len(timeline) == 4
    assert timeline[0]["elapsed_time_str"] == "T+00m"
    assert timeline[1]["step_number"] == 2
    assert "PAYMENT" in timeline[3]["vector"] or "QR" in timeline[3]["vector"]

    # Recommended action check
    assert "PLAYBOOK" in campaign["recommended_action"]

    # Phrasing and disclaimer check
    assert "possible related activity" in campaign["disclaimer"].lower()
    assert any("possible related activity" in ev.lower() for ev in campaign["correlation_evidence"])

def test_threat_dna_campaigns_get():
    response = client.get("/threat-dna/campaigns?time_window_hours=12", headers=AUTH_HEADERS)
    assert response.status_code == 200
    data = response.json()
    assert data["time_window_hours"] == 12
    assert len(data["campaigns"]) >= 1
