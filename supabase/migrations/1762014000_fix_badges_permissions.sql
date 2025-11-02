-- Migration: fix_badges_permissions
-- Created at: 1762014000
-- Fix RLS policies for badges and user_badges tables

-- 为badges表启用RLS
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

-- 创建badges表的RLS策略
-- 所有人都可以读取徽章数据
CREATE POLICY "Everyone can read badges" ON badges
    FOR SELECT USING (true);

-- 只有系统或管理员可以插入徽章（这里简化，允许认证用户插入）
CREATE POLICY "Authenticated users can insert badges" ON badges
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 更新user_badges表，添加外键约束
ALTER TABLE user_badges ADD CONSTRAINT fk_user_badges_badge_id 
    FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE;

-- 为user_badges表启用RLS
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- 创建user_badges表的RLS策略
-- 用户可以查看自己的徽章记录
CREATE POLICY "Users can view their own badges" ON user_badges
    FOR SELECT USING (auth.uid() = user_id);

-- 用户可以插入自己的徽章记录
CREATE POLICY "Users can insert their own badges" ON user_badges
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 用户可以更新自己的徽章记录
CREATE POLICY "Users can update their own badges" ON user_badges
    FOR UPDATE USING (auth.uid() = user_id);

-- 用户可以删除自己的徽章记录
CREATE POLICY "Users can delete their own badges" ON user_badges
    FOR DELETE USING (auth.uid() = user_id);

-- 为其他相关表也启用RLS（如果还没有的话）
DO $$
BEGIN
    -- 为skills表启用RLS
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'skills' AND schemaname = 'public') THEN
        RAISE NOTICE 'skills table does not exist, skipping RLS enable';
    ELSE
        EXECUTE 'ALTER TABLE skills ENABLE ROW LEVEL SECURITY';
        -- 创建skills表的策略
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'skills' AND policyname = 'Everyone can read skills') THEN
            CREATE POLICY "Everyone can read skills" ON skills
                FOR SELECT USING (true);
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'skills' AND policyname = 'Authenticated users can insert skills') THEN
            CREATE POLICY "Authenticated users can insert skills" ON skills
                FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
        END IF;
    END IF;

    -- 为user_skills表启用RLS
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'user_skills' AND schemaname = 'public') THEN
        RAISE NOTICE 'user_skills table does not exist, skipping RLS enable';
    ELSE
        EXECUTE 'ALTER TABLE user_skills ENABLE ROW LEVEL SECURITY';
        -- 创建user_skills表的策略
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_skills' AND policyname = 'Users can view their own skills') THEN
            CREATE POLICY "Users can view their own skills" ON user_skills
                FOR SELECT USING (auth.uid() = user_id);
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_skills' AND policyname = 'Users can insert their own skills') THEN
            CREATE POLICY "Users can insert their own skills" ON user_skills
                FOR INSERT WITH CHECK (auth.uid() = user_id);
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_skills' AND policyname = 'Users can update their own skills') THEN
            CREATE POLICY "Users can update their own skills" ON user_skills
                FOR UPDATE USING (auth.uid() = user_id);
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_skills' AND policyname = 'Users can delete their own skills') THEN
            CREATE POLICY "Users can delete their own skills" ON user_skills
                FOR DELETE USING (auth.uid() = user_id);
        END IF;
    END IF;
END $$;