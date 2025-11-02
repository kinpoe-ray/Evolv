-- Migration: guild_chat_features
-- Created at: 1762017793

-- ========================================
-- 公会聊天功能数据库扩展
-- 创建日期: 2025-11-02
-- 描述: 为公会系统添加聊天和活动功能
-- ========================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- 1. 公会消息表 (guild_messages)
-- 公会内聊天消息
-- ========================================
CREATE TABLE guild_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guild_id UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type VARCHAR(20) CHECK (message_type IN ('text', 'image', 'file', 'system')) DEFAULT 'text',
    reply_to UUID REFERENCES guild_messages(id),
    is_edited BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_guild_messages_guild_id ON guild_messages(guild_id);
CREATE INDEX idx_guild_messages_user_id ON guild_messages(user_id);
CREATE INDEX idx_guild_messages_created_at ON guild_messages(created_at);
CREATE INDEX idx_guild_messages_reply_to ON guild_messages(reply_to);

-- ========================================
-- 2. 公会活动表 (guild_activities)
-- 公会成员活动记录
-- ========================================
CREATE TABLE guild_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guild_id UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(30) CHECK (activity_type IN ('joined', 'left', 'message', 'achievement', 'level_up', 'project', 'event')) NOT NULL,
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_guild_activities_guild_id ON guild_activities(guild_id);
CREATE INDEX idx_guild_activities_user_id ON guild_activities(user_id);
CREATE INDEX idx_guild_activities_created_at ON guild_activities(created_at);
CREATE INDEX idx_guild_activities_type ON guild_activities(activity_type);

-- ========================================
-- 触发器：自动更新时间戳
-- ========================================

-- 为消息表添加更新时间戳触发器
CREATE TRIGGER update_guild_messages_updated_at 
    BEFORE UPDATE ON guild_messages 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 行级安全策略 (RLS)
-- ========================================

-- 启用 RLS
ALTER TABLE guild_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_activities ENABLE ROW LEVEL SECURITY;

-- 公会消息策略
CREATE POLICY "用户可以查看所属公会消息" ON guild_messages
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM guild_members 
            WHERE guild_members.guild_id = guild_messages.guild_id 
            AND guild_members.user_id = auth.uid() 
            AND guild_members.status = 'active'
        )
    );

CREATE POLICY "用户可以向所属公会发送消息" ON guild_messages
    FOR INSERT 
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM guild_members 
            WHERE guild_members.guild_id = guild_messages.guild_id 
            AND guild_members.user_id = auth.uid() 
            AND guild_members.status = 'active'
        )
    );

-- 公会活动策略
CREATE POLICY "用户可以查看所属公会活动" ON guild_activities
    FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM guild_members 
            WHERE guild_members.guild_id = guild_activities.guild_id 
            AND guild_members.user_id = auth.uid() 
            AND guild_members.status = 'active'
        )
    );;