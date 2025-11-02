import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { supabase, type Skill } from '../lib/supabase';
import { useErrorHandler } from '../hooks/useErrorHandler';
import { useDebounce, useCache } from '../hooks/usePerformance';
import { validateForm, commonValidation } from '../utils/validation';
import { Dumbbell, Award, Play, CheckCircle, AlertCircle, RefreshCw } from 'lucide-react';

export default function SkillGym() {
  const { profile } = useAuth();
  const { handleError, handleSuccess } = useErrorHandler();
  const [skills, setSkills] = useState<Skill[]>([]);
  const [selectedSkill, setSelectedSkill] = useState<Skill | null>(null);
  const [questions, setQuestions] = useState<any[]>([]);
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [userAnswers, setUserAnswers] = useState<{ [key: number]: string }>({});
  const [isAssessing, setIsAssessing] = useState(false);
  const [assessmentResult, setAssessmentResult] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // 使用缓存和防抖优化性能
  const debouncedSkillsQuery = useDebounce('', 300);
  
  const { data: cachedSkills, refetch: refetchSkills } = useCache(
    'skills',
    async () => {
      const { data, error } = await supabase
        .from('skills')
        .select('*')
        .order('category');
      
      if (error) throw error;
      return data || [];
    },
    [debouncedSkillsQuery]
  );

  useEffect(() => {
    if (cachedSkills) {
      setSkills(cachedSkills);
    }
    setLoading(false);
  }, [cachedSkills]);

  const handleRefresh = async () => {
    setRefreshing(true);
    try {
      await refetchSkills();
      handleSuccess('技能列表已刷新', '刷新成功');
    } catch (error) {
      handleError(error, '刷新技能列表');
    } finally {
      setRefreshing(false);
    }
  };

  const startAssessment = async (skill: Skill) => {
    // 表单验证
    const validation = validateForm(
      { skill: skill.id },
      { skill: { required: true, message: '请选择技能' } }
    );
    
    if (!validation.isValid) {
      handleError(validation.errors.skill?.[0] || '请选择技能');
      return;
    }

    setSelectedSkill(skill);
    setIsAssessing(true);
    setCurrentQuestion(0);
    setUserAnswers({});
    setAssessmentResult(null);

    try {
      const { data, error } = await supabase
        .from('questions')
        .select('*')
        .eq('skill_id', skill.id)
        .eq('is_approved', true)
        .limit(10);

      if (error) throw error;
      
      if (!data || data.length === 0) {
        handleError('该技能暂无测评题目，请选择其他技能');
        setIsAssessing(false);
        return;
      }

      setQuestions(data);
      handleSuccess('开始技能测评', '测评已准备就绪');
    } catch (error) {
      handleError(error, '加载测评题目');
      setIsAssessing(false);
    }
  };

  const handleAnswer = (answer: string) => {
    // 验证答案
    if (!answer || answer.trim() === '') {
      handleError('请选择一个答案');
      return;
    }

    setUserAnswers({ ...userAnswers, [currentQuestion]: answer });
    
    if (currentQuestion < questions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
    } else {
      completeAssessment();
    }
  };

  const completeAssessment = async () => {
    if (!profile || !selectedSkill) {
      handleError('用户信息或技能信息缺失');
      return;
    }

    try {
      const correctAnswers = questions.filter((q, index) => 
        userAnswers[index] === q.correct_answer
      ).length;

      const score = Math.round((correctAnswers / questions.length) * 100);

      // 插入测评记录
      const { error: assessmentError } = await supabase.from('skill_assessments').insert({
        user_id: profile.id,
        skill_id: selectedSkill.id,
        score,
        total_questions: questions.length,
        correct_answers: correctAnswers,
        time_spent: 300,
      });

      if (assessmentError) throw assessmentError;

      // 如果分数达标，更新用户技能
      if (score >= 80) {
        const { error: skillError } = await supabase.from('user_skills').upsert({
          user_id: profile.id,
          skill_id: selectedSkill.id,
          score,
          level: Math.floor(score / 20),
          verified: true,
        });

        if (skillError) throw skillError;
      }

      const result = {
        score,
        total: questions.length,
        correct: correctAnswers,
        passed: score >= 60,
      };

      setAssessmentResult(result);
      
      if (result.passed) {
        handleSuccess(
          `恭喜通过${selectedSkill.name}技能测评！获得了${result.score}分。`,
          '测评完成'
        );
      } else {
        handleError(
          `${selectedSkill.name}技能测评未通过，获得了${result.score}分。`,
          '继续努力'
        );
      }
    } catch (error) {
      handleError(error, '完成测评');
      setIsAssessing(false);
      setSelectedSkill(null);
    }
  };

  const skillsByCategory = skills.reduce((acc, skill) => {
    if (!acc[skill.category]) {
      acc[skill.category] = [];
    }
    acc[skill.category].push(skill);
    return acc;
  }, {} as { [key: string]: Skill[] });

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">正在加载技能数据...</p>
        </div>
      </div>
    );
  }

  if (isAssessing && questions.length > 0) {
    if (assessmentResult) {
      return (
        <div className="max-w-2xl mx-auto">
          <div className="bg-white rounded-lg shadow-lg p-8 text-center">
            <div className={`w-24 h-24 mx-auto mb-6 rounded-full flex items-center justify-center ${
              assessmentResult.passed ? 'bg-green-100' : 'bg-red-100'
            }`}>
              {assessmentResult.passed ? (
                <CheckCircle className="h-12 w-12 text-green-600" />
              ) : (
                <Award className="h-12 w-12 text-red-600" />
              )}
            </div>

            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              {assessmentResult.passed ? '恭喜通过测评' : '继续加油'}
            </h2>

            <div className="text-4xl font-bold text-blue-600 mb-4">
              {assessmentResult.score}分
            </div>

            <p className="text-gray-600 mb-8">
              答对 {assessmentResult.correct} / {assessmentResult.total} 题
            </p>

            {assessmentResult.passed && (
              <div className="bg-green-50 rounded-lg p-4 mb-6">
                <p className="text-green-700 font-medium">
                  你已获得 {selectedSkill?.name} 技能验证徽章
                </p>
              </div>
            )}

            <button
              onClick={() => {
                setIsAssessing(false);
                setSelectedSkill(null);
              }}
              className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700"
            >
              返回技能列表
            </button>
          </div>
        </div>
      );
    }

    const question = questions[currentQuestion];
    const options = question.options as { [key: string]: string };

    return (
      <div className="max-w-2xl mx-auto">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <div className="mb-6">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-600">
                题目 {currentQuestion + 1} / {questions.length}
              </span>
              <span className="text-sm text-gray-600">
                难度：{'★'.repeat(question.difficulty)}
              </span>
            </div>
            <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
              <div
                className="h-full bg-blue-600 transition-all"
                style={{ width: `${((currentQuestion + 1) / questions.length) * 100}%` }}
              />
            </div>
          </div>

          <h3 className="text-xl font-semibold text-gray-900 mb-6">
            {question.question_text}
          </h3>

          <div className="space-y-3">
            {Object.entries(options).map(([key, value]) => (
              <button
                key={key}
                onClick={() => handleAnswer(key)}
                className="w-full text-left p-4 border-2 border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
              >
                <span className="font-medium text-gray-700">{key}.</span>{' '}
                <span className="text-gray-900">{value}</span>
              </button>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Dumbbell className="h-8 w-8 text-blue-600" />
            <div>
              <h1 className="text-2xl font-bold text-gray-900">技能健身房</h1>
              <p className="text-sm text-gray-600">通过测评验证你的技能，获得官方认证徽章</p>
            </div>
          </div>
          <button
            onClick={handleRefresh}
            disabled={refreshing}
            className="flex items-center gap-2 px-4 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`h-4 w-4 ${refreshing ? 'animate-spin' : ''}`} />
            刷新
          </button>
        </div>
        
        {/* 模式选择 */}
        <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="border-2 border-blue-200 rounded-lg p-4 hover:border-blue-400 transition-colors cursor-pointer"
               onClick={() => {/* 默认模式 */}}>
            <div className="flex items-center gap-3 mb-2">
              <Play className="h-6 w-6 text-blue-600" />
              <h3 className="font-semibold text-gray-900">快速测评模式</h3>
            </div>
            <p className="text-sm text-gray-600">经典的单轮测评模式，适合快速了解技能水平</p>
          </div>
          
          <Link to="/challenge" className="block">
            <div className="border-2 border-purple-200 rounded-lg p-4 hover:border-purple-400 transition-colors">
              <div className="flex items-center gap-3 mb-2">
                <Award className="h-6 w-6 text-purple-600" />
                <h3 className="font-semibold text-gray-900">闯关挑战模式</h3>
              </div>
              <p className="text-sm text-gray-600">三关递进挑战，更有挑战性和趣味性</p>
            </div>
          </Link>
        </div>
      </div>

      {Object.entries(skillsByCategory).map(([category, categorySkills]) => (
        <div key={category} className="bg-white rounded-lg shadow-sm p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">{category}</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {categorySkills.map((skill) => (
              <div
                key={skill.id}
                className="border border-gray-200 rounded-lg p-4 hover:border-blue-500 transition-colors"
              >
                <h3 className="font-semibold text-gray-900 mb-2">{skill.name}</h3>
                <p className="text-sm text-gray-600 mb-4">{skill.description}</p>
                <button
                  onClick={() => startAssessment(skill)}
                  className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 text-sm"
                >
                  <Play className="h-4 w-4" />
                  开始测评
                </button>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
