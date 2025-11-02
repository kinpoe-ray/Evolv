import { allQuestions } from '../src/data/questionBank';
import { createClient } from '@supabase/supabase-js';

// 初始化Supabase客户端（需要提供正确的URL和密钥）
const supabaseUrl = process.env.SUPABASE_URL || 'YOUR_SUPABASE_URL';
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'YOUR_SERVICE_ROLE_KEY';
const supabase = createClient(supabaseUrl, supabaseKey);

async function initializeQuestionBank() {
  try {
    console.log('开始初始化题目库...');

    // 清空现有题目（如果需要）
    // await supabase.from('questions').delete().neq('id', '00000000-0000-0000-0000-000000000000');

    // 批量插入题目
    const questionsToInsert = allQuestions.map(question => ({
      skill_id: question.skill_id,
      question_text: question.question_text,
      question_type: question.question_type,
      options: question.options || null,
      correct_answer: Array.isArray(question.correct_answer) 
        ? JSON.stringify(question.correct_answer) 
        : question.correct_answer,
      difficulty: question.difficulty,
      skill_points: question.skill_points,
      explanation: question.explanation,
      created_by: '00000000-0000-0000-0000-000000000000', // 系统用户ID
      is_approved: true,
      time_limit: 60
    }));

    // 分批插入（避免请求过大）
    const batchSize = 50;
    let insertedCount = 0;

    for (let i = 0; i < questionsToInsert.length; i += batchSize) {
      const batch = questionsToInsert.slice(i, i + batchSize);
      
      const { data, error } = await supabase
        .from('questions')
        .insert(batch)
        .select();

      if (error) {
        console.error('插入批次失败:', error);
        break;
      }

      insertedCount += batch.length;
      console.log(`已插入 ${insertedCount}/${questionsToInsert.length} 道题目`);
    }

    console.log(`题目库初始化完成！共插入 ${insertedCount} 道题目`);

    // 验证插入结果
    const { data: count, error: countError } = await supabase
      .from('questions')
      .select('*', { count: 'exact', head: true });

    if (!countError) {
      console.log(`数据库中现有题目总数: ${count}`);
    }

  } catch (error) {
    console.error('初始化题目库失败:', error);
  }
}

// 如果直接运行此文件
if (require.main === module) {
  initializeQuestionBank();
}

export default initializeQuestionBank;