Deno.serve(async (req) => {
    const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE, PATCH',
        'Access-Control-Max-Age': '86400',
        'Access-Control-Allow-Credentials': 'false'
    };

    if (req.method === 'OPTIONS') {
        return new Response(null, { status: 200, headers: corsHeaders });
    }

    try {
        const { action, userData } = await req.json();

        if (!action) {
            throw new Error('Action is required');
        }

        const supabaseUrl = Deno.env.get('SUPABASE_URL');
        const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

        if (!supabaseUrl || !serviceRoleKey) {
            throw new Error('Supabase configuration missing');
        }

        let result;

        switch (action) {
            case 'generate_skill_map':
                result = await generateSkillMap(userData);
                break;
            case 'career_diagnosis':
                result = await careerDiagnosis(userData);
                break;
            case 'learning_path':
                result = await generateLearningPath(userData);
                break;
            default:
                throw new Error('Invalid action');
        }

        return new Response(JSON.stringify({ data: result }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });

    } catch (error) {
        console.error('AI Career Advisor error:', error);

        const errorResponse = {
            error: {
                code: 'AI_SERVICE_ERROR',
                message: error.message
            }
        };

        return new Response(JSON.stringify(errorResponse), {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
    }
});

async function generateSkillMap(userData: any) {
    const { courses, experiences, targetRole } = userData;

    const skillCategories = ['IT', '产品', '运营', '设计', '软技能'];
    const skillMap = skillCategories.map(category => ({
        category,
        skills: generateCategorySkills(category, courses, experiences),
        score: Math.floor(Math.random() * 30) + 60
    }));

    return {
        skillMap,
        overallScore: Math.floor(skillMap.reduce((acc, cat) => acc + cat.score, 0) / skillMap.length),
        recommendations: generateRecommendations(skillMap, targetRole)
    };
}

function generateCategorySkills(category: string, courses: any[], experiences: any[]) {
    const skillsByCategory: { [key: string]: string[] } = {
        'IT': ['编程能力', '算法设计', '系统架构', '数据库设计'],
        '产品': ['需求分析', '产品规划', '用户研究', '数据分析'],
        '运营': ['内容运营', '用户增长', '数据运营', '活动策划'],
        '设计': ['UI设计', '交互设计', '视觉设计', '用户体验'],
        '软技能': ['沟通表达', '团队协作', '项目管理', '问题解决']
    };

    return (skillsByCategory[category] || []).map(skill => ({
        name: skill,
        level: Math.floor(Math.random() * 3) + 2,
        verified: Math.random() > 0.5
    }));
}

function generateRecommendations(skillMap: any[], targetRole: string) {
    const recommendations = [];
    
    const weakCategories = skillMap.filter(cat => cat.score < 70);
    weakCategories.forEach(cat => {
        recommendations.push({
            type: 'skill_improvement',
            category: cat.category,
            message: `建议加强${cat.category}类技能，当前得分${cat.score}分`
        });
    });

    if (targetRole) {
        recommendations.push({
            type: 'career_path',
            message: `针对${targetRole}岗位，建议重点提升相关核心技能`
        });
    }

    return recommendations;
}

async function careerDiagnosis(userData: any) {
    const { currentSkills, targetPosition, background } = userData;

    const gapAnalysis = {
        strengths: ['学习能力强', '技术基础扎实', '项目经验丰富'],
        weaknesses: ['实战经验不足', '某些领域技能待提升'],
        opportunities: ['行业需求旺盛', '技术栈匹配度高'],
        threats: ['竞争激烈', '技术更新快']
    };

    const requiredSkills = [
        { name: 'Python编程', current: 75, required: 85, gap: 10 },
        { name: '数据分析', current: 60, required: 80, gap: 20 },
        { name: '机器学习', current: 50, required: 75, gap: 25 },
        { name: '项目管理', current: 70, required: 70, gap: 0 }
    ];

    return {
        gapAnalysis,
        requiredSkills,
        matchScore: 72,
        timeEstimate: '3-6个月',
        recommendation: `您的技能匹配度为72%，建议重点提升数据分析和机器学习能力`
    };
}

async function generateLearningPath(userData: any) {
    const { currentLevel, targetRole, timeframe } = userData;

    const path = {
        phases: [
            {
                phase: 1,
                title: '基础巩固',
                duration: '1-2个月',
                tasks: [
                    { name: '完成Python高级编程课程', type: 'course', priority: 'high' },
                    { name: '练习50道算法题', type: 'practice', priority: 'high' },
                    { name: '阅读相关技术书籍', type: 'reading', priority: 'medium' }
                ]
            },
            {
                phase: 2,
                title: '技能进阶',
                duration: '2-3个月',
                tasks: [
                    { name: '完成机器学习实战项目', type: 'project', priority: 'high' },
                    { name: '参加Kaggle竞赛', type: 'competition', priority: 'medium' },
                    { name: '学习数据工程工具', type: 'course', priority: 'medium' }
                ]
            },
            {
                phase: 3,
                title: '实战提升',
                duration: '1-2个月',
                tasks: [
                    { name: '开发个人项目并开源', type: 'project', priority: 'high' },
                    { name: '准备技术面试', type: 'preparation', priority: 'high' },
                    { name: '参与开源社区贡献', type: 'community', priority: 'low' }
                ]
            }
        ],
        milestones: [
            { name: '完成基础课程', date: '2个月后' },
            { name: '获得第一个认证徽章', date: '3个月后' },
            { name: '完成第一个实战项目', date: '5个月后' }
        ],
        estimatedCompletion: timeframe || '6个月'
    };

    return path;
}
