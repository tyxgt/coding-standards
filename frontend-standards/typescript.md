<!--
@coding-standards
@version: 2.0.0
@last-updated: 2026-06-05
@category: typescript
@summary: tsconfig paths配置、StatusConfig映射模式、禁止列表
@trigger:
  - 编写 interface 或 type 定义
  - 使用泛型或类型断言
  - 配置 TypeScript 类型检查
-->

# TypeScript 规范

## tsconfig.json 路径别名

```json
{
  "compilerOptions": {
    "strict": true,
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

`@/*` 为项目约定别名，映射到 `src/` 目录。

## 枚举 + 配置映射模式

配合枚举定义展示配置（状态/类型 → 文本/颜色映射），统一放在组件或模块的 `constants.ts` 中：

```typescript
export enum OrderStatus {
  Pending = 'pending',
  Processing = 'processing',
  Completed = 'completed',
  Cancelled = 'cancelled',
}

export const StatusConfig: Record<string, { color: string; text: string }> = {
  pending: { color: 'processing', text: '待处理' },
  completed: { color: 'success', text: '已完成' },
  failed: { color: 'error', text: '失败' },
};
```

## 类型使用原则

### 避免 any

尽量避免使用 `any`。优先使用具体类型、泛型约束或 `unknown`：

```typescript
// ✅ 正确
function process<T>(data: T): T { ... }
function handleError(error: unknown) { ... }

// ❌ 避免
function process(data: any): any { ... }
```

### 返回类型标注

不强制要求每个函数都显式标注返回类型（可依靠类型推断），但**公开导出的函数**建议标注：

```typescript
// ✅ 导出函数建议标注返回类型
export function getUserList(params: QueryParams): Promise<User[]> {
  return request.get('/user/list', { params });
}

// ✅ 内部函数可依赖推断
function formatDate(date: Date) {
  return date.toISOString().split('T')[0];
}
```

### const 断言

使用 `const` 断言明确字面量类型时，优先使用 `as const`：

```typescript
// ✅ 正确
const STATUS_MAP = {
  active: '启用',
  inactive: '禁用',
} as const;

type StatusKey = keyof typeof STATUS_MAP; // 'active' | 'inactive'
```

### 非空断言

非空断言 `!` 谨慎使用，仅在确定值不为 `null`/`undefined` 时使用：

```typescript
// 谨慎使用，确保运行时一定存在该值
const element = document.getElementById('root')!;
```

### require 导入

允许使用 `require` 导入（如配置文件、脚本等场景）：

```typescript
// ✅ 允许
const pkg = require('./package.json');
const config = require('config');
```

## 禁止事项

- ❌ 使用 `any` 类型（用 `unknown` 替代）
- ❌ 使用 `@ts-ignore`（用 `@ts-expect-error` + 注释替代）
- ❌ 滥用 `!` 非空断言（`obj!.prop`）
- ❌ 定义未使用的类型
- ❌ 在类型中使用 `Function` 类型（应使用具体函数签名）
- ❌ 对基本类型装箱（`String`、`Number`、`Boolean`）
