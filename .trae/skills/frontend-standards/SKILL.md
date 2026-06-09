---
name: frontend-standards
description: 前端编码规范 - 写组件/页面、写样式、调API、状态管理、TypeScript类型、导入组织、代码风格、文件命名、组件约束
category: coding-standards
version: "2.0.0"
input_schema:
  type: object
  properties: {}
output_schema:
  type: object
  properties: {}
examples:
  - 创建一个新组件
  - 编写 API 调用
  - 管理页面状态
  - 组织文件和目录结构
limitations:
  - 本地配置文件（.prettierrc、.eslintrc、.editorconfig）优先级高于本规范
  - 本规范不覆盖后端代码、数据库等非前端领域
---

# 前端编码规范 (v2.0.0)

## 使用方式

本规范集采用**渐进加载策略**。规范文件位于 `frontend-standards/` 目录下。
根据当前任务类型，按需读取对应的规范文件，不要一次性读取所有文件。

## 工作流程

### 第 1 步：识别项目类型

检查项目根目录下的 `package.json`、`tsconfig.json`、`vite.config.ts` 等配置文件，
判断项目类型：Umi 3/4、Vite、CRA、组件库项目 或 新项目。

### 第 2 步：检查本地配置

检查 `.prettierrc`、`.eslintrc`、`.editorconfig` 等配置文件。
本地配置优先级高于本规范集。

### 第 3 步：按需加载规范

根据当前任务类型，加载对应的规范文件（位于 `frontend-standards/` 目录下）。

| 当前任务 | 需要加载的文件 |
|----------|---------------|
| 创建/修改组件 | `naming-conventions.md` → `component-patterns.md` → `react-jsx.md` |
| 编写组件逻辑/JSX | `react-jsx.md` |
| 添加 import 语句 | `import-organization.md` |
| 管理状态 | `state-management.md` |
| 编写 API 调用 | `api-requests.md` |
| 编写样式 | `styling.md` |
| 编写类型定义 | `typescript.md` |
| 组织文件/目录 | `file-organization.md` |
| 代码格式/风格 | `code-style.md` |

> 当需要加载多个文件时，按上表中从左到右的顺序依次读取。

### 第 4 步：自查

代码完成后，逐一检查以下事项：

- [ ] 字段名是否与接口定义完全一致（大小写敏感）
- [ ] 是否有未使用的 import 或变量？
- [ ] 是否有 `console.log` 或 `debugger` 遗留？
- [ ] 是否有 TODO/FIXME/HACK 注释应处理？
- [ ] 文件名是否符合命名规范？
- [ ] 样式是否使用了项目对应的方案（CSS Modules / Tailwind / Less）？
- [ ] 是否有静态内联样式（`style={{ }}` 中的固定值）？应提取到 CSS Modules
- [ ] import 分组顺序是否正确（核心库 → UI 库 → 工具库 → `@/` → 相对路径 → 样式 → 类型）？
- [ ] 是否使用了禁止的 TypeScript 语法（`any`、`@ts-ignore`、`!` 非空断言、`Function` 类型）？
- [ ] 状态是否放在了正确的层级（就近原则）？
- [ ] 是否修改了非本次任务的代码？如有，向用户说明

### 第 5 步：输出结果

向用户输出修改总结：
1. 修改了哪些文件
2. 应用了哪些规范（列出一两条关键规则）
3. 如果有需要用户手动确认的事项，明确指出

## 通用规则（无需读取文件）

- 函数组件 + Hooks，不使用 class 组件
- TypeScript 启用 strict 模式
- Props 接口定义在组件文件顶部（interface 组件名 + Props）
- 默认导出组件，命名导出类型
- 列表 key 使用唯一且稳定的值
- 使用 try-catch 处理异步错误
- 本地配置优先，不破坏已有代码
