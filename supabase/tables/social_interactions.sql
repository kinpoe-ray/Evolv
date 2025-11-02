CREATE TABLE social_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    target_id UUID NOT NULL,
    interaction_type TEXT CHECK (interaction_type IN ('follow',
    'like',
    'comment')),
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);