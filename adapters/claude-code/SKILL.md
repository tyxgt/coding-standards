---
name: frontend-standards
description: 前端编码规范 - 覆盖命名、组件、状态管理、API请求、样式、TypeScript、文件组织、导入规范
when_to_use: 当需要编写或修改前端代码（创建组件、实现页面、添加功能、修改 UI）时使用
context: fork
---

# 前端编码规范 (v2.0.0)

## 使用方式

本规范集采用**渐进加载策略**。不要一次性读取所有规范文件。
根据你当前的任务类型，只读取下面相关的文件。

规范文件位于 `{{AI_RULES_PATH}}/frontend-standards/` 目录下。

## 工作流程

### 第 1 步：识别项目类型

检查项目根目录下的 `package.json`、`tsconfig.json`、`vite.config.ts` 等配置文件，
判断项目类型：Umi 3/4、Vite、CRA、组件库项目 或 新项目。

### 第 2 步：检查本地配置

检查 `.prettierrc`、`.eslintrc`、`.editorconfig` 等本地配置文件。
本地配置优先级**高于**本规范集，本规范仅作为补充。

### 第 3 步：按需加载规范

| 当前任务 | 需要加载的文件 |
|----------|---------------|
| 创建/修改组件 | `Read {{AI_RULES_PATH}}/frontend-standards/naming-conventions.md` 和 `component-patterns.md` |
| 添加 import 语句 | `Read {{AI_RULES_PATH}}/frontend-standards/import-organization.md` |
| 管理状态 | `Read {{AI_RULES_PATH}}/frontend-standards/state-management.md` |
| 编写 API 调用 | `Read {{AI_RULES_PATH}}/frontend-standards/api-requests.md` |
| 编写样式 | `Read {{AI_RULES_PATH}}/frontend-standards/styling.md` |
| 编写类型定义 | `Read {{AI_RULES_PATH}}/frontend-standards/typescript.md` |
| 组织文件/目录 | `Read {{AI_RULES_PATH}}/frontend-standards/file-organization.md` |

### 第 4 步：生成代码 + 自查

生成完成后，快速检查：
- [ ] 字段名是否与接口定义完全一致（大小写敏感）
- [ ] 是否有未使用的 import 或变量？
- [ ] 是否有 `console.log` 遗留？
- [ ] 文件名是否符合规范？
- [ ] 样式是否使用了项目对应的方案？
- [ ] 是否修改了非本次任务的代码？如有，已通知用户

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
| `naming-conventions.md` | 目录命名、文件命名 |
| `file-organization.md` | 目录结构、文件拆分 |
| `component-patterns.md` | 组件约束、注释规范 |
| `import-organization.md` | 导入顺序、路径别名 |
| `state-management.md` | Dva/RTK/Zustand |
| `api-requests.md` | 请求封装、错误处理 |
| `styling.md` | CSS Modules、样式方案 |
| `typescript.md` | tsconfig 配置、类型禁止项 |
