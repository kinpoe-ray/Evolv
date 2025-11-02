-- Migration: update_skills_table_structure
-- Created at: 1762008267

-- Migration: update_skills_table_structure
-- 更新skills表结构，添加技能前置关系和详细信息
ALTER TABLE skills 
ADD COLUMN IF NOT EXISTS prerequisites TEXT[],
ADD COLUMN IF NOT EXISTS difficulty_level INTEGER CHECK (difficulty_level >= 1 AND difficulty_level <= 5) DEFAULT 1,
ADD COLUMN IF NOT EXISTS learning_resources TEXT[],
ADD COLUMN IF NOT EXISTS estimated_learning_time INTEGER;;