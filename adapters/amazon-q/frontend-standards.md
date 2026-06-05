# 前端编码规范 (v2.0.0)

## Naming
- 页面目录 PascalCase，组件目录 camelCase
- 文件入口 index.tsx，Hook 文件 useXxx.ts

## Components
- 单文件 ≤ 300 行，Props ≤ 8 个
- 默认导出组件，命名导出类型
- 结构：Props 类型 → state → effect → 事件 → 渲染

## Imports
顺序：核心库 → UI 库 → 工具库 → @/ 别名 → 相对路径 → 样式 → import type
每组空一行，@/ 跨目录，相对路径 ≤ 3 层。

## State Management
- 本地用 useState，全局用 Dva/RTK/Zustand
- 禁止直接修改 state，不混用方案

## TypeScript
- Props 用 interface，联合类型用 type
- 禁止 @ts-ignore（用 @ts-expect-error + 注释）
- 禁止 ! 非空断言、Function 类型、any

## Styling
- CSS Modules 优先，camelCase 命名
- Umi → Less + CSS Modules，Vite → CSS Modules/Tailwind
- 禁止内联静态样式、!important，嵌套 ≤ 3 层

## API
- 统一请求实例 + 拦截器
- code === 0 → data，401 → 登录页
- 字段名必须与接口定义完全一致（大小写敏感）

## Prohibitions
- ❌ 禁止 any、@ts-ignore、class 组件
- ❌ 禁止内联静态样式、直接修改 state
- ❌ 禁止 console.log 流入生产、循环依赖
- ❌ 本地配置优先，不修改已有代码
