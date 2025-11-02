-- 更新技能表结构
ALTER TABLE skills ADD COLUMN IF NOT EXISTS icon TEXT;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS level_required INTEGER DEFAULT 1;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS market_demand INTEGER DEFAULT 50;

-- 更新题目表结构
ALTER TABLE questions ADD COLUMN IF NOT EXISTS explanation TEXT;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS skill_points INTEGER DEFAULT 10;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS time_limit INTEGER DEFAULT 60;

-- 更新技能评估表结构
ALTER TABLE skill_assessments ADD COLUMN IF NOT EXISTS assessment_data JSONB;
ALTER TABLE skill_assessments ADD COLUMN IF NOT EXISTS skill_points INTEGER DEFAULT 0;

-- 创建技能等级表
CREATE TABLE IF NOT EXISTS skill_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    skill_id UUID NOT NULL,
    level INTEGER DEFAULT 1,
    score INTEGER DEFAULT 0,
    verified BOOLEAN DEFAULT false,
    last_assessment TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, skill_id)
);

-- 创建测评记录详细表
CREATE TABLE IF NOT EXISTS assessment_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    skill_id UUID NOT NULL,
    question_id UUID REFERENCES questions(id),
    user_answer TEXT,
    is_correct BOOLEAN,
    time_spent INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建关卡进度表
CREATE TABLE IF NOT EXISTS challenge_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    skill_id UUID NOT NULL,
    current_level INTEGER DEFAULT 1,
    completed_levels INTEGER[] DEFAULT '{}',
    total_score INTEGER DEFAULT 0,
    best_score INTEGER DEFAULT 0,
    last_attempt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, skill_id)
);

-- 插入基础技能数据
INSERT INTO skills (id, name, category, description, icon, level_required, market_demand) VALUES
('11111111-1111-1111-1111-111111111111', '前端开发', '技术技能', '掌握HTML、CSS、JavaScript等前端技术，具备用户界面开发能力', '💻', 1, 90),
('22222222-2222-2222-2222-222222222222', '后端开发', '技术技能', '精通服务器端编程语言和数据库技术', '⚙️', 1, 95),
('33333333-3333-3333-3333-333333333333', '数据库管理', '技术技能', '能够设计、管理和优化数据库系统', '🗄️', 2, 80),
('44444444-4444-4444-4444-444444444444', 'DevOps', '技术技能', '熟悉持续集成/持续部署流程和工具', '🔄', 3, 85),
('55555555-5555-5555-5555-555555555555', '网络安全', '技术技能', '具备网络安全防护和风险评估能力', '🔒', 3, 88),

('66666666-6666-6666-6666-666666666666', '内容运营', '运营技能', '负责内容策划、制作和分发，提升用户参与度', '📝', 1, 75),
('77777777-7777-7777-7777-777777777777', '数据运营', '运营技能', '通过数据分析优化运营策略和效果', '📊', 2, 82),
('88888888-8888-8888-8888-888888888888', '用户运营', '运营技能', '负责用户获取、留存和转化工作', '👥', 1, 78),
('99999999-9999-9999-9999-999999999999', '社群运营', '运营技能', '运营和维护社群，提升用户活跃度和粘性', '🌐', 2, 70),

('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '产品设计', '产品技能', '负责产品功能设计和用户体验优化', '🎨', 2, 85),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '产品分析', '产品技能', '分析产品数据和用户反馈，指导产品迭代', '📈', 3, 80),
('cccccccc-cccc-cccc-cccc-cccccccccccc', '产品运营', '产品技能', '负责产品生命周期管理和商业化运营', '🚀', 2, 75),
('dddddddd-dddd-dddd-dddd-dddddddddddd', '商业模式', '产品技能', '设计和优化产品商业模式', '💼', 4, 70),

('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '数据分析', '数据技能', '收集、分析和解读数据，支撑业务决策', '🔍', 2, 88),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '数字营销', '营销技能', '通过数字渠道进行品牌推广和获客', '📢', 2, 82)
ON CONFLICT (id) DO NOTHING;