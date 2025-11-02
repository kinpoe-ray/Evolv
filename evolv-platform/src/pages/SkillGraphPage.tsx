import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Skill, SkillGraph } from '../types';
import { useSkills, useUserSkills, useSkillGraph, useSkillStats } from '../hooks/useSkills';
import { skillAssessmentService } from '../services/skillAssessment';
import SkillGraphComponent from '../components/SkillGraph';
import { 
  Brain, 
  Plus, 
  TrendingUp, 
  Award, 
  Target, 
  BarChart3,
  Settings,
  Sparkles,
  BookOpen,
  Clock,
  CheckCircle2,
  AlertCircle,
} from 'lucide-react';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
// @ts-ignore - 暂时忽略recharts类型问题

const SkillGraphPage: React.FC = () => {
  const { profile } = useAuth();
  const { skills, loading: skillsLoading } = useSkills();
  const { userSkills, assessSkillWithAI } = useUserSkills();
  const { currentGraph, generateSkillGraph } = useSkillGraph();
  const { stats, loading: statsLoading } = useSkillStats();

  const [selectedSkill, setSelectedSkill] = useState<Skill | null>(null);
  const [assessmentResult, setAssessmentResult] = useState<any>(null);
  const [isGeneratingGraph, setIsGeneratingGraph] = useState(false);
  const [activeTab, setActiveTab] = useState<'graph' | 'stats' | 'assessment'>('graph');
  const [aiRecommendations, setAiRecommendations] = useState<string[]>([]);

  // 生成技能图谱
  const handleGenerateGraph = async () => {
    setIsGeneratingGraph(true);
    try {
      await generateSkillGraph(
        `${profile?.full_name || '用户'}的技能图谱`,
        '基于AI分析的个性化技能图谱'
      );
    } catch (error) {
      console.error('生成技能图谱失败:', error);
    } finally {
      setIsGeneratingGraph(false);
    }
  };

  // 处理技能节点点击
  const handleSkillNodeClick = async (skill: Skill) => {
    setSelectedSkill(skill);
    
    try {
      const result = await assessSkillWithAI(skill.name, 'comprehensive');
      setAssessmentResult(result);
      setActiveTab('assessment');
    } catch (error) {
      console.error('技能评估失败:', error);
    }
  };

  // 获取AI学习建议
  const loadAIRecommendations = async () => {
    try {
      const userSkillData = userSkills.map(us => ({
        name: us.skill?.name || '',
        level: us.level,
        score: us.score,
      }));
      
      const recommendations = await skillAssessmentService.generateLearningRecommendations(userSkillData);
      setAiRecommendations(recommendations);
    } catch (error) {
      console.error('获取AI建议失败:', error);
      setAiRecommendations(['建议制定系统化的学习计划', '多参与实践项目巩固技能']);
    }
  };

  useEffect(() => {
    if (userSkills.length > 0) {
      loadAIRecommendations();
    }
  }, [userSkills]);

  const COLORS = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4'];

  const chartData = stats ? Object.entries(stats.category_distribution).map(([category, count]) => ({
    name: category,
    value: count,
  })) : [];

  if (skillsLoading || statsLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* 页面头部 */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Brain className="h-8 w-8 text-blue-600" />
            <div>
              <h1 className="text-2xl font-bold text-gray-900">技能图谱生成系统</h1>
              <p className="text-sm text-gray-600">可视化展示您的技能体系，获取AI驱动的学习建议</p>
            </div>
          </div>
          
          <div className="flex gap-3">
            <button
              onClick={handleGenerateGraph}
              disabled={isGeneratingGraph}
              className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {isGeneratingGraph ? (
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
              ) : (
                <Sparkles className="h-4 w-4" />
              )}
              {isGeneratingGraph ? '生成中...' : '生成技能图谱'}
            </button>
          </div>
        </div>
      </div>

      {/* 统计概览 */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 rounded-lg">
                <Target className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">总技能数</p>
                <p className="text-2xl font-bold text-gray-900">{stats.total_skills}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 rounded-lg">
                <CheckCircle2 className="h-6 w-6 text-green-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">已掌握</p>
                <p className="text-2xl font-bold text-gray-900">{stats.completed_skills}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-yellow-100 rounded-lg">
                <Clock className="h-6 w-6 text-yellow-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">学习中</p>
                <p className="text-2xl font-bold text-gray-900">{stats.in_progress_skills}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-purple-100 rounded-lg">
                <Award className="h-6 w-6 text-purple-600" />
              </div>
              <div>
                <p className="text-sm text-gray-600">平均分数</p>
                <p className="text-2xl font-bold text-gray-900">{stats.average_score}</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* 选项卡导航 */}
      <div className="bg-white rounded-lg shadow-sm">
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            {[
              { id: 'graph', label: '技能图谱', icon: Brain },
              { id: 'stats', label: '统计分析', icon: BarChart3 },
              { id: 'assessment', label: '技能评估', icon: Target },
            ].map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setActiveTab(id as any)}
                className={`flex items-center gap-2 py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === id
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <Icon className="h-4 w-4" />
                {label}
              </button>
            ))}
          </nav>
        </div>

        <div className="p-6">
          {activeTab === 'graph' && (
            <div className="space-y-6">
              {currentGraph ? (
                <SkillGraphComponent
                  skillGraph={currentGraph}
                  skills={skills}
                  userSkills={userSkills}
                  onNodeClick={handleSkillNodeClick}
                  className="h-[600px]"
                />
              ) : (
                <div className="text-center py-12">
                  <Brain className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">还没有技能图谱</h3>
                  <p className="text-gray-600 mb-6">点击上方按钮生成您的个性化技能图谱</p>
                  <button
                    onClick={handleGenerateGraph}
                    className="bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700"
                  >
                    立即生成
                  </button>
                </div>
              )}
            </div>
          )}

          {activeTab === 'stats' && stats && (
            <div className="space-y-8">
              {/* 技能分类分布 */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">技能分类分布</h3>
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  <div className="bg-gray-50 rounded-lg p-6">
                    {/* 暂时用文字代替图表 */}
                    <div className="text-center py-12">
                      <BarChart3 className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                      <p className="text-gray-600">技能分类统计图表</p>
                      <p className="text-sm text-gray-500 mt-2">
                        总技能数: {chartData.reduce((sum, item) => sum + item.value, 0)}
                      </p>
                    </div>
                  </div>
                  
                  <div className="bg-gray-50 rounded-lg p-6">
                    <h4 className="font-medium text-gray-900 mb-4">AI学习建议</h4>
                    <div className="space-y-3">
                      {aiRecommendations.map((recommendation, index) => (
                        <div key={index} className="flex items-start gap-3 p-3 bg-white rounded-lg border">
                          <Sparkles className="h-5 w-5 text-blue-500 mt-0.5 flex-shrink-0" />
                          <p className="text-sm text-gray-700">{recommendation}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* 最近成就 */}
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-4">最近成就</h3>
                <div className="space-y-3">
                  {stats.recent_achievements.length > 0 ? (
                    stats.recent_achievements.map((achievement, index) => (
                      <div key={index} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                        <div className="flex items-center gap-3">
                          <Award className="h-5 w-5 text-yellow-500" />
                          <div>
                            <p className="font-medium text-gray-900">{achievement.skill_name}</p>
                            <p className="text-sm text-gray-600">
                              达到等级 {achievement.level_achieved}，分数 {achievement.score}
                            </p>
                          </div>
                        </div>
                        <span className="text-sm text-gray-500">
                          {new Date(achievement.achieved_at).toLocaleDateString()}
                        </span>
                      </div>
                    ))
                  ) : (
                    <p className="text-gray-600 text-center py-4">暂无成就记录</p>
                  )}
                </div>
              </div>
            </div>
          )}

          {activeTab === 'assessment' && (
            <div className="space-y-6">
              {selectedSkill && assessmentResult ? (
                <div className="bg-gray-50 rounded-lg p-6">
                  <div className="flex items-center gap-3 mb-6">
                    <Target className="h-6 w-6 text-blue-600" />
                    <h3 className="text-xl font-semibold text-gray-900">
                      {selectedSkill.name} - AI技能评估
                    </h3>
                  </div>
                  
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                    <div className="bg-white rounded-lg p-4 text-center">
                      <div className="text-2xl font-bold text-blue-600 mb-1">
                        {assessmentResult.level}
                      </div>
                      <div className="text-sm text-gray-600">技能等级</div>
                    </div>
                    
                    <div className="bg-white rounded-lg p-4 text-center">
                      <div className="text-2xl font-bold text-green-600 mb-1">
                        {assessmentResult.score}
                      </div>
                      <div className="text-sm text-gray-600">评估分数</div>
                    </div>
                    
                    <div className="bg-white rounded-lg p-4 text-center">
                      <div className="text-2xl font-bold text-purple-600 mb-1">
                        {Math.round(assessmentResult.confidence * 100)}%
                      </div>
                      <div className="text-sm text-gray-600">置信度</div>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <h4 className="font-medium text-gray-900 mb-3">优势</h4>
                      <div className="space-y-2">
                        {assessmentResult.strengths.map((strength: string, index: number) => (
                          <div key={index} className="flex items-center gap-2">
                            <CheckCircle2 className="h-4 w-4 text-green-500" />
                            <span className="text-sm text-gray-700">{strength}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                    
                    <div>
                      <h4 className="font-medium text-gray-900 mb-3">改进建议</h4>
                      <div className="space-y-2">
                        {assessmentResult.recommendations.map((recommendation: string, index: number) => (
                          <div key={index} className="flex items-center gap-2">
                            <AlertCircle className="h-4 w-4 text-orange-500" />
                            <span className="text-sm text-gray-700">{recommendation}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                  
                  <div className="mt-6">
                    <h4 className="font-medium text-gray-900 mb-3">下一步行动</h4>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {assessmentResult.next_steps.map((step: string, index: number) => (
                        <div key={index} className="flex items-start gap-2">
                          <BookOpen className="h-4 w-4 text-blue-500 mt-0.5 flex-shrink-0" />
                          <span className="text-sm text-gray-700">{step}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ) : (
                <div className="text-center py-12">
                  <Target className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">选择技能进行评估</h3>
                  <p className="text-gray-600">点击技能图谱中的节点开始AI技能评估</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default SkillGraphPage;