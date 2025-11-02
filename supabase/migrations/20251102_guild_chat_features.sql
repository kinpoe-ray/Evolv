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
    created_by UUID NOT NULL REFERENCES users(id),
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
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) CHECK (role IN ('member', 'moderator', 'admin')) DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(room_id, user_id)
);

-- 创建索引
CREATE INDEX idx_guild_chat_room_members_room_id ON guild_chat_room_members(room_id);
CREATE INDEX idx_guild_chat_room_members_user_id ON guild_chat_room_members(user_id);

-- ========================================
-- 5. 公会文件分享表 (guild_file_shares)
-- 公会内文件分享记录
-- ========================================
CREATE TABLE guild_file_shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guild_id UUID NOT NULL REFERENCES guilds(id) ON DELETE CASCADE,
    room_id UUID REFERENCES guild_chat_rooms(id) ON DELETE CASCADE,
    message_id UUID REFERENCES guild_messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(100) NOT NULL,
    file_size INTEGER NOT NULL,
    download_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_guild_file_shares_guild_id ON guild_file_shares(guild_id);
CREATE INDEX idx_guild_file_shares_message_id ON guild_file_shares(message_id);
CREATE INDEX idx_guild_file_shares_user_id ON guild_file_shares(user_id);

-- ========================================
-- 6. 公会消息反应表 (guild_message_reactions)
-- 消息点赞/反应
-- ========================================
CREATE TABLE guild_message_reactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID NOT NULL REFERENCES guild_messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reaction_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(message_id, user_id, reaction_type)
);

-- 创建索引
CREATE INDEX idx_guild_message_reactions_message_id ON guild_message_reactions(message_id);
CREATE INDEX idx_guild_message_reactions_user_id ON guild_message_reactions(user_id);

-- ========================================
-- 触发器：自动更新时间戳
-- ========================================

-- 为消息表添加更新时间戳触发器
CREATE TRIGGER update_guild_messages_updated_at 
    BEFORE UPDATE ON guild_messages 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 为聊天室表添加更新时间戳触发器
CREATE TRIGGER update_guild_chat_rooms_updated_at 
    BEFORE UPDATE ON guild_chat_rooms 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 行级安全策略 (RLS)
-- ========================================

-- 启用 RLS
ALTER TABLE guild_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_chat_room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_file_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE guild_message_reactions ENABLE ROW LEVEL SECURITY;

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
    );

-- 聊天室策略
CREATE POLICY "用户可以查看所属公会的公开聊天室" ON guild_chat_rooms
    FOR SELECT 
    USING (
        is_public = true OR
        EXISTS (
            SELECT 1 FROM guild_members 
            WHERE guild_members.guild_id = guild_chat_rooms.guild_id 
            AND guild_members.user_id = auth.uid() 
            AND guild_members.status = 'active'
        )
    );

-- ========================================
-- 初始数据插入
-- ========================================

-- 创建默认聊天室
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
);

-- ========================================
-- 数据库扩展创建完成
-- ========================================

-- 提示：运行完成后需要重新生成 TypeScript 类型定义
-- supabase gen types typescript --project-id your-project-id > types/database.types.ts
