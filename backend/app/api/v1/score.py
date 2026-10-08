"""
CyberGuard Personal Security Score API Routes
Handles score evaluation, transparent factor rules, and delta explainability logs.
"""

from fastapi import APIRouter, HTTPException, Query, Body
from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field
from datetime import datetime, timezone
import uuid

from app.ml.scoring_engine import (
    scoring_engine,
    PersonalSecurityScoreResult,
    ScoreDeltaRecord,
)

router = APIRouter(prefix="/score", tags=["Personal Security Score"])

# In-memory mock/fallback store for score state & delta audit history
# (Mirrors Supabase public.security_score and public.security_score_history)
CURRENT_POSTURE_STATE = {
    "call_screening_enabled": True,
    "auto_block_high_risk_calls": True,
    "notification_listener_enabled": True,
    "scam_token_sniffer_enabled": True,
    "biometric_lock_enabled": True,
    "realtime_hud_enabled": True,
    "telemetry_anonymization_enabled": True,
    "training_modules_completed": 3,
    "total_training_modules": 4,
    "unresolved_critical_threats": 0,
    "unresolved_high_threats": 0,
    "dangerous_links_clicked_last_30d": 0,
    "clipboard_url_scanner_enabled": True,
    "scam_call_blocklist_enabled": True,
    "verified_calls_safely_blocked": 4,
}

HISTORICAL_DELTAS: List[Dict[str, Any]] = [
    {
        "id": "delta_hist_01",
        "timestamp": "2026-10-02T19:30:00Z",
        "previous_score": 83,
        "new_score": 88,
        "delta": 5,
        "factor_category": "USER_TRAINING",
        "trigger_title": "Training Module 3 Completed (+4 pts)",
        "reason_explanation": "Your score increased by 4 points because you successfully completed the 'Dangerous Links & Quishing Defense' training module and scored 100% on the quiz.",
        "remediation_action": None,
    },
    {
        "id": "delta_hist_02",
        "timestamp": "2026-10-02T14:15:00Z",
        "previous_score": 78,
        "new_score": 83,
        "delta": 5,
        "factor_category": "CALL_PROTECTION",
        "trigger_title": "Auto-Block High-Risk Calls Enabled (+5 pts)",
        "reason_explanation": "Your score increased by 5 points after engaging automatic blocking for spoofed and vishing telephone numbers in CyberGuard Call Protection.",
        "remediation_action": None,
    },
    {
        "id": "delta_hist_03",
        "timestamp": "2026-10-01T22:00:00Z",
        "previous_score": 86,
        "new_score": 78,
        "delta": -8,
        "factor_category": "THREAT_EVENTS",
        "trigger_title": "Critical Phishing SMS Intercepted (-8 pts)",
        "reason_explanation": "Your score dropped by 8 points because an incoming SMS contained a high-risk credential-harvesting banking domain. Resolving the threat restored the score.",
        "remediation_action": "Quarantine active threat alerts (+8 pts)",
    },
]


class RecalculateRequest(BaseModel):
    call_screening_enabled: Optional[bool] = None
    auto_block_high_risk_calls: Optional[bool] = None
    notification_listener_enabled: Optional[bool] = None
    scam_token_sniffer_enabled: Optional[bool] = None
    biometric_lock_enabled: Optional[bool] = None
    realtime_hud_enabled: Optional[bool] = None
    telemetry_anonymization_enabled: Optional[bool] = None
    training_modules_completed: Optional[int] = None
    unresolved_critical_threats: Optional[int] = None
    unresolved_high_threats: Optional[int] = None
    dangerous_links_clicked_last_30d: Optional[int] = None
    clipboard_url_scanner_enabled: Optional[bool] = None
    scam_call_blocklist_enabled: Optional[bool] = None
    verified_calls_safely_blocked: Optional[int] = None


class TrainingCompletionRequest(BaseModel):
    module_index: int = Field(..., ge=1, le=4, description="Module number (1 to 4)")
    score_percent: int = Field(default=100, ge=0, le=100)


@router.get("", summary="Get Current Personal Security Score")
def get_personal_security_score():
    """
    Returns current personal security score (0-100), letter grade,
    granular 7-factor breakdown, rules transparency, and actionable improvements.
    """
    result = scoring_engine.evaluate_score(**CURRENT_POSTURE_STATE)
    return {
        "status": "success",
        "data": {
            "overall_score": result.overall_score,
            "grade": result.grade,
            "posture_title": result.posture_title,
            "posture_description": result.posture_description,
            "scoring_timestamp": result.scoring_timestamp,
            "factors": {
                k: {
                    "category": f.category,
                    "name": f.name,
                    "current_points": f.current_points,
                    "max_points": f.max_points,
                    "status": f.status,
                    "summary": f.summary,
                    "rules": [
                        {
                            "rule_id": r.rule_id,
                            "title": r.title,
                            "description": r.description,
                            "points_awarded": r.points_awarded,
                            "max_points": r.max_points,
                            "is_satisfied": r.is_satisfied,
                            "explanation": r.explanation,
                            "remediation_action": r.remediation_action,
                        }
                        for r in f.rules
                    ],
                }
                for k, f in result.factors.items()
            },
            "actionable_improvements": result.actionable_improvements,
            "recent_score_changes": HISTORICAL_DELTAS[:5],
        },
    }


@router.get("/history", summary="Score Change History & Delta Explainability")
def get_score_history(limit: int = Query(default=10, ge=1, le=50)):
    """
    Shows users exactly why their score changed over time,
    with granular deltas (+/-), factor categories, and transparent explanations.
    """
    return {
        "status": "success",
        "data": {
            "total_records": len(HISTORICAL_DELTAS),
            "history": HISTORICAL_DELTAS[:limit],
        },
    }


@router.get("/rules", summary="Public Transparent Scoring Rubric")
def get_scoring_rubric():
    """
    Returns public specification of the mathematical scoring rules,
    point allocations, and criteria.
    """
    return {
        "status": "success",
        "data": scoring_engine.get_public_transparent_rules(),
    }


@router.post("/recalculate", summary="Recalculate Score with New Posture")
def recalculate_score(req: RecalculateRequest):
    """
    Recalculates the personal security score based on updated factors,
    generates "Why Did My Score Change?" deltas, and updates audit history.
    """
    previous_result = scoring_engine.evaluate_score(**CURRENT_POSTURE_STATE)

    # Apply updates
    updates = req.model_dump(exclude_unset=True)
    for k, v in updates.items():
        if v is not None and k in CURRENT_POSTURE_STATE:
            CURRENT_POSTURE_STATE[k] = v

    new_result = scoring_engine.evaluate_score(**CURRENT_POSTURE_STATE)
    deltas = scoring_engine.explain_score_delta(previous_result, new_result)

    # Store deltas in history
    for d in deltas:
        delta_dict = {
            "id": f"delta_{uuid.uuid4().hex[:8]}",
            "timestamp": d.timestamp,
            "previous_score": d.previous_score,
            "new_score": d.new_score,
            "delta": d.delta,
            "factor_category": d.factor_category,
            "trigger_title": d.trigger_title,
            "reason_explanation": d.reason_explanation,
            "remediation_action": d.remediation_action,
        }
        HISTORICAL_DELTAS.insert(0, delta_dict)

    return {
        "status": "success",
        "message": f"Score recalculated: {previous_result.overall_score} -> {new_result.overall_score}",
        "data": {
            "previous_score": previous_result.overall_score,
            "new_score": new_result.overall_score,
            "net_delta": new_result.overall_score - previous_result.overall_score,
            "grade": new_result.grade,
            "deltas_generated": [
                {
                    "factor": d.factor_category,
                    "delta": d.delta,
                    "trigger": d.trigger_title,
                    "explanation": d.reason_explanation,
                    "remediation": d.remediation_action,
                }
                for d in deltas
            ],
            "factors": {
                k: {
                    "name": f.name,
                    "points": f.current_points,
                    "max": f.max_points,
                    "status": f.status,
                }
                for k, f in new_result.factors.items()
            },
        },
    }


@router.post("/training/complete", summary="Complete User Training Module")
def complete_training_module(req: TrainingCompletionRequest):
    """
    Completes a specific cyber awareness training module and recalculates score,
    logging a transparent score gain event.
    """
    current_completed = CURRENT_POSTURE_STATE["training_modules_completed"]
    if req.module_index > current_completed:
        CURRENT_POSTURE_STATE["training_modules_completed"] = req.module_index

    # Recalculate
    return recalculate_score(RecalculateRequest(training_modules_completed=CURRENT_POSTURE_STATE["training_modules_completed"]))


@router.post("/threat/resolve", summary="Resolve Active Threat Event")
def resolve_threat_event(threat_type: str = Query(default="CRITICAL", enum=["CRITICAL", "HIGH"])):
    """
    Simulates resolving/quarantining an active threat, recovering deducted score points.
    """
    if threat_type == "CRITICAL" and CURRENT_POSTURE_STATE["unresolved_critical_threats"] > 0:
        CURRENT_POSTURE_STATE["unresolved_critical_threats"] -= 1
    elif threat_type == "HIGH" and CURRENT_POSTURE_STATE["unresolved_high_threats"] > 0:
        CURRENT_POSTURE_STATE["unresolved_high_threats"] -= 1

    return recalculate_score(RecalculateRequest(
        unresolved_critical_threats=CURRENT_POSTURE_STATE["unresolved_critical_threats"],
        unresolved_high_threats=CURRENT_POSTURE_STATE["unresolved_high_threats"]
    ))
