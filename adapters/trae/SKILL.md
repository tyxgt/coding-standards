---
name: frontend-standards
description: 前端编码规范 - 覆盖命名、组件、状态管理、API请求、样式、TypeScript
category: coding-standards
version: "1.0.0"
input_schema:
  type: object
  properties: {}
output_schema:
  type: object
  properties: {}
examples:
  - 创建新组件时应用组件规范
  - 添加 API 调用时应用 API 请求规范
limitations:
  - 本规范不覆盖后端代码
  - 项目本地配置文件优先级高于本规范
---

# 前端编码规范 (v1.0.0)

## 使用方式

本规范集采用渐进加载策略。规范文件位于 `{{AI_RULES_PATH}}/frontend-standards/` 目录下。
根据当前任务类型，按需读取对应的规范文件，不要一次性读取所有文件。

## 工作流程

### 第 1 步：识别项目类型
检查 `package.json`、`tsconfig.json`、`vite.config.ts` 等配置文件，
判断项目类型：Umi 3/4、Vite、CRA、组件库项目 或 新项目。

### 第 2 步：检查本地配置
检查 `.prettierrc`、`.eslintrc`、`.editorconfig` 等配置文件。
本地配置优先级高于本规范集。

### 第 3 步：按需加载规范

| 当前任务 | 需要加载的文件 |
|----------|---------------|
| 创建/修改组件 | `component-patterns.md` + `naming-conventions.md` |
| 添加 import 语句 | `import-organization.md` |
| 管理状态 | `state-management.md` |
| 编写 API 调用 | `api-requests.md` |
| 编写样式 | `styling.md` |
| 编写类型定义 | `typescript.md` |
| 组织文件/目录 | `file-organization.md` |
| 添加注释 | `comments.md` |
| 代码重构/审查 | `lint-rules.md` |
| 创建新项目 | `new-project-defaults.md` |

### 第 4 步：自查
- 无遗留 `console.log`、`any` 类型、未使用的 import
- 文件名符合命名规范，样式使用项目对应方案
- 不修改非目标代码

## 跨项目通用规则

- 函数组件 + Hooks，不使用 class 组件
- TypeScript strict 模式，避免 `any`
- Props interface 定义在组件文件顶部（组件名 + Props）
- 默认导出组件，命名导出类型
- useEffect 依赖数组完整，列表 key 使用唯一值
- 使用 try-catch 处理异步错误
- 本地配置优先，不破坏已有代码
