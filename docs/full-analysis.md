<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: audit
@summary: ai-rules 项目全面审计报告 — 涵盖规范内容安全性分析、工程化基础设施问题、改进建议优先级
-->

# ai-rules 项目全面审计报告

> 基于 v2.0.0（8 份规范源文件 + 5 个适配器）的全面审计。
> 生成日期：2026-06-05

---

## 一、总览

### 1.1 项目声明

"一套规范源，适配多款 AI 编码工具"——当前覆盖 **Claude Code · Cursor · Trae · CodeBuddy · Amazon Q Developer**。

8 份规范源文件 + 5 套适配器 + 1 个安装脚本。

### 1.2 当前版本

```
VERSION: 2.0.0
frontend-standards/ 下的 8 个规范文件
adapters/ 下的 5 套工具适配器
scripts/ 下的 install.sh 和 generate-adapters.sh
```

### 1.3 审计范围

本审计覆盖两个维度：

| 维度 | 对象 | 来源文件 |
|------|------|----------|
| **规范内容审计** | 8 份规范文件的内容完整性、安全性、缺口 | 本报告 §二 |
| **工程化审计** | 适配器系统、安装脚本、CI、元数据、项目自描述 | 本报告 §三 |

---

## 二、规范内容审计

### 2.1 当前已覆盖内容

项目 8 份规范文件覆盖了**代码风格和结构层面**的以下内容：

| 文件 | 覆盖内容 | 行数 |
|------|----------|------|
| `naming-conventions.md` | 目录命名（PascalCase/camelCase）、文件命名（index.tsx/useXxx.ts）、API 函数命名 | ~57 |
| `file-organization.md` | 目录结构模板、文件拆分决策树（300 行红线）、全局 vs 页面级放置决策 | ~85 |
| `component-patterns.md` | 结构顺序、导出约定、Props ≤ 8 / useEffect ≤ 4 / 行数 ≤ 300、TODO/FIXME/HACK 注释格式 | ~74 |
| `import-organization.md` | 7 组分组顺序、`@/` 别名规则、相对路径 ≤ 3 层 | ~66 |
| `state-management.md` | Dva/RTK/Zustand 三种模式完整示例、本地 vs 全局状态决策表 | ~183 |
| `api-requests.md` | axios 拦截器、401 跳转、按模块封装、字段准确性（大小写敏感）、加载状态要求 | ~163 |
| `styling.md` | CSS Modules 优先、Less/Tailwind 项目判别、!important 禁止、嵌套 ≤ 3 层 | ~57 |
| `typescript.md` | strict 模式、StatusConfig 映射模式、any/@ts-ignore/! 非空断言/Function 类型禁止 | ~55 |

SKILL.md 工作流中还附带了一个自查清单（字段一致性、未使用 import、console.log 残留检查）。

**总体评价**：代码风格和结构层面覆盖较好，但安全和工程化层面有重大缺口（见下文）。

---

### 2.2 安全性分析：严重不足

当前规范在安全性方面**几乎完全空白**。8 份文件中唯一涉及"安全"的是 `typescript.md` 的类型安全（TypeScript strict），而非应用安全。API 规范中的 401 处理也只是基础的会话过期管理。

#### 2.2.1 当前规范中的安全风险点

| 位置 | 当前写法 | 安全风险 |
|------|----------|----------|
| `api-requests.md:33-37` | token 存在 `localStorage`，请求时取出 | 任何 XSS 漏洞都可窃取 token。应当使用 httpOnly Cookie 或内存持有 |
| `api-requests.md:42-56` | 响应拦截器处理 401 直接跳登录 | 无 refresh token 静默续期机制，暴力跳转可能被利用做重定向攻击 |
| `api-requests.md` | 无 CSRF 提及 | 请求实例中没有 CSRF token 自动附加或 SameSite Cookie 配置 |
| 所有文件 | 无渲染安全 | 没有对 `dangerouslySetInnerHTML` 的使用约束，没有用户输入 sanitize 要求 |
| `component-patterns.md` | 无权限相关 | 没有按钮级/页面级权限控制模式 |
| 所有文件 | 无敏感数据 | 没有敏感字段脱敏要求、没有日志过滤约束 |
| 所有文件 | 无输入校验 | 前端表单输入没有长度/格式/类型校验的规范约束 |

#### 2.2.2 缺失的安全规范详细清单

##### P0 — 核心安全漏洞级（必须立即补充）

**1. XSS 防御缺失**

没有任何关于以下高风险模式的约束：

| 风险模式 | 应增加的约束 |
|----------|-------------|
| `dangerouslySetInnerHTML` | 原则上禁止；确需使用时必须经过 DOMPurify 等库 sanitize 后方可使用 |
| 用户输入渲染 | 用户输入的文本内容在渲染前必须做 HTML 转义 |
| `href` / `src` 属性注入 | 用户可控的 URL 必须校验协议（禁止 `javascript:`），图片 src 须限制协议白名单 |
| 富文本编辑器 | 富文本内容须经过严格的 HTML 过滤白名单 |

**2. Token/凭据存储安全缺失**

API 规范中直接将 token 存入 `localStorage` 并每次读取——这在生产环境是公认的反模式：

| 问题 | 建议改进 |
|------|---------|
| localStorage 易被 XSS 窃取 | 改用 httpOnly Cookie（自动附加，不受 XSS 影响） |
| 无 token 轮换 | 增加 refresh token 静默续期模式 |
| 无过期处理 | 增加 token 过期前的预刷新逻辑，避免用户无感知登出 |
| OAuth 集成 | 添加第三方登录（OAuth/SSO）的前端处理模式 |

**3. 输入验证缺失**

AI 生成前端代码时需要有明确的输入校验规范：

| 场景 | 约束 |
|------|------|
| 文本输入 | 最大长度限制（如 500 字符），匹配 API 设计的字段长度 |
| 数字输入 | 范围校验（min/max），类型校验（整数/小数） |
| 特殊字符 | 根据业务场景定义字符白名单（如用户名无特殊字符） |
| 文件上传 | 文件类型白名单、文件大小上限、预览时的安全处理 |
| URL/链接输入 | 协议白名单，禁止 `javascript:`、`data:` 等危险协议 |

**4. API 安全调用缺失**

当前只做了基本的请求封装，缺少：

| 缺失项 | 说明 |
|--------|------|
| CSRF 保护 | 非 GET 请求自动附带 CSRF token，或 Cookie 配置 SameSite=Strict/Lax |
| HTTPS 强制 | 请求实例应检测协议，非 HTTPS 环境发出警告 |
| 请求重放防护 | 敏感操作（支付、修改密码）应有幂等性 key 或 timestamp + nonce |
| 敏感请求确认 | 删除/修改关键资源时，应有二次确认机制 |

##### P1 — 架构安全级（应在下个版本增加）

**5. 权限控制模式缺失**

前端 RBAC/ABAC 的实现模式无任何覆盖：

| 场景 | 应提供的模式 |
|------|-------------|
| 页面级权限 | 路由守卫（Route Guard）的实现方式，权限不足时的重定向或 403 页面 |
| 按钮级权限 | 自定义 `AuthButton`/`Authorized` 组件模式 |
| 数据级权限 | 列表/详情页中根据权限字段控制数据可见性 |
| 权限数据管理 | 用户权限数据的获取时机、缓存策略、更新机制 |

**6. 敏感数据保护缺失**

| 约束 | 说明 |
|------|------|
| 禁止输出敏感字段 | 补充自查清单：`console.log`、网络请求日志不得包含密码/token/身份证号 |
| 禁止 URL 参数传递敏感数据 | 敏感数据不得放入 URL query string（会被服务器日志记录） |
| 最小化存储 | 前端不存储不需要的敏感数据，及时清理 |
| 脱敏显示 | 手机号/身份证/银行卡号的脱敏显示模式（138****1234） |

**7. 依赖安全缺失**

| 约束 | 说明 |
|------|------|
| 包选择 | 优先选择维护活跃、下载量大、有安全审计的包 |
| 禁止包 | 已知有安全漏洞且不再维护的包加入黑名单 |
| lockfile | 必须提交 lockfile（package-lock.json / yarn.lock / pnpm-lock.yaml） |

---

### 2.3 前端规范的其他不足

#### 2.3.1 完全缺失的规范领域

| 缺失领域 | 为何对 AI 生成重要 | 优先级 |
|----------|-------------------|--------|
| **性能优化** | AI 默认不会使用 memo/useMemo，需要约束何时使用；代码分割、懒加载、虚拟列表模式 | P1 |
| **测试规范** | AI 生成代码应同时生成对应测试（Vitest + Testing Library + Playwright），缺少模式约束 | P2 |
| **无障碍（a11y）** | AI 生成的 JSX 默认不考虑 ARIA、键盘导航、语义化，需要约束 | P2 |
| **表单处理** | 表单是最常见的 AI 任务之一，React Hook Form / Formik + zod/yup 的模式约束缺失 | P1 |
| **国际化（i18n）** | 翻译文件组织、key 命名、动态切换模式；AI 生成的文本默认硬编码 | P2 |
| **路由与导航** | 路由懒加载模式、路由守卫、面包屑生成、标签页缓存（keep-alive） | P1 |
| **错误边界** | React Error Boundary 的放置层级、粒度、兜底 UI 规范 | P2 |
| **日志与监控** | Sentry 集成、错误上报边界、用户行为追踪 | P2 |
| **环境变量** | `.env` 文件命名约定（`.env.local` vs `.env.production`）、VITE_/UMI_/REACT_APP_ 前缀规则 | P3 |
| **Mock 策略** | MSW 模式、开发/测试环境 mock 切换 | P3 |
| **Git 约定** | commit message 格式（对 AI 生成的 commit 有约束价值） | P3 |

#### 2.3.2 已覆盖但深度不足的领域

| 领域 | 当前覆盖 | 缺口 |
|------|----------|------|
| **组件规范** | 基础结构、大小限制、导出约定 | 无自定义 Hook 编写模式、无 render props/children 约定、无 ref 转发模式、无 Portal 使用规范 |
| **API 请求** | axios 封装、拦截器、模块组织 | 无 SWR/React Query/TanStack Query 模式、无乐观更新（optimistic update）、无请求取消、无轮询、无 WebSocket 模式 |
| **状态管理** | Dva/RTK/Zustand 基础模式代码 | 无 Zustand persist/devtools 中间件、无 RTK Query、无 Context 使用决策（何时用 Context vs Store）、无 Jotai/Valtio 模式 |
| **样式规范** | CSS Modules + Less/Tailwind 择优 | 无 Tailwind 具体约束（类名顺序、自定义主题扩展、responsive 前缀）、无 CSS-in-JS（emotion/styled）模式、无 CSS 变量主题切换模式 |
| **TypeScript** | strict 模式、禁止列表 | 无泛型约束模式、无类型工具函数（Pick/Omit/Partial）使用指南、无 API 响应类型推导、无 branded types 模式 |

#### 2.3.3 可观测性与工程化缺失

1. **无量词约束可被 AI 验证** — 现有 "≤ 300 行"、"Props ≤ 8 个" 等约束，缺少 AI 自查清单让大模型生成完成后逐条验证
2. **缺少项目类型感知系统** — SKILL.md 提到"识别项目类型：Umi 3/4、Vite、CRA"，但缺少项目特征表（如 package.json 依赖特征判断项目框架）
3. **缺少新项目初始化模式** — 大模型从头创建项目时没有脚手架选择指引（create-umi、create-next-app、create-vite）

---

### 2.4 AI 特有风险补充

大模型生成前端代码时有一些**非人类开发者**特有的风险，规范中没有任何覆盖：

| 风险 | 表现 | 影响 |
|------|------|------|
| **API 字段虚构（hallucination）** | 生成不存在的 API 字段名或错误的数据结构 | 运行时错误、后端接口不匹配 |
| **权限校验遗漏** | 默认"不校验权限"，只写功能逻辑 | 越权访问 |
| **不安全代码模式** | 倾向使用 `eval`、`Function()`、`innerHTML` 等危险模式 | XSS、代码注入 |
| **过度依赖第三方库** | 为简单功能引入重库（如为日期格式化引入 moment） | 包体积膨胀、攻击面增加 |
| **框架版本幻觉** | 生成旧版 API 用法（如 React class 组件） | 构建失败、运行时警告 |

---

## 三、工程化与基础设施审计

### 3.1 核心价值断裂：适配器生成未实现

项目宣称"一套规范源，适配多款 AI 编码工具"，核心价值在于**单源 + 自动生成适配器**。但 `scripts/generate-adapters.sh` 是一个**空壳**——第 18 行明确写"自动生成逻辑尚未实现"。

该脚本实际功能：
1. 查找 adapters/ 下所有文件并统计大小
2. 对每个适配器跑 `grep -qi` 检查关键词是否出现
3. 输出 ✗ 警告让用户手动处理

**后果**：
- 每次规范更新必须**手动同步 5 个适配器**
- 适配器内容与规范源必然**随时间漂移**
- Claude Code/Trae 的 SKILL.md 引用路径、Cursor/CodeBuddy/Amazon Q 的内联规则，全部手写维护
- README 指导用户"运行 scripts/generate-adapters.sh 检查适配器是否需要同步"——这行不通

### 3.2 适配器覆盖严重不均衡

内联适配器（Cursor、CodeBuddy、Amazon Q）与规范源之间存在巨大覆盖差距：

| 适配器 | 行数 | 覆盖规范比例 |
|--------|------|-------------|
| Claude Code | 72 + Read 规范 | 100%（按需加载） |
| Cursor (2 files) | 92 合计 | ~13% |
| CodeBuddy | 47 | ~6% |
| Amazon Q | 39 | ~5% |

**完全未覆盖的主题**（在内联适配器中）：

| 规范主题 | 源文件行数 | CodeBuddy | Amazon Q | Cursor |
|----------|-----------|-----------|----------|--------|
| 文件组织/拆分决策 | file-org 85 行 | ❌ | ❌ | ❌ |
| 注释规范（TODO 格式） | component ~10 行 | ❌ | ❌ | ❌ |
| Dva/RTK/Zustand 模式 | state 182 行 | ❌ | ❌ | ❌（仅决策表） |
| API 拦截器细节 | api 162 行 | 仅 3 行 | 仅 4 行 | 仅 8 行 |
| 状态管理禁止事项 | state 尾部 | ❌ | ❌ | ❌ |

### 3.3 INDEX.md 入口文件缺失

`frontend-standards/` 目录缺少 `INDEX.md` 作为规范集的**工具无关入口**。

- v1.0.0 CHANGELOG 记录"index.md → INDEX.md"，但 INDEX.md 从未创建
- TEAM-ADOPTION-PLAN 第 82-86 行设计过 INDEX.md 的内容，但未执行
- 当前入口是 Claude Code 的 `adapters/claude-code/SKILL.md`——这会使入口与工具绑定

### 3.4 TEAM-ADOPTION-PLAN.md 严重过时

该文档（330 行）是 v1.0.0 状态下编写的未来工作计划，v2.0.0 重构后未更新：

| 原计划条目 | 当前状态 |
|-----------|---------|
| #1 INDEX.md 缺失 | 仍然缺失 |
| #2 generate-adapters.sh 为空 | 仍然为空 |
| #3 lint-rules.md 死链 | 文件已删除，不适用 |
| #4 new-project-defaults.md 玩笑 | 文件已删除，不适用 |
| #5 macOS 路径问题 | 未修复 |
| #6 默认 copy 模式 | 未修复 |
| #7 适配器差异 | 仍存在（且因 v2.0.0 更突出） |
| #8 CI | 仍然没有 |
| #9 自检 | Claude Code 有，其他没有 |

### 3.5 项目缺少自描述文件

- 没有 `.claude/CLAUDE.md`
- 没有 `.claude/settings.json`
- 没有 `.github/` 目录
- 没有 `CONTRIBUTING.md`

当 AI 工具在这个仓库中编辑规范文件时，它没有任何关于项目本身约定、目录结构、适配器生成工作流程的指引。

### 3.6 跨适配器元数据不一致

各适配器的 YAML 前置元数据使用了不同的模式：

| 字段 | Claude Code | Trae | Cursor | CodeBuddy | Amazon Q |
|------|------------|------|--------|-----------|----------|
| version | ❌ | ✅ 2.0.0 | ✅ 2.0.0 | ✅ 2.0.0 | ✅ 2.0.0 |
| when_to_use | ✅ | ❌ | ❌ | ❌ | ❌ |
| context: fork | ✅ | ❌ | ❌ | ❌ | ❌ |
| input_schema | ❌ | ✅ | ❌ | ❌ | ❌ |
| globs | ❌ | ❌ | ✅ | ❌ | ❌ |
| alwaysApply | ❌ | ❌ | ✅ | ✅ | ❌ |

**语言不一致**：Amazon Q 适配器使用**英文标题**，其他所有适配器和规范文件使用中文。

### 3.7 验证缺失：无自动化保障

1. **适配器与规范一致性检查**：generate-adapters.sh 是空壳
2. **Cross-reference 检查**：没有检查
3. **格式校验**：没有检查
4. **CI 流程**：没有 `.github/workflows/`

---

## 四、改进建议优先级汇总

### P0 — 必须立即补充

| 类别 | 条目 | 影响 |
|------|------|------|
| 安全 | 新增 `security.md`，覆盖 XSS 防御、Token 存储改进、输入验证、CSRF 防护 | 核心安全漏洞 |
| 安全 | 补充 `api-requests.md` 中的安全部分（HTTPS 强制、敏感请求确认） | 核心安全漏洞 |
| 安全 | 自学查清单中增加 AI 特有风险检测（字段虚构、权限遗漏等） | AI 特有风险 |
| 工程化 | 实现 `generate-adapters.sh` 的真正功能 | 核心价值断裂 |

### P1 — 下一版本增加

| 类别 | 条目 |
|------|------|
| 安全 | RBAC/ABAC 权限控制模式、敏感数据脱敏与日志过滤、依赖安全检查清单 |
| 规范 | 新增 `form-patterns.md`（React Hook Form + zod/yup） |
| 规范 | 扩充 `component-patterns.md`（性能优化：memo、代码分割） |
| 规范 | 新增 `routing-standards.md`（路由守卫、懒加载、面包屑） |
| 规范 | 新增 `hooks-patterns.md`（自定义 Hook 编写模式） |
| 工程化 | 创建 `INDEX.md` 入口文件 |
| 工程化 | 创建 `CLAUDE.md` 项目自描述 |
| 工程化 | 修复 `install.sh` macOS 兼容性（realpath --relative-to） |
| 工程化 | `install.sh` 默认模式从 copy 改为 symlink |

### P2 — 中期改进目标

| 类别 | 条目 |
|------|------|
| 规范 | 新增 `testing-standards.md`（Vitest + Testing Library + Playwright） |
| 规范 | 新增 `accessibility-standards.md`（a11y） |
| 规范 | 新增 `i18n-standards.md`（国际化） |
| 规范 | 新增 `error-boundaries.md`（错误边界与兜底 UI） |
| 规范 | 新增 `logging-monitoring.md`（日志与监控） |
| 规范 | 新增 `api-requests.md` 中 TanStack Query / SWR 模式 |
| 工程化 | 统一跨适配器元数据模式 |
| 工程化 | 建立内联适配器最低覆盖标准 |

### P3 — 长期完善

| 类别 | 条目 |
|------|------|
| 规范 | 新增 `mock-standards.md`（MSW 策略） |
| 规范 | 新增 `environment-variables.md`（环境变量约定） |
| 工程化 | CI pipeline（适配器一致性检查、格式检查） |
| 工程化 | pre-commit hook |
| 工程化 | 跨适配器内容一致性自动化 |
| 工程化 | 更新 `TEAM-ADOPTION-PLAN.md` 使其与当前状态一致 |

---

## 附录：相关文档索引

| 文档 | 位置 | 说明 |
|------|------|------|
| 前端命名规范 | `frontend-standards/naming-conventions.md` | 目录命名、文件命名、页面目录结构 |
| 文件组织规范 | `frontend-standards/file-organization.md` | 目录结构、拆分决策树、放置原则 |
| 组件编写规范 | `frontend-standards/component-patterns.md` | 组件结构、大小限制、导出约定、注释规范 |
| 导入规范 | `frontend-standards/import-organization.md` | 导入分组、路径别名、相对路径限制 |
| 状态管理规范 | `frontend-standards/state-management.md` | Dva/RTK/Zustand 模式、状态放置决策 |
| API 请求规范 | `frontend-standards/api-requests.md` | 请求封装、拦截器、字段准确性 |
| 样式规范 | `frontend-standards/styling.md` | CSS Modules、方案选择、禁止事项 |
| TypeScript 规范 | `frontend-standards/typescript.md` | tsconfig paths、StatusConfig 模式、禁止列表 |
| 安装脚本 | `scripts/install.sh` | 多工具适配器安装 |
| 适配器生成/验证脚本 | `scripts/generate-adapters.sh` | ⚠ 尚未实现真正的自动生成 |
| 团队采纳计划 | `TEAM-ADOPTION-PLAN.md` | ⚠ 严重过时，基于 v1.0.0 状态编写 |
