-- Migration: fix_user_courses_and_badges_queries
-- Created at: 1762012713

-- Migration: fix_user_courses_and_badges_queries
-- Created at: 1762014200
-- Fix user_courses table structure and RLS policies

-- 为user_courses表添加缺失的列
ALTER TABLE user_courses ADD COLUMN IF NOT EXISTS status TEXT CHECK (status IN ('in_progress', 'completed', 'dropped')) DEFAULT 'in_progress';
ALTER TABLE user_courses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 为user_courses表启用RLS
ALTER TABLE user_courses ENABLE ROW LEVEL SECURITY;

-- 创建user_courses表的RLS策略
-- 用户可以查看自己的课程记录
CREATE POLICY "Users can view their own courses" ON user_courses
    FOR SELECT USING (auth.uid() = user_id);

-- 用户可以插入自己的课程记录
CREATE POLICY "Users can insert their own courses" ON user_courses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 用户可以更新自己的课程记录
CREATE POLICY "Users can update their own courses" ON user_courses
    FOR UPDATE USING (auth.uid() = user_id);

-- 用户可以删除自己的课程记录
CREATE POLICY "Users can delete their own courses" ON user_courses
    FOR DELETE USING (auth.uid() = user_id);

-- 为user_badges表添加更好的外键约束
ALTER TABLE user_badges DROP CONSTRAINT IF EXISTS fk_user_badges_badge_id;
ALTER TABLE user_badges ADD CONSTRAINT fk_user_badges_badge_id 
    FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE;

-- 为user_badges表添加updated_at列
ALTER TABLE user_badges ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 修复可能的表结构问题
DO $$
BEGIN
    -- 检查并修复profiles表RLS
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'profiles' AND schemaname = 'public') THEN
        RAISE NOTICE 'profiles table does not exist, skipping';
    ELSE
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can view their own profile') THEN
            CREATE POLICY "Users can view their own profile" ON profiles
                FOR SELECT USING (auth.uid() = id);
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles' AND policyname = 'Users can update their own profile') THEN
            CREATE POLICY "Users can update their own profile" ON profiles
                FOR UPDATE USING (auth.uid() = id);
        END IF;
    END IF;
END $$;;