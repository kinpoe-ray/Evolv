-- Migration: create_learning_paths_table
-- Created at: 1762008254

-- Migration: create_learning_paths_table
-- 创建learning_paths表（学习路径）
CREATE TABLE IF NOT EXISTS learning_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    skill_graph_id UUID REFERENCES skill_graphs(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    steps JSONB DEFAULT '[]',
    total_duration INTEGER DEFAULT 0,
    difficulty_level INTEGER CHECK (difficulty_level >= 1 AND difficulty_level <= 5) DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);;