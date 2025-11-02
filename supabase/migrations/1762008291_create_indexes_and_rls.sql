-- Migration: create_indexes_and_rls
-- Created at: 1762008291

-- Migration: create_indexes_and_rls
-- 创建索引
CREATE INDEX IF NOT EXISTS idx_skill_graphs_user_id ON skill_graphs(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_graphs_active ON skill_graphs(is_active);
CREATE INDEX IF NOT EXISTS idx_skill_assessments_user_id ON skill_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_assessments_skill_id ON skill_assessments(skill_id);
CREATE INDEX IF NOT EXISTS idx_skill_assessments_created_at ON skill_assessments(created_at);
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