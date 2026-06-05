---
description: 前端编码规范 - 命名、组件、导入、状态管理、样式、TypeScript
alwaysApply: true
enabled: true
paths:
  - "src/**/*.{ts,tsx,js,jsx,less,css}"
updatedAt: "2026-06-05"
---

# 前端编码规范 (v1.0.0)

## 命名
- 目录：页面 PascalCase，组件/工具 camelCase
- 文件：入口 `index.tsx`，Hook `useXxx.ts`
- 变量/函数：camelCase，事件 `handle` 前缀，布尔 `is/has/should` 前缀
- 组件：PascalCase，Props 接口：`组件名 + Props`

## 组件
- 函数组件 + Hooks（不使用 class 组件）
- 结构：Props 类型 → 组件 → 状态 → 副作用 → 事件 → 渲染 → 默认导出
- 单文件 ≤ 300 行，Props ≤ 8 个
- 列表 key 使用唯一稳定值，不使用索引

## 导入
顺序：核心库 → UI 库 → 工具库 → 内部别名(`@/`) → 相对路径 → 样式 → 类型导入
每组空一行，同类按字母序。`@/` 跨目录，相对路径不超过 3 层。

## 状态管理
- 就近原则：本地用 useState，全局用 Dva/RTK/Zustand
- 不可变性：不直接修改 state
- 不混用多种状态管理方案

## 样式
- CSS Modules 优先，camelCase 命名
- 禁止内联静态样式、!important
- 选择器嵌套 ≤ 3 层

## TypeScript
- strict 模式，禁止 `any`（用 `unknown` 替代）
- Props 用 `interface`，联合类型用 `type`
- `import type` 用于类型导入
- 禁止 `@ts-ignore`、`!` 非空断言

## 通用禁止
- var、any、@ts-ignore、class 组件
- 内联静态样式、直接修改 state
- 未使用的 import/变量、循环依赖
- 嵌套三元、console.log 遗留到生产
