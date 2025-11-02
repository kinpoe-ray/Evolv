-- Migration: create_grades_table
-- Created at: 1762018221

-- ========================================
-- 成绩管理功能数据库表
-- 创建日期: 2025-11-02
-- 描述: 为成绩管理系统创建grades表
-- ========================================

-- 成绩表 (grades)
-- 课程成绩记录
CREATE TABLE grades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    course_id UUID,
    assessment_id UUID,
    skill_id UUID,
    grade_type VARCHAR(50) CHECK (grade_type IN ('quiz', 'assignment', 'project', 'final_exam', 'participation', 'peer_evaluation')) NOT NULL,
    title VARCHAR(200) NOT NULL,
    max_score INTEGER NOT NULL DEFAULT 100,
    score INTEGER,
    letter_grade VARCHAR(2),
    percentage DECIMAL(5, 2),
    is_passed BOOLEAN,
    feedback TEXT,
    graded_by UUID REFERENCES profiles(id),
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
CREATE INDEX idx_grades_created_at ON grades(created_at);

-- 为成绩表添加更新时间戳触发器
CREATE TRIGGER update_grades_updated_at 
    BEFORE UPDATE ON grades 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();;