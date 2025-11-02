-- Migration: create_skill_graphs_table
-- Created at: 1762008234

-- Migration: create_skill_graphs_table
-- 创建skill_graphs表（技能图谱）
CREATE TABLE IF NOT EXISTS skill_graphs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    nodes JSONB DEFAULT '[]',
    edges JSONB DEFAULT '[]',
    total_skills INTEGER DEFAULT 0,
    completed_skills INTEGER DEFAULT 0,
    average_score DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);;