<!--
@coding-standards
@version: 2.0.0
@last-updated: 2026-06-05
@category: component
@summary: 组件大小限制、导出约定、拆分原则、注释规范
@trigger:
  - 创建新的 React 组件
  - 修改组件结构或 Props
  - 决定组件是否需要拆分
-->
# 前端组件编写规范

## 组件设计原则

| 原则 | 说明 |
|------|------|
| **单一职责** | 一个组件只做一件事，职责模糊时考虑拆分 |
| **函数组件优先** | 优先使用函数组件 + Hooks，避免类组件（除非特殊 legacy 需求） |
| **容器 vs 展示分离** | 容器组件负责数据获取和逻辑，展示组件纯渲染 UI |
| **条件渲染简洁** | 不使用复杂三元/嵌套，优先提前 return 或使用 `&&` |

```tsx
// ✅ 容器组件：负责数据和逻辑
function UserListContainer() {
  const { data, isLoading, error } = useQuery(...);
  return <UserList users={data} loading={isLoading} error={error} />;
}

// ✅ 展示组件：纯渲染 UI
function UserList({ users, loading, error }: UserListProps) {
  if (loading) return <Skeleton />;
  if (error) return <ErrorPage />;
  if (!users?.length) return <Empty />;
  return <Table dataSource={users} />;
}
```

## 组件结构顺序

组件内部按以下顺序排列，用空行分隔逻辑块：

1. Props 类型定义（文件顶部）
2. 组件函数定义 + 类型标注
3. useState / useReducer 状态
4. useEffect 副作用
5. useCallback / 事件处理函数
6. 渲染辅助函数（`render` 前缀）
7. 主渲染 return

## 导出约定

- **默认导出**组件本身
- **命名导出**辅助类型（Props 类型、关联类型）

```tsx
export interface UserTableProps { ... }
export type { UserTableProps };    // 命名导出类型
export default UserTable;          // 默认导出组件
```

## 组件大小限制

| 指标 | 建议 |
|------|------|
| 单文件最大行数 | ≤ 300 行 |
| 单组件 Props 数量 | ≤ 8 个（过多考虑拆分） |
| 单组件 useEffect 数量 | ≤ 4 个（过多考虑拆分逻辑） |
| 条件渲染深度 | ≤ 2 层三元嵌套（提取为变量或子组件） |

## 组件拆分原则

当一个组件出现以下特征时，应考虑拆分：

1. **渲染内容过多**：render 部分超过 100 行
2. **状态逻辑复杂**：超过 4 个 useState + 3 个 useEffect
3. **职责模糊**：组件名中包含 "And" 或同时做两件不同的事
4. **复用需求**：某部分 UI 在 2+ 个地方被使用

## 注释规范

### TODO / FIXME / HACK 格式

统一使用标记前缀 + 责任人/日期/原因，便于追踪和检索：

```typescript
// TODO: @zhangsan 2025-06 - 接口上线后替换为真实 API
// FIXME: @lisi 2025-05 - 当用户名为空时点击保存会崩溃
// HACK: @wangwu 2025-04 - Ant Design Select 在 dataSource 为空时不会触发 onChange
```

### JSX 注释

JSX 中使用 `{/* */}` 语法，不使用 `//`（会渲染到页面）。

### @ts-expect-error 注释

使用 `@ts-expect-error` 时必须附带注释说明原因：

```typescript
// @ts-expect-error: 该类型来自后端 API，运行时保证存在该字段
```

## 组件拆分决策树

```
组件是否需要拆分？
│
├── 渲染内容 > 100 行？
│   └── 是 → 拆分为容器组件 + 展示组件
│
├── useState > 4 个 或 useEffect > 3 个？
│   └── 是 → 将相关状态和逻辑拆分为自定义 Hook 或子组件
│
├── 职责是否模糊（组件名含 "And"）？
│   └── 是 → 拆分为多个单一职责组件
│
├── 某部分 UI 在 2+ 地方复用？
│   └── 是 → 拆分为可复用组件
│
└── Props > 8 个？
    └── 是 → 考虑拆分Props（将相关props提取为对象或拆分组件）
```

## 好/坏代码对比

### 1. Props 传递层级过深

```tsx
// ❌ 不好：Props 逐级传递（Prop Drilling）
function App() {
  const [user, setUser] = useState(...);
  return <Layout user={user} onUpdateUser={setUser} />;
}
function Layout({ user, onUpdateUser }) {
  return <Sidebar user={user} onUpdateUser={onUpdateUser} />;
}
function Sidebar({ user, onUpdateUser }) {
  return <UserProfile user={user} onUpdateUser={onUpdateUser} />;
}

// ✅ 好：使用 Context 或状态管理
const UserContext = createContext(...);
function App() {
  return <UserProvider><Layout /></UserProvider></UserProvider>;
}
```

### 2. 条件渲染嵌套过深

```tsx
// ❌ 不好：嵌套三元表达式
return (
  <div>
    {user ? (user.isActive ? <ActiveUser user={user} /> : <InactiveUser />) : <Loading />}
  </div>
);

// ✅ 好：提前 return 或使用逻辑运算符
if (!user) return <Loading />;
if (!user.isActive) return <InactiveUser />;
return <ActiveUser user={user} />;
```

### 3. 副作用未清理

```tsx
// ❌ 不好：useEffect 未清理副作用
useEffect(() => {
  const timer = setInterval(() => fetchData(), 5000);
  // 缺少 return cleanup
}, []);

// ✅ 好：useEffect 返回清理函数
useEffect(() => {
  const timer = setInterval(() => fetchData(), 5000);
  return () => clearInterval(timer);
}, []);
```
