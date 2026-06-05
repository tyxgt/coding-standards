<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: typescript
@summary: strict模式、interface vs type、泛型、枚举、工具类型、事件类型
-->

# TypeScript 规范

## 核心原则

1. **strict 模式开启**：确保 `strict: true` 在 `tsconfig.json` 中
2. **类型优先**：能写类型的地方都写类型，利用 TypeScript 的类型检查能力
3. **避免 any**：尽量少用 `any`，使用更精确的类型
4. **类型导出**：公共类型定义导出，方便复用

## tsconfig.json 核心配置

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,        // 禁止隐式 any
    "strictNullChecks": true,     // 严格 null 检查
    "noUnusedLocals": true,       // 禁止未使用的局部变量
    "noUnusedParameters": true,   // 禁止未使用的参数
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

## Interface vs Type

```typescript
// ✅ Interface：用于定义对象/组件的 Props 形状（可扩展，描述性更好）
interface UserInfo {
  id: string;
  name: string;
  email: string;
  role: Role;
}

interface UserTableProps {
  dataSource: UserInfo[];
  loading?: boolean;
  onSelect?: (user: UserInfo) => void;
}

// ✅ Interface 可以合并声明（同名 interface 自动合并）
interface RequestConfig {
  url: string;
  method: 'GET' | 'POST';
}

interface RequestConfig {
  headers?: Record<string, string>;
}
// 合并后：{ url, method, headers? }

// ✅ Type：用于联合类型、交叉类型、工具类型
type Status = 'active' | 'inactive' | 'pending';
type PaginatedData<T> = { list: T[]; total: number; page: number };
type UserRole = 'admin' | 'editor' | 'viewer';
type ComponentProps = UserTableProps & { visible: boolean };

// ✅ 使用 type 定义函数签名
type FetchFunction = (params: QueryParams) => Promise<Response>;
```

**选择原则**：
- 定义 Props 用 `interface`（项目惯例，可读性好）
- 联合/交叉/泛型工具用 `type`
- 第三方库类型扩展用 `interface`（可自动合并）

## 泛型使用

```typescript
// ✅ 函数泛型
function getItemById<T extends { id: string }>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}

// ✅ 组件泛型
interface ListProps<T> {
  dataSource: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ dataSource, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <div>
      {dataSource.map((item, index) => (
        <div key={keyExtractor(item)}>{renderItem(item, index)}</div>
      ))}
    </div>
  );
}

// ✅ API 响应泛型
interface ApiResponse<T> {
  code: number;
  data: T;
  msg: string;
}

async function get<T>(url: string): Promise<T> {
  const response = await request.get<ApiResponse<T>>(url);
  return response.data;
}
```

## 枚举规范

```typescript
// ✅ 字符串枚举（推荐，值明确可读）
export enum OrderStatus {
  Pending = 'pending',
  Processing = 'processing',
  Completed = 'completed',
  Cancelled = 'cancelled',
}

// ✅ 数字枚举（当值在数据库中使用数字存储时）
export enum DataType {
  Double = 1,
  Long = 2,
  String = 3,
}

// ✅ 枚举配合映射对象（常用模式）
export const DataTypeMap: Record<DataType, string> = {
  [DataType.Double]: '浮点',
  [DataType.Long]: '整型',
  [DataType.String]: '字符串',
};

export const StatusConfig: Record<string, { color: string; text: string }> = {
  pending: { color: 'processing', text: '待处理' },
  completed: { color: 'success', text: '已完成' },
  failed: { color: 'error', text: '失败' },
};

// ✅ 使用 const enum 在编译时内联（性能更好）
const enum Direction {
  Up = 'up',
  Down = 'down',
}
```

## 工具类型使用

```typescript
// ✅ Partial：所有属性可选
function updateUser(id: string, data: Partial<UserInfo>) { ... }

// ✅ Required：所有属性必填
type CompleteProfile = Required<PartialProfile>;

// ✅ Pick：选取部分属性
type UserBasicInfo = Pick<UserInfo, 'id' | 'name'>;

// ✅ Omit：排除部分属性
type CreateUserInput = Omit<UserInfo, 'id' | 'createdAt'>;

// ✅ Record：键值映射
type RoleMap = Record<string, string[]>;

// ✅ Readonly：只读
type ImmutableUser = Readonly<UserInfo>;

// ✅ ReturnType：提取函数返回类型
type FetchResult = ReturnType<typeof fetchUserList>;
```

## 类型导入导出

```typescript
// ✅ 导出公共类型
// src/types/index.ts
export interface User { ... }
export type Status = 'active' | 'inactive';

// ✅ 组件 Props 类型跟随组件导出
// src/components/UserTable/index.tsx
export interface UserTableProps { ... }
export default UserTable;

// ✅ 使用 import type（编译时移除）
import type { User, Status } from '@/types';
import type { UserTableProps } from '@/components/UserTable';

// ✅ 相对路径引用页面内类型
import type { AlgorithmConfig } from './types';
```

## 事件类型

```tsx
// ✅ 表单事件
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  setValue(e.target.value);
};

// ✅ 点击事件
const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
  e.preventDefault();
};

// ✅ 键盘事件
const handleKeyDown = (e: React.KeyboardEvent<HTMLDivElement>) => {
  if (e.key === 'Enter') {
    handleSearch();
  }
};

// ✅ 表单提交
const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault();
};
```

## Ref 类型

```tsx
// ✅ useRef 类型标注
const inputRef = useRef<HTMLInputElement>(null);
const containerRef = useRef<HTMLDivElement>(null);

// ✅ forwardRef 组件
interface FancyInputProps {
  placeholder?: string;
}

const FancyInput = forwardRef<HTMLInputElement, FancyInputProps>(
  (props, ref) => <input ref={ref} {...props} />
);
```

## 类型安全实践

```typescript
// ✅ 避免 any，使用 unknown 替代
function safeParse(data: string): unknown {
  return JSON.parse(data);
}

// ✅ 类型守卫
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj
  );
}

// ✅ as const 字面量类型
const COLORS = ['red', 'blue', 'green'] as const;
type Color = typeof COLORS[number];  // 'red' | 'blue' | 'green'

// ✅ satisfies 操作符（TypeScript 4.9+）
const config = {
  api: 'https://api.example.com',
  timeout: 30000,
} satisfies Record<string, string | number>;
// config.api 的类型是 string 而非 string | number
```

## 禁止事项

- ❌ 使用 `any` 类型（用 `unknown` 替代）
- ❌ 使用 `@ts-ignore`（用 `@ts-expect-error` 并加注释）
- ❌ 定义未使用的类型
- ❌ 在类型中使用 `Function` 类型（应使用具体函数签名）
- ❌ 对基本类型装箱（`String`、`Number`、`Boolean`）
- ❌ 使用 `!` 非空断言（`obj!.prop`）——确保类型定义正确而非绕过检查
