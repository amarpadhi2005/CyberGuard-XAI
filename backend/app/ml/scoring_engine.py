"""
CyberGuard Personal Security Score Engine (0 - 100)
Provides transparent mathematical scoring, granular factor breakdowns,
and explainable delta analysis ("Why did my score change?").
"""

from typing import Dict, List, Any, Optional
from datetime import datetime, timezone
from dataclasses import dataclass, field, asdict


@dataclass
class TransparentRule:
    rule_id: str
    factor_category: str
    title: str
    description: str
    points_awarded: int
    max_points: int
    is_satisfied: bool
    explanation: str
    remediation_action: Optional[str] = None


@dataclass
class FactorScore:
    category: str
    name: str
    current_points: int
    max_points: int
    status: str  # "OPTIMAL", "WARNING", "CRITICAL"
    summary: str
    rules: List[TransparentRule] = field(default_factory=list)


@dataclass
class ScoreDeltaRecord:
    id: str
    timestamp: str
    previous_score: int
    new_score: int
    delta: int
    factor_category: str
    trigger_title: str
    reason_explanation: str
    remediation_action: Optional[str] = None


@dataclass
class PersonalSecurityScoreResult:
    overall_score: int
    grade: str
    posture_title: str
    posture_description: str
    factors: Dict[str, FactorScore]
    actionable_improvements: List[Dict[str, Any]]
    scoring_timestamp: str


class PersonalSecurityScoreEngine:
    """
    Transparent Point Allocation (Total = 100 pts):
    1. Call Protection: 15 pts
    2. Notification Protection: 15 pts
    3. Security Settings & Hygiene: 15 pts
    4. User Training Completion: 15 pts
    5. Recent Threat Events Posture: 15 pts
    6. Dangerous Links Posture: 15 pts
    7. Blocked Calls & Defense Efficacy: 10 pts
    """

    MAX_POINTS = {
        "call_protection": 15,
        "notification_protection": 15,
        "security_settings": 15,
        "user_training": 15,
        "threat_events": 15,
        "dangerous_links": 15,
        "blocked_calls": 10,
    }

    @staticmethod
    def calculate_grade(score: int) -> tuple[str, str, str]:
        if score >= 95:
            return "A+", "Maximum Shield", "All interceptors active, zero unresolved threats, full training certified."
        elif score >= 85:
            return "A", "High Defense Posture", "Comprehensive protection engaged. Attack surface is tightly minimized."
        elif score >= 70:
            return "B", "Moderate Defense", "Core defenses operating. Minor configuration gaps or incomplete training."
        elif score >= 50:
            return "C", "Vulnerable Posture", "Essential interceptors disabled or active threat warnings require attention."
        elif score >= 30:
            return "D", "High Risk", "Significant vulnerabilities exposed. Malicious links or calls may breach defense."
        else:
            return "F", "Critical Hazard", "Crucial security layers inactive. Immediate remediation required."

    def evaluate_score(
        self,
        call_screening_enabled: bool = True,
        auto_block_high_risk_calls: bool = True,
        notification_listener_enabled: bool = True,
        scam_token_sniffer_enabled: bool = True,
        biometric_lock_enabled: bool = True,
        realtime_hud_enabled: bool = True,
        telemetry_anonymization_enabled: bool = True,
        training_modules_completed: int = 2,
        total_training_modules: int = 4,
        unresolved_critical_threats: int = 0,
        unresolved_high_threats: int = 0,
        dangerous_links_clicked_last_30d: int = 0,
        clipboard_url_scanner_enabled: bool = True,
        scam_call_blocklist_enabled: bool = True,
        verified_calls_safely_blocked: int = 3,
    ) -> PersonalSecurityScoreResult:
        factors: Dict[str, FactorScore] = {}
        actionable_improvements: List[Dict[str, Any]] = []

        # ----------------------------------------------------------------------
        # 1. Call Protection (15 pts Max)
        # ----------------------------------------------------------------------
        call_rules: List[TransparentRule] = []
        call_points = 0

        # Sub-rule 1: Call Screening Engine (+10 pts)
        call_screening_pts = 10 if call_screening_enabled else 0
        call_points += call_screening_pts
        call_rules.append(
            TransparentRule(
                rule_id="RULE_CALL_SCREENING",
                factor_category="CALL_PROTECTION",
                title="Call Screening Engine",
                description="Live audio analysis and carrier spam reputation inspection on incoming calls.",
                points_awarded=call_screening_pts,
                max_points=10,
                is_satisfied=call_screening_enabled,
                explanation="Active call screening protects against vishing and spoofed identities."
                if call_screening_enabled
                else "Call screening is disabled. Unknown incoming callers are not vetted.",
                remediation_action="Enable Call Screening in Settings (+10 pts)" if not call_screening_enabled else None,
            )
        )

        # Sub-rule 2: Auto-Block High Risk (+5 pts)
        auto_block_pts = 5 if auto_block_high_risk_calls else 0
        call_points += auto_block_pts
        call_rules.append(
            TransparentRule(
                rule_id="RULE_AUTO_BLOCK_CALLS",
                factor_category="CALL_PROTECTION",
                title="Auto-Block High-Risk Calls",
                description="Automatically drop or silence incoming calls exceeding 75% risk threshold.",
                points_awarded=auto_block_pts,
                max_points=5,
                is_satisfied=auto_block_high_risk_calls,
                explanation="High-risk scam numbers are autonomously prevented from ringing."
                if auto_block_high_risk_calls
                else "High-risk calls ring through without automatic interception.",
                remediation_action="Turn on Auto-Block High-Risk Calls (+5 pts)" if not auto_block_high_risk_calls else None,
            )
        )

        call_status = "OPTIMAL" if call_points == 15 else ("WARNING" if call_points >= 10 else "CRITICAL")
        factors["call_protection"] = FactorScore(
            category="CALL_PROTECTION",
            name="Call Protection",
            current_points=call_points,
            max_points=15,
            status=call_status,
            summary="Autonomous screening and interception of predatory voice calls.",
            rules=call_rules,
        )
        if call_points < 15:
            actionable_improvements.append({
                "factor": "CALL_PROTECTION",
                "points_potential": 15 - call_points,
                "action": "Enable Full Call Protection",
                "description": "Engage real-time call screening and auto-block to prevent phone fraud (+%d pts)." % (15 - call_points),
            })

        # ----------------------------------------------------------------------
        # 2. Notification Protection (15 pts Max)
        # ----------------------------------------------------------------------
        notif_rules: List[TransparentRule] = []
        notif_points = 0

        # Sub-rule 1: Notification Threat Listener (+10 pts)
        listener_pts = 10 if notification_listener_enabled else 0
        notif_points += listener_pts
        notif_rules.append(
            TransparentRule(
                rule_id="RULE_NOTIFICATION_LISTENER",
                factor_category="NOTIFICATION_PROTECTION",
                title="Notification Threat Listener",
                description="Monitors incoming SMS, OTP notifications, and messenger alerts in real time.",
                points_awarded=listener_pts,
                max_points=10,
                is_satisfied=notification_listener_enabled,
                explanation="Notification streams are scrutinized on-device for malicious payloads."
                if notification_listener_enabled
                else "Notification listener permission is missing or turned off.",
                remediation_action="Grant Notification Access to CyberGuard (+10 pts)" if not notification_listener_enabled else None,
            )
        )

        # Sub-rule 2: Scam Token & Impersonation Heuristics (+5 pts)
        sniffer_pts = 5 if scam_token_sniffer_enabled else 0
        notif_points += sniffer_pts
        notif_rules.append(
            TransparentRule(
                rule_id="RULE_SCAM_TOKEN_SNIFFER",
                factor_category="NOTIFICATION_PROTECTION",
                title="Scam Token & Urgency Sniffer",
                description="Detects urgent extortion terms, fake bank fraud alerts, and imposter OTP requests.",
                points_awarded=sniffer_pts,
                max_points=5,
                is_satisfied=scam_token_sniffer_enabled,
                explanation="Advanced on-device linguistic heuristics detect deceptive urgency."
                if scam_token_sniffer_enabled
                else "Urgent text heuristics disabled.",
                remediation_action="Enable Scam Token Heuristics (+5 pts)" if not scam_token_sniffer_enabled else None,
            )
        )

        notif_status = "OPTIMAL" if notif_points == 15 else ("WARNING" if notif_points >= 10 else "CRITICAL")
        factors["notification_protection"] = FactorScore(
            category="NOTIFICATION_PROTECTION",
            name="Notification Protection",
            current_points=notif_points,
            max_points=15,
            status=notif_status,
            summary="Real-time SMS and messaging scam interception.",
            rules=notif_rules,
        )
        if notif_points < 15:
            actionable_improvements.append({
                "factor": "NOTIFICATION_PROTECTION",
                "points_potential": 15 - notif_points,
                "action": "Enable Full Notification Defense",
                "description": "Activate SMS and push alert interceptors to neutralize smishing tokens (+%d pts)." % (15 - notif_points),
            })

        # ----------------------------------------------------------------------
        # 3. Security Settings & Device Hygiene (15 pts Max)
        # ----------------------------------------------------------------------
        sec_rules: List[TransparentRule] = []
        sec_points = 0

        # Sub-rule 1: Biometric Lock (+5 pts)
        bio_pts = 5 if biometric_lock_enabled else 0
        sec_points += bio_pts
        sec_rules.append(
            TransparentRule(
                rule_id="RULE_BIOMETRIC_LOCK",
                factor_category="SECURITY_SETTINGS",
                title="Biometric Screen Enclave",
                description="Device protected by fingerprint, Face Unlock, or secure PIN.",
                points_awarded=bio_pts,
                max_points=5,
                is_satisfied=biometric_lock_enabled,
                explanation="Biometric enclave secures local crypto keys and prevents physical bypass."
                if biometric_lock_enabled
                else "Device has no secure biometric lock configured.",
                remediation_action="Enable Biometric or PIN lock on device (+5 pts)" if not biometric_lock_enabled else None,
            )
        )

        # Sub-rule 2: Real-time Floating HUD (+5 pts)
        hud_pts = 5 if realtime_hud_enabled else 0
        sec_points += hud_pts
        sec_rules.append(
            TransparentRule(
                rule_id="RULE_REALTIME_HUD",
                factor_category="SECURITY_SETTINGS",
                title="Floating Heads-Up Warning HUD",
                description="Instant floating cyber warning overlay over dangerous apps, calls, and links.",
                points_awarded=hud_pts,
                max_points=5,
                is_satisfied=realtime_hud_enabled,
                explanation="Floating HUD alerts you in real time over incoming call windows and messaging."
                if realtime_hud_enabled
                else "Floating overlay permission is disabled.",
                remediation_action="Enable Overlay HUD permission (+5 pts)" if not realtime_hud_enabled else None,
            )
        )

        # Sub-rule 3: Privacy & Telemetry Anonymization (+5 pts)
        telemetry_pts = 5 if telemetry_anonymization_enabled else 0
        sec_points += telemetry_pts
        sec_rules.append(
            TransparentRule(
                rule_id="RULE_PRIVACY_ANONYMIZATION",
                factor_category="SECURITY_SETTINGS",
                title="Telemetry Privacy & Hashing",
                description="Salted SHA-256 caller ID hashing and anonymized threat reporting.",
                points_awarded=telemetry_pts,
                max_points=5,
                is_satisfied=telemetry_anonymization_enabled,
                explanation="All phone numbers and notification bodies are hashed prior to transmission."
                if telemetry_anonymization_enabled
                else "Privacy hashing disabled.",
                remediation_action="Enable Telemetry Anonymization in Privacy Settings (+5 pts)" if not telemetry_anonymization_enabled else None,
            )
        )

        sec_status = "OPTIMAL" if sec_points == 15 else ("WARNING" if sec_points >= 10 else "CRITICAL")
        factors["security_settings"] = FactorScore(
            category="SECURITY_SETTINGS",
            name="Security Settings & Hygiene",
            current_points=sec_points,
            max_points=15,
            status=sec_status,
            summary="Hardened device authentication, privacy controls, and HUD overlay posture.",
            rules=sec_rules,
        )
        if sec_points < 15:
            actionable_improvements.append({
                "factor": "SECURITY_SETTINGS",
                "points_potential": 15 - sec_points,
                "action": "Harden Security Settings",
                "description": "Engage Floating HUD and Biometric lock for defense-in-depth (+%d pts)." % (15 - sec_points),
            })

        # ----------------------------------------------------------------------
        # 4. User Training Completion (15 pts Max)
        # ----------------------------------------------------------------------
        training_rules: List[TransparentRule] = []
        modules_completed_clamped = min(max(0, training_modules_completed), total_training_modules)
        training_ratio = (modules_completed_clamped / total_training_modules) if total_training_modules > 0 else 0.0
        # 4 modules: 4 pts, 4 pts, 4 pts, 3 pts = 15 pts total
        module_weights = [4, 4, 4, 3]
        earned_training_points = sum(module_weights[:modules_completed_clamped])

        training_names = [
            ("Phishing & Smishing Anatomy", "Recognize spoofed bank domains and urgent text lures.", 4),
            ("Voice Clone Deepfake Identification", "Detect synthetic audio artifacts and conversational latency cues.", 4),
            ("Dangerous Links & Quishing Defense", "Analyze misleading QR codes, shortened URLs, and IDN homographs.", 4),
            ("Emergency Imposter & OTP Protocol", "Step-by-step procedures when family members or banks demand instant funds.", 3),
        ]

        for i, (m_title, m_desc, m_pts) in enumerate(training_names):
            is_done = i < modules_completed_clamped
            training_rules.append(
                TransparentRule(
                    rule_id=f"RULE_TRAINING_MODULE_{i+1}",
                    factor_category="USER_TRAINING",
                    title=f"Module {i+1}: {m_title}",
                    description=m_desc,
                    points_awarded=m_pts if is_done else 0,
                    max_points=m_pts,
                    is_satisfied=is_done,
                    explanation=f"Completed: Knowledge verified (+{m_pts} pts)."
                    if is_done
                    else f"Incomplete: Worth +{m_pts} pts upon quiz completion.",
                    remediation_action=f"Complete '{m_title}' module (+{m_pts} pts)" if not is_done else None,
                )
            )

        training_status = "OPTIMAL" if earned_training_points == 15 else ("WARNING" if earned_training_points >= 8 else "CRITICAL")
        factors["user_training"] = FactorScore(
            category="USER_TRAINING",
            name="User Training Completion",
            current_points=earned_training_points,
            max_points=15,
            status=training_status,
            summary=f"Completed {modules_completed_clamped} of {total_training_modules} cyber awareness modules.",
            rules=training_rules,
        )
        if earned_training_points < 15:
            actionable_improvements.append({
                "factor": "USER_TRAINING",
                "points_potential": 15 - earned_training_points,
                "action": "Complete Cyber Defense Modules",
                "description": f"Finish remaining awareness lessons to boost defense score by +{15 - earned_training_points} pts.",
            })

        # ----------------------------------------------------------------------
        # 5. Recent Threat Events Posture (15 pts Max)
        # ----------------------------------------------------------------------
        # Baseline = 15 pts.
        # Deductions: -8 pts per unresolved critical threat, -4 pts per unresolved high threat.
        threat_rules: List[TransparentRule] = []
        threat_deductions = (unresolved_critical_threats * 8) + (unresolved_high_threats * 4)
        threat_points = max(0, 15 - threat_deductions)

        threat_rules.append(
            TransparentRule(
                rule_id="RULE_ZERO_CRITICAL_THREATS",
                factor_category="THREAT_EVENTS",
                title="Zero Unresolved Critical Threats",
                description="Clean posture without active malicious APKs, confirmed voice clones, or credential harvesters.",
                points_awarded=8 if unresolved_critical_threats == 0 else max(0, 8 - (unresolved_critical_threats * 8)),
                max_points=8,
                is_satisfied=(unresolved_critical_threats == 0),
                explanation="Zero active critical threats currently impacting your device."
                if unresolved_critical_threats == 0
                else f"{unresolved_critical_threats} unresolved critical threat(s) detected (-{unresolved_critical_threats * 8} pts).",
                remediation_action="Quarantine active critical threats (+8 pts)" if unresolved_critical_threats > 0 else None,
            )
        )

        threat_rules.append(
            TransparentRule(
                rule_id="RULE_ZERO_HIGH_THREATS",
                factor_category="THREAT_EVENTS",
                title="Zero Unresolved Warning Events",
                description="No unreviewed high-probability scam messages or suspicious contacts.",
                points_awarded=7 if unresolved_high_threats == 0 else max(0, 7 - (unresolved_high_threats * 4)),
                max_points=7,
                is_satisfied=(unresolved_high_threats == 0),
                explanation="No unresolved high-severity warning events."
                if unresolved_high_threats == 0
                else f"{unresolved_high_threats} unreviewed high threat(s) detected (-{unresolved_high_threats * 4} pts).",
                remediation_action="Review and resolve pending threat alerts (+4 pts)" if unresolved_high_threats > 0 else None,
            )
        )

        threat_status = "OPTIMAL" if threat_points == 15 else ("WARNING" if threat_points >= 8 else "CRITICAL")
        factors["threat_events"] = FactorScore(
            category="THREAT_EVENTS",
            name="Recent Threat Events",
            current_points=threat_points,
            max_points=15,
            status=threat_status,
            summary="Evaluates exposure and resolution of recent high-risk attacks."
            if threat_deductions == 0
            else f"{threat_deductions} pts deducted due to active unresolved threats.",
            rules=threat_rules,
        )
        if threat_points < 15:
            actionable_improvements.append({
                "factor": "THREAT_EVENTS",
                "points_potential": 15 - threat_points,
                "action": "Resolve Active Threat Alerts",
                "description": f"Dismiss, quarantine, or block active threat events to recover +{15 - threat_points} pts immediately.",
            })

        # ----------------------------------------------------------------------
        # 6. Dangerous Links Posture (15 pts Max)
        # ----------------------------------------------------------------------
        link_rules: List[TransparentRule] = []
        link_points = 0

        # Sub-rule 1: Zero Malicious Links Compromised (+10 pts)
        clean_browsing_pts = 10 if dangerous_links_clicked_last_30d == 0 else max(0, 10 - (dangerous_links_clicked_last_30d * 5))
        link_points += clean_browsing_pts
        link_rules.append(
            TransparentRule(
                rule_id="RULE_CLEAN_LINK_POSTURE",
                factor_category="DANGEROUS_LINKS",
                title="Clean Browsing & URL History (30 Days)",
                description="Zero malicious, homograph, or phishing URLs accessed in the last 30 days.",
                points_awarded=clean_browsing_pts,
                max_points=10,
                is_satisfied=(dangerous_links_clicked_last_30d == 0),
                explanation="Clean link history: No dangerous links accessed."
                if dangerous_links_clicked_last_30d == 0
                else f"{dangerous_links_clicked_last_30d} dangerous link(s) accessed recently (-{dangerous_links_clicked_last_30d * 5} pts).",
                remediation_action="Clear browser cache and avoid unverified links" if dangerous_links_clicked_last_30d > 0 else None,
            )
        )

        # Sub-rule 2: Clipboard & Pre-flight URL Scanner Active (+5 pts)
        scanner_pts = 5 if clipboard_url_scanner_enabled else 0
        link_points += scanner_pts
        link_rules.append(
            TransparentRule(
                rule_id="RULE_CLIPBOARD_URL_SCANNER",
                factor_category="DANGEROUS_LINKS",
                title="Real-Time URL Pre-Flight Scanner",
                description="Instantly scans URLs copied to clipboard or tapped in messages before browser launch.",
                points_awarded=scanner_pts,
                max_points=5,
                is_satisfied=clipboard_url_scanner_enabled,
                explanation="Clipboard & app URLs are inspected before execution."
                if clipboard_url_scanner_enabled
                else "Pre-flight URL scanner is turned off.",
                remediation_action="Turn on Clipboard URL Scanner (+5 pts)" if not clipboard_url_scanner_enabled else None,
            )
        )

        link_status = "OPTIMAL" if link_points == 15 else ("WARNING" if link_points >= 10 else "CRITICAL")
        factors["dangerous_links"] = FactorScore(
            category="DANGEROUS_LINKS",
            name="Dangerous Links Posture",
            current_points=link_points,
            max_points=15,
            status=link_status,
            summary="Pre-flight analysis of web links, phishing domains, and QR payloads.",
            rules=link_rules,
        )
        if link_points < 15:
            actionable_improvements.append({
                "factor": "DANGEROUS_LINKS",
                "points_potential": 15 - link_points,
                "action": "Enable Real-time Link Scanner",
                "description": f"Engage URL pre-flight inspection to protect against phishing (+{15 - link_points} pts).",
            })

        # ----------------------------------------------------------------------
        # 7. Blocked Calls & Defense Efficacy (10 pts Max)
        # ----------------------------------------------------------------------
        block_rules: List[TransparentRule] = []
        block_points = 0

        # Sub-rule 1: Global Scam Blocklist Engaged (+5 pts)
        blocklist_pts = 5 if scam_call_blocklist_enabled else 0
        block_points += blocklist_pts
        block_rules.append(
            TransparentRule(
                rule_id="RULE_SCAM_BLOCKLIST",
                factor_category="BLOCKED_CALLS",
                title="Carrier Threat Blocklist Synced",
                description="Synchronized with cloud-updated lists of verified telemarketing and spoof numbers.",
                points_awarded=blocklist_pts,
                max_points=5,
                is_satisfied=scam_call_blocklist_enabled,
                explanation="Latest carrier threat blocklist is active."
                if scam_call_blocklist_enabled
                else "Threat blocklist is not synchronized.",
                remediation_action="Sync Threat Blocklist in Settings (+5 pts)" if not scam_call_blocklist_enabled else None,
            )
        )

        # Sub-rule 2: Threat Intercept Efficacy (+5 pts)
        efficacy_pts = 5 if verified_calls_safely_blocked >= 1 or (call_screening_enabled and auto_block_high_risk_calls) else 2
        block_points += efficacy_pts
        block_rules.append(
            TransparentRule(
                rule_id="RULE_INTERCEPT_EFFICACY",
                factor_category="BLOCKED_CALLS",
                title="Defense Intercept Efficacy",
                description="Demonstrated capability to intercept and neutralize incoming robocall attacks.",
                points_awarded=efficacy_pts,
                max_points=5,
                is_satisfied=(efficacy_pts == 5),
                explanation=f"Defense verified: {verified_calls_safely_blocked} malicious calls intercepted."
                if verified_calls_safely_blocked > 0
                else "Call protection policies verified ready to intercept incoming spoof attacks.",
                remediation_action="Ensure call auto-block is active (+3 pts)" if efficacy_pts < 5 else None,
            )
        )

        block_status = "OPTIMAL" if block_points == 10 else ("WARNING" if block_points >= 5 else "CRITICAL")
        factors["blocked_calls"] = FactorScore(
            category="BLOCKED_CALLS",
            name="Blocked Calls & Efficacy",
            current_points=block_points,
            max_points=10,
            status=block_status,
            summary="Metrics on blocked fraud calls and active defense rules.",
            rules=block_rules,
        )
        if block_points < 10:
            actionable_improvements.append({
                "factor": "BLOCKED_CALLS",
                "points_potential": 10 - block_points,
                "action": "Activate Threat Blocklist",
                "description": f"Ensure scam blocklist is synced to eliminate fraud rings (+{10 - block_points} pts).",
            })

        # ----------------------------------------------------------------------
        # Total Overall Score
        # ----------------------------------------------------------------------
        total_score = sum(f.current_points for f in factors.values())
        clamped_score = max(0, min(100, total_score))
        grade, posture_title, posture_desc = self.calculate_grade(clamped_score)

        # Sort improvements by potential point gain (descending)
        actionable_improvements.sort(key=lambda x: x["points_potential"], reverse=True)

        return PersonalSecurityScoreResult(
            overall_score=clamped_score,
            grade=grade,
            posture_title=posture_title,
            posture_description=posture_desc,
            factors=factors,
            actionable_improvements=actionable_improvements,
            scoring_timestamp=datetime.now(timezone.utc).isoformat(),
        )

    def explain_score_delta(
        self,
        previous_result: PersonalSecurityScoreResult,
        new_result: PersonalSecurityScoreResult,
        trigger_context: Optional[str] = None,
    ) -> List[ScoreDeltaRecord]:
        """
        Calculates exact factor differences and produces transparent, human-readable
        "Why Did My Score Change?" delta explanations.
        """
        deltas: List[ScoreDeltaRecord] = []
        overall_delta = new_result.overall_score - previous_result.overall_score

        if overall_delta == 0:
            return deltas

        now_iso = datetime.now(timezone.utc).isoformat()

        # Check each factor
        for category_key, new_factor in new_result.factors.items():
            prev_factor = previous_result.factors.get(category_key)
            if not prev_factor:
                continue

            factor_delta = new_factor.current_points - prev_factor.current_points
            if factor_delta == 0:
                continue

            sign_str = f"+{factor_delta}" if factor_delta > 0 else f"{factor_delta}"
            category_name = new_factor.name

            # Identify specific rules that changed
            rule_diffs = []
            for new_rule in new_factor.rules:
                matching_prev = next((r for r in prev_factor.rules if r.rule_id == new_rule.rule_id), None)
                if matching_prev and matching_prev.is_satisfied != new_rule.is_satisfied:
                    if new_rule.is_satisfied:
                        rule_diffs.append(f"Satisfied '{new_rule.title}' (+{new_rule.points_awarded} pts)")
                    else:
                        rule_diffs.append(f"Lost '{new_rule.title}' (-{matching_prev.points_awarded} pts)")

            rule_details = "; ".join(rule_diffs) if rule_diffs else ""

            if factor_delta > 0:
                trigger_title = f"{category_name} Enhanced ({sign_str} pts)"
                explanation = (
                    f"Your score increased by {factor_delta} points because your defense posture in {category_name} improved. "
                    f"({rule_details if rule_details else new_factor.summary})"
                )
                remediation = None
            else:
                trigger_title = f"{category_name} Degraded ({sign_str} pts)"
                explanation = (
                    f"Your score dropped by {abs(factor_delta)} points due to changes in {category_name}. "
                    f"({rule_details if rule_details else new_factor.summary})"
                )
                # Find an unsatisfied rule to offer remediation
                remedial_rule = next((r for r in new_factor.rules if not r.is_satisfied and r.remediation_action), None)
                remediation = remedial_rule.remediation_action if remedial_rule else None

            deltas.append(
                ScoreDeltaRecord(
                    id=f"delta_{category_key}_{int(datetime.now().timestamp())}",
                    timestamp=now_iso,
                    previous_score=previous_result.overall_score,
                    new_score=new_result.overall_score,
                    delta=factor_delta,
                    factor_category=new_factor.category,
                    trigger_title=trigger_title,
                    reason_explanation=explanation,
                    remediation_action=remediation,
                )
            )

        return deltas

    def get_public_transparent_rules(self) -> Dict[str, Any]:
        """
        Returns full, open, transparent documentation of the scoring system
        so users can verify that no arbitrary or hidden penalties exist.
        """
        return {
            "title": "CyberGuard Personal Security Score Rubric (0 - 100)",
            "version": "2.0.0",
            "mathematical_formula": "Score = Clamp(0, 100, F_call(15) + F_notif(15) + F_settings(15) + F_training(15) + F_threats(15) + F_links(15) + F_blocked(10))",
            "grade_scale": {
                "A+": "95 - 100 (Maximum Shield)",
                "A": "85 - 94 (High Defense Posture)",
                "B": "70 - 84 (Moderate Defense)",
                "C": "50 - 69 (Vulnerable Posture)",
                "D": "30 - 49 (High Risk)",
                "F": "0 - 29 (Critical Hazard)",
            },
            "factors": [
                {
                    "name": "Call Protection",
                    "max_points": 15,
                    "rules": [
                        {"rule": "Call Screening Engine Active", "points": 10},
                        {"rule": "Auto-Block High-Risk Vishing Active", "points": 5},
                    ],
                },
                {
                    "name": "Notification Protection",
                    "max_points": 15,
                    "rules": [
                        {"rule": "SMS & App Notification Threat Listener Active", "points": 10},
                        {"rule": "Scam Token & Urgency NLP Sniffer Active", "points": 5},
                    ],
                },
                {
                    "name": "Security Settings & Hygiene",
                    "max_points": 15,
                    "rules": [
                        {"rule": "Biometric / PIN Screen Lock Configured", "points": 5},
                        {"rule": "Real-time Floating Heads-Up Warning HUD Active", "points": 5},
                        {"rule": "Privacy Telemetry Hashing & Anonymization Active", "points": 5},
                    ],
                },
                {
                    "name": "User Training Completion",
                    "max_points": 15,
                    "rules": [
                        {"rule": "Module 1: Phishing & Smishing Anatomy", "points": 4},
                        {"rule": "Module 2: Voice Clone Deepfake Defense", "points": 4},
                        {"rule": "Module 3: Dangerous Links & Quishing (Malicious QR)", "points": 4},
                        {"rule": "Module 4: Emergency Imposter & OTP Protocol", "points": 3},
                    ],
                },
                {
                    "name": "Recent Threat Events Posture",
                    "max_points": 15,
                    "rules": [
                        {"rule": "Clean baseline (Zero active unresolved threats)", "points": 15},
                        {"rule": "Penalty: Unresolved Critical Threat", "points": "-8 pts per event"},
                        {"rule": "Penalty: Unresolved Warning Threat", "points": "-4 pts per event"},
                        {"rule": "Restoration: Quarantining or resolving threat", "points": "Restores deducted points immediately"},
                    ],
                },
                {
                    "name": "Dangerous Links Posture",
                    "max_points": 15,
                    "rules": [
                        {"rule": "Clean Browsing History (No malicious URLs accessed in 30d)", "points": 10},
                        {"rule": "Clipboard & Pre-Flight URL Scanner Active", "points": 5},
                        {"rule": "Penalty: Accessing dangerous link", "points": "-5 pts per incident"},
                    ],
                },
                {
                    "name": "Blocked Calls & Defense Efficacy",
                    "max_points": 10,
                    "rules": [
                        {"rule": "Carrier Scam Blocklist Synchronized", "points": 5},
                        {"rule": "Verified Defense Intercept Efficacy", "points": 5},
                    ],
                },
            ],
        }


# Singleton engine instance
scoring_engine = PersonalSecurityScoreEngine()
