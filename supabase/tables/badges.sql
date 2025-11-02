CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon_url TEXT,
    skill_id UUID,
    rarity TEXT CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')) NOT NULL DEFAULT 'common',
    category TEXT CHECK (category IN ('learning', 'social', 'achievement', 'skill', 'milestone')) NOT NULL DEFAULT 'learning',
    requirement_type TEXT CHECK (requirement_type IN ('score', 'course_complete', 'skill_mastery', 'streak', 'social', 'milestone')) NOT NULL DEFAULT 'milestone',
    requirement_value INTEGER NOT NULL DEFAULT 1,
    requirement_score INTEGER,
    points INTEGER NOT NULL DEFAULT 10,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);