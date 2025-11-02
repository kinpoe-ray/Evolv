CREATE TABLE career_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    goal_title TEXT NOT NULL,
    target_position TEXT,
    target_company TEXT,
    deadline DATE,
    status TEXT CHECK (status IN ('active',
    'completed',
    'abandoned')) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);