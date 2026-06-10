---
name: coding-standards
description: >
  前端编码规范。新建页面、实现功能、编写组件或审查代码时自动触发。
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

### 第 1 步：识别任务类型

根据用户当前操作，判断属于哪类任务：

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

### 第 3 步：按需加载规范

按上表从左到右顺序加载规范文件（→ 分隔表示加载顺序）。

### 第 4 步：代码生成 + 自查

通用规则和自查清单已在 **Rule（.trae/rules/frontend-standards.md）** 中始终生效，此处不再重复。
按加载的规范文件生成代码，完成后自查：

- [ ] 生成的代码符合已加载的规范文件要求
- [ ] 未修改非本次任务的代码

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
