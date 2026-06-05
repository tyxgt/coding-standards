<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: component
@summary: 函数组件、Props接口、Hooks规范、条件渲染、列表key、组件拆分
-->
# 前端组件编写规范

## 基本原则

1. **函数组件 + Hooks**：统一使用函数组件，不使用 class 组件
2. **单一职责**：一个组件只做一件事，做大之后拆分
3. **Props 驱动**：组件的可定制性通过 Props 暴露
4. **避免副作用泄露**：useEffect 的依赖数组必须完整

## 组件结构

### 标准组件模板

```tsx
import React, { useState, useEffect } from 'react';
import { Button, Table } from 'antd';
import styles from './index.less';

// 1. Props 类型定义（文件顶部，组件名 + Props 后缀）
interface UserTableProps {
  userId: string;
  onSelect?: (user: User) => void;
  readonly?: boolean;
}

// 2. 组件定义（函数组件 + 类型标注）
const UserTable: React.FC<UserTableProps> = ({ userId, onSelect, readonly = false }) => {
  // 3. 状态定义在最前面
  const [dataSource, setDataSource] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);

  // 4. 副作用紧随其后
  useEffect(() => {
    fetchUserData(userId);
  }, [userId]);

  // 5. 事件处理函数（handle 前缀）
  const handleRowClick = (record: User) => {
    onSelect?.(record);
  };

  // 6. 渲染辅助函数（命名以 render 前缀）
  const renderStatus = (status: number) => {
    // ...
  };

  // 7. 主渲染
  return (
    <div className={styles.container}>
      <Table
        dataSource={dataSource}
        loading={loading}
        onRow={(record) => ({
          onClick: () => handleRowClick(record),
        })}
      />
    </div>
  );
};

// 8. 默认导出
export default UserTable;
```

### Props 类型定义

```tsx
// ✅ 推荐：使用 interface（对外 API 描述性更好）
interface SearchFormProps {
  /** 表单字段配置 */
  fields: FieldConfig[];
  /** 搜索回调 */
  onSearch: (values: Record<string, any>) => void;
  /** 初始值 */
  initialValues?: Record<string, any>;
  className?: string;  // 允许外部覆盖样式
  style?: React.CSSProperties;  // 允许外部覆盖样式
}

// ✅ 当需要联合类型或工具类型时使用 type
type ModalMode = 'create' | 'edit' | 'view';

interface UserModalProps {
  mode: ModalMode;
  userId?: string;  // edit/view 时需要
  onSuccess: () => void;
}
```

## 组件导出

```tsx
// ✅ 每个组件目录一个 index.tsx，默认导出组件
export default UserTable;

// ✅ 命名导出辅助类型
export type { UserTableProps };
```

## Hooks 规范

### 自定义 Hook 命名

```tsx
// ✅ useXxx 格式
function useAuth() { ... }
function usePagination(fetchFn: FetchFunction) { ... }
function useDebounce<T>(value: T, delay: number): T { ... }
```

### Hook 编写规范

```tsx
// ✅ 明确输入输出类型
function useUserList(roleId: string): {
  users: User[];
  loading: boolean;
  error: Error | null;
  refresh: () => void;
} {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    try {
      const data = await getUserList({ roleId });
      setUsers(data);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, [roleId]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  return { users, loading, error, refresh: fetchUsers };
}
```

### useEffect 规范

```tsx
// ✅ 依赖数组完整（eslint-plugin-react-hooks 规则）
useEffect(() => {
  fetchData(id);
}, [id, fetchData]);  // 外部使用的值必须在依赖中

// ✅ 清理副作用
useEffect(() => {
  const timer = setInterval(tick, 1000);
  return () => clearInterval(timer);  // 组件卸载时清理
}, []);
```

## 条件渲染

```tsx
// ✅ 三元表达式（简单条件）
return (
  <div>
    {isLoading ? <Spin /> : <Content data={data} />}
  </div>
);

// ✅ 逻辑与（短路求值，仅渲染或不渲染）
return (
  <div>
    {hasPermission && <AdminPanel />}
    {data.length > 0 && <List data={data} />}
  </div>
);

// ❌ 避免：三元表达式嵌套过深
return isLoading ? <Spin /> : error ? <Error /> : <Content />;

// ✅ 建议：提取为变量或子组件
const renderBody = () => {
  if (isLoading) return <Spin />;
  if (error) return <Error />;
  return <Content />;
};
return <div>{renderBody()}</div>;
```

## 列表与 key

```tsx
// ✅ 使用唯一且稳定的 key
{items.map((item) => (
  <ListItem key={item.id} data={item} />
))}

// ❌ 避免使用索引作为 key（会导致渲染性能问题和状态错误）
{items.map((item, index) => (
  <ListItem key={index} data={item} />
))}
```

## 组件通信

| 场景 | 方式 |
|------|------|
| 父传子 | Props |
| 子传父 | Props + 回调函数（`onXxx`） |
| 兄弟组件 | 提升状态到共同父组件 |
| 跨层级 | Context / 全局状态管理 |
| 复杂状态联动 | Dva / Redux Toolkit / Zustand |

## 组件大小规范

| 指标 | 建议 |
|------|------|
| 单文件最大行数 | ≤ 300 行 |
| 单组件 Props 数量 | ≤ 8 个（过多考虑拆分） |
| 单组件 useEffect 数量 | ≤ 4 个（过多考虑拆分逻辑） |
| 组件分支渲染深度 | ≤ 2 层三元嵌套 |

## 组件拆分原则

当一个组件出现以下特征时，应考虑拆分：

1. **渲染内容过多**：render 函数超过 100 行
2. **状态逻辑复杂**：超过 4 个 useState + 3 个 useEffect
3. **职责模糊**：组件名中包含 "And" 或同时做两件不同的事
4. **复用需求**：某部分 UI 在 2+ 个地方被使用
