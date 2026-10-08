-- ==============================================================================
-- CyberGuard Personal Security Score (0-100) System Migration
-- Transparent Scoring Rules, Factor Breakdown & Score Change Delta History
-- ==============================================================================

-- 1. User Training Modules Table
CREATE TABLE IF NOT EXISTS public.user_training_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    module_key TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    points_reward INT NOT NULL DEFAULT 4 CHECK (points_reward > 0),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    score_percentage INT CHECK (score_percentage BETWEEN 0 AND 100),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, module_key)
);

CREATE INDEX IF NOT EXISTS idx_user_training_user_id ON public.user_training_modules(user_id);
CREATE INDEX IF NOT EXISTS idx_user_training_completed ON public.user_training_modules(is_completed);

-- 2. Enhanced Security Score Table with Transparent Factors (0-100)
-- Total Score = Call Protection (15) + Notification Protection (15) + Security Settings (15)
--             + User Training (15) + Threat Events Posture (15) + Dangerous Links (15) + Blocked Calls (10) = 100 Max
ALTER TABLE public.security_score 
    ADD COLUMN IF NOT EXISTS call_protection_score INT NOT NULL DEFAULT 15 CHECK (call_protection_score BETWEEN 0 AND 15),
    ADD COLUMN IF NOT EXISTS notification_protection_score INT NOT NULL DEFAULT 15 CHECK (notification_protection_score BETWEEN 0 AND 15),
    ADD COLUMN IF NOT EXISTS security_settings_score INT NOT NULL DEFAULT 15 CHECK (security_settings_score BETWEEN 0 AND 15),
    ADD COLUMN IF NOT EXISTS user_training_score INT NOT NULL DEFAULT 8 CHECK (user_training_score BETWEEN 0 AND 15),
    ADD COLUMN IF NOT EXISTS threat_events_score INT NOT NULL DEFAULT 15 CHECK (threat_events_score BETWEEN 0 AND 15),
    ADD COLUMN IF NOT EXISTS dangerous_links_score INT NOT NULL DEFAULT 15 CHECK (dangerous_links_score BETWEEN 0 AND 15),
    ADD COLUMN IF NOT EXISTS blocked_calls_score INT NOT NULL DEFAULT 10 CHECK (blocked_calls_score BETWEEN 0 AND 10),
    ADD COLUMN IF NOT EXISTS factor_breakdown JSONB NOT NULL DEFAULT '{}'::jsonb;

-- 3. Security Score Change History Table ("Show users why their score changed")
CREATE TABLE IF NOT EXISTS public.security_score_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    previous_score INT NOT NULL CHECK (previous_score BETWEEN 0 AND 100),
    new_score INT NOT NULL CHECK (new_score BETWEEN 0 AND 100),
    delta_points INT NOT NULL,
    factor_category TEXT NOT NULL CHECK (factor_category IN (
        'CALL_PROTECTION', 'NOTIFICATION_PROTECTION', 'THREAT_EVENTS', 
        'DANGEROUS_LINKS', 'BLOCKED_CALLS', 'SECURITY_SETTINGS', 'USER_TRAINING', 'SYSTEM_RECALCULATION'
    )),
    trigger_title TEXT NOT NULL,
    reason_explanation TEXT NOT NULL,
    remediation_action TEXT,
    event_timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_score_history_user_id ON public.security_score_history(user_id);
CREATE INDEX IF NOT EXISTS idx_score_history_created_at ON public.security_score_history(created_at DESC);

-- Enable RLS
ALTER TABLE public.user_training_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_score_history ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can manage their own training modules"
    ON public.user_training_modules FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their score change history"
    ON public.security_score_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their score change history"
    ON public.security_score_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Realtime publication
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.security_score_history;
        ALTER PUBLICATION supabase_realtime ADD TABLE public.user_training_modules;
    END IF;
END $$;
