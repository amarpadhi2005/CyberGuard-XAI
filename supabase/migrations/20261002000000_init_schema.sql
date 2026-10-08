-- ==============================================================================
-- CyberGuard XAI - Comprehensive Supabase Database Schema Migration
-- ==============================================================================
-- Designed for: Personal AI Cyber-Safety Layer
-- Features: AI Call Screening, Notification Scam Sniffer, QR/URL Threat Analyzer,
--           Deepfake Forensics, XAI Engine, Alerts, Security Scores, & AI Assistant.
-- Security: Row Level Security (RLS) enforced across all private user data.
-- ==============================================================================

-- Enable Core Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 0. Reusable Utility Trigger for updated_at Timestamps
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 1. Profiles Table (Extends Supabase auth.users)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    phone_number TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 2. Devices Table (Registered Android Phones & FCM Tokens)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_fingerprint TEXT NOT NULL,
    device_name TEXT NOT NULL,
    model TEXT,
    os_version TEXT,
    app_version TEXT,
    fcm_token TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, device_fingerprint)
);

CREATE INDEX IF NOT EXISTS idx_devices_user_id ON public.devices(user_id);
CREATE INDEX IF NOT EXISTS idx_devices_fingerprint ON public.devices(device_fingerprint);
CREATE INDEX IF NOT EXISTS idx_devices_fcm_token ON public.devices(fcm_token);

CREATE TRIGGER set_devices_updated_at
    BEFORE UPDATE ON public.devices
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 3. Calls Table (Raw & Screened Phone Calls)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.calls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    phone_number TEXT NOT NULL,
    phone_number_hash TEXT,
    caller_name TEXT,
    call_type TEXT NOT NULL CHECK (call_type IN ('INCOMING', 'OUTGOING', 'MISSED', 'BLOCKED', 'REJECTED')),
    call_duration_seconds INT NOT NULL DEFAULT 0,
    call_timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    was_screened BOOLEAN NOT NULL DEFAULT FALSE,
    action_taken TEXT NOT NULL DEFAULT 'ALLOWED' CHECK (action_taken IN ('ALLOWED', 'SILENCED', 'BLOCKED', 'FLAGGED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_calls_user_id ON public.calls(user_id);
CREATE INDEX IF NOT EXISTS idx_calls_phone_number ON public.calls(phone_number);
CREATE INDEX IF NOT EXISTS idx_calls_timestamp ON public.calls(call_timestamp DESC);

-- ==============================================================================
-- 4. Call Risk Analysis Table (AI/XAI Assessment for Calls)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.call_risk_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    call_id UUID NOT NULL REFERENCES public.calls(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    risk_score INT NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    risk_level TEXT NOT NULL CHECK (risk_level IN ('SAFE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    category TEXT NOT NULL,
    confidence NUMERIC(5,4) NOT NULL,
    telephony_carrier TEXT,
    line_type TEXT,
    carrier_reputation_score INT CHECK (carrier_reputation_score BETWEEN 0 AND 100),
    community_reports_count INT NOT NULL DEFAULT 0,
    primary_indicators JSONB NOT NULL DEFAULT '[]'::jsonb,
    attribution_weights JSONB NOT NULL DEFAULT '{}'::jsonb,
    xai_explanation TEXT NOT NULL,
    recommended_action TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_call_risk_call_id ON public.call_risk_analysis(call_id);
CREATE INDEX IF NOT EXISTS idx_call_risk_user_id ON public.call_risk_analysis(user_id);
CREATE INDEX IF NOT EXISTS idx_call_risk_level ON public.call_risk_analysis(risk_level);

-- ==============================================================================
-- 5. Notifications Table (Intercepted App Notifications)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    package_name TEXT NOT NULL,
    app_name TEXT NOT NULL,
    notification_key TEXT,
    title TEXT,
    content_snippet TEXT,
    posted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    is_threat BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_package ON public.notifications(package_name);
CREATE INDEX IF NOT EXISTS idx_notifications_posted_at ON public.notifications(posted_at DESC);

-- ==============================================================================
-- 6. Notification Analysis Table (NLP & Smishing Assessment)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.notification_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    threat_type TEXT NOT NULL CHECK (threat_type IN ('NONE', 'SMISHING', 'PHISHING', 'OTP_THEFT', 'EXTORTION', 'LOTTERY_SCAM', 'COERCIVE_URGENCY')),
    risk_score INT NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    risk_level TEXT NOT NULL CHECK (risk_level IN ('SAFE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    confidence NUMERIC(5,4) NOT NULL,
    extracted_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    extracted_entities JSONB NOT NULL DEFAULT '{}'::jsonb,
    linguistic_cues JSONB NOT NULL DEFAULT '[]'::jsonb,
    xai_explanation TEXT NOT NULL,
    suggested_action TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_notif_analysis_notif_id ON public.notification_analysis(notification_id);
CREATE INDEX IF NOT EXISTS idx_notif_analysis_user_id ON public.notification_analysis(user_id);
CREATE INDEX IF NOT EXISTS idx_notif_analysis_risk_level ON public.notification_analysis(risk_level);

-- ==============================================================================
-- 7. Threats Table (Consolidated Security Incidents & Threat History)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.threats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    threat_category TEXT NOT NULL CHECK (threat_category IN ('CALL_SCAM', 'SMISHING', 'PHISHING_URL', 'QR_SCAM', 'DEEPFAKE_MEDIA', 'MALWARE_NOTIFICATION', 'IMPERSONATION')),
    severity TEXT NOT NULL CHECK (severity IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    source_identifier TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'MITIGATED', 'DISMISSED', 'FALSE_POSITIVE')),
    risk_score INT NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    xai_summary TEXT NOT NULL,
    indicators JSONB NOT NULL DEFAULT '[]'::jsonb,
    mitigation_steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    action_taken TEXT NOT NULL,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_threats_user_id ON public.threats(user_id);
CREATE INDEX IF NOT EXISTS idx_threats_severity ON public.threats(severity);
CREATE INDEX IF NOT EXISTS idx_threats_status ON public.threats(status);
CREATE INDEX IF NOT EXISTS idx_threats_created_at ON public.threats(created_at DESC);

CREATE TRIGGER set_threats_updated_at
    BEFORE UPDATE ON public.threats
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 8. URLs Table (Unique Analyzed Links & Domains Registry)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.urls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    raw_url TEXT NOT NULL,
    normalized_url TEXT UNIQUE NOT NULL,
    domain TEXT NOT NULL,
    subdomain TEXT,
    tld TEXT NOT NULL,
    protocol TEXT NOT NULL,
    is_ip_address BOOLEAN NOT NULL DEFAULT FALSE,
    is_shortened BOOLEAN NOT NULL DEFAULT FALSE,
    reputation_score INT DEFAULT 50 CHECK (reputation_score BETWEEN 0 AND 100),
    global_verdict TEXT NOT NULL DEFAULT 'UNKNOWN' CHECK (global_verdict IN ('UNKNOWN', 'BENIGN', 'SUSPICIOUS', 'MALICIOUS')),
    domain_age_days INT,
    has_valid_ssl BOOLEAN,
    first_seen_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    last_scanned_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_urls_domain ON public.urls(domain);
CREATE INDEX IF NOT EXISTS idx_urls_global_verdict ON public.urls(global_verdict);

-- ==============================================================================
-- 9. URL Scans Table (Transaction-level User Scans)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.url_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    url_id UUID NOT NULL REFERENCES public.urls(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    scan_origin TEXT NOT NULL CHECK (scan_origin IN ('DIRECT_INPUT', 'QR_SCAN', 'NOTIFICATION', 'SMS', 'CLIPBOARD')),
    verdict TEXT NOT NULL CHECK (verdict IN ('SAFE', 'SUSPICIOUS', 'MALICIOUS')),
    risk_score INT NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    confidence NUMERIC(5,4) NOT NULL,
    threat_types JSONB NOT NULL DEFAULT '[]'::jsonb,
    redirect_chain JSONB NOT NULL DEFAULT '[]'::jsonb,
    entropy_score NUMERIC(6,3),
    homograph_detected BOOLEAN NOT NULL DEFAULT FALSE,
    xai_explanation TEXT NOT NULL,
    indicators JSONB NOT NULL DEFAULT '[]'::jsonb,
    action_suggested TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_url_scans_user_id ON public.url_scans(user_id);
CREATE INDEX IF NOT EXISTS idx_url_scans_url_id ON public.url_scans(url_id);
CREATE INDEX IF NOT EXISTS idx_url_scans_verdict ON public.url_scans(verdict);
CREATE INDEX IF NOT EXISTS idx_url_scans_created_at ON public.url_scans(created_at DESC);

-- ==============================================================================
-- 10. QR Scans Table (CameraX / ML Kit Barcode Scans)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.qr_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    raw_payload TEXT NOT NULL,
    payload_type TEXT NOT NULL CHECK (payload_type IN ('URL', 'WIFI', 'VCARD', 'TEXT', 'CRYPTO_ADDRESS', 'PAYMENT_UPI', 'OTHER')),
    is_threat BOOLEAN NOT NULL DEFAULT FALSE,
    risk_score INT NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    risk_level TEXT NOT NULL CHECK (risk_level IN ('SAFE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    associated_url_id UUID REFERENCES public.urls(id) ON DELETE SET NULL,
    associated_url_scan_id UUID REFERENCES public.url_scans(id) ON DELETE SET NULL,
    xai_explanation TEXT NOT NULL,
    indicators JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_qr_scans_user_id ON public.qr_scans(user_id);
CREATE INDEX IF NOT EXISTS idx_qr_scans_risk_level ON public.qr_scans(risk_level);
CREATE INDEX IF NOT EXISTS idx_qr_scans_created_at ON public.qr_scans(created_at DESC);

-- ==============================================================================
-- 11. Deepfake Scans Table (Forensic Inspection for Audio, Video, Image)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.deepfake_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    media_type TEXT NOT NULL CHECK (media_type IN ('AUDIO', 'IMAGE', 'VIDEO')),
    file_storage_path TEXT NOT NULL,
    file_hash_sha256 TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    file_duration_seconds NUMERIC(8,2),
    is_synthetic BOOLEAN NOT NULL DEFAULT FALSE,
    synthetic_likelihood_percentage NUMERIC(5,2) NOT NULL CHECK (synthetic_likelihood_percentage BETWEEN 0 AND 100),
    confidence NUMERIC(5,4) NOT NULL,
    model_version TEXT NOT NULL,
    artifacts_detected JSONB NOT NULL DEFAULT '[]'::jsonb,
    attribution_weights JSONB NOT NULL DEFAULT '{}'::jsonb,
    xai_explanation TEXT NOT NULL,
    recommendation TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_deepfake_scans_user_id ON public.deepfake_scans(user_id);
CREATE INDEX IF NOT EXISTS idx_deepfake_scans_synthetic ON public.deepfake_scans(is_synthetic);
CREATE INDEX IF NOT EXISTS idx_deepfake_scans_hash ON public.deepfake_scans(file_hash_sha256);
CREATE INDEX IF NOT EXISTS idx_deepfake_scans_created_at ON public.deepfake_scans(created_at DESC);

-- ==============================================================================
-- 12. Security Events Table (Unified Audit Telemetry)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL CHECK (event_type IN (
        'SERVICE_STARTED', 'SERVICE_STOPPED', 'CALL_SCREENED', 'CALL_BLOCKED', 
        'NOTIFICATION_INTERCEPTED', 'URL_SCANNED', 'QR_SCANNED', 'DEEPFAKE_SCANNED', 
        'SETTINGS_UPDATED', 'AUTH_LOGIN', 'PERMISSIONS_MODIFIED', 'SCORE_RECALCULATED'
    )),
    event_severity TEXT NOT NULL DEFAULT 'INFO' CHECK (event_severity IN ('INFO', 'NOTICE', 'WARNING', 'CRITICAL')),
    title TEXT NOT NULL,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    ip_address INET,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_security_events_user_id ON public.security_events(user_id);
CREATE INDEX IF NOT EXISTS idx_security_events_type ON public.security_events(event_type);
CREATE INDEX IF NOT EXISTS idx_security_events_created_at ON public.security_events(created_at DESC);

-- ==============================================================================
-- 13. Alerts Table (Real-time In-App, Heads-Up & Push Notifications)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id UUID REFERENCES public.devices(id) ON DELETE SET NULL,
    threat_id UUID REFERENCES public.threats(id) ON DELETE CASCADE,
    alert_title TEXT NOT NULL,
    alert_message TEXT NOT NULL,
    alert_level TEXT NOT NULL CHECK (alert_level IN ('INFO', 'WARNING', 'CRITICAL')),
    delivery_channel TEXT NOT NULL DEFAULT 'ALL' CHECK (delivery_channel IN ('IN_APP', 'PUSH_NOTIFICATION', 'HEADS_UP_OVERLAY', 'ALL')),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    is_dismissed BOOLEAN NOT NULL DEFAULT FALSE,
    action_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    read_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_alerts_user_id ON public.alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_is_read ON public.alerts(is_read);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON public.alerts(created_at DESC);

-- ==============================================================================
-- 14. Security Score Table (Aggregated Cyber-Safety Score & Breakdown)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.security_score (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    overall_score INT NOT NULL CHECK (overall_score BETWEEN 0 AND 100),
    grade TEXT NOT NULL CHECK (grade IN ('A+', 'A', 'B', 'C', 'D', 'F')),
    call_safety_subscore INT NOT NULL CHECK (call_safety_subscore BETWEEN 0 AND 100),
    message_safety_subscore INT NOT NULL CHECK (message_safety_subscore BETWEEN 0 AND 100),
    browsing_safety_subscore INT NOT NULL CHECK (browsing_safety_subscore BETWEEN 0 AND 100),
    device_hygiene_subscore INT NOT NULL CHECK (device_hygiene_subscore BETWEEN 0 AND 100),
    deductions JSONB NOT NULL DEFAULT '[]'::jsonb,
    improvements JSONB NOT NULL DEFAULT '[]'::jsonb,
    calculated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_security_score_user_id ON public.security_score(user_id);
CREATE INDEX IF NOT EXISTS idx_security_score_calculated_at ON public.security_score(calculated_at DESC);

-- ==============================================================================
-- 15. AI Conversations Table (Chat Threads with Cyber Assistant)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.ai_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Cyber Safety Consultation',
    context_threat_id UUID REFERENCES public.threats(id) ON DELETE SET NULL,
    is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON public.ai_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_updated_at ON public.ai_conversations(updated_at DESC);

CREATE TRIGGER set_ai_conversations_updated_at
    BEFORE UPDATE ON public.ai_conversations
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 16. AI Messages Table (Dialogue Messages with XAI Citations)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.ai_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.ai_conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    xai_citations JSONB NOT NULL DEFAULT '[]'::jsonb,
    suggested_quick_replies JSONB NOT NULL DEFAULT '[]'::jsonb,
    action_triggers JSONB NOT NULL DEFAULT '[]'::jsonb,
    tokens_used INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_ai_messages_conv_id ON public.ai_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_ai_messages_user_id ON public.ai_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_messages_created_at ON public.ai_messages(created_at ASC);

-- ==============================================================================
-- 17. User Settings Table (Granular Defense & Privacy Config)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    call_screening_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    auto_block_high_risk_calls BOOLEAN NOT NULL DEFAULT TRUE,
    call_risk_threshold INT NOT NULL DEFAULT 75 CHECK (call_risk_threshold BETWEEN 1 AND 100),
    notification_protection_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    auto_scan_clipboard_urls BOOLEAN NOT NULL DEFAULT TRUE,
    deepfake_media_inspection_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    realtime_floating_hud_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    fcm_critical_alerts_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    privacy_mode_hash_phone_numbers BOOLEAN NOT NULL DEFAULT TRUE,
    anonymize_notification_telemetry BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON public.user_settings(user_id);

CREATE TRIGGER set_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 18. New User Automation Trigger (Auto-provision Profile & User Settings)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user_provisioning()
RETURNS TRIGGER AS $$
BEGIN
    -- Provision Profile
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
    )
    ON CONFLICT (id) DO NOTHING;

    -- Provision Default User Settings
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;

    -- Provision Initial Baseline Security Score
    INSERT INTO public.security_score (
        user_id, 
        overall_score, 
        grade, 
        call_safety_subscore, 
        message_safety_subscore, 
        browsing_safety_subscore, 
        device_hygiene_subscore,
        improvements
    )
    VALUES (
        NEW.id,
        85,
        'B',
        90,
        85,
        80,
        85,
        '["Enable notification threat listener", "Scan your first URL or QR code"]'::jsonb
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_provisioning();

-- ==============================================================================
-- 19. Row Level Security (RLS) Configuration
-- ==============================================================================

-- Enable RLS on every table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.calls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.call_risk_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.threats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.urls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.url_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.qr_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deepfake_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_score ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Policies
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- 2. Devices Policies
CREATE POLICY "Users can view their own devices"
    ON public.devices FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own devices"
    ON public.devices FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own devices"
    ON public.devices FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own devices"
    ON public.devices FOR DELETE
    USING (auth.uid() = user_id);

-- 3. Calls Policies
CREATE POLICY "Users can view their own calls"
    ON public.calls FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own calls"
    ON public.calls FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own calls"
    ON public.calls FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own calls"
    ON public.calls FOR DELETE
    USING (auth.uid() = user_id);

-- 4. Call Risk Analysis Policies
CREATE POLICY "Users can view their own call risk analyses"
    ON public.call_risk_analysis FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own call risk analyses"
    ON public.call_risk_analysis FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 5. Notifications Policies
CREATE POLICY "Users can view their own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notifications"
    ON public.notifications FOR DELETE
    USING (auth.uid() = user_id);

-- 6. Notification Analysis Policies
CREATE POLICY "Users can view their own notification analyses"
    ON public.notification_analysis FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notification analyses"
    ON public.notification_analysis FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 7. Threats Policies
CREATE POLICY "Users can view their own threats"
    ON public.threats FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own threats"
    ON public.threats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own threats"
    ON public.threats FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own threats"
    ON public.threats FOR DELETE
    USING (auth.uid() = user_id);

-- 8. URLs Policies (Shared Global Intelligence Cache, readable by authenticated users)
CREATE POLICY "Authenticated users can view URLs"
    ON public.urls FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can insert URLs"
    ON public.urls FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Authenticated users can update URLs"
    ON public.urls FOR UPDATE
    TO authenticated
    USING (true);

-- 9. URL Scans Policies
CREATE POLICY "Users can view their own URL scans"
    ON public.url_scans FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own URL scans"
    ON public.url_scans FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own URL scans"
    ON public.url_scans FOR DELETE
    USING (auth.uid() = user_id);

-- 10. QR Scans Policies
CREATE POLICY "Users can view their own QR scans"
    ON public.qr_scans FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own QR scans"
    ON public.qr_scans FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own QR scans"
    ON public.qr_scans FOR DELETE
    USING (auth.uid() = user_id);

-- 11. Deepfake Scans Policies
CREATE POLICY "Users can view their own deepfake scans"
    ON public.deepfake_scans FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own deepfake scans"
    ON public.deepfake_scans FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own deepfake scans"
    ON public.deepfake_scans FOR DELETE
    USING (auth.uid() = user_id);

-- 12. Security Events Policies
CREATE POLICY "Users can view their own security audit events"
    ON public.security_events FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own security audit events"
    ON public.security_events FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 13. Alerts Policies
CREATE POLICY "Users can view their own alerts"
    ON public.alerts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own alerts"
    ON public.alerts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own alerts"
    ON public.alerts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own alerts"
    ON public.alerts FOR DELETE
    USING (auth.uid() = user_id);

-- 14. Security Score Policies
CREATE POLICY "Users can view their own security scores"
    ON public.security_score FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own security scores"
    ON public.security_score FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 15. AI Conversations Policies
CREATE POLICY "Users can view their own AI conversations"
    ON public.ai_conversations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own AI conversations"
    ON public.ai_conversations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own AI conversations"
    ON public.ai_conversations FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own AI conversations"
    ON public.ai_conversations FOR DELETE
    USING (auth.uid() = user_id);

-- 16. AI Messages Policies
CREATE POLICY "Users can view their own AI messages"
    ON public.ai_messages FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own AI messages"
    ON public.ai_messages FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own AI messages"
    ON public.ai_messages FOR DELETE
    USING (auth.uid() = user_id);

-- 17. User Settings Policies
CREATE POLICY "Users can view their own settings"
    ON public.user_settings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own settings"
    ON public.user_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own settings"
    ON public.user_settings FOR UPDATE
    USING (auth.uid() = user_id);

-- ==============================================================================
-- 20. Supabase Realtime Publications
-- ==============================================================================
-- Enable Realtime subscriptions for live dashboard, threats and alerts
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.threats;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.alerts;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.security_score;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.calls;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
