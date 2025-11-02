-- Migration: enable_rls_and_policies
-- Created at: 1762001504

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE guilds ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumni_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumni_comments ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (is_public = true OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id OR auth.role() IN ('anon', 'service_role'));

-- Skills policies (public read, admin write)
CREATE POLICY "Skills are viewable by everyone" ON skills
  FOR SELECT USING (true);

CREATE POLICY "Allow insert skills" ON skills
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

-- User skills policies
CREATE POLICY "User skills viewable by owner or public profiles" ON user_skills
  FOR SELECT USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can insert own skills" ON user_skills
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can update own skills" ON user_skills
  FOR UPDATE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Badges policies
CREATE POLICY "Badges are viewable by everyone" ON badges
  FOR SELECT USING (true);

CREATE POLICY "Allow insert badges" ON badges
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

-- User badges policies
CREATE POLICY "User badges viewable by everyone" ON user_badges
  FOR SELECT USING (true);

CREATE POLICY "Allow insert user badges" ON user_badges
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

-- Skill assessments policies
CREATE POLICY "Users can view own assessments" ON skill_assessments
  FOR SELECT USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can insert own assessments" ON skill_assessments
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Courses policies
CREATE POLICY "Courses are viewable by everyone" ON courses
  FOR SELECT USING (true);

CREATE POLICY "Allow insert courses" ON courses
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

-- User courses policies
CREATE POLICY "Users can view own courses" ON user_courses
  FOR SELECT USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can insert own courses" ON user_courses
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can update own courses" ON user_courses
  FOR UPDATE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Questions policies
CREATE POLICY "Approved questions viewable by everyone" ON questions
  FOR SELECT USING (is_approved = true OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Teachers can insert questions" ON questions
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Creators can update own questions" ON questions
  FOR UPDATE USING (auth.uid() = created_by OR auth.role() IN ('anon', 'service_role'));

-- User answers policies
CREATE POLICY "Users can view own answers" ON user_answers
  FOR SELECT USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can insert own answers" ON user_answers
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Guilds policies
CREATE POLICY "Guilds are viewable by everyone" ON guilds
  FOR SELECT USING (true);

CREATE POLICY "Users can create guilds" ON guilds
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Guild owners can update" ON guilds
  FOR UPDATE USING (auth.uid() = created_by OR auth.role() IN ('anon', 'service_role'));

-- Guild members policies
CREATE POLICY "Guild members viewable by everyone" ON guild_members
  FOR SELECT USING (true);

CREATE POLICY "Users can join guilds" ON guild_members
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can leave guilds" ON guild_members
  FOR DELETE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Social interactions policies
CREATE POLICY "Interactions viewable by involved users" ON social_interactions
  FOR SELECT USING (auth.uid() IN (user_id, target_id) OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can create interactions" ON social_interactions
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can delete own interactions" ON social_interactions
  FOR DELETE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Career goals policies
CREATE POLICY "Users can view own goals" ON career_goals
  FOR SELECT USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can insert own goals" ON career_goals
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can update own goals" ON career_goals
  FOR UPDATE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Learning paths policies
CREATE POLICY "Users can view own paths" ON learning_paths
  FOR SELECT USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can insert own paths" ON learning_paths
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can update own paths" ON learning_paths
  FOR UPDATE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Alumni posts policies
CREATE POLICY "Alumni posts viewable by everyone" ON alumni_posts
  FOR SELECT USING (true);

CREATE POLICY "Users can create posts" ON alumni_posts
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can update own posts" ON alumni_posts
  FOR UPDATE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can delete own posts" ON alumni_posts
  FOR DELETE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));

-- Alumni comments policies
CREATE POLICY "Comments viewable by everyone" ON alumni_comments
  FOR SELECT USING (true);

CREATE POLICY "Users can create comments" ON alumni_comments
  FOR INSERT WITH CHECK (auth.role() IN ('anon', 'service_role'));

CREATE POLICY "Users can delete own comments" ON alumni_comments
  FOR DELETE USING (auth.uid() = user_id OR auth.role() IN ('anon', 'service_role'));;