---
name: coding-standards
description: "前端编码规范。创建 React 组件、编写 TypeScript/JSX、设计前端方案、审查代码时按约束生成符合项目规范的代码。"
version: "2.0.0"
author: coding-standards-team
category: code_generation
license: MIT
input_schema:
  type: object
  properties:
    task_type:
      type: string
      description: "前端开发任务类型"
      enum: ["component", "style", "api", "state", "type", "import", "file", "review"]
      example: "component"
output_schema:
  type: object
  properties:
    applied_rules:
      type: array
      description: "已应用的规范规则列表"
      items:
        type: string
    modified_files:
      type: array
      description: "修改的文件列表"
      items:
        type: string
examples:
  - input:
      task_type: "component"
    output:
      applied_rules:
        - "naming-conventions: 组件使用 PascalCase"
        - "component-patterns: Props ≤ 8 个"
        - "react-jsx: 函数组件 + Hooks"
      modified_files: []
    description: "创建组件时应用命名、组件和 JSX 规范"
  - input:
      task_type: "review"
    output:
      applied_rules:
        - "code-style: 变量声明规范"
        - "typescript: strict 模式禁止 any"
        - "import-organization: 导入 7 组顺序"
      modified_files: []
    description: "代码审查时检查代码风格和 TypeScript 规范"
  - input:
      task_type: "api"
    output:
      applied_rules:
        - "api-requests: 统一请求实例 + 拦截器"
        - "state-management: 状态就近原则"
      modified_files: []
    description: "添加 API 调用时应用请求和状态管理规范"
  - input:
      task_type: "component"
    output:
      applied_rules:
        - "styling: CSS Modules 管理样式"
        - "react-jsx: 函数组件 + Hooks"
        - "naming-conventions: 文件 camelCase 命名"
      modified_files:
        - "src/components/RedSquare/index.tsx"
        - "src/components/RedSquare/style.less"
    description: "实现简单 UI 功能（如红色方块）时自动应用样式和组件规范"
limitations:
  - "本规范不覆盖后端代码"
  - "项目本地配置文件（.prettierrc、.eslintrc）优先级高于本规范"
  - "不处理非前端项目（后端、数据库等）"
security_notes:
  - "规范文件仅作为编码参考，不处理敏感数据"
  - "不修改项目已有配置文件，仅补充规范约束"
context: fork
---
# 前端编码规范 (v2.0.0)

## 渐进加载策略

规范文件位于 `frontend-standards/` 目录下。**不要一次性读取所有文件**，根据当前任务按需加载。

## 工作流程

### 第 1 步：识别项目类型 + 判断当前阶段

检查项目根目录下的 `package.json`、`tsconfig.json`、`vite.config.ts` 等配置文件，
判断项目类型：Umi 3/4、Vite、CRA、组件库项目 或 新项目。

同时判断当前工作阶段，后续步骤将按阶段加载对应规则：

- **方案设计阶段**：当用户请求涉及"设计"、"方案"、"架构"、"Propose"时，按下方方案设计阶段规则执行
- **编码阶段**：按任务表加载对应的规范文件
- **Review 阶段**：加载代码质量类规则（代码风格、TypeScript、React/JSX）

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

4. 完成方案后，跳转到输出结果步骤，**不需要执行代码生成步骤**

#### 任务类型识别（编码/Review 阶段）

当处于编码或 Review 阶段时，根据用户当前操作判断任务类型：

| 任务类型 | 识别特征 | 对应规范文件 |
|----------|----------|-------------|
| **组件开发** [T1] | 创建组件、修改组件 Props、编写 JSX | naming-conventions.md → component-patterns.md → react-jsx.md |
| **样式编写** [T6] | 修改 .less/.css、使用 Tailwind | styling.md |
| **API 调用** [T5] | 编写接口请求、axios 封装 | api-requests.md |
| **状态管理** [T4] | 使用 Dva/RTK/Zustand、useState | state-management.md |
| **类型定义** [T7] | 编写 interface/type、泛型 | typescript.md |
| **导入组织** [T3] | import 语句、路径别名 | import-organization.md |
| **文件组织** [T8] | 目录结构、文件拆分 | file-organization.md |
| **代码审查** [T9] | review 代码、检查规范 | code-style.md |

> **任务-规范映射依据**（对应规范文件 `@trigger` 元数据）：
> - [T1] → naming:「创建组件、页面文件」；component:「创建新的 React 组件」；react:「编写 JSX 代码」
> - [T3] → import:「添加或修改 import 语句」
> - [T4] → state:「使用 useState 或状态管理库」
> - [T5] → api:「编写 API 请求接口」
> - [T6] → styling:「编写或修改 CSS/Less 样式」
> - [T7] → ts:「编写 interface 或 type 定义」
> - [T8] → file:「设计项目目录结构」
> - [T9] → code-style:「代码格式化检查、Review 代码风格」

### 第 2 步：检查本地配置

检查 `.prettierrc`、`.eslintrc`、`.editorconfig` 等配置文件，**本地配置优先级最高**。

### 第 3 步：改动决策（优先级排序）

处理目标项目代码时，按以下决策框架执行：

| 场景 | 行为 |
|------|------|
| 已有文件，本次任务不需要改动 | 不主动修改。如因上下文需要读取该文件，仅做**合规观察**：发现不符合当前已加载规范的代码时向用户提示，但不修改代码 |
| 已有文件，本次任务需要改动其内容 | 修改前先询问用户是否确认改动，说明改什么和为什么 |
| 完全新增文件 | 以项目本身的既有规范为最高优先级，skill 规范仅作补充参考 |

### 第 4 步：按需加载规范

按上表从左到右顺序加载规范文件（→ 分隔表示加载顺序）。

> 当需要加载多个文件时，按上表中从左到右的顺序（`→` 分隔）依次读取。

### 第 5 步：生成代码 + 合规检查

通用规则和自查清单已在 **Rule（.trae/rules/frontend-standards.md）** 中始终生效，此处不再重复。
按加载的规范文件生成代码。

代码修改完成后，**必须执行以下操作**：

1. **Review 修改的文件**：重新读取修改过的文件，对照已加载的规范逐条检查
2. **运行自查清单**：执行 Rule 文件中的自查清单
3. **交叉检查**：如果修改了多个文件，检查文件之间的接口、类型、props 是否一致
4. **输出规范遵守情况**：在下一步中说明应用了哪些规范、是否符合预期

### 第 6 步：输出结果

向用户输出修改总结：
1. 修改了哪些文件
2. 应用了哪些规范（列出一两条关键规则）
3. 如果有需要用户手动确认的事项，明确指出

## 规范文件索引

| 文件 | 简述 |
|------|------|
| `naming-conventions.md` | 目录/文件/代码命名规范 |
| `file-organization.md` | 目录结构、文件拆分 |
| `component-patterns.md` | 组件原则、大小限制、注释规范 |
| `react-jsx.md` | React/JSX 格式、Hooks 规则 |
| `code-style.md` | 基础格式、变量声明、函数复杂度 |
| `import-organization.md` | 导入顺序、路径别名 |
| `state-management.md` | Dva/RTK/Zustand |
| `api-requests.md` | 请求封装、错误处理 |
| `styling.md` | CSS Modules、样式方案 |
| `typescript.md` | tsconfig、类型原则、禁止项 |
