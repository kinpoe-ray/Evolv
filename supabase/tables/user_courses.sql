CREATE TABLE user_courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    course_id UUID NOT NULL,
    grade TEXT,
    score DECIMAL,
    semester TEXT,
    year INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);