import { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { Brain, Target, Map, Sparkles, TrendingUp } from 'lucide-react';

export default function AICareerAdvisor() {
  const { profile } = useAuth();
  const [activeTab, setActiveTab] = useState<'skill-map' | 'diagnosis' | 'learning-path'>('skill-map');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [formData, setFormData] = useState({
    targetRole: '',
    currentLevel: 'beginner',
    timeframe: '3-6个月',
  });

  const handleGenerateSkillMap = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke('ai-career-advisor', {
        body: {
          action: 'generate_skill_map',
          userData: {
            courses: [],
            experiences: [],
            targetRole: formData.targetRole,
          },
        },
      });

      if (error) throw error;
      setResult(data.data);
    } catch (error) {
      console.error('Error generating skill map:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCareerDiagnosis = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke('ai-career-advisor', {
        body: {
          action: 'career_diagnosis',
          userData: {
            currentSkills: [],
            targetPosition: formData.targetRole,
            background: profile,
          },
        },
      });

      if (error) throw error;
      setResult(data.data);
    } catch (error) {
      console.error('Error in career diagnosis:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleGenerateLearningPath = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase.functions.invoke('ai-career-advisor', {
        body: {
          action: 'learning_path',
          userData: {
            currentLevel: formData.currentLevel,
            targetRole: formData.targetRole,
            timeframe: formData.timeframe,
          },
        },
      });

      if (error) throw error;
      setResult(data.data);
    } catch (error) {
      console.error('Error generating learning path:', error);
    } finally {
      setLoading(false);
    }
  };

  const tabs = [
    { id: 'skill-map', name: '技能图谱', icon: Map },
    { id: 'diagnosis', name: '职业诊断', icon: Target },
    { id: 'learning-path', name: '学习路径', icon: TrendingUp },
  ];

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center gap-3 mb-4">
          <Brain className="h-8 w-8 text-blue-600" />
          <div>
            <h1 className="text-2xl font-bold text-gray-900">AI职业导师</h1>
            <p className="text-sm text-gray-600">智能分析你的技能，规划职业发展路径</p>
          </div>
        </div>

        <div className="border-b border-gray-200">
          <div className="flex space-x-4">
            {tabs.map((tab) => {
              const Icon = tab.icon;
              return (
                <button
                  key={tab.id}
                  onClick={() => {
                    setActiveTab(tab.id as any);
                    setResult(null);
                  }}
                  className={`flex items-center gap-2 px-4 py-2 border-b-2 font-medium text-sm ${
                    activeTab === tab.id
                      ? 'border-blue-600 text-blue-600'
                      : 'border-transparent text-gray-600 hover:text-gray-900'
                  }`}
                >
                  <Icon className="h-4 w-4" />
                  {tab.name}
                </button>
              );
            })}
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm p-6">
        {activeTab === 'skill-map' && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-4">生成技能图谱</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    目标岗位
                  </label>
                  <input
                    type="text"
                    value={formData.targetRole}
                    onChange={(e) => setFormData({ ...formData, targetRole: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="例如：数据分析师、产品经理"
                  />
                </div>

                <button
                  onClick={handleGenerateSkillMap}
                  disabled={loading || !formData.targetRole}
                  className="flex items-center gap-2 bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Sparkles className="h-5 w-5" />
                  {loading ? '生成中...' : '生成技能图谱'}
                </button>
              </div>

              {result && result.skillMap && (
                <div className="mt-8 space-y-6">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">技能图谱分析</h3>
                    <div className="bg-blue-50 rounded-lg p-4 mb-4">
                      <p className="text-sm text-gray-600">综合评分</p>
                      <p className="text-3xl font-bold text-blue-600">{result.overallScore}分</p>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {result.skillMap.map((category: any, index: number) => (
                        <div key={index} className="border border-gray-200 rounded-lg p-4">
                          <div className="flex items-center justify-between mb-3">
                            <h4 className="font-semibold text-gray-900">{category.category}</h4>
                            <span className="text-sm font-medium text-blue-600">{category.score}分</span>
                          </div>
                          <div className="space-y-2">
                            {category.skills.map((skill: any, idx: number) => (
                              <div key={idx} className="flex items-center justify-between text-sm">
                                <span className="text-gray-700">{skill.name}</span>
                                <div className="flex items-center gap-2">
                                  <div className="flex gap-1">
                                    {Array.from({ length: 5 }).map((_, i) => (
                                      <div
                                        key={i}
                                        className={`w-2 h-2 rounded-full ${
                                          i < skill.level ? 'bg-blue-600' : 'bg-gray-300'
                                        }`}
                                      />
                                    ))}
                                  </div>
                                  {skill.verified && (
                                    <span className="text-xs text-green-600">已验证</span>
                                  )}
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {result.recommendations && (
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 mb-4">发展建议</h3>
                      <div className="space-y-2">
                        {result.recommendations.map((rec: any, index: number) => (
                          <div key={index} className="flex items-start gap-3 bg-yellow-50 rounded-lg p-3">
                            <Sparkles className="h-5 w-5 text-yellow-600 mt-0.5" />
                            <p className="text-sm text-gray-700">{rec.message}</p>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'diagnosis' && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-4">职业目标诊断</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    目标职位
                  </label>
                  <input
                    type="text"
                    value={formData.targetRole}
                    onChange={(e) => setFormData({ ...formData, targetRole: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="例如：前端工程师、产品经理"
                  />
                </div>

                <button
                  onClick={handleCareerDiagnosis}
                  disabled={loading || !formData.targetRole}
                  className="flex items-center gap-2 bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Target className="h-5 w-5" />
                  {loading ? '诊断中...' : '开始诊断'}
                </button>
              </div>

              {result && (
                <div className="mt-8 space-y-6">
                  <div className="bg-blue-50 rounded-lg p-6">
                    <h3 className="text-lg font-semibold text-gray-900 mb-2">匹配度分析</h3>
                    <div className="flex items-center gap-4">
                      <div className="text-4xl font-bold text-blue-600">{result.matchScore}%</div>
                      <div className="text-sm text-gray-600">
                        <p>预计达成时间：{result.timeEstimate}</p>
                        <p className="mt-1">{result.recommendation}</p>
                      </div>
                    </div>
                  </div>

                  {result.requiredSkills && (
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900 mb-4">技能差距分析</h3>
                      <div className="space-y-3">
                        {result.requiredSkills.map((skill: any, index: number) => (
                          <div key={index} className="border border-gray-200 rounded-lg p-4">
                            <div className="flex items-center justify-between mb-2">
                              <span className="font-medium text-gray-900">{skill.name}</span>
                              <span className={`text-sm ${skill.gap === 0 ? 'text-green-600' : 'text-orange-600'}`}>
                                {skill.gap === 0 ? '已达标' : `差距 ${skill.gap}分`}
                              </span>
                            </div>
                            <div className="flex items-center gap-2 text-sm text-gray-600">
                              <span>当前：{skill.current}分</span>
                              <span>→</span>
                              <span>目标：{skill.required}分</span>
                            </div>
                            <div className="mt-2 h-2 bg-gray-200 rounded-full overflow-hidden">
                              <div
                                className="h-full bg-blue-600"
                                style={{ width: `${(skill.current / skill.required) * 100}%` }}
                              />
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'learning-path' && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-semibold text-gray-900 mb-4">生成学习路径</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    目标职位
                  </label>
                  <input
                    type="text"
                    value={formData.targetRole}
                    onChange={(e) => setFormData({ ...formData, targetRole: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder="例如：机器学习工程师"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    当前水平
                  </label>
                  <select
                    value={formData.currentLevel}
                    onChange={(e) => setFormData({ ...formData, currentLevel: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                    <option value="beginner">初学者</option>
                    <option value="intermediate">中级</option>
                    <option value="advanced">高级</option>
                  </select>
                </div>

                <button
                  onClick={handleGenerateLearningPath}
                  disabled={loading || !formData.targetRole}
                  className="flex items-center gap-2 bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <TrendingUp className="h-5 w-5" />
                  {loading ? '生成中...' : '生成学习路径'}
                </button>
              </div>

              {result && result.phases && (
                <div className="mt-8 space-y-6">
                  <div className="bg-blue-50 rounded-lg p-4">
                    <p className="text-sm text-gray-600">预计完成时间</p>
                    <p className="text-2xl font-bold text-blue-600">{result.estimatedCompletion}</p>
                  </div>

                  <div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-4">学习阶段</h3>
                    <div className="space-y-6">
                      {result.phases.map((phase: any, index: number) => (
                        <div key={index} className="border border-gray-200 rounded-lg p-6">
                          <div className="flex items-center gap-3 mb-4">
                            <div className="w-10 h-10 bg-blue-600 text-white rounded-full flex items-center justify-center font-bold">
                              {phase.phase}
                            </div>
                            <div>
                              <h4 className="font-semibold text-gray-900">{phase.title}</h4>
                              <p className="text-sm text-gray-600">{phase.duration}</p>
                            </div>
                          </div>
                          <div className="space-y-2">
                            {phase.tasks.map((task: any, taskIndex: number) => (
                              <div key={taskIndex} className="flex items-center gap-3 p-3 bg-gray-50 rounded-md">
                                <input type="checkbox" className="h-4 w-4 text-blue-600 rounded" />
                                <div className="flex-1">
                                  <p className="text-sm text-gray-900">{task.name}</p>
                                  <div className="flex items-center gap-2 mt-1">
                                    <span className="text-xs text-gray-600">{task.type}</span>
                                    <span className={`text-xs px-2 py-0.5 rounded ${
                                      task.priority === 'high' ? 'bg-red-100 text-red-700' :
                                      task.priority === 'medium' ? 'bg-yellow-100 text-yellow-700' :
                                      'bg-gray-100 text-gray-700'
                                    }`}>
                                      {task.priority === 'high' ? '高优先级' :
                                       task.priority === 'medium' ? '中优先级' : '低优先级'}
                                    </span>
                                  </div>
                                </div>
                              </div>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
