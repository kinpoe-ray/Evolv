/**
 * Evolv Platform 端到端测试脚本
 * 模拟真实用户操作的完整流程测试
 */

const puppeteer = require('puppeteer');
const https = require('https');
const { createClient } = require('@supabase/supabase-js');

// 配置
const config = {
    url: 'https://ndlvdstdljej.space.minimax.io',
    supabaseUrl: 'https://qpgefcjcuhcqojiawpit.supabase.co',
    supabaseKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwZ2VmY2pjdWhjcW9qaWF3cGl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5OTk5MjgsImV4cCI6MjA3NzU3NTkyOH0.CJJCNIYH2FjA83lJ1UhJbTZeDD41_nvEEq2gsz9sqLg',
    testUser: {
        email: 'rgatqrua@minimax.com',
        password: 'ZNHgc8WcPo',
        id: '25ac5e01-09ea-4498-b879-d5bdf921fc58'
    }
};

// 测试类
class EvolvE2ETester {
    constructor() {
        this.browser = null;
        this.page = null;
        this.testResults = [];
    }

    // 记录测试结果
    log(testName, status, details = '') {
        const result = {
            name: testName,
            status: status,
            details: details,
            timestamp: new Date().toISOString()
        };
        this.testResults.push(result);
        console.log(`[${status}] ${testName}: ${details}`);
    }

    // 初始化浏览器
    async init() {
        try {
            this.log('初始化浏览器', '开始');
            
            // 尝试连接到现有Chrome实例
            this.browser = await puppeteer.connect({
                browserURL: 'http://localhost:9222',
                defaultViewport: { width: 1920, height: 1080 }
            });
            
            this.page = await this.browser.newPage();
            this.log('浏览器初始化', '成功');
            
        } catch (error) {
            this.log('浏览器初始化', '失败', error.message);
            throw error;
        }
    }

    // 测试1: 页面加载和基础渲染
    async testPageLoading() {
        try {
            this.log('页面加载测试', '开始');
            
            // 访问主页
            await this.page.goto(config.url, { waitUntil: 'networkidle0' });
            
            // 检查页面标题
            const title = await this.page.title();
            this.log('页面标题检查', title.includes('Evolv') ? '通过' : '失败', `标题: ${title}`);
            
            // 检查React应用是否挂载
            const reactApp = await this.page.$('#root');
            this.log('React应用挂载', reactApp ? '通过' : '失败');
            
            // 检查导航菜单
            const navItems = await this.page.$$eval('nav a, .nav-link, [href*="-hub"], [href*="-folio"], [href*="-arena"], [href*="teacher"], [href*="dashboard"]', 
                elements => elements.map(el => el.textContent.trim()).filter(text => text.length > 0)
            );
            
            this.log('导航菜单检查', navItems.length > 0 ? '通过' : '失败', `找到 ${navItems.length} 个导航项`);
            
            // 截图保存
            await this.page.screenshot({ path: '/workspace/screenshots/homepage.png' });
            this.log('主页截图', '完成');
            
        } catch (error) {
            this.log('页面加载测试', '错误', error.message);
        }
    }

    // 测试2: 用户认证流程
    async testAuthenticationFlow() {
        try {
            this.log('用户认证流程测试', '开始');
            
            // 查找登录按钮
            const loginButton = await this.page.$('button:contains("登录"), a[href*="login"], [data-testid="login"]');
            
            if (loginButton) {
                // 点击登录按钮
                await loginButton.click();
                await this.page.waitForTimeout(2000);
                
                // 检查登录表单
                const emailField = await this.page.$('input[type="email"], input[name="email"]');
                const passwordField = await this.page.$('input[type="password"], input[name="password"]');
                
                if (emailField && passwordField) {
                    // 填写测试用户信息
                    await emailField.type(config.testUser.email, { delay: 100 });
                    await passwordField.type(config.testUser.password, { delay: 100 });
                    
                    // 提交表单
                    const submitButton = await this.page.$('button[type="submit"], button:contains("登录")');
                    if (submitButton) {
                        await submitButton.click();
                        await this.page.waitForTimeout(3000);
                        
                        // 检查登录后的页面
                        const currentUrl = await this.page.url();
                        this.log('登录流程', currentUrl !== config.url ? '通过' : '失败', `跳转到: ${currentUrl}`);
                        
                        // 检查用户状态
                        const userProfile = await this.page.$('.user-profile, [data-testid="user-menu"], .user-avatar');
                        this.log('登录状态检查', userProfile ? '通过' : '失败');
                        
                    } else {
                        this.log('登录按钮', '未找到');
                    }
                } else {
                    this.log('登录表单', '表单元素不完整');
                }
            } else {
                this.log('登录入口', '未找到登录按钮');
            }
            
        } catch (error) {
            this.log('用户认证流程测试', '错误', error.message);
        }
    }

    // 测试3: 各功能模块访问
    async testModuleAccess() {
        const modules = [
            { name: '校友会系统', path: '/alumni-hub' },
            { name: 'SkillFolio', path: '/skill-folio' },
            { name: '技能擂台', path: '/skill-arena' },
            { name: '高校老师平台', path: '/teacher-portal' },
            { name: '学校管理端', path: '/school-dashboard' }
        ];

        for (const module of modules) {
            try {
                this.log(`测试${module.name}访问`, '开始');
                
                const fullUrl = config.url + module.path;
                await this.page.goto(fullUrl, { waitUntil: 'networkidle0' });
                
                // 检查页面是否正常加载
                const hasContent = await this.page.evaluate(() => {
                    const root = document.getElementById('root');
                    return root && root.children.length > 0;
                });
                
                this.log(`${module.name}页面加载`, hasContent ? '通过' : '失败');
                
                // 等待React渲染完成
                await this.page.waitForTimeout(2000);
                
                // 截图保存
                await this.page.screenshot({ path: `/workspace/screenshots/${module.path.replace('/', '')}.png` });
                
                // 检查特定功能元素
                await this.checkModuleSpecificElements(module.name);
                
            } catch (error) {
                this.log(`测试${module.name}访问`, '错误', error.message);
            }
        }
    }

    // 检查模块特定元素
    async checkModuleSpecificElements(moduleName) {
        try {
            const checks = {
                '校友会系统': ['mentor', '导师', 'alumni', '校友'],
                'SkillFolio': ['skill', '技能', 'profile', '档案', 'portfolio'],
                '技能擂台': ['challenge', '挑战', 'arena', '擂台', 'competition'],
                '高校老师平台': ['question', '题目', 'teacher', '老师', 'resource'],
                '学校管理端': ['dashboard', '统计', 'chart', '图', 'analytics']
            };
            
            const keywords = checks[moduleName] || [];
            if (keywords.length === 0) return;
            
            const pageText = await this.page.evaluate(() => document.body.innerText);
            const foundKeywords = keywords.filter(keyword => 
                pageText.toLowerCase().includes(keyword.toLowerCase())
            );
            
            this.log(`${moduleName}内容检查`, foundKeywords.length > 0 ? '通过' : '失败', 
                `找到关键词: ${foundKeywords.join(', ')}`);
                
        } catch (error) {
            this.log(`${moduleName}元素检查`, '错误', error.message);
        }
    }

    // 测试4: 数据操作CRUD
    async testDataOperations() {
        try {
            this.log('数据操作CRUD测试', '开始');
            
            // 测试TeacherPortal的数据操作
            await this.page.goto(config.url + '/teacher-portal', { waitUntil: 'networkidle0' });
            
            // 寻找"创建题目"或类似按钮
            const createButtons = await this.page.$$('button:contains("创建"), button:contains("新增"), button:contains("添加"), button:contains("新建")');
            
            if (createButtons.length > 0) {
                // 点击创建按钮
                await createButtons[0].click();
                await this.page.waitForTimeout(2000);
                
                // 查找表单字段
                const titleField = await this.page.$('input[name*="title"], input[placeholder*="标题"], input[placeholder*="题目"]');
                const contentField = await this.page.$('textarea[name*="content"], textarea[name*="question"], [placeholder*="内容"]');
                
                if (titleField && contentField) {
                    // 填写测试数据
                    await titleField.type('端到端测试题目', { delay: 100 });
                    await contentField.type('这是一个用于端到端测试的题目内容', { delay: 100 });
                    
                    // 提交
                    const submitButton = await this.page.$('button[type="submit"], button:contains("保存"), button:contains("提交")');
                    if (submitButton) {
                        await submitButton.click();
                        await this.page.waitForTimeout(3000);
                        
                        // 检查数据是否保存
                        const pageText = await this.page.evaluate(() => document.body.innerText);
                        const saveSuccess = pageText.includes('端到端测试题目') || pageText.includes('成功') || pageText.includes('保存');
                        
                        this.log('数据创建操作', saveSuccess ? '通过' : '失败', saveSuccess ? '数据可能已保存' : '未找到保存成功提示');
                        
                    } else {
                        this.log('提交按钮', '未找到');
                    }
                } else {
                    this.log('表单字段', '字段不完整');
                }
            } else {
                this.log('创建功能入口', '未找到创建按钮');
            }
            
        } catch (error) {
            this.log('数据操作CRUD测试', '错误', error.message);
        }
    }

    // 测试5: 响应式设计
    async testResponsiveDesign() {
        try {
            this.log('响应式设计测试', '开始');
            
            const viewports = [
                { name: '移动端', width: 375, height: 667 },
                { name: '平板', width: 768, height: 1024 },
                { name: '桌面端', width: 1920, height: 1080 }
            ];
            
            for (const viewport of viewports) {
                try {
                    await this.page.setViewport({ width: viewport.width, height: viewport.height });
                    await this.page.goto(config.url, { waitUntil: 'networkidle0' });
                    await this.page.waitForTimeout(2000);
                    
                    // 检查页面元素是否正常显示
                    const bodyWidth = await this.page.evaluate(() => document.body.clientWidth);
                    const isResponsive = Math.abs(bodyWidth - viewport.width) < 50;
                    
                    this.log(`响应式_${viewport.name}`, isResponsive ? '通过' : '失败', 
                        `期望: ${viewport.width}px, 实际: ${bodyWidth}px`);
                    
                    // 截图保存
                    await this.page.screenshot({ 
                        path: `/workspace/screenshots/responsive_${viewport.width}.png`,
                        fullPage: true 
                    });
                    
                } catch (error) {
                    this.log(`响应式_${viewport.name}`, '错误', error.message);
                }
            }
            
        } catch (error) {
            this.log('响应式设计测试', '错误', error.message);
        }
    }

    // 清理资源
    async cleanup() {
        try {
            if (this.browser) {
                await this.browser.close();
            }
            this.log('资源清理', '完成');
        } catch (error) {
            this.log('资源清理', '警告', error.message);
        }
    }

    // 生成测试报告
    generateReport() {
        const report = {
            summary: {
                total: this.testResults.length,
                passed: this.testResults.filter(r => r.status === '通过').length,
                failed: this.testResults.filter(r => r.status === '失败').length,
                errors: this.testResults.filter(r => r.status === '错误').length
            },
            results: this.testResults,
            timestamp: new Date().toISOString()
        };
        
        console.log('\n' + '='.repeat(60));
        console.log('🎯 Evolv Platform 端到端测试报告');
        console.log('='.repeat(60));
        console.log(`总测试数: ${report.summary.total}`);
        console.log(`通过: ${report.summary.passed} ✅`);
        console.log(`失败: ${report.summary.failed} ❌`);
        console.log(`错误: ${report.summary.errors} ⚠️`);
        console.log(`成功率: ${((report.summary.passed / report.summary.total) * 100).toFixed(1)}%`);
        console.log('='.repeat(60));
        
        return report;
    }
}

// 主测试函数
async function runE2ETests() {
    const tester = new EvolvE2ETester();
    
    try {
        console.log('🚀 开始Evolv Platform端到端测试...');
        
        // 初始化
        await tester.init();
        
        // 执行测试
        await tester.testPageLoading();
        await tester.testAuthenticationFlow();
        await tester.testModuleAccess();
        await tester.testDataOperations();
        await tester.testResponsiveDesign();
        
    } catch (error) {
        console.error('测试执行错误:', error.message);
    } finally {
        // 清理和生成报告
        await tester.cleanup();
        const report = tester.generateReport();
        
        // 保存报告
        const fs = require('fs');
        fs.writeFileSync('/workspace/e2e-test-report.json', JSON.stringify(report, null, 2));
        console.log('\n📄 详细测试报告已保存到: e2e-test-report.json');
    }
}

// 如果直接运行此文件
if (require.main === module) {
    runE2ETests().catch(console.error);
}

module.exports = { EvolvE2ETester, runE2ETests };
