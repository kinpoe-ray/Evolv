CREATE TABLE guild_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guild_id UUID NOT NULL,
    user_id UUID NOT NULL,
    role TEXT CHECK (role IN ('member',
    'admin',
    'owner')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);