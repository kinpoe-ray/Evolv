-- Migration: create_indexes_only
-- Created at: 1762008563

-- Migration: create_indexes_only
-- 创建索引
CREATE INDEX IF NOT EXISTS idx_skill_graphs_user_id ON skill_graphs(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_graphs_active ON skill_graphs(is_active);
CREATE INDEX IF NOT EXISTS idx_learning_paths_user_id ON learning_paths(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_paths_active ON learning_paths(is_active);;