<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: comments
@summary: JSDoc/TSDoc规范、TODO/FIXME/HACK管理、复杂逻辑注释、JSX注释
-->

# 前端注释规范

## 核心原则

注释的质量不在于"写了多少"，而在于"读的人是否获得了无法从代码中直接读到的信息"。

| 原则 | 说明 |
|------|------|
| **自解释优先** | 好的命名 > 坏注释。先通过命名让代码自解释，注释只补充剩余信息 |
| **解释 Why，非 What** | 注释的价值在于解释"为什么这么写"（业务约束、性能考量、特殊场景），而非"这段代码在做什么" |
| **随代码维护** | 注释是代码的一部分，修改代码时必须同步更新相关注释。过时的注释比没有注释更糟 |
| **宁缺毋滥** | 不确定是否有用的注释就不写。冗余注释会稀释真正有价值注释的可信度 |

> 参考 [命名规范](naming-conventions.md) 的"自解释"原则：**命名应能反映其用途，不需要额外注释**。

---

## JSDoc / TSDoc 注释

### Props 接口注释（必须）

Props 接口中的每个属性都应使用 `/** */` 注释说明用途：

```tsx
// ✅ 推荐：Props 属性全部标注 JSDoc
interface SearchFormProps {
  /** 表单字段配置 */
  fields: FieldConfig[];
  /** 搜索回调，返回搜索条件 */
  onSearch: (values: Record<string, any>) => void;
  /** 初始值 */
  initialValues?: Record<string, any>;
  className?: string;     // 自解释的可选 Props 可仅用行尾注释
}

// ❌ 避免：Props 属性缺少说明
interface SearchFormProps {
  fields: FieldConfig[];        // ❌ 什么字段？什么格式？
  onSearch: (values: any) => void;  // ❌ 参数类型、回调时机不清楚
}
```

### 公共工具函数注释（推荐）

```typescript
// ✅ 推荐：公共函数标注用途和参数
/**
 * 格式化文件大小
 * @param bytes - 文件字节数
 * @param decimals - 保留小数位数，默认 2
 * @returns 格式化后的字符串，如 "1.5 MB"
 */
function formatFileSize(bytes: number, decimals: number = 2): string {
  // ...
}
```

### 内部函数注释（无需 JSDoc）

```typescript
// ✅ 推荐：内部函数用行内注释或自然命名即可
function getStatusColor(status: OrderStatus): string {
  // 直接通过函数名和代码自解释，不需要额外的 JSDoc
}

// ❌ 避免：对内部简单函数写无用 JSDoc
/**
 * 格式化日期  // ❌ 函数名已经说清楚了
 * @param date  // ❌ 参数名已经说清楚了
 */
function formatDate(date: Date): string { ... }
```

### 何时必须写 / 何时不需要

| 场景 | JSDoc 要求 | 示例 |
|------|-----------|------|
| Props 接口属性 | **必须写** | `/** 表格数据源 */ dataSource: T[]` |
| 公共工具函数/API | **推荐写** | `@param`, `@returns` 标注 |
| 内部函数 | 不需要 | 命名自解释即可 |
| 单文件私有函数 | 不需要 | 仅在当前文件使用 |
| React Hook | 推荐写返回值说明 | `@returns { users, loading, refresh }` |
| 事件处理函数 | 不需要 | `handleSubmit`, `handleClick` 已自解释 |
| mock 数据/临时数据 | 不需要 | 代码即文档 |

---

## 文件头注释

### 何时需要

- 独立的工具函数模块（`utils.ts`）
- 复杂的状态管理模块（`models/`、`stores/`）
- 通用的配置文件（`config.ts`、`constants.ts`）
- 包含特殊业务逻辑的文件

### 格式

```typescript
/**
 * 用户管理相关 API
 * 提供用户列表查询、创建、更新、删除接口
 */
```

```typescript
/**
 * 订单状态枚举和状态映射工具
 * 包含状态流转规则和展示配置
 */
```

### 不需要文件头注释的场景

```typescript
// ✅ 标准的页面组件无需文件头注释，组件名已说明用途
// pages/UserList/index.tsx
const UserListPage: React.FC = () => { ... };

// ❌ 避免：为每个文件都加头注释（变成噪音）
/**
 * UserList 页面组件  // ❌ 文件名和组件名已说清楚
 */
```

---

## 复杂逻辑注释

### 算法 / 复杂计算

```typescript
// ✅ 推荐：解释算法的思路和来源
// 使用滚动哈希（Rabin-Karp 算法）进行模糊匹配
// 在数据量 > 1000 时性能优于逐项对比
function fuzzySearch(text: string, pattern: string): number[] {
  // ...
}

// ❌ 避免：逐行翻译代码
// 设置总数为 0
let total = 0;
// 循环遍历数组
for (let i = 0; i < list.length; i++) {
  // 累加数量
  total += list[i].count;
}
```

### 边缘情况 / Hack

```typescript
// ✅ 推荐：解释为什么需要特殊处理
// 后端在数据为空时返回 `null`，而文档约定返回 `[]`
// 需要做一层防御处理，等后端修掉后可以移除（TODO: 2025-Q2）
const safeList = rawList ?? [];

// 使用 requestAnimationFrame 延迟执行以确保 DOM 已更新
// Ant Design Table 在 setState 后不会立即重新渲染
requestAnimationFrame(() => {
  tableRef.current?.scrollTo({ index: 0 });
});
```

### 类型断言 / 类型转换

```typescript
// ✅ 推荐：说明类型断言的原因
// API 返回的 status 虽然是字符串，但值只可能是 OrderStatus 枚举成员
const status = rawData.status as OrderStatus;

// 从 JSON.parse 解析的结果，经运行时校验确认符合 User 结构
const user = parsedData as User;  // 前面已用 isUser() 守卫校验
```

---

## TODO / FIXME / HACK 注释规范

### 统一格式

使用标记前缀 + 责任人/日期/原因，便于追踪和检索：

```typescript
// TODO: [责任人] 日期 - 原因
// FIXME: [责任人] 日期 - 原因
// HACK: [责任人] 日期 - 原因
```

```typescript
// ✅ 推荐：附带上下文信息
// TODO: @zhangsan 2025-06 - 接口上线后替换为真实 API
// const response = await realApi(params);
const mockData = getMockData();

// FIXME: @lisi 2025-05 - 当用户名为空时点击保存会崩溃，需修复 validate 逻辑
// 临时加了空值判断，后续需要统一处理表单验证
if (!username) return;

// HACK: @wangwu 2025-04 - Ant Design Select 在 dataSource 为空时不会触发 onChange
// 手动触发一次 onChange 以确保父组件状态同步
```

### 上线前检查

```typescript
// ❌ 禁止：没有过期检查的 TODO 流入生产环境
// TODO: 以后优化
// FIXME: 这里有点问题
// HACK: 临时方案
```

---

## React JSX 注释

JSX 中使用 `{/* */}` 语法：

```tsx
// ✅ 推荐：解释复杂条件渲染的原因
return (
  <div>
    {/* 仅管理员可见的操作面板 */}
    {isAdmin && <AdminPanel />}

    {/* 无数据时展示空状态 */}
    {list.length === 0 ? (
      <Empty description="暂无数据" />
    ) : (
      <Table dataSource={list} columns={columns} />
    )}
  </div>
);
```

```tsx
// ❌ 避免：JSX 中使用 // 注释（会渲染到页面）
return (
  <div>
    // 用户列表
    <UserTable />
  </div>
);
```

---

## 禁止的注释

| 禁止类型 | 错误示例 | 正确做法 |
|---------|---------|---------|
| **逐行翻译代码** | `// 遍历列表` + for 循环 | 让代码自解释，或优化命名 |
| **已注释掉的代码** | 保留整块注释掉的旧代码 | 使用版本控制（Git），删除无用代码 |
| **明显废话** | `// 定义一个变量` + `const a = 1` | 不写 |
| **过期 TODO** | `// TODO: 以后优化`（无责任人/时间） | 明确责任和期限，否则不写 |
| **无意义注释** | `// 这里比较重要`（不说明为什么重要） | 说明具体的注意事项 |
| **信息不对等** | `// 处理特殊数据`（什么特殊？） | 说明触发条件或约束 |

---

## 注释速查表

| 注释类型 | 格式 | 是否推荐 | 适用场景 |
|---------|------|---------|---------|
| Props 属性文档 | `/** 说明 */` | **必须** | Props interface 每个属性 |
| 公共函数文档 | `/** @param @returns */` | 推荐 | 独立工具函数、API 方法 |
| 文件头注释 | `/** 模块说明 */` | 按需 | 复杂模块、工具函数集 |
| 行尾注释 | `// 说明` | 推荐 | 简单说明、边缘情况、TODO |
| 多行逻辑注释 | `/* 说明 */` 或 `// 行1\n// 行2` | 推荐 | 复杂算法、业务逻辑 |
| TODO | `// TODO: @人 日期 - 原因` | **必须** | 需后续完成的工作 |
| FIXME | `// FIXME: @人 日期 - 原因` | **必须** | 已知问题，需修复 |
| HACK | `// HACK: @人 日期 - 原因` | **必须** | 临时方案，说明原因 |
| JSX 注释 | `{/* 说明 */}` | 推荐 | JSX 中复杂渲染说明 |
| `@ts-expect-error` 说明 | `// 原因: xxx` | **必须** | 见 [TypeScript 规范](typescript.md) |

---

## 配套规范

- [命名规范](naming-conventions.md) — 优先通过命名自解释，减少注释依赖
- [TypeScript 规范](typescript.md) — `@ts-expect-error` 必须附带注释说明
- [组件编写规范](component-patterns.md) — Props 接口注释写法示例
