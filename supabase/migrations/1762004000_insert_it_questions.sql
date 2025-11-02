-- 插入IT技能题目
INSERT INTO questions (skill_id, question_text, question_type, options, correct_answer, difficulty, skill_points, explanation, created_by, is_approved, time_limit) VALUES

-- 前端开发题目
('frontend-dev', '以下哪个HTML标签用于创建无序列表？', 'single_choice', '{"A": "<ol>", "B": "<ul>", "C": "<li>", "D": "<dl>"}', 'B', 1, 10, '<ul>标签用于创建无序列表，<ol>用于有序列表，<li>是列表项，<dl>是定义列表。', '00000000-0000-0000-0000-000000000000', true, 60),
('frontend-dev', 'CSS中用于设置元素边距的属性是？', 'single_choice', '{"A": "padding", "B": "margin", "C": "border", "D": "spacing"}', 'B', 2, 15, 'margin用于设置外边距，padding用于设置内边距。', '00000000-0000-0000-0000-000000000000', true, 60),
('frontend-dev', 'JavaScript中，以下哪些是数组方法？（多选）', 'multiple_choice', '{"A": "push()", "B": "pop()", "C": "map()", "D": "length", "E": "forEach()"}', '["A", "B", "C", "E"]', 3, 20, 'push()、pop()、map()、forEach()都是数组方法，length是数组属性。', '00000000-0000-0000-0000-000000000000', true, 90),
('frontend-dev', '请填写React组件中用于处理状态更新的Hook名称：use_____', 'fill_blank', NULL, 'State', 2, 15, 'React中使用useState Hook来管理组件状态。', '00000000-0000-0000-0000-000000000000', true, 60),

-- 后端开发题目
('backend-dev', 'RESTful API中，GET请求通常用于什么操作？', 'single_choice', '{"A": "创建资源", "B": "获取资源", "C": "更新资源", "D": "删除资源"}', 'B', 2, 15, 'GET请求用于获取资源，POST用于创建，PUT用于更新，DELETE用于删除。', '00000000-0000-0000-0000-000000000000', true, 60),
('backend-dev', '以下哪个不是数据库事务的ACID特性？', 'single_choice', '{"A": "Atomicity（原子性）", "B": "Consistency（一致性）", "C": "Isolation（隔离性）", "D": "Availability（可用性）"}', 'D', 4, 25, 'ACID包括Atomicity、Consistency、Isolation、Durability，没有Availability。', '00000000-0000-0000-0000-000000000000', true, 60),
('backend-dev', '请简述什么是API Gateway及其主要作用', 'fill_blank', NULL, '统一入口|请求路由|流量控制', 4, 30, 'API Gateway是系统统一入口，提供请求路由、认证、限流等功能。', '00000000-0000-0000-0000-000000000000', true, 120),

-- 数据库管理题目
('database-admin', 'SQL语句中用于查询数据的关键词是？', 'single_choice', '{"A": "INSERT", "B": "SELECT", "C": "UPDATE", "D": "DELETE"}', 'B', 1, 10, 'SELECT语句用于查询数据，INSERT用于插入，UPDATE用于更新，DELETE用于删除。', '00000000-0000-0000-0000-000000000000', true, 60),
('database-admin', '数据库索引的主要作用是什么？（多选）', 'multiple_choice', '{"A": "提高查询速度", "B": "保证数据唯一性", "C": "减少存储空间", "D": "加快排序操作", "E": "提高写入速度"}', '["A", "B", "D"]', 3, 20, '索引可以提高查询速度、保证唯一性、加快排序，但会增加存储空间且可能降低写入速度。', '00000000-0000-0000-0000-000000000000', true, 90),
('database-admin', '请写出MySQL中创建数据库的SQL语句：_____ DATABASE mydb;', 'fill_blank', NULL, 'CREATE', 2, 15, '使用CREATE DATABASE语句创建新数据库。', '00000000-0000-0000-0000-000000000000', true, 60),

-- DevOps题目
('devops', 'Docker容器与虚拟机的主要区别是什么？', 'single_choice', '{"A": "Docker更轻量，共享主机内核", "B": "Docker更重，需要更多资源", "C": "Docker只能运行Linux应用", "D": "Docker不需要操作系统"}', 'A', 3, 20, 'Docker容器更轻量，共享主机内核，而虚拟机需要完整的Guest OS。', '00000000-0000-0000-0000-000000000000', true, 60),
('devops', 'CI/CD流程中的主要环节包括？（多选）', 'multiple_choice', '{"A": "代码提交", "B": "自动测试", "C": "构建打包", "D": "自动部署", "E": "监控告警"}', '["A", "B", "C", "D", "E"]', 3, 25, 'CI/CD包括代码提交、自动测试、构建、部署和监控等完整流程。', '00000000-0000-0000-0000-000000000000', true, 90),
('devops', 'Git中用于创建新分支并切换到该分支的命令是：git _____ branch-name', 'fill_blank', NULL, 'checkout -b', 3, 20, 'git checkout -b 创建并切换到新分支，也可用git switch -c（新版本）。', '00000000-0000-0000-0000-000000000000', true, 60),

-- 网络安全题目
('cybersecurity', '以下哪个是常见的Web应用安全漏洞？', 'single_choice', '{"A": "SQL注入", "B": "XSS攻击", "C": "CSRF攻击", "D": "以上都是"}', 'D', 3, 20, 'SQL注入、XSS、CSRF都是常见的Web应用安全漏洞。', '00000000-0000-0000-0000-000000000000', true, 60),
('cybersecurity', 'HTTPS协议比HTTP协议更安全的主要原因是什么？（多选）', 'multiple_choice', '{"A": "使用SSL/TLS加密", "B": "验证服务器身份", "C": "防止数据篡改", "D": "提高传输速度", "E": "支持更多端口"}', '["A", "B", "C"]', 4, 25, 'HTTPS通过SSL/TLS提供加密、身份验证和数据完整性保护。', '00000000-0000-0000-0000-000000000000', true, 90),
('cybersecurity', '请解释什么是零信任安全模型', 'fill_blank', NULL, '永不信任|始终验证|最小权限', 5, 35, '零信任模型的核心原则是"永不信任，始终验证"，实施最小权限原则。', '00000000-0000-0000-0000-000000000000', true, 120);