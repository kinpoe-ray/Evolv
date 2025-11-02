-- Migration: update_badges_table_structure
-- Created at: 1762007548

-- 更新徽章表结构
ALTER TABLE badges 
ADD COLUMN IF NOT EXISTS category TEXT CHECK (category IN ('learning', 'social', 'achievement', 'skill', 'milestone')) NOT NULL DEFAULT 'learning',
ADD COLUMN IF NOT EXISTS requirement_type TEXT CHECK (requirement_type IN ('score', 'course_complete', 'skill_mastery', 'streak', 'social', 'milestone')) NOT NULL DEFAULT 'milestone',
ADD COLUMN IF NOT EXISTS requirement_value INTEGER NOT NULL DEFAULT 1,
ADD COLUMN IF NOT EXISTS points INTEGER NOT NULL DEFAULT 10;

-- 设置稀有度字段为非空并设置默认值
ALTER TABLE badges ALTER COLUMN rarity SET DEFAULT 'common';
ALTER TABLE badges ALTER COLUMN rarity SET NOT NULL;;