-- Migration: guild_chat_features_fixed
-- Created at: 1762018177

-- ========================================
-- 公会聊天功能数据库扩展（适配现有结构）
-- 创建日期: 2025-11-02
-- 描述: 为公会系统添加聊天和活动功能
-- 适配profiles表和现有guilds/guild_members结构
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
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
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
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
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
-- 3. 公会聊天室表 (guild_chat_rooms)
-- 公会内的聊天频道
-- ========================================
CREATE TABLE guild_chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guild_id UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    room_type VARCHAR(20) CHECK (room_type IN ('general', 'announcements', 'resources', 'projects', 'events')) DEFAULT 'general',
    is_private BOOLEAN DEFAULT false,
    member_count INTEGER DEFAULT 0,
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_guild_chat_rooms_guild_id ON guild_chat_rooms(guild_id);
CREATE INDEX idx_guild_chat_rooms_type ON guild_chat_rooms(room_type);
CREATE INDEX idx_guild_chat_rooms_is_private ON guild_chat_rooms(is_private);

-- ========================================
-- 4. 公会聊天室成员表 (guild_chat_room_members)
-- 聊天室成员关系
-- ========================================
CREATE TABLE guild_chat_room_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID NOT NULL REFERENCES guild_chat_rooms(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role VARCHAR(20) CHECK (role IN ('member', 'moderator', 'admin')) DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(room_id, user_id)
);

-- 创建索引
CREATE INDEX idx_guild_chat_room_members_room_id ON guild_chat_room_members(room_id);
CREATE INDEX idx_guild_chat_room_members_user_id ON guild_chat_room_members(user_id);

-- ========================================
-- 触发器：自动更新时间戳
-- ========================================

-- 创建更新时间戳的函数（如果不存在）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为消息表添加更新时间戳触发器
DROP TRIGGER IF EXISTS update_guild_messages_updated_at ON guild_messages;
CREATE TRIGGER update_guild_messages_updated_at 
    BEFORE UPDATE ON guild_messages 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 为聊天室表添加更新时间戳触发器
DROP TRIGGER IF EXISTS update_guild_chat_rooms_updated_at ON guild_chat_rooms;
CREATE TRIGGER update_guild_chat_rooms_updated_at 
    BEFORE UPDATE ON guild_chat_rooms 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 初始数据插入：为现有公会创建默认聊天室
-- ========================================

INSERT INTO guild_chat_rooms (guild_id, name, description, room_type, created_by)
SELECT 
    g.id,
    'general',
    '公会通用聊天频道',
    'general',
    g.created_by
FROM guilds g
WHERE NOT EXISTS (
    SELECT 1 FROM guild_chat_rooms 
    WHERE guild_chat_rooms.guild_id = g.id 
    AND guild_chat_rooms.room_type = 'general'
);;