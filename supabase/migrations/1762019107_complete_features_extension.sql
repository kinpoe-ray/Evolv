-- Migration: complete_features_extension
-- Created at: 1762019107

-- ========================================
-- Evolv平台完整功能模块数据库扩展
-- 创建日期: 2025-11-02
-- 描述: 支持校友会、SkillFolio、技能擂台、老师平台、学校管理端
-- ========================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- 1. 校友导师匹配表 (alumni_mentors)
-- 校友导师信息和管理
-- ========================================
CREATE TABLE alumni_mentors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mentor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    industry VARCHAR(100) NOT NULL,
    company VARCHAR(200),
    position VARCHAR(100),
    experience_years INTEGER DEFAULT 0,
    specializations TEXT[],
    availability VARCHAR(20) CHECK (availability IN ('available', 'busy', 'unavailable')) DEFAULT 'available',
    max_mentees INTEGER DEFAULT 3,
    current_mentees INTEGER DEFAULT 0,
    mentoring_fee DECIMAL(10, 2) DEFAULT 0.00,
    bio TEXT,
    linkedin_url VARCHAR(500),
    portfolio_url VARCHAR(500),
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_alumni_mentors_mentor_id ON alumni_mentors(mentor_id);
CREATE INDEX idx_alumni_mentors_industry ON alumni_mentors(industry);
CREATE INDEX idx_alumni_mentors_availability ON alumni_mentors(availability);

-- ========================================
-- 2. 导师匹配申请表 (mentor_requests)
-- 学生申请导师的记录
-- ========================================
CREATE TABLE mentor_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mentor_id UUID NOT NULL REFERENCES alumni_mentors(id) ON DELETE CASCADE,
    mentee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    request_message TEXT NOT NULL,
    academic_background TEXT,
    career_goals TEXT,
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted', 'rejected', 'completed')) DEFAULT 'pending',
    response_message TEXT,
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    responded_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 索引
CREATE INDEX idx_mentor_requests_mentor_id ON mentor_requests(mentor_id);
CREATE INDEX idx_mentor_requests_mentee_id ON mentor_requests(mentee_id);
CREATE INDEX idx_mentor_requests_status ON mentor_requests(status);

-- ========================================
-- 3. 技能挑战赛表 (skill_challenges)
-- 技能擂台系统核心表
-- ========================================
CREATE TABLE skill_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    challenge_type VARCHAR(50) CHECK (challenge_type IN ('coding', 'design', 'presentation', 'problem_solving', 'team_competition', 'individual')) NOT NULL,
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')) DEFAULT 'beginner',
    skills_required TEXT[] NOT NULL,
    max_participants INTEGER DEFAULT 100,
    current_participants INTEGER DEFAULT 0,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    registration_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
    prize_description TEXT,
    prize_amount DECIMAL(10, 2) DEFAULT 0.00,
    rules TEXT NOT NULL,
    resources TEXT[],
    created_by UUID NOT NULL REFERENCES profiles(id),
    status VARCHAR(20) CHECK (status IN ('draft', 'open', 'in_progress', 'completed', 'cancelled')) DEFAULT 'draft',
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_skill_challenges_type ON skill_challenges(challenge_type);
CREATE INDEX idx_skill_challenges_difficulty ON skill_challenges(difficulty_level);
CREATE INDEX idx_skill_challenges_status ON skill_challenges(status);
CREATE INDEX idx_skill_challenges_start_time ON skill_challenges(start_time);

-- ========================================
-- 4. 挑战参赛记录表 (challenge_participants)
-- 参与挑战的记录
-- ========================================
CREATE TABLE challenge_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id UUID NOT NULL REFERENCES skill_challenges(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    team_name VARCHAR(100),
    team_members UUID[],
    registration_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    submission_time TIMESTAMP WITH TIME ZONE,
    score INTEGER DEFAULT 0,
    max_score INTEGER DEFAULT 100,
    ranking INTEGER,
    status VARCHAR(20) CHECK (status IN ('registered', 'submitted', 'disqualified')) DEFAULT 'registered',
    submission_link VARCHAR(500),
    notes TEXT,
    UNIQUE(challenge_id, user_id)
);

-- 索引
CREATE INDEX idx_challenge_participants_challenge_id ON challenge_participants(challenge_id);
CREATE INDEX idx_challenge_participants_user_id ON challenge_participants(user_id);
CREATE INDEX idx_challenge_participants_ranking ON challenge_participants(ranking);

-- ========================================
-- 5. 技能评估报告表 (skill_assessments_public)
-- 公开的技能评估报告
-- ========================================
CREATE TABLE skill_assessments_public (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    assessment_type VARCHAR(50) CHECK (assessment_type IN ('comprehensive', 'skill_specific', 'project_based')) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    assessment_data JSONB NOT NULL,
    overall_score INTEGER CHECK (overall_score >= 0 AND overall_score <= 100),
    skill_breakdown JSONB,
    recommendations TEXT[],
    assessment_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_public BOOLEAN DEFAULT true,
    verification_level VARCHAR(20) CHECK (verification_level IN ('self_assessed', 'peer_verified', 'instructor_verified', 'certified')) DEFAULT 'self_assessed',
    certificate_url VARCHAR(500),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_skill_assessments_public_user_id ON skill_assessments_public(user_id);
CREATE INDEX idx_skill_assessments_public_type ON skill_assessments_public(assessment_type);
CREATE INDEX idx_skill_assessments_public_public ON skill_assessments_public(is_public);
CREATE INDEX idx_skill_assessments_public_score ON skill_assessments_public(overall_score);

-- ========================================
-- 6. 题库扩展表 (question_bank)
-- 扩展的题库系统，支持多种题型
-- ========================================
CREATE TABLE question_bank (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    question_text TEXT NOT NULL,
    question_type VARCHAR(30) CHECK (question_type IN ('multiple_choice', 'true_false', 'short_answer', 'essay', 'coding', 'drag_drop', 'matching')) NOT NULL,
    subject_area VARCHAR(100) NOT NULL,
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced', 'expert')) DEFAULT 'beginner',
    options JSONB, -- for multiple choice, drag_drop, matching
    correct_answer TEXT NOT NULL,
    explanation TEXT,
    points INTEGER DEFAULT 1,
    time_limit INTEGER, -- in minutes
    tags TEXT[],
    created_by UUID NOT NULL REFERENCES profiles(id),
    usage_count INTEGER DEFAULT 0,
    accuracy_rate DECIMAL(5, 2) DEFAULT 0.00,
    is_public BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES profiles(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_question_bank_type ON question_bank(question_type);
CREATE INDEX idx_question_bank_subject ON question_bank(subject_area);
CREATE INDEX idx_question_bank_difficulty ON question_bank(difficulty_level);
CREATE INDEX idx_question_bank_created_by ON question_bank(created_by);

-- ========================================
-- 7. 学校统计数据表 (school_statistics)
-- 学校管理端统计数据
-- ========================================
CREATE TABLE school_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    school_name VARCHAR(200) NOT NULL,
    statistic_type VARCHAR(50) CHECK (statistic_type IN ('student_count', 'graduate_employment', 'skill_distribution', 'course_performance', 'alumni_network')) NOT NULL,
    period_type VARCHAR(20) CHECK (period_type IN ('daily', 'weekly', 'monthly', 'semester', 'yearly')) DEFAULT 'monthly',
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    data JSONB NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_school_statistics_school ON school_statistics(school_name);
CREATE INDEX idx_school_statistics_type ON school_statistics(statistic_type);
CREATE INDEX idx_school_statistics_period ON school_statistics(period_start, period_end);

-- ========================================
-- 8. 求职资源表 (career_resources)
-- 校友分享的求职资源
-- ========================================
CREATE TABLE career_resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    resource_type VARCHAR(50) CHECK (resource_type IN ('resume_template', 'interview_guide', 'portfolio_example', 'job_search_tips', 'industry_analysis', 'salary_guide')) NOT NULL,
    file_url VARCHAR(500),
    file_type VARCHAR(50),
    file_size INTEGER,
    target_audience VARCHAR(100),
    industry_focus VARCHAR(100),
    experience_level VARCHAR(50),
    download_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    created_by UUID NOT NULL REFERENCES profiles(id),
    is_featured BOOLEAN DEFAULT false,
    is_verified BOOLEAN DEFAULT false,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_career_resources_type ON career_resources(resource_type);
CREATE INDEX idx_career_resources_industry ON career_resources(industry_focus);
CREATE INDEX idx_career_resources_featured ON career_resources(is_featured);
CREATE INDEX idx_career_resources_downloads ON career_resources(download_count);

-- ========================================
-- 触发器：自动更新时间戳
-- ========================================

-- 创建统一的更新时间戳函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要的表添加更新时间戳触发器
CREATE TRIGGER update_alumni_mentors_updated_at 
    BEFORE UPDATE ON alumni_mentors 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skill_challenges_updated_at 
    BEFORE UPDATE ON skill_challenges 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_skill_assessments_public_updated_at 
    BEFORE UPDATE ON skill_assessments_public 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_question_bank_updated_at 
    BEFORE UPDATE ON question_bank 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_school_statistics_updated_at 
    BEFORE UPDATE ON school_statistics 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_career_resources_updated_at 
    BEFORE UPDATE ON career_resources 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 行级安全策略 (RLS)
-- ========================================

-- 启用 RLS
ALTER TABLE alumni_mentors ENABLE ROW LEVEL SECURITY;
ALTER TABLE mentor_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_assessments_public ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_bank ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_resources ENABLE ROW LEVEL SECURITY;

-- 校友导师策略
CREATE POLICY "用户可以查看活跃的校友导师" ON alumni_mentors
    FOR SELECT 
    USING (availability = 'available' AND is_verified = true);

CREATE POLICY "校友可以管理自己的导师信息" ON alumni_mentors
    FOR ALL 
    USING (auth.uid() = mentor_id);

-- 技能挑战策略
CREATE POLICY "用户可以查看公开的技能挑战" ON skill_challenges
    FOR SELECT 
    USING (is_public = true AND status IN ('open', 'in_progress', 'completed'));

CREATE POLICY "创建者可以管理自己的挑战" ON skill_challenges
    FOR ALL 
    USING (auth.uid() = created_by);

-- 技能评估公开策略
CREATE POLICY "用户可以查看公开的技能评估报告" ON skill_assessments_public
    FOR SELECT 
    USING (is_public = true);

CREATE POLICY "用户可以管理自己的技能评估报告" ON skill_assessments_public
    FOR ALL 
    USING (auth.uid() = user_id);

-- 题目库策略
CREATE POLICY "用户可以查看公开和已验证的题目" ON question_bank
    FOR SELECT 
    USING (is_public = true AND (is_verified = true OR auth.uid() = created_by));

-- 求职资源策略
CREATE POLICY "用户可以查看求职资源" ON career_resources
    FOR SELECT 
    USING (true);

CREATE POLICY "创建者可以管理自己的求职资源" ON career_resources
    FOR ALL 
    USING (auth.uid() = created_by);

-- ========================================
-- 初始数据插入
-- ========================================

-- 插入示例校友导师（使用现有profiles数据）
INSERT INTO alumni_mentors (mentor_id, industry, company, position, experience_years, specializations, availability)
SELECT 
    p.id,
    '软件开发',
    '腾讯',
    '高级软件工程师',
    5,
    ARRAY['Java', 'Spring Boot', '微服务架构'],
    'available'
FROM profiles p 
WHERE p.user_type = 'alumni'
LIMIT 3;

-- 插入示例技能挑战
INSERT INTO skill_challenges (title, description, challenge_type, difficulty_level, skills_required, start_time, end_time, registration_deadline, rules, created_by)
VALUES 
('前端开发挑战赛', '基于React的现代Web应用开发挑战', 'coding', 'intermediate', ARRAY['React', 'JavaScript', 'CSS'], NOW() + INTERVAL '7 days', NOW() + INTERVAL '14 days', NOW() + INTERVAL '5 days', '使用React构建响应式Web应用', (SELECT id FROM profiles LIMIT 1)),
('UI设计大赛', '移动应用界面设计挑战', 'design', 'beginner', ARRAY['UI Design', 'Figma', '用户体验'], NOW() + INTERVAL '3 days', NOW() + INTERVAL '10 days', NOW() + INTERVAL '2 days', '设计一个移动应用的用户界面原型', (SELECT id FROM profiles LIMIT 1));

-- 插入示例求职资源
INSERT INTO career_resources (title, description, resource_type, target_audience, industry_focus, experience_level, created_by)
VALUES 
('大学生求职简历模板', '适合应届毕业生的标准简历模板', 'resume_template', '应届毕业生', '全行业', 'entry_level', (SELECT id FROM profiles LIMIT 1)),
('技术面试常见问题集', '软件开发岗位面试常见问题和答案', 'interview_guide', '求职者', '软件开发', 'all_levels', (SELECT id FROM profiles LIMIT 1));;