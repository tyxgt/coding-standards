<!--
@coding-standards
@version: 2.0.0
@last-updated: 2026-06-08
@category: react-jsx
@summary: React 组件、JSX 格式、Hooks 规则、条件渲染
@trigger:
  - 编写 JSX 代码
  - 使用 useState/useEffect 等 Hooks
  - 实现条件渲染或列表渲染
-->

# React & JSX 规范

## 组件设计原则

| 原则 | 说明 |
|------|------|
| 单一职责 | 一个组件只做一件事 |
| 组件形式 | 优先使用函数组件 + Hooks，避免类组件（除非特殊 legacy 需求） |
| 容器 vs 展示 | 容器组件负责数据获取和逻辑，展示组件纯渲染 UI |
| 条件渲染 | 不使用复杂的三元/嵌套，可提前 return 或使用 `&&` |

```tsx
// ✅ 正确：提前 return 简化条件渲染
function Dashboard() {
  const { data, isLoading, error } = useDashboardData();

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorPage error={error} />;
  if (!data) return <Empty />;

  return <DashboardView data={data} />;
}

// ✅ 容器组件
function UserPageContainer() {
  const { data, isLoading } = useQuery(...);
  return <UserPage users={data} loading={isLoading} />;
}

// ✅ 展示组件
function UserPage({ users, loading }: UserPageProps) {
  return <Table dataSource={users} loading={loading} />;
}
```

## JSX 格式

| 规则 | 要求 |
|------|------|
| 缩进 | 2 个空格，属性换行时同样缩进 2 格 |
| 花括号空格 | 内侧不留空格：`{value}` 而非 `{ value }` |
| 自闭合 | 没有子元素的标签必须自闭合：`<Component />` |
| 多行 JSX | 使用括号包裹，增强可读性 |
| 组件命名 | PascalCase |

```tsx
// ✅ 正确
function Welcome() {
  return (
    <div className={styles.container}>
      <UserProfile name={userName} onUpdate={handleUpdate} />
    </div>
  );
}

// ✅ 多行属性换行
<UserProfile
  name={userName}
  age={userAge}
  onUpdate={handleUpdate}
  onDelete={handleDelete}
/>

// ❌ 错误
<Component name={ name }/>    // 花括号内侧空格
<Component name="text"></Component>  // 应自闭合
```

## React 17+ 新 JSX 转换

React 17+ 项目中，无需在组件文件顶部手动 `import React`，除非使用了 React 的其他 API（如 `useState`、`useEffect` 等仍需按需导入）：

```tsx
// ✅ React 17+，无需 import React
import { useState, useEffect } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

## Hooks 规则

| 规则 | 说明 |
|------|------|
| 顶层调用 | 只在函数组件或自定义 Hook 的顶层调用 Hooks |
| 禁止条件调用 | 不要在循环、条件或嵌套函数中使用 Hooks |
| 依赖完整性 | `useEffect`/`useMemo`/`useCallback` 的依赖数组要完整 |
| eslint 警告 | 收到依赖警告时应修正，而不是随意禁用检查 |

```typescript
// ✅ 正确：顶层调用
function SearchBox({ query }: Props) {
  const [debouncedQuery, setDebouncedQuery] = useState(query);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(query), 300);
    return () => clearTimeout(timer);
  }, [query]);  // 依赖完整

  return <input value={query} onChange={...} />;
}

// ❌ 错误：条件中使用 Hook
function BadComponent({ flag }: { flag: boolean }) {
  if (flag) {
    const [data, setData] = useState(null); // 禁止
  }
}
```

## prop-types

不使用 `prop-types`，类型检查交给 TypeScript：

```tsx
// ✅ 正确：TypeScript 类型
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return <button className={styles[variant]} onClick={onClick}>{label}</button>;
}

// ❌ 避免
// Button.propTypes = { label: PropTypes.string.isRequired };
```

## 组件文件结构

```
UserProfile.tsx
├── import 语句
├── Props 接口定义（文件顶部）
├── 组件函数定义
├── useState / useReducer 状态
├── useEffect 副作用
├── useCallback / 事件处理函数
├── 辅助渲染函数（可选）
└── 主渲染 return
```
