<!--
@ai-rules
@version: 2.0.0
@last-updated: 2026-06-05
@category: typescript
@summary: tsconfig paths配置、StatusConfig映射模式、禁止列表
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

## 禁止事项

- ❌ 使用 `any` 类型（用 `unknown` 替代）
- ❌ 使用 `@ts-ignore`（用 `@ts-expect-error` + 注释替代）
- ❌ 使用 `!` 非空断言（`obj!.prop`）
- ❌ 定义未使用的类型
- ❌ 在类型中使用 `Function` 类型（应使用具体函数签名）
- ❌ 对基本类型装箱（`String`、`Number`、`Boolean`）
