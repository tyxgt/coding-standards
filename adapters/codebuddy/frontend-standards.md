---
description: 前端编码规范 - 命名、组件约束、导入、状态管理、样式、TypeScript
alwaysApply: true
enabled: true
paths:
  - "src/**/*.{ts,tsx,js,jsx,less,css}"
updatedAt: "2026-06-05"
---

# 前端编码规范 (v2.0.0)

## 命名
- 目录：页面 PascalCase，组件 camelCase
- 文件：入口 `index.tsx`，Hook `useXxx.ts`

## 组件
- 单文件 ≤ 300 行，Props ≤ 8 个
- 结构：Props 类型 → 组件 → state → effect → 事件 → 渲染
- 默认导出组件，命名导出类型

## 导入
顺序：核心库 → UI 库 → 工具库 → `@/` 别名 → 相对路径 → 样式 → `import type`
每组空一行。`@/` 跨目录，相对路径不超过 3 层。

## 状态管理
- 就近原则：本地用 useState，全局用 Dva/RTK/Zustand
- 不直接修改 state，不混用方案

## 样式
- CSS Modules 优先，camelCase 命名（`styles.container` ✅，禁止 `styles['kebab-case']` ❌）
  - 使用 Tailwind CSS
| 项目已有 Tailwind（`tailwind.config.*`） | 使用 Tailwind class 写法 |
| 项目使用普通 CSS（无上述配置） | 继续用普通 CSS，不引入 CSS Modules / Tailwind / 预处理器 |
| 选择器嵌套 | 不超过 3 层 |
| `!important` | 禁止使用（除非覆盖第三方库） |
- ❌ 引入项目未使用的样式方案（如 Less 项目改 CSS Modules、普通 CSS 项目引入 Tailwind）

## TypeScript
- Props 用 `interface`，联合类型用 `type`
- `import type` 用于类型导入
- 禁止 `@ts-ignore`、`!` 非空断言、`Function` 类型

## API
- 统一请求实例 + 拦截器，code === 0 → data，401 → 登录页
- 字段名必须与接口定义完全一致（大小写敏感）
- 每个请求有对应 loading 状态

## 禁止
- `any`、`@ts-ignore`、class 组件、内联静态样式
- 直接修改 state、循环依赖、`console.log` 遗留到生产
- 本地配置优先于本规范，不修改已有代码
