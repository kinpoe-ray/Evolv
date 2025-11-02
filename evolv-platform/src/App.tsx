import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { ToastProvider } from './components/Toast';
import { useAuth } from './hooks/useAuth.tsx';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import AICareerAdvisor from './pages/AICareerAdvisor';
import SkillGym from './pages/SkillGym';
import SkillGraphPage from './pages/SkillGraphPage';
import ChallengeMode from './pages/ChallengeMode';
import SocialHub from './pages/SocialHub';
import Profile from './pages/Profile';
import Guilds from './pages/Guilds';
import Alumni from './pages/Alumni';
import AuthTest from './pages/AuthTest';
import Badges from './pages/Badges';
import BadgeWall from './components/BadgeWall';
import GradeManagement from './pages/GradeManagement';
import SkillFolio from './components/SkillFolio';
import SkillArena from './components/SkillArena';
import TeacherPortal from './components/TeacherPortal';
import SchoolDashboard from './components/SchoolDashboard';
import Layout from './components/Layout';
import GlobalLoading from './components/GlobalLoading';
import { useState } from 'react';

function PrivateRoute({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const [showLoading, setShowLoading] = useState(false);

  // 显示加载状态如果认证检查时间过长
  if (loading) {
    setTimeout(() => setShowLoading(true), 2000);
    
    return (
      <div className="min-h-screen flex items-center justify-center">
        {showLoading ? (
          <GlobalLoading message="正在验证用户信息..." />
        ) : (
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        )}
      </div>
    );
  }

  return user ? <>{children}</> : <Navigate to="/login" />;
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route
        path="/"
        element={
          <PrivateRoute>
            <Layout />
          </PrivateRoute>
        }
      >
        <Route index element={<Dashboard />} />
        <Route path="ai-advisor" element={<AICareerAdvisor />} />
        <Route path="skill-gym" element={<SkillGym />} />
        <Route path="skill-graph" element={<SkillGraphPage />} />
        <Route path="challenge" element={<ChallengeMode />} />
        <Route path="social" element={<SocialHub />} />
        <Route path="profile" element={<Profile />} />
        <Route path="guilds" element={<Guilds />} />
        <Route path="grades" element={<GradeManagement />} />
        <Route path="alumni" element={<Alumni />} />
        <Route path="skill-folio" element={<SkillFolio />} />
        <Route path="skill-arena" element={<SkillArena />} />
        <Route path="teacher-portal" element={<TeacherPortal />} />
        <Route path="school-dashboard" element={<SchoolDashboard />} />
        <Route path="badges" element={<Badges />} />
        <Route path="badge-wall" element={<BadgeWall />} />
        <Route path="auth-test" element={<AuthTest />} />
      </Route>
    </Routes>
  );
}

function App() {
  return (
    <BrowserRouter>
      <ToastProvider>
        <AuthProvider>
          <AppRoutes />
        </AuthProvider>
      </ToastProvider>
    </BrowserRouter>
  );
}

export default App;
