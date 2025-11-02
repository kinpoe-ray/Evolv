CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_type TEXT NOT NULL CHECK (user_type IN ('student',
    'teacher',
    'alumni')),
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    school TEXT,
    major TEXT,
    graduation_year INTEGER,
    bio TEXT,
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);