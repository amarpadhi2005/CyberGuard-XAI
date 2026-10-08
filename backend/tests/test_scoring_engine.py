"""
Unit tests for CyberGuard Personal Security Score Engine (0-100).
Verifies:
- All 7 factors calculation
- Transparent scoring rules
- Grade boundaries
- Score change delta analysis ("Why did my score change?")
"""

from app.ml.scoring_engine import PersonalSecurityScoreEngine, scoring_engine


def test_perfect_score_evaluation():
    """Verify that full protection on all 7 factors produces a clean 100 / A+."""
    res = scoring_engine.evaluate_score(
        call_screening_enabled=True,
        auto_block_high_risk_calls=True,
        notification_listener_enabled=True,
        scam_token_sniffer_enabled=True,
        biometric_lock_enabled=True,
        realtime_hud_enabled=True,
        telemetry_anonymization_enabled=True,
        training_modules_completed=4,
        total_training_modules=4,
        unresolved_critical_threats=0,
        unresolved_high_threats=0,
        dangerous_links_clicked_last_30d=0,
        clipboard_url_scanner_enabled=True,
        scam_call_blocklist_enabled=True,
        verified_calls_safely_blocked=5,
    )

    assert res.overall_score == 100
    assert res.grade == "A+"
    assert res.posture_title == "Maximum Shield"
    assert len(res.actionable_improvements) == 0

    # Verify all 7 factor point sums
    factors = res.factors
    assert factors["call_protection"].current_points == 15
    assert factors["notification_protection"].current_points == 15
    assert factors["security_settings"].current_points == 15
    assert factors["user_training"].current_points == 15
    assert factors["threat_events"].current_points == 15
    assert factors["dangerous_links"].current_points == 15
    assert factors["blocked_calls"].current_points == 10


def test_zero_defense_degraded_score():
    """Verify worst-case scenario with all defenses off, threats active, and dangerous links."""
    res = scoring_engine.evaluate_score(
        call_screening_enabled=False,
        auto_block_high_risk_calls=False,
        notification_listener_enabled=False,
        scam_token_sniffer_enabled=False,
        biometric_lock_enabled=False,
        realtime_hud_enabled=False,
        telemetry_anonymization_enabled=False,
        training_modules_completed=0,
        unresolved_critical_threats=3,
        unresolved_high_threats=2,
        dangerous_links_clicked_last_30d=3,
        clipboard_url_scanner_enabled=False,
        scam_call_blocklist_enabled=False,
        verified_calls_safely_blocked=0,
    )

    assert 0 <= res.overall_score <= 10
    assert res.grade == "F"
    assert res.posture_title == "Critical Hazard"
    assert len(res.actionable_improvements) > 0


def test_call_protection_factor_breakdown():
    """Verify call protection points (10 for screening + 5 for auto-block)."""
    # Only screening
    res1 = scoring_engine.evaluate_score(
        call_screening_enabled=True,
        auto_block_high_risk_calls=False,
    )
    assert res1.factors["call_protection"].current_points == 10

    # Both disabled
    res2 = scoring_engine.evaluate_score(
        call_screening_enabled=False,
        auto_block_high_risk_calls=False,
    )
    assert res2.factors["call_protection"].current_points == 0
    assert res2.factors["call_protection"].status == "CRITICAL"


def test_user_training_incremental_gains():
    """Verify incremental points awarded for completing training modules (4, 4, 4, 3 = 15)."""
    m0 = scoring_engine.evaluate_score(training_modules_completed=0)
    assert m0.factors["user_training"].current_points == 0

    m1 = scoring_engine.evaluate_score(training_modules_completed=1)
    assert m1.factors["user_training"].current_points == 4

    m2 = scoring_engine.evaluate_score(training_modules_completed=2)
    assert m2.factors["user_training"].current_points == 8

    m3 = scoring_engine.evaluate_score(training_modules_completed=3)
    assert m3.factors["user_training"].current_points == 12

    m4 = scoring_engine.evaluate_score(training_modules_completed=4)
    assert m4.factors["user_training"].current_points == 15


def test_recent_threat_events_penalty_and_recovery():
    """Verify critical threats subtract 8 pts, and resolving them restores the score."""
    clean = scoring_engine.evaluate_score(unresolved_critical_threats=0)
    assert clean.factors["threat_events"].current_points == 15

    threat_active = scoring_engine.evaluate_score(unresolved_critical_threats=1)
    assert threat_active.factors["threat_events"].current_points == 7  # 15 - 8 = 7

    two_threats = scoring_engine.evaluate_score(unresolved_critical_threats=2)
    assert two_threats.factors["threat_events"].current_points == 0  # 15 - 16 -> clamped at 0


def test_score_delta_explainability():
    """Verify delta explainability when score increases or decreases."""
    engine = PersonalSecurityScoreEngine()

    prev_state = engine.evaluate_score(
        call_screening_enabled=True,
        auto_block_high_risk_calls=False,  # 10 pts
        training_modules_completed=2,      # 8 pts
    )

    new_state = engine.evaluate_score(
        call_screening_enabled=True,
        auto_block_high_risk_calls=True,   # 15 pts (+5)
        training_modules_completed=3,      # 12 pts (+4)
    )

    deltas = engine.explain_score_delta(prev_state, new_state)
    assert len(deltas) == 2

    # Check Call Protection delta
    call_delta = next((d for d in deltas if d.factor_category == "CALL_PROTECTION"), None)
    assert call_delta is not None
    assert call_delta.delta == 5
    assert "Call Protection Enhanced" in call_delta.trigger_title
    assert "Auto-Block High-Risk Calls" in call_delta.reason_explanation

    # Check Training delta
    training_delta = next((d for d in deltas if d.factor_category == "USER_TRAINING"), None)
    assert training_delta is not None
    assert training_delta.delta == 4
    assert "User Training Completion" in training_delta.trigger_title


def test_public_transparent_rules():
    """Verify public transparency output has all 7 factors and mathematical formula."""
    rules_doc = scoring_engine.get_public_transparent_rules()
    assert "mathematical_formula" in rules_doc
    assert len(rules_doc["factors"]) == 7
    factor_names = [f["name"] for f in rules_doc["factors"]]
    assert "Call Protection" in factor_names
    assert "Notification Protection" in factor_names
    assert "Security Settings & Hygiene" in factor_names
    assert "User Training Completion" in factor_names
    assert "Recent Threat Events Posture" in factor_names
    assert "Dangerous Links Posture" in factor_names
    assert "Blocked Calls & Defense Efficacy" in factor_names
