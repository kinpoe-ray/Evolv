-- Migration: insert_data_marketing_questions
-- Created at: 1762007782

-- 插入数据分析和数字营销题目
INSERT INTO questions (skill_id, question_text, question_type, options, correct_answer, difficulty, skill_points, explanation, created_by, is_approved, time_limit) VALUES

-- 数据分析题目
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '数据清洗的主要目的是什么？', 'single_choice', '{"A": "增加数据量", "B": "提高数据质量", "C": "降低数据成本", "D": "加快处理速度"}', 'B', 2, 15, '数据清洗的目的是发现并纠正数据中的错误和不一致，提高数据质量。', '00000000-0000-0000-0000-000000000000', true, 60),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '数据异常值检测的方法包括？（多选）', 'multiple_choice', '{"A": "3σ原则", "B": "箱型图分析", "C": "聚类分析", "D": "业务规则判断", "E": "统计学检验"}', '["A", "B", "C", "D", "E"]', 4, 30, '异常值检测有多种方法，需要根据数据特点选择合适的方法。', '00000000-0000-0000-0000-000000000000', true, 90),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '请说明ETL在数据处理中的作用', 'fill_blank', NULL, '数据抽取|数据转换|数据加载', 3, 20, 'ETL包括Extract（抽取）、Transform（转换）、Load（加载）三个环节。', '00000000-0000-0000-0000-000000000000', true, 120),

-- 描述性统计和推断性统计
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '描述性统计和推断性统计的主要区别是什么？', 'single_choice', '{"A": "处理数据类型不同", "B": "描述已发生vs预测未来", "C": "使用工具不同", "D": "数据来源不同"}', 'B', 3, 20, '描述性统计总结已发生数据的特征，推断性统计用于从样本推断总体。', '00000000-0000-0000-0000-000000000000', true, 60),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '相关性分析中，皮尔逊相关系数的取值范围是？', 'single_choice', '{"A": "0到1", "B": "-1到1", "C": "负无穷到正无穷", "D": "0到正无穷"}', 'B', 3, 20, '皮尔逊相关系数取值范围是-1到1，-1为完全负相关，1为完全正相关。', '00000000-0000-0000-0000-000000000000', true, 60),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '请简述回归分析的基本原理', 'fill_blank', NULL, '变量关系|函数拟合|预测建模', 4, 25, '回归分析通过建立变量间的数学关系来拟合函数并进行预测。', '00000000-0000-0000-0000-000000000000', true, 120),

-- 数字营销题目
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'SEO优化中，关键词密度控制在多少比较合适？', 'single_choice', '{"A": "1-3%", "B": "3-5%", "C": "5-10%", "D": "10%以上"}', 'A', 2, 15, '关键词密度应控制在1-3%，过高可能被判定为关键词堆砌。', '00000000-0000-0000-0000-000000000000', true, 60),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '影响网站排名的主要因素包括？（多选）', 'multiple_choice', '{"A": "内容质量", "B": "页面加载速度", "C": "外链质量", "D": "用户体验", "E": "服务器稳定性"}', '["A", "B", "C", "D", "E"]', 3, 25, '网站排名受内容、技术、外链、用户体验等多重因素影响。', '00000000-0000-0000-0000-000000000000', true, 90),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '请简述什么是长尾关键词及其优势', 'fill_blank', NULL, '低竞争|高精准|转化率高', 3, 20, '长尾关键词竞争小、搜索意图明确、转化率相对较高。', '00000000-0000-0000-0000-000000000000', true, 120),

-- 广告投放
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'CTR在广告投放中代表什么指标？', 'single_choice', '{"A": "点击转化率", "B": "点击率", "C": "展示转化率", "D": "广告投资回报率"}', 'B', 2, 15, 'CTR(Click-Through Rate)是点击率，表示广告被点击的次数除以展示次数。', '00000000-0000-0000-0000-000000000000', true, 60),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '程序化广告的核心特征包括？（多选）', 'multiple_choice', '{"A": "自动化投放", "B": "精准定向", "C": "实时竞价", "D": "效果可衡量", "E": "跨媒体覆盖"}', '["A", "B", "C", "D", "E"]', 4, 30, '程序化广告具有自动化、精准性、实时性、可测量和跨媒体等特征。', '00000000-0000-0000-0000-000000000000', true, 90),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '请说明CPC和CPM两种计费方式的区别', 'fill_blank', NULL, '按点击付费|按展示付费', 3, 20, 'CPC按点击付费，CPM按千次展示付费，适用不同营销目标。', '00000000-0000-0000-0000-000000000000', true, 120),

-- 社交媒体营销
('ffffffff-ffff-ffff-ffff-ffffffffffff', '社交媒体营销中，UGC指的是什么？', 'single_choice', '{"A": "用户生成内容", "B": "品牌官方内容", "C": "付费推广内容", "D": "网红推荐内容"}', 'A', 2, 15, 'UGC(User Generated Content)指用户自发产生的内容。', '00000000-0000-0000-0000-000000000000', true, 60),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '有效的社交媒体内容策略包括？（多选）', 'multiple_choice', '{"A": "保持品牌调性", "B": "定期更新内容", "C": "互动式内容", "D": "数据驱动优化", "E": "跨平台一致性"}', '["A", "B", "C", "D", "E"]', 3, 25, '社交媒体内容需要系统性策略，包括调性、频率、互动和数据优化。', '00000000-0000-0000-0000-000000000000', true, 90),
('ffffffff-ffff-ffff-ffff-ffffffffffff', '请简述社交媒体监测的重要指标', 'fill_blank', NULL, '提及量|情感分析|传播范围', 3, 20, '社交媒体监测关注品牌提及量、情感倾向和传播影响范围。', '00000000-0000-0000-0000-000000000000', true, 120);;