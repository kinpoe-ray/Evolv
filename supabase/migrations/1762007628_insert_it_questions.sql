-- Migration: insert_it_questions
-- Created at: 1762007628

-- 插入IT技能题目
INSERT INTO questions (skill_id, question_text, question_type, options, correct_answer, difficulty, skill_points, explanation, created_by, is_approved, time_limit) VALUES

-- 前端开发题目
('frontend-dev', '以下哪个HTML标签用于创建无序列表？', 'single_choice', '{"A": "<ol>", "B": "<ul>", "C": "<li>", "D": "<dl>"}', 'B', 1, 10, '<ul>标签用于创建无序列表，<ol>用于有序列表，<li>是列表项，<dl>是定义列表。', '00000000-0000-0000-0000-000000000000', true, 60),
('frontend-dev', 'CSS中用于设置元素边距的属性是？', 'single_choice', '{"A": "padding", "B": "margin", "C": "border", "D": "spacing"}', 'B', 2, 15, 'margin用于设置外边距，padding用于设置内边距。', '00000000-0000-0000-0000-000000000000', true, 60),
('frontend-dev', 'JavaScript中，以下哪些是数组方法？（多选）', 'multiple_choice', '{"A": "push()", "B": "pop()", "C": "map()", "D": "length", "E": "forEach()"}', '["A", "B", "C", "E"]', 3, 20, 'push()、pop()、map()、forEach()都是数组方法，length是数组属性。', '00000000-0000-0000-0000-000000000000', true, 90),
('frontend-dev', '请填写React组件中用于处理状态更新的Hook名称：use_____', 'fill_blank', NULL, 'State', 2, 15, 'React中使用useState Hook来管理组件状态。', '00000000-0000-0000-0000-000000000000', true, 60);;