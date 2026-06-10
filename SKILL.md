---
name: coding-standards
description: "前端编码规范。创建 React 组件、编写 TypeScript/JSX、设计前端方案、审查代码时按约束生成符合项目规范的代码。"
when_to_use: >
  适用于以下场景，应在执行前读取规范文件：
  - 创建或修改 React 组件、页面、Hooks
  - 编写 TypeScript 类型定义、API 调用、状态管理
  - 设计前端架构方案、目录结构、组件拆分
  - 审查/Review 前端代码是否符合规范
  - 编写样式、导入语句等细节代码
---

# 前端编码规范 (v2.0.0)

## 使用方式

本规范集采用**渐进加载策略**。不要一次性读取所有规范文件。
根据你当前的任务类型，只读取下面相关的文件。

**规范文件路径前缀：** `frontend-standards/`

## 工作流程

### 第 1 步：识别项目类型 + 判断当前阶段

检查项目根目录下的 `package.json`、`tsconfig.json`、`vite.config.ts` 等配置文件，
判断项目类型：Umi 3/4、Vite、CRA、组件库项目 或 新项目。

同时判断当前工作阶段，后续步骤将按阶段加载对应规则：

- **方案设计阶段**：当用户请求涉及"设计"、"方案"、"架构"、"Propose"时，按下方方案设计阶段规则执行
- **编码阶段**：在第 4 步按任务表加载对应的规范文件
- **Review 阶段**：在第 4 步加载代码质量类规则（代码风格、TypeScript、React/JSX）

#### 方案设计阶段

当用户请求为方案性需求时：

1. **只加载架构相关规范文件**：
   - `naming-conventions.md`（命名约定）— @trigger: 重命名文件或目录、定义命名
   - `file-organization.md`（目录结构、文件拆分）— @trigger: 设计项目目录结构、拆分文件
   - `component-patterns.md`（组件拆分原则、大小限制）— @trigger: 决定组件是否拆分
   - `state-management.md`（状态管理模式选择）— @trigger: 配置状态管理方案
   - `api-requests.md`（API 模块组织）— @trigger: 封装请求工具

2. **方案中必须注明每项设计决策的规范依据**（如"按 file-organization.md 约定，页面组件放在 pages/ 目录"）

3. **方案交付物**应包括：目录结构图、组件树、状态管理方案、API 接口设计、命名约定说明

4. 完成方案后，跳转到第 6 步输出结果，**不需要执行代码生成步骤**

### 第 2 步：检查本地配置

检查 `.prettierrc`、`.eslintrc`、`.editorconfig` 等本地配置文件。
本地配置优先级**高于**本规范集，本规范仅作为补充。

### 第 3 步：改动决策（优先级排序）

处理目标项目代码时，按以下决策框架执行：

| 场景 | 行为 |
|------|------|
| 已有文件，本次任务不需要改动 | 不主动修改。如因上下文需要读取该文件，仅做**合规观察**：发现不符合当前已加载规范的代码时向用户提示，但不修改代码 |
| 已有文件，本次任务需要改动其内容 | 修改前先询问用户是否确认改动，说明改什么和为什么 |
| 完全新增文件 | 以项目本身的既有规范为最高优先级，skill 规范仅作补充参考 |

### 第 4 步：按需加载规范

根据当前任务类型，使用 `Read` 工具加载对应的规范文件。文件均位于 `frontend-standards/` 目录下。

| 当前任务 | 需要加载的文件 |
|----------|---------------|
| 创建/修改组件 [T1] | `naming-conventions.md` → `component-patterns.md` → `react-jsx.md` |
| 编写组件逻辑/JSX [T2] | `react-jsx.md` |
| 添加 import 语句 [T3] | `import-organization.md` |
| 管理状态 [T4] | `state-management.md` |
| 编写 API 调用 [T5] | `api-requests.md` |
| 编写样式 [T6] | `styling.md` |
| 编写类型定义 [T7] | `typescript.md` |
| 组织文件/目录 [T8] | `file-organization.md` |
| 代码格式/风格 [T9] | `code-style.md` |

> **任务-规范映射依据**（对应规范文件 `@trigger` 元数据）：
> - [T1] → naming:「创建组件、页面文件」；component:「创建新的 React 组件」；react:「编写 JSX 代码」
> - [T2] → react:「编写 JSX 代码、使用 Hooks」
> - [T3] → import:「添加或修改 import 语句」
> - [T4] → state:「使用 useState 或状态管理库」
> - [T5] → api:「编写 API 请求接口」
> - [T6] → styling:「编写或修改 CSS/Less 样式」
> - [T7] → ts:「编写 interface 或 type 定义」
> - [T8] → file:「设计项目目录结构」
> - [T9] → code-style:「代码格式化检查、Review 代码风格」 |

> 当需要加载多个文件时，按上表中从左到右的顺序（`→` 分隔）依次读取。

### 第 5 步：生成代码

根据第 4 步加载的规范文件生成代码。如果代码修改量较大，可使用 `Agent` 工具在独立上下文中生成，避免规范文件占用过多上下文空间。

生成完成后立即执行自查清单：

- [ ] 字段名是否与接口定义完全一致（大小写敏感）
- [ ] 是否有未使用的 import 或变量、`console.log`/`debugger`？
- [ ] 文件名和目录名是否符合命名规范？
- [ ] 样式是否使用了项目对应的方案（CSS Modules / Tailwind / Less）？是否有静态内联样式？
- [ ] import 分组顺序是否正确（核心库 → UI 库 → 工具库 → `@/` → 相对路径 → 样式 → 类型）？
- [ ] 是否使用了禁止的 TS 语法（`any`、`@ts-ignore`、`!` 非空断言、`Function` 类型）？
- [ ] 状态是否放在了正确的层级（就近原则）？
- [ ] 是否修改了非本次任务的代码？如有，向用户说明

### 代码生成后的合规检查

代码修改完成后，**必须执行以下操作**：

1. **Review 修改的文件**：重新读取修改过的文件，对照 Step 4 加载的规范逐条检查
2. **运行自查清单**：执行上方的自查清单
3. **交叉检查**：如果修改了多个文件，检查文件之间的接口、类型、props 是否一致
4. **输出规范遵守情况**：在下一步中说明应用了哪些规范、是否符合预期

### 第 6 步：输出结果

向用户输出修改总结：
1. 修改了哪些文件
2. 应用了哪些规范（列出一两条关键规则）
3. 如果有需要用户手动确认的事项，明确指出

## 跨项目通用规则（无需读取文件）

- 函数组件 + Hooks，不使用 class 组件
- TypeScript 启用 strict 模式
- Props 接口定义在组件文件顶部（interface 组件名 + Props）
- 默认导出组件，命名导出类型
- 列表 key 使用唯一且稳定的值
- 使用 try-catch 处理异步错误
- 本地配置优先，不破坏已有代码

## 规范文件索引

| 文件 | 简述 |
|------|------|
| `naming-conventions.md` | 目录命名、文件命名、代码命名 |
| `file-organization.md` | 目录结构、文件拆分 |
| `component-patterns.md` | 组件原则、组件约束、注释规范 |
| `react-jsx.md` | React/JSX 格式、Hooks 规则 |
| `code-style.md` | 基础格式、变量声明、运算符、函数复杂度、调试 |
| `import-organization.md` | 导入顺序、路径别名 |
| `state-management.md` | Dva/RTK/Zustand |
| `api-requests.md` | 请求封装、错误处理、服务端缓存 |
| `styling.md` | CSS Modules、样式方案 |
| `typescript.md` | tsconfig 配置、类型原则、类型禁止项 |
