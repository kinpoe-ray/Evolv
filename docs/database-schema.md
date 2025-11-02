# Evolv平台数据库架构设计

## 核心表结构

### 1. 用户系统

#### profiles (用户档案)
- id: UUID (primary key, references auth.users)
- user_type: TEXT (student/teacher/alumni)
- full_name: TEXT
- avatar_url: TEXT
- school: TEXT
- major: TEXT
- graduation_year: INTEGER
- bio: TEXT
- is_public: BOOLEAN (档案是否公开)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP

### 2. 技能系统

#### skills (技能定义)
- id: UUID (primary key)
- name: TEXT
- category: TEXT (IT/运营/产品/设计等)
- description: TEXT
- icon: TEXT
- created_at: TIMESTAMP

#### user_skills (用户技能图谱)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- skill_id: UUID (references skills.id)
- level: INTEGER (1-5级)
- score: INTEGER (技能分数)
- verified: BOOLEAN (是否通过测评验证)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP

#### skill_assessments (技能测评记录)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- skill_id: UUID (references skills.id)
- score: INTEGER
- total_questions: INTEGER
- correct_answers: INTEGER
- time_spent: INTEGER (秒)
- completed_at: TIMESTAMP

#### badges (徽章定义)
- id: UUID (primary key)
- name: TEXT
- description: TEXT
- icon_url: TEXT
- skill_id: UUID (references skills.id)
- rarity: TEXT (common/rare/epic/legendary)
- requirement_score: INTEGER
- created_at: TIMESTAMP

#### user_badges (用户徽章)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- badge_id: UUID (references badges.id)
- earned_at: TIMESTAMP

### 3. 学习系统

#### courses (课程)
- id: UUID (primary key)
- name: TEXT
- code: TEXT
- credits: DECIMAL
- category: TEXT
- description: TEXT
- created_at: TIMESTAMP

#### user_courses (用户课程成绩)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- course_id: UUID (references courses.id)
- grade: TEXT (A/B/C/D/F)
- score: DECIMAL
- semester: TEXT
- year: INTEGER
- created_at: TIMESTAMP

#### questions (题库)
- id: UUID (primary key)
- skill_id: UUID (references skills.id)
- question_text: TEXT
- question_type: TEXT (single_choice/multiple_choice/code)
- options: JSONB
- correct_answer: TEXT
- difficulty: INTEGER (1-5)
- created_by: UUID (references profiles.id)
- is_approved: BOOLEAN
- created_at: TIMESTAMP

#### user_answers (答题记录)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- question_id: UUID (references questions.id)
- answer: TEXT
- is_correct: BOOLEAN
- answered_at: TIMESTAMP

### 4. 社交系统

#### guilds (技能公会)
- id: UUID (primary key)
- name: TEXT
- description: TEXT
- skill_category: TEXT
- icon_url: TEXT
- member_count: INTEGER
- created_by: UUID (references profiles.id)
- created_at: TIMESTAMP

#### guild_members (公会成员)
- id: UUID (primary key)
- guild_id: UUID (references guilds.id)
- user_id: UUID (references profiles.id)
- role: TEXT (member/admin/owner)
- joined_at: TIMESTAMP

#### social_interactions (社交互动)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- target_id: UUID (references profiles.id)
- interaction_type: TEXT (follow/like/comment)
- content: TEXT (评论内容)
- created_at: TIMESTAMP

### 5. 职业发展系统

#### career_goals (职业目标)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- goal_title: TEXT
- target_position: TEXT
- target_company: TEXT
- deadline: DATE
- status: TEXT (active/completed/abandoned)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP

#### learning_paths (学习路径)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- career_goal_id: UUID (references career_goals.id)
- path_data: JSONB (AI生成的学习路径)
- progress: INTEGER (0-100)
- created_at: TIMESTAMP
- updated_at: TIMESTAMP

### 6. 校友系统

#### alumni_posts (校友分享)
- id: UUID (primary key)
- user_id: UUID (references profiles.id)
- title: TEXT
- content: TEXT
- industry: TEXT
- company: TEXT
- position: TEXT
- tags: TEXT[]
- likes_count: INTEGER
- views_count: INTEGER
- created_at: TIMESTAMP
- updated_at: TIMESTAMP

#### alumni_comments (校友评论)
- id: UUID (primary key)
- post_id: UUID (references alumni_posts.id)
- user_id: UUID (references profiles.id)
- content: TEXT
- created_at: TIMESTAMP
