-- Migration: update_assessment_tables
-- Created at: 1762007597

-- 更新技能表结构
ALTER TABLE skills ADD COLUMN IF NOT EXISTS icon TEXT;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS level_required INTEGER DEFAULT 1;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS market_demand INTEGER DEFAULT 50;

-- 更新题目表结构
ALTER TABLE questions ADD COLUMN IF NOT EXISTS explanation TEXT;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS skill_points INTEGER DEFAULT 10;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS time_limit INTEGER DEFAULT 60;

-- 更新技能评估表结构
ALTER TABLE skill_assessments ADD COLUMN IF NOT EXISTS assessment_data JSONB;
ALTER TABLE skill_assessments ADD COLUMN IF NOT EXISTS skill_points INTEGER DEFAULT 0;

-- 创建技能等级表
CREATE TABLE IF NOT EXISTS skill_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    skill_id UUID NOT NULL,
    level INTEGER DEFAULT 1,
    score INTEGER DEFAULT 0,
    verified BOOLEAN DEFAULT false,
    last_assessment TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, skill_id)
);

-- 创建测评记录详细表
CREATE TABLE IF NOT EXISTS assessment_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    skill_id UUID NOT NULL,
    question_id UUID REFERENCES questions(id),
    user_answer TEXT,
    is_correct BOOLEAN,
    time_spent INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建关卡进度表
CREATE TABLE IF NOT EXISTS challenge_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    skill_id UUID NOT NULL,
    current_level INTEGER DEFAULT 1,
    completed_levels INTEGER[] DEFAULT '{}',
    total_score INTEGER DEFAULT 0,
    best_score INTEGER DEFAULT 0,
    last_attempt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, skill_id)
);;