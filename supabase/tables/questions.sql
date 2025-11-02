CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_id UUID NOT NULL,
    question_text TEXT NOT NULL,
    question_type TEXT CHECK (question_type IN ('single_choice',
    'multiple_choice',
    'code')),
    options JSONB,
    correct_answer TEXT NOT NULL,
    difficulty INTEGER CHECK (difficulty >= 1 AND difficulty <= 5),
    created_by UUID NOT NULL,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);