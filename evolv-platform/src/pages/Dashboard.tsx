import { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';
import { BadgeService } from '../services/badgeService';
import { useErrorHandler } from '../hooks/useErrorHandler';
import { useCache, useResourcePreloader } from '../hooks/usePerformance';
import { Brain, Trophy, Users, BookOpen, TrendingUp, Award, RefreshCw, AlertCircle } from 'lucide-react';
import { Link } from 'react-router-dom';
import DemoPanel from '../components/DemoPanel';

export default function Dashboard() {
  const { profile } = useAuth();
  const { handleError, handleSuccess } = useErrorHandler();
  const { preloadResource } = useResourcePreloader();
  const [stats, setStats] = useState({
    totalSkills: 0,
    verifiedSkills: 0,
    badges: 0,
    courses: 0,
  });
  const [recentActivities, setRecentActivities] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // 使用缓存优化数据加载
  const { data: dashboardData, refetch: refetchDashboard } = useCache(
    `dashboard-${profile?.id}`,
    async () => {
      if (!profile) return null;

      const [skillsData, badgesData, coursesData] = await Promise.all([
        supabase.from('user_skills').select('*', { count: 'exact' }).eq('user_id', profile.id),
        supabase.from('user_badges').select('*', { count: 'exact' }).eq('user_id', profile.id),
        supabase.from('user_courses').select('*', { count: 'exact' }).eq('user_id', profile.id),
      ]);

      const verifiedSkillsCount = skillsData.data?.filter(s => s.verified).length || 0;

      return {
        skills: skillsData.data || [],
        badges: badgesData.data || [],
        courses: coursesData.data || [],
        verifiedSkillsCount
      };
    },
    [profile?.id]
  );

  useEffect(() => {
    if (dashboardData) {
      setStats({
        totalSkills: dashboardData.skills.length,
        verifiedSkills: dashboardData.verifiedSkillsCount,
        badges: dashboardData.badges.length,
        courses: dashboardData.courses.length,
      });
      setLoading(false);
    }
  }, [dashboardData]);

  useEffect(() => {
    // 初始化徽章系统
    const initializeBadgeSystem = async () => {
      try {
        await BadgeService.initializeBadgeLibrary();
        if (profile) {
          await BadgeService.checkAndAwardBadges(profile.id);
        }
      } catch (error) {
        handleError(error, '初始化徽章系统');
      }
    };

    initializeBadgeSystem();
  }, [profile]);

  // 预加载重要资源
  useEffect(() => {
    const resources = [
      { type: 'image', src: '/icons/skill-graph.svg' },
      { type: 'image', src: '/icons/assessment.svg' },
    ];
    
    resources.forEach(preloadResource);
  }, [preloadResource]);

  const handleRefresh = async () => {
    setRefreshing(true);
    try {
      await refetchDashboard();
      handleSuccess('仪表板数据已刷新', '刷新成功');
    } catch (error) {
      handleError(error, '刷新仪表板数据');
    } finally {
      setRefreshing(false);
    }
  };

  const quickActions = [
    {
      title: 'AI职业导师',
      description: '获取个性化的职业建议和技能发展路径',
      icon: Brain,
      link: '/ai-advisor',
      color: 'bg-blue-500',
    },
    {
      title: '技能健身房',
      description: '参加技能测评，获得认证徽章',
      icon: Trophy,
      link: '/skill-gym',
      color: 'bg-purple-500',
    },
    {
      title: '技能社交',
      description: '加入技能公会，与同道者交流',
      icon: Users,
      link: '/social',
      color: 'bg-green-500',
    },
    {
      title: '课程管理',
      description: '导入课程成绩，生成学术技能图谱',
      icon: BookOpen,
      link: '/courses',
      color: 'bg-orange-500',
    },
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg p-8 text-white">
        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-3xl font-bold mb-2">欢迎回来，{profile?.full_name}</h1>
            <p className="text-blue-100">
              {profile?.user_type === 'student' && '继续你的技能成长之旅'}
              {profile?.user_type === 'teacher' && '欢迎来到教师共创平台'}
              {profile?.user_type === 'alumni' && '分享你的职场经验，帮助学弟学妹'}
            </p>
          </div>
          <button
            onClick={handleRefresh}
            disabled={refreshing}
            className="flex items-center gap-2 px-4 py-2 bg-white bg-opacity-20 hover:bg-opacity-30 rounded-lg transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`h-4 w-4 ${refreshing ? 'animate-spin' : ''}`} />
            刷新
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">掌握技能</p>
              <p className="text-2xl font-bold text-gray-900">{stats.totalSkills}</p>
            </div>
            <TrendingUp className="h-10 w-10 text-blue-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">已验证技能</p>
              <p className="text-2xl font-bold text-gray-900">{stats.verifiedSkills}</p>
            </div>
            <Award className="h-10 w-10 text-green-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">获得徽章</p>
              <p className="text-2xl font-bold text-gray-900">{stats.badges}</p>
            </div>
            <Trophy className="h-10 w-10 text-purple-500" />
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">已修课程</p>
              <p className="text-2xl font-bold text-gray-900">{stats.courses}</p>
            </div>
            <BookOpen className="h-10 w-10 text-orange-500" />
          </div>
        </div>
      </div>

      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-6">快速开始</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {quickActions.map((action) => (
            <Link
              key={action.link}
              to={action.link}
              className="bg-white rounded-lg shadow p-6 hover:shadow-lg transition-shadow"
            >
              <div className="flex items-start gap-4">
                <div className={`${action.color} p-3 rounded-lg`}>
                  <action.icon className="h-6 w-6 text-white" />
                </div>
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-1">{action.title}</h3>
                  <p className="text-sm text-gray-600">{action.description}</p>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>

      {/* 演示面板 - 仅在无数据时显示 */}
      {stats.totalSkills === 0 && stats.badges === 0 && stats.courses === 0 && (
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-6">开始体验</h2>
          <div className="max-w-2xl">
            <DemoPanel />
          </div>
        </div>
      )}
    </div>
  );
}
