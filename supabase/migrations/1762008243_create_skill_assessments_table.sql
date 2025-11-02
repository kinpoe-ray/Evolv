-- Migration: create_skill_assessments_table
-- Created at: 1762008243

-- Migration: create_skill_assessments_table
-- 创建skill_assessments表（技能评估历史）
CREATE TABLE IF NOT EXISTS skill_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    assessment_type TEXT CHECK (assessment_type IN ('knowledge', 'practical', 'comprehensive')) NOT NULL DEFAULT 'comprehensive',
    level INTEGER CHECK (level >= 1 AND level <= 5),
    score INTEGER CHECK (score >= 0 AND score <= 100),
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    strengths TEXT[],
    weaknesses TEXT[],
    recommendations TEXT[],
    next_steps TEXT[],
    estimated_learning_time TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);;