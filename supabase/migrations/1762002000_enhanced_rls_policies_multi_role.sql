-- 增强RLS策略以支持多角色认证系统
-- Migration: enhanced_rls_policies_multi_role
-- Created at: 1762002000

-- 首先删除现有的可能冲突的策略
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- 重新创建更精确的profiles策略
CREATE POLICY "Public profiles viewable by authenticated users" ON profiles
  FOR SELECT 
  USING (
    is_public = true 
    OR auth.uid() = id 
    OR auth.role() IN ('anon', 'service_role')
  );

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT 
  WITH CHECK (
    auth.uid() = id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE 
  USING (
    auth.uid() = id 
    OR auth.role() IN ('service_role')
  );

-- 教师可以查看所有学生的非公开资料（用于教学管理）
CREATE POLICY "Teachers can view all profiles for educational purposes" ON profiles
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM profiles teacher_profile 
      WHERE teacher_profile.id = auth.uid() 
      AND teacher_profile.user_type = 'teacher'
    )
  );

-- 删除现有的user_skills策略并重新创建
DROP POLICY IF EXISTS "User skills viewable by owner or public profiles" ON user_skills;
DROP POLICY IF EXISTS "Users can insert own skills" ON user_skills;
DROP POLICY IF EXISTS "Users can update own skills" ON user_skills;

-- 更精确的user_skills策略
CREATE POLICY "Users can view own skills" ON user_skills
  FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 教师可以查看其学生的技能（用于教学评估）
CREATE POLICY "Teachers can view student skills for educational purposes" ON user_skills
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM profiles teacher_profile 
      WHERE teacher_profile.id = auth.uid() 
      AND teacher_profile.user_type = 'teacher'
    )
  );

CREATE POLICY "Users can insert own skills" ON user_skills
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can update own skills" ON user_skills
  FOR UPDATE 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 删除并重新创建技能评估策略
DROP POLICY IF EXISTS "Users can view own assessments" ON skill_assessments;
DROP POLICY IF EXISTS "Users can insert own assessments" ON skill_assessments;

CREATE POLICY "Users can view own assessments" ON skill_assessments
  FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 教师可以查看学生的评估结果
CREATE POLICY "Teachers can view student assessments" ON skill_assessments
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM profiles teacher_profile 
      WHERE teacher_profile.id = auth.uid() 
      AND teacher_profile.user_type = 'teacher'
    )
  );

CREATE POLICY "Users can insert own assessments" ON skill_assessments
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 教师和管理员可以插入评估
CREATE POLICY "Teachers can insert assessments for students" ON skill_assessments
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles teacher_profile 
      WHERE teacher_profile.id = auth.uid() 
      AND teacher_profile.user_type = 'teacher'
    )
  );

-- 删除并重新创建课程相关策略
DROP POLICY IF EXISTS "Users can view own courses" ON user_courses;
DROP POLICY IF EXISTS "Users can insert own courses" ON user_courses;
DROP POLICY IF EXISTS "Users can update own courses" ON user_courses;

CREATE POLICY "Users can view own courses" ON user_courses
  FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can insert own courses" ON user_courses
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can update own courses" ON user_courses
  FOR UPDATE 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 教师可以查看选修其课程的学生
CREATE POLICY "Teachers can view students in their courses" ON user_courses
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      JOIN profiles teacher_profile ON teacher_profile.id = auth.uid()
      WHERE c.created_by = teacher_profile.id
      AND user_courses.course_id = c.id
      AND teacher_profile.user_type = 'teacher'
    )
  );

-- 删除并重新创建问答相关策略
DROP POLICY IF EXISTS "Approved questions viewable by everyone" ON questions;
DROP POLICY IF EXISTS "Teachers can insert questions" ON questions;
DROP POLICY IF EXISTS "Creators can update own questions" ON questions;

CREATE POLICY "Approved questions viewable by authenticated users" ON questions
  FOR SELECT 
  USING (
    is_approved = true 
    OR auth.uid() = created_by
    OR auth.role() IN ('service_role')
  );

-- 只有教师和管理员可以创建问题
CREATE POLICY "Teachers can create questions" ON questions
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles profile 
      WHERE profile.id = auth.uid() 
      AND profile.user_type = 'teacher'
    )
  );

CREATE POLICY "Creators can update own questions" ON questions
  FOR UPDATE 
  USING (
    auth.uid() = created_by 
    OR auth.role() IN ('service_role')
  );

-- 删除并重新创建答案策略
DROP POLICY IF EXISTS "Users can view own answers" ON user_answers;
DROP POLICY IF EXISTS "Users can insert own answers" ON user_answers;

CREATE POLICY "Users can view own answers" ON user_answers
  FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 教师可以查看学生的答案
CREATE POLICY "Teachers can view student answers" ON user_answers
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM profiles teacher_profile 
      WHERE teacher_profile.id = auth.uid() 
      AND teacher_profile.user_type = 'teacher'
    )
  );

CREATE POLICY "Users can insert own answers" ON user_answers
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 删除并重新创建社团相关策略
DROP POLICY IF EXISTS "Guilds are viewable by everyone" ON guilds;
DROP POLICY IF EXISTS "Users can create guilds" ON guilds;
DROP POLICY IF EXISTS "Guild owners can update" ON guilds;

CREATE POLICY "Guilds viewable by authenticated users" ON guilds
  FOR SELECT 
  USING (
    true 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Authenticated users can create guilds" ON guilds
  FOR INSERT 
  WITH CHECK (
    auth.uid() IS NOT NULL 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Guild owners and teachers can update" ON guilds
  FOR UPDATE 
  USING (
    auth.uid() = created_by 
    OR EXISTS (
      SELECT 1 FROM profiles profile 
      WHERE profile.id = auth.uid() 
      AND profile.user_type = 'teacher'
    )
    OR auth.role() IN ('service_role')
  );

-- 删除并重新创建社交互动策略
DROP POLICY IF EXISTS "Interactions viewable by involved users" ON social_interactions;
DROP POLICY IF EXISTS "Users can create interactions" ON social_interactions;
DROP POLICY IF EXISTS "Users can delete own interactions" ON social_interactions;

CREATE POLICY "Interactions viewable by involved users" ON social_interactions
  FOR SELECT 
  USING (
    auth.uid() IN (user_id, target_id)
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Authenticated users can create interactions" ON social_interactions
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can delete own interactions" ON social_interactions
  FOR DELETE 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 删除并重新创建职业目标策略
DROP POLICY IF EXISTS "Users can view own goals" ON career_goals;
DROP POLICY IF EXISTS "Users can insert own goals" ON career_goals;
DROP POLICY IF EXISTS "Users can update own goals" ON career_goals;

CREATE POLICY "Users can view own goals" ON career_goals
  FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 教师可以查看学生的职业目标（用于指导）
CREATE POLICY "Teachers can view student career goals" ON career_goals
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM profiles teacher_profile 
      WHERE teacher_profile.id = auth.uid() 
      AND teacher_profile.user_type = 'teacher'
    )
  );

CREATE POLICY "Users can insert own goals" ON career_goals
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can update own goals" ON career_goals
  FOR UPDATE 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 删除并重新创建学习路径策略
DROP POLICY IF EXISTS "Users can view own paths" ON learning_paths;
DROP POLICY IF EXISTS "Users can insert own paths" ON learning_paths;
DROP POLICY IF EXISTS "Users can update own paths" ON learning_paths;

CREATE POLICY "Users can view own paths" ON learning_paths
  FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can insert own paths" ON learning_paths
  FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

CREATE POLICY "Users can update own paths" ON learning_paths
  FOR UPDATE 
  USING (
    auth.uid() = user_id 
    OR auth.role() IN ('service_role')
  );

-- 创建角色管理函数
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, user_type, is_public)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'full_name', ''),
    COALESCE(new.raw_user_meta_data->>'user_type', 'student'),
    true
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建触发器，当新用户注册时自动创建profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();