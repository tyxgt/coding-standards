# 前端编码规范 (v1.0.0)

## Naming
- 页面目录 PascalCase，组件目录 camelCase
- 文件入口 index.tsx，Hook 文件 useXxx.ts
- 变量/函数 camelCase，事件 handle 前缀，布尔 is/has/should 前缀
- 组件 PascalCase，Props 接口：组件名 + Props

## Components
- 只使用函数组件 + Hooks，不使用 class 组件
- 组件结构：Props 接口 → 组件函数 → state → effect → 事件 → 渲染
- 单文件 ≤ 300 行，Props ≤ 8 个
- 列表 key 使用唯一稳定值（不使用索引）
- 禁止嵌套三元表达式

## Imports
顺序：核心库 → UI 库 → 工具库 → 内部别名(@/) → 相对路径 → 样式 → import type
每组空一行，同类按字母序。相对路径不超过 3 层。

## State Management
- 就近原则：本地状态用 useState，全局用 Dva/RTK/Zustand
- 禁止直接修改 state（不可变性）
- 禁止在渲染函数中调用状态更新函数

## TypeScript
- strict 模式，禁止 any（用 unknown 替代）
- Props 用 interface，联合类型用 type
- import type 用于类型导入
- 禁止 @ts-ignore，使用 @ts-expect-error + 注释

## Styling
- CSS Modules 优先，camelCase 命名
- 禁止内联静态样式
- 禁止 !important
- 选择器嵌套不超过 3 层

## API Error Handling
- 请求 → 拦截器（token）→ 响应拦截器
- code === 0 → 返回数据，401 → 登录页，其他 → 错误提示
- 每个请求有对应的 loading 状态
- API 字段名必须与接口定义完全一致（大小写敏感）

## Hard Prohibitions
- ❌ 禁止使用 var、any、@ts-ignore
- ❌ 禁止 class 组件
- ❌ 禁止内联静态样式、直接修改 state
- ❌ 禁止未使用的 import 和变量
- ❌ 禁止 console.log 流入生产
- ❌ 禁止循环依赖、嵌套三元
- ❌ 本地配置优先于本规范
- ❌ 不因规范自动修改已有代码
