-- Migration: create_basic_indexes
-- Created at: 1762008583

-- Migration: create_basic_indexes
-- 创建索引
CREATE INDEX IF NOT EXISTS idx_skill_graphs_user_id ON skill_graphs(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_paths_user_id ON learning_paths(user_id);;