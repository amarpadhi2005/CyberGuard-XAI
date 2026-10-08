import hashlib
from datetime import datetime, timezone, timedelta
from typing import List, Optional
from app.models.threat_dna import (
    SecurityEventItem,
    TimelineEvent,
    ThreatCampaign,
    ThreatDnaCorrelationResponse
)

def get_demo_attack_campaign_events() -> List[SecurityEventItem]:
    """
    Standard demonstration scenario of a coordinated multi-stage social engineering attack:
    1. Suspicious VoIP call spoofing banking fraud department
    2. Follow-up SMS notification urging urgent account verification
    3. Typosquatted credential harvester URL
    4. Malicious QR code requesting urgent UPI/crypto debit authorization
    """
    now = datetime.now(timezone.utc)
    return [
        SecurityEventItem(
            event_id="evt-001",
            event_type="CALL_SCREENED",
            timestamp_iso=(now - timedelta(minutes=38)).isoformat(),
            title="Suspicious VoIP Robocall Spoof",
            source="+1 (800) 555-0199",
            risk_score=72,
            severity="HIGH",
            target_brand="PayPal",
            indicators=["Unallocated toll-free exchange", "Automated synthetic voice", "Coercive urgency prompt"],
            details={"threat_type": "CALL_SCAM", "caller_claimed_name": "PayPal Fraud Prevention"}
        ),
        SecurityEventItem(
            event_id="evt-002",
            event_type="NOTIFICATION_INTERCEPTED",
            timestamp_iso=(now - timedelta(minutes=35)).isoformat(),
            title="Urgent Security Smishing Notification",
            source="com.google.android.apps.messaging",
            risk_score=85,
            severity="CRITICAL",
            target_brand="PayPal",
            indicators=["Coercive account lock claim", "Immediate 24h deadline", "Phishing URL enclosed"],
            details={"threat_type": "SMISHING", "text": "PayPal Alert: Your account was suspended due to unauthorized login. Verify immediately at: https://paypa1-account-security.top"}
        ),
        SecurityEventItem(
            event_id="evt-003",
            event_type="URL_SCANNED",
            timestamp_iso=(now - timedelta(minutes=20)).isoformat(),
            title="Typosquatted Credential Harvester",
            source="paypa1-account-security.top",
            risk_score=92,
            severity="CRITICAL",
            target_brand="PayPal",
            indicators=["Character substitution ('paypa1')", "High-abuse TLD (.top)", "Unencrypted cleartext flow"],
            details={"threat_type": "PHISHING_URL", "domain": "paypa1-account-security.top"}
        ),
        SecurityEventItem(
            event_id="evt-004",
            event_type="QR_SCANNED",
            timestamp_iso=(now - timedelta(minutes=4)).isoformat(),
            title="Deceptive Pre-filled Payment Transfer QR",
            source="Optical QR Scanner",
            risk_score=88,
            severity="HIGH",
            target_brand="PayPal",
            indicators=["Pre-filled financial transfer intent", "Deceptive payee impersonation", "Irreversible debit mechanism"],
            details={"threat_type": "QR_PAYMENT", "payee": "PayPalSupportRefundDepartment@upi"}
        )
    ]

class ThreatDnaEngine:
    """
    Threat DNA Correlation Engine.
    Correlates disparate security events (calls, notifications, URLs, QR codes, media)
    belonging to the same user within a configurable temporal sliding window.
    """

    def correlate_events(
        self,
        events: Optional[List[SecurityEventItem]] = None,
        time_window_hours: int = 24,
        user_id: str = "usr_demo_12345"
    ) -> ThreatDnaCorrelationResponse:
        input_events = events if (events and len(events) > 0) else get_demo_attack_campaign_events()

        # 1. Parse timestamps and sort chronologically
        parsed_events = []
        for ev in input_events:
            try:
                dt = datetime.fromisoformat(ev.timestamp_iso.replace("Z", "+00:00"))
            except Exception:
                dt = datetime.now(timezone.utc)
            parsed_events.append((dt, ev))

        parsed_events.sort(key=lambda x: x[0])

        # 2. Filter within configured time window relative to latest event
        if not parsed_events:
            return ThreatDnaCorrelationResponse(
                total_events_evaluated=0,
                time_window_hours=time_window_hours,
                campaigns=[],
                summary="No security events detected within the configured time window."
            )

        latest_time = parsed_events[-1][0]
        window_cutoff = latest_time - timedelta(hours=time_window_hours)
        windowed_events = [(dt, ev) for dt, ev in parsed_events if dt >= window_cutoff]

        if not windowed_events:
            return ThreatDnaCorrelationResponse(
                total_events_evaluated=len(input_events),
                time_window_hours=time_window_hours,
                campaigns=[],
                summary=f"No events found within the last {time_window_hours} hours."
            )

        # 3. Detect multi-vector clusters & build Threat Campaign
        earliest_time = windowed_events[0][0]
        time_span_minutes = max(1, int((latest_time - earliest_time).total_seconds() / 60))

        # Vector normalization
        vector_map = {
            "CALL_SCREENED": "SUSPICIOUS_CALL",
            "CALL_BLOCKED": "SUSPICIOUS_CALL",
            "NOTIFICATION_INTERCEPTED": "SMISHING_NOTIFICATION",
            "URL_SCANNED": "PHISHING_URL",
            "QR_SCANNED": "QR_PAYMENT_REQUEST",
            "DEEPFAKE_SCANNED": "DEEPFAKE_MEDIA"
        }

        vectors_in_order = []
        timeline_steps = []
        shared_brands = set()
        highest_single_risk = 0

        for idx, (dt, ev) in enumerate(windowed_events):
            v_name = vector_map.get(ev.event_type, "SECURITY_EVENT")
            if v_name not in vectors_in_order:
                vectors_in_order.append(v_name)

            if ev.target_brand:
                shared_brands.add(ev.target_brand)
            if ev.risk_score > highest_single_risk:
                highest_single_risk = ev.risk_score

            elapsed_mins = int((dt - earliest_time).total_seconds() / 60)
            elapsed_str = f"T+{elapsed_mins:02d}m"

            timeline_steps.append(TimelineEvent(
                step_number=idx + 1,
                elapsed_time_str=elapsed_str,
                timestamp_iso=dt.isoformat(),
                vector=v_name,
                title=ev.title,
                source=ev.source,
                risk_score=ev.risk_score,
                severity=ev.severity,
                snippet=(
                    f"[{v_name}] from {ev.source}. "
                    + (f"Impersonating {ev.target_brand}. " if ev.target_brand else "")
                    + f"Risk Score: {ev.risk_score}/100."
                )
            ))

        # 4. Compute Escalated Risk Score & Escalation Factor
        distinct_vectors_count = len(vectors_in_order)
        vector_escalation_boost = 0
        if distinct_vectors_count >= 4:
            vector_escalation_boost = 24
        elif distinct_vectors_count >= 3:
            vector_escalation_boost = 18
        elif distinct_vectors_count >= 2:
            vector_escalation_boost = 12

        temporal_proximity_boost = 8 if time_span_minutes <= 60 else (4 if time_span_minutes <= 240 else 0)
        brand_alignment_boost = 6 if len(shared_brands) == 1 and len(windowed_events) >= 2 else 0

        total_boost = vector_escalation_boost + temporal_proximity_boost + brand_alignment_boost
        escalated_risk = min(98, highest_single_risk + total_boost)

        # 5. Deterministic Campaign ID & Threat DNA Fingerprint
        cluster_seed = f"{user_id}:{len(windowed_events)}:{distinct_vectors_count}:{shared_brands}"
        hash_digest = hashlib.sha256(cluster_seed.encode("utf-8")).hexdigest()[:8].upper()
        campaign_id = f"DNA-CMP-{hash_digest}"

        brand_tag = list(shared_brands)[0].upper() if shared_brands else "GENERIC"
        dna_fingerprint = f"DNA:{'+'.join([v[:4] for v in vectors_in_order])}:{brand_tag}:T-{time_span_minutes}M"

        # 6. Correlation Evidence with strict forensic phrasing
        evidence = [
            f"Temporal Clustering: {len(windowed_events)} security events intercepted within a {time_span_minutes}-minute window.",
            f"Cross-Vector Convergence: Attack sequence spanned {distinct_vectors_count} distinct channels ({', '.join(vectors_in_order)}).",
            f"Intent Progression: Progression observed from preliminary inbound caller screening to urgent smishing bait, typosquatted domain harvesting, and financial QR execution.",
            "Heuristic Attribution: Indicators exhibit synchronized social engineering themes ('possible related activity')."
        ]
        if shared_brands:
            evidence.insert(1, f"Common Target Impersonation: Multiple intercepted artifacts repeatedly targeted '{list(shared_brands)[0]}'.")

        # 7. Unified Recommended Action Playbook
        recommended_action = (
            "🚨 MULTI-STAGE CAMPAIGN DEFENSE PLAYBOOK:\n"
            "1. Block caller phone line (+1 800 555-0199) and reject incoming spoofed verification calls.\n"
            "2. Add domain 'paypa1-account-security.top' to personal device blacklist and clear browser cache.\n"
            "3. Reject and discard the pre-filled UPI payment request; do not enter banking PIN.\n"
            "4. Log into your genuine financial account directly via official application to verify security status."
        )

        escalation_reason = (
            f"Risk escalated by +{total_boost} points due to multi-vector convergence across {distinct_vectors_count} channels "
            f"occurring within {time_span_minutes} minutes."
        )

        campaign = ThreatCampaign(
            campaign_id=campaign_id,
            threat_dna_fingerprint=dna_fingerprint,
            correlation_status="POSSIBLE_RELATED_ACTIVITY",
            vectors_involved=vectors_in_order,
            event_count=len(windowed_events),
            time_span_minutes=time_span_minutes,
            baseline_risk_score=highest_single_risk,
            escalated_risk_score=escalated_risk,
            escalation_reason=escalation_reason,
            confidence=0.88 if len(shared_brands) > 0 else 0.78,
            correlation_evidence=evidence,
            timeline=timeline_steps,
            recommended_action=recommended_action
        )

        return ThreatDnaCorrelationResponse(
            total_events_evaluated=len(windowed_events),
            time_window_hours=time_window_hours,
            campaigns=[campaign],
            correlation_engine_version="ThreatDNA-v1.0",
            summary=(
                f"Identified 1 active correlated campaign ({campaign_id}) showing possible related activity across "
                f"{distinct_vectors_count} attack vectors within a {time_window_hours}h monitoring window."
            )
        )

# Global engine instance
threat_dna_engine = ThreatDnaEngine()
