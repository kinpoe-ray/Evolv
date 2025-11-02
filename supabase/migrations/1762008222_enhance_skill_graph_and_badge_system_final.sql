-- Migration: enhance_skill_graph_and_badge_system_final
-- Created at: 1762008222

-- Migration: enhance_skill_graph_and_badge_system_final
-- Created at: 1762013556

-- 更新skills表结构，添加技能前置关系和详细信息
ALTER TABLE skills 
ADD COLUMN IF NOT EXISTS prerequisites TEXT[], -- 技能前置关系，存储skill ID数组
ADD COLUMN IF NOT EXISTS difficulty_level INTEGER CHECK (difficulty_level >= 1 AND difficulty_level <= 5) DEFAULT 1,
ADD COLUMN IF NOT EXISTS learning_resources TEXT[],
ADD COLUMN IF NOT EXISTS estimated_learning_time INTEGER; -- 预估学习时间（小时）

-- 创建skill_graphs表（技能图谱）
CREATE TABLE IF NOT EXISTS skill_graphs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    nodes JSONB DEFAULT '[]', -- 存储技能节点数据
    edges JSONB DEFAULT '[]', -- 存储技能边关系数据
    total_skills INTEGER DEFAULT 0,
    completed_skills INTEGER DEFAULT 0,
    average_score DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_skill_graphs_user_id ON skill_graphs(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_graphs_active ON skill_graphs(is_active);

-- 更新user_skills表，添加 proficiency_score字段
ALTER TABLE user_skills 
ADD COLUMN IF NOT EXISTS proficiency_score INTEGER CHECK (proficiency_score >= 0 AND proficiency_score <= 100) DEFAULT 0;

-- 更新user_skills表的level字段约束
ALTER TABLE user_skills DROP CONSTRAINT IF EXISTS user_skills_level_check;
ALTER TABLE user_skills ADD CONSTRAINT user_skills_level_check CHECK (level >= 0 AND level <= 5);

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
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_skill_assessments_user_id ON skill_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_assessments_skill_id ON skill_assessments(skill_id);
CREATE INDEX IF NOT EXISTS idx_skill_assessments_created_at ON skill_assessments(created_at);

-- 创建learning_paths表（学习路径）
CREATE TABLE IF NOT EXISTS learning_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    skill_graph_id UUID REFERENCES skill_graphs(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    steps JSONB DEFAULT '[]', -- 存储学习步骤数据
    total_duration INTEGER DEFAULT 0, -- 总学习时长（小时）
    difficulty_level INTEGER CHECK (difficulty_level >= 1 AND difficulty_level <= 5) DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_learning_paths_user_id ON learning_paths(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_paths_active ON learning_paths(is_active);

-- 添加RLS策略
ALTER TABLE skill_graphs ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;

-- 创建RLS策略
CREATE POLICY "Users can view their own skill graphs" ON skill_graphs
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own skill graphs" ON skill_graphs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own skill graphs" ON skill_graphs
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own skill graphs" ON skill_graphs
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own skill assessments" ON skill_assessments
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own skill assessments" ON skill_assessments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own learning paths" ON learning_paths
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own learning paths" ON learning_paths
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own learning paths" ON learning_paths
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own learning paths" ON learning_paths
    FOR DELETE USING (auth.uid() = user_id);;