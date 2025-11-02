-- ========================================
-- Supabase 数据库表结构设计
-- 创建日期: 2025-11-01
-- 描述: 技能学习平台数据库表结构
-- ========================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- 1. 用户表 (users)
-- 支持 student/teacher 角色
-- ========================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'teacher', 'admin')),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- 创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);

-- ========================================
-- 2. 用户档案表 (user_profiles)
-- 与users表一对一关系
-- ========================================
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(500),
    bio TEXT,
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),
    website_url VARCHAR(500),
    company VARCHAR(100),
    job_title VARCHAR(100),
    graduation_year INTEGER,
    current_level VARCHAR(20) DEFAULT 'beginner',
    experience_years INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_current_level ON user_profiles(current_level);

-- ========================================
-- 3. 技能库表 (skills)
-- 技能分类和定义
-- ========================================
CREATE TABLE skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')) DEFAULT 'beginner',
    is_active BOOLEAN DEFAULT true,
    icon_url VARCHAR(500),
    estimated_learning_hours INTEGER DEFAULT 0,
    prerequisites JSONB DEFAULT '[]',
    learning_outcomes TEXT[],
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_skills_category ON skills(category);
CREATE INDEX idx_skills_difficulty ON skills(difficulty_level);
CREATE INDEX idx_skills_is_active ON skills(is_active);

-- ========================================
-- 4. 用户技能表 (user_skills)
-- 用户与技能的多对多关系
-- ========================================
CREATE TABLE user_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    current_level VARCHAR(20) CHECK (current_level IN ('beginner', 'intermediate', 'advanced', 'expert')) DEFAULT 'beginner',
    proficiency_score INTEGER DEFAULT 0 CHECK (proficiency_score >= 0 AND proficiency_score <= 100),
    hours_practiced INTEGER DEFAULT 0,
    last_practiced_at TIMESTAMP WITH TIME ZONE,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, skill_id)
);

-- 创建索引
CREATE INDEX idx_user_skills_user_id ON user_skills(user_id);
CREATE INDEX idx_user_skills_skill_id ON user_skills(skill_id);
CREATE INDEX idx_user_skills_current_level ON user_skills(current_level);
CREATE INDEX idx_user_skills_proficiency_score ON user_skills(proficiency_score);

-- ========================================
-- 5. 测评记录表 (assessments)
-- 用户技能测评记录
-- ========================================
CREATE TABLE assessments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
    assessment_type VARCHAR(50) NOT NULL CHECK (assessment_type IN ('quiz', 'project', 'peer_review', 'self_assessment', 'practical_test')),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    max_score INTEGER NOT NULL DEFAULT 100,
    score INTEGER,
    passing_score INTEGER DEFAULT 70,
    status VARCHAR(20) CHECK (status IN ('draft', 'in_progress', 'completed', 'passed', 'failed')) DEFAULT 'draft',
    time_spent_minutes INTEGER DEFAULT 0,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    feedback TEXT,
    assessor_feedback TEXT,
    attempts INTEGER DEFAULT 1,
    is_published BOOLEAN DEFAULT false,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_assessments_user_id ON assessments(user_id);
CREATE INDEX idx_assessments_skill_id ON assessments(skill_id);
CREATE INDEX idx_assessments_type ON assessments(assessment_type);
CREATE INDEX idx_assessments_status ON assessments(status);
CREATE INDEX idx_assessments_completed_at ON assessments(completed_at);

-- ========================================
-- 6. 徽章表 (badges)
-- 成就徽章定义
-- ========================================
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    badge_type VARCHAR(50) NOT NULL CHECK (badge_type IN ('skill_mastery', 'achievement', 'participation', 'milestone', 'special')),
    icon_url VARCHAR(500),
    rarity VARCHAR(20) CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')) DEFAULT 'common',
    criteria JSONB NOT NULL,
    points_awarded INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_badges_badge_type ON badges(badge_type);
CREATE INDEX idx_badges_rarity ON badges(rarity);
CREATE INDEX idx_badges_is_active ON badges(is_active);

-- ========================================
-- 7. 用户徽章表 (user_badges)
-- 用户获得的徽章记录
-- ========================================
CREATE TABLE user_badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    earned_for JSONB,
    is_featured BOOLEAN DEFAULT false,
    notes TEXT,
    UNIQUE(user_id, badge_id)
);

-- 创建索引
CREATE INDEX idx_user_badges_user_id ON user_badges(user_id);
CREATE INDEX idx_user_badges_badge_id ON user_badges(badge_id);
CREATE INDEX idx_user_badges_earned_at ON user_badges(earned_at);

-- ========================================
-- 8. 技能公会表 (guilds)
-- 学习小组/公会
-- ========================================
CREATE TABLE guilds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    guild_type VARCHAR(50) NOT NULL CHECK (guild_type IN ('study_group', 'project_team', 'mentorship', 'community', 'competition')),
    category VARCHAR(100),
    skill_focus UUID REFERENCES skills(id),
    max_members INTEGER DEFAULT 50,
    current_members INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    avatar_url VARCHAR(500),
    banner_url VARCHAR(500),
    rules TEXT,
    requirements TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_guilds_guild_type ON guilds(guild_type);
CREATE INDEX idx_guilds_category ON guilds(category);
CREATE INDEX idx_guilds_skill_focus ON guilds(skill_focus);
CREATE INDEX idx_guilds_is_public ON guilds(is_public);
CREATE INDEX idx_guilds_created_by ON guilds(created_by);

-- ========================================
-- 9. 公会成员表 (guild_members)
-- 公会成员关系
-- ========================================
CREATE TABLE guild_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guild_id UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) CHECK (role IN ('member', 'moderator', 'admin', 'founder')) DEFAULT 'member',
    status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'banned')) DEFAULT 'active',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active_at TIMESTAMP WITH TIME ZONE,
    contribution_score INTEGER DEFAULT 0,
    UNIQUE(guild_id, user_id)
);

-- 创建索引
CREATE INDEX idx_guild_members_guild_id ON guild_members(guild_id);
CREATE INDEX idx_guild_members_user_id ON guild_members(user_id);
CREATE INDEX idx_guild_members_role ON guild_members(role);
CREATE INDEX idx_guild_members_status ON guild_members(status);

-- ========================================
-- 10. 课程表 (courses)
-- 课程信息
-- ========================================
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    course_type VARCHAR(50) NOT NULL CHECK (course_type IN ('video', 'text', 'interactive', 'workshop', 'mentorship')),
    category VARCHAR(100) NOT NULL,
    skill_focus UUID REFERENCES skills(id),
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')) DEFAULT 'beginner',
    duration_hours INTEGER DEFAULT 0,
    max_students INTEGER,
    current_students INTEGER DEFAULT 0,
    price DECIMAL(10, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'USD',
    is_free BOOLEAN DEFAULT true,
    is_published BOOLEAN DEFAULT false,
    thumbnail_url VARCHAR(500),
    instructor_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE
);

-- 创建索引
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_skill_focus ON courses(skill_focus);
CREATE INDEX idx_courses_difficulty ON courses(difficulty_level);
CREATE INDEX idx_courses_instructor_id ON courses(instructor_id);
CREATE INDEX idx_courses_is_published ON courses(is_published);

-- ========================================
-- 11. 课程章节表 (course_modules)
-- 课程的章节/模块
-- ========================================
CREATE TABLE course_modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    module_order INTEGER NOT NULL,
    content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('video', 'text', 'quiz', 'assignment', 'resource')),
    content_url VARCHAR(500),
    content_text TEXT,
    duration_minutes INTEGER DEFAULT 0,
    is_required BOOLEAN DEFAULT true,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_course_modules_course_id ON course_modules(course_id);
CREATE INDEX idx_course_modules_module_order ON course_modules(module_order);
CREATE INDEX idx_course_modules_content_type ON course_modules(content_type);

-- ========================================
-- 12. 课程注册表 (course_enrollments)
-- 用户课程注册记录
-- ========================================
CREATE TABLE course_enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(20) CHECK (status IN ('enrolled', 'in_progress', 'completed', 'dropped', 'suspended')) DEFAULT 'enrolled',
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    last_accessed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    final_grade DECIMAL(5, 2),
    certificate_url VARCHAR(500),
    UNIQUE(user_id, course_id)
);

-- 创建索引
CREATE INDEX idx_course_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX idx_course_enrollments_course_id ON course_enrollments(course_id);
CREATE INDEX idx_course_enrollments_status ON course_enrollments(status);
CREATE INDEX idx_course_enrollments_progress ON course_enrollments(progress_percentage);

-- ========================================
-- 13. 成绩表 (grades)
-- 课程成绩记录
-- ========================================
CREATE TABLE grades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    assessment_id UUID REFERENCES assessments(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
    grade_type VARCHAR(50) NOT NULL CHECK (grade_type IN ('quiz', 'assignment', 'project', 'final_exam', 'participation', 'peer_evaluation')),
    title VARCHAR(200) NOT NULL,
    max_score INTEGER NOT NULL DEFAULT 100,
    score INTEGER,
    letter_grade VARCHAR(2),
    percentage DECIMAL(5, 2),
    is_passed BOOLEAN,
    feedback TEXT,
    graded_by UUID REFERENCES users(id),
    graded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_grades_user_id ON grades(user_id);
CREATE INDEX idx_grades_course_id ON grades(course_id);
CREATE INDEX idx_grades_assessment_id ON grades(assessment_id);
CREATE INDEX idx_grades_skill_id ON grades(skill_id);
CREATE INDEX idx_grades_grade_type ON grades(grade_type);

-- ========================================
-- 14. 校友分享表 (alumni_posts)
-- 校友经验分享
-- ========================================
CREATE TABLE alumni_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    post_type VARCHAR(50) NOT NULL CHECK (post_type IN ('experience', 'career_advice', 'project_showcase', 'industry_insights', 'mentorship', 'success_story')),
    category VARCHAR(100),
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    reading_time_minutes INTEGER DEFAULT 0,
    featured_image_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE
);

-- 创建索引
CREATE INDEX idx_alumni_posts_author_id ON alumni_posts(author_id);
CREATE INDEX idx_alumni_posts_post_type ON alumni_posts(post_type);
CREATE INDEX idx_alumni_posts_category ON alumni_posts(category);
CREATE INDEX idx_alumni_posts_is_featured ON alumni_posts(is_featured);
CREATE INDEX idx_alumni_posts_is_published ON alumni_posts(is_published);
CREATE INDEX idx_alumni_posts_created_at ON alumni_posts(created_at);

-- ========================================
-- 15. 文章点赞表 (post_likes)
-- 用户对文章的点赞记录
-- ========================================
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES alumni_posts(id) ON DELETE CASCADE,
    liked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- 创建索引
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);

-- ========================================
-- 16. 文章评论表 (post_comments)
-- 对校友分享文章的评论
-- ========================================
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES alumni_posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES post_comments(id),
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT true,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_post_comments_post_id ON post_comments(post_id);
CREATE INDEX idx_post_comments_author_id ON post_comments(author_id);
CREATE INDEX idx_post_comments_parent_id ON post_comments(parent_comment_id);

-- ========================================
-- 触发器：自动更新时间戳
-- ========================================

-- 创建更新时间戳的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要的表添加更新时间戳触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_skills_updated_at BEFORE UPDATE ON skills FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_skills_updated_at BEFORE UPDATE ON user_skills FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_assessments_updated_at BEFORE UPDATE ON assessments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_badges_updated_at BEFORE UPDATE ON badges FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_guilds_updated_at BEFORE UPDATE ON guilds FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_course_modules_updated_at BEFORE UPDATE ON course_modules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_grades_updated_at BEFORE UPDATE ON grades FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_alumni_posts_updated_at BEFORE UPDATE ON alumni_posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_post_comments_updated_at BEFORE UPDATE ON post_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 行级安全策略 (RLS) 基础设置
-- ========================================

-- 启用 RLS (根据需要启用)
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE user_skills ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE guild_members ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE grades ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;

-- ========================================
-- 初始数据插入示例
-- ========================================

-- 插入示例徽章
INSERT INTO badges (name, description, badge_type, criteria, points_awarded) VALUES
('新手上路', '完成首次技能评估', 'achievement', '{"assessment_count": 1}', 10),
('技能新手', '掌握第一个技能', 'skill_mastery', '{"skills_mastered": 1}', 50),
('学习之星', '连续学习7天', 'milestone', '{"consecutive_days": 7}', 100),
('社群达人', '加入5个公会', 'participation', '{"guilds_joined": 5}', 75);

-- 插入示例技能
INSERT INTO skills (name, description, category, difficulty_level, estimated_learning_hours) VALUES
('Python编程', 'Python编程语言基础和进阶', '编程', 'beginner', 40),
('Web开发', 'HTML, CSS, JavaScript前端开发', '编程', 'beginner', 60),
('数据分析', '数据处理和分析技能', '数据科学', 'intermediate', 50),
('机器学习', '机器学习算法和应用', '数据科学', 'advanced', 80),
('项目管理', '项目规划和管理技能', '管理', 'intermediate', 30);

-- ========================================
-- 数据库模式创建完成
-- ========================================

-- 提示：创建完成后需要运行 generate_typescript_types 命令生成TypeScript类型定义
-- supabase gen types typescript --project-id your-project-id > types/database.types.ts