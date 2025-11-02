-- Migration: update_user_skills_table
-- Created at: 1762008276

-- Migration: update_user_skills_table
-- 更新user_skills表，添加 proficiency_score字段
ALTER TABLE user_skills 
ADD COLUMN IF NOT EXISTS proficiency_score INTEGER CHECK (proficiency_score >= 0 AND proficiency_score <= 100) DEFAULT 0;

-- 更新user_skills表的level字段约束
ALTER TABLE user_skills DROP CONSTRAINT IF EXISTS user_skills_level_check;
ALTER TABLE user_skills ADD CONSTRAINT user_skills_level_check CHECK (level >= 0 AND level <= 5);;