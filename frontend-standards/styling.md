<!--
@ai-rules
@version: 2.0.0
@last-updated: 2026-06-05
@category: styling
@summary: 样式方案选择、核心约束、禁止事项
-->

# 前端样式规范

## 核心原则（按优先级排列）

1. **不破坏现有结构（最高优先级）**：优先采用项目已有的样式方案，不引入新方案，不改写已有代码
2. **禁止引入新框架**：无论个人偏好，项目用什么你就用什么，不因"推荐"而引入新方案
3. **本地配置优先**：项目已有 `.prettierrc`、`.eslintrc`、`tailwind.config` 等配置，以此为准
4. **禁止静态内联样式**：`style={{ }}` 中只允许引用变量（state/props/计算值），禁止写入固定值
5. **全局覆盖集中管理**：框架级样式覆盖写在全局样式文件（如 `global.less`）中

## 样式方案判断

不要推荐或引入新方案。检查项目已有配置，沿用现有方案：

| 检测到项目特征 | 应当怎么做 |
|----------------|-----------|
| 项目已有 CSS Modules（含 `*.module.less` / `*.module.css`） | 沿用 CSS Modules，使用已有 patterns |
| 项目已有 Tailwind（`tailwind.config.*`） | 使用 Tailwind class 写法 |
| 项目已有 styled-components / emotion | 沿用 styled-components |
| 项目已有 Less / Sass 变量文件 | 复用已有变量，不新增变量文件 |
| 项目使用普通 CSS（无上述配置） | 继续用普通 CSS，不引入 CSS Modules / Tailwind / 预处理器 |

## 关键约束

| 类别 | 规范 |
|------|------|
| 组件样式 | CSS Modules，camelCase 命名（`styles.container`） |
| 全局样式 | kebab-case 命名，放 `global.less` |
| 内联样式 | **禁止固定值**，只允许引用变量（`style={{ top: offsetY }}` ✅，`style={{ marginRight: 8 }}` ❌） |
| 颜色值 | 使用变量（Less 变量或 CSS 变量） |
| 选择器嵌套 | 不超过 3 层 |
| `!important` | 禁止使用（除非覆盖第三方库） |
| `:global` 使用 | 禁止顶层，必须嵌套在局部类名内（`.wrapper :global(.xxx) {}` ✅） |

## Inline 样式规则

### 允许：仅变量引用（值来自 state/props/计算）

```tsx
// ✅ 正确：引用变量（值由 state/props/计算驱动）
const [offsetY, setOffsetY] = useState(0);
<div style={{ top: offsetY }} />

// ✅ 正确：引用 props
<div style={{ width: progressBarWidth }} />

// ✅ 正确：引用响应式 hook 返回值
<div style={{ transform: `translateX(${scrollX}px)` }} />
```

### 禁止：固定值（应使用 CSS Modules）

```tsx
// ❌ 固定数值
<div style={{ marginRight: 8 }} />
<div style={{ width: 100, height: 50 }} />

// ❌ 固定字符串
<div style={{ color: 'red', fontSize: '14px' }} />

// ❌ 固定对象字面量
<div style={{ display: 'flex', alignItems: 'center' }} />
```

> 以上禁止的固定值应写入 `.module.less` 文件，通过 `styles.xxx` 引用。

## `:global` 嵌套规则

CSS Modules 中顶层使用 `:global` 会污染全局命名空间，必须嵌套在局部类名内。

```less
// ❌ 禁止：顶层 :global 污染全局
:global(.container) { color: red; }

// ❌ 禁止：顶层 :global 包裹多个选择器
:global {
  .container { color: red; }
  .header { font-size: 16px; }
}

// ✅ 正确：嵌套在局部类名内
.wrapper {
  :global(.container) { color: red; }
}

// ✅ 正确：嵌套在局部类名内（多个）
.wrapper {
  :global {
    .container { color: red; }
    .header { font-size: 16px; }
  }
}
```

## 全局 vs 组件样式

```tsx
// ✅ 组件样式：使用 CSS Modules
import styles from './index.less';
<div className={styles.container} />

// ✅ 全局样式：使用字符串 className
<div className="page-container" />
```

## 禁止事项

- ❌ 使用内联样式写静态样式（`style={{ color: 'red' }}`、`style={{ marginRight: 8 }}`）
- ❌ 在 JSX 中直接用 `className="xxx"` 引用非全局样式
- ❌ 引入项目未使用的样式方案（如 Less 项目改 CSS Modules、普通 CSS 项目引入 Tailwind）
- ❌ 改写已有样式代码（除非任务明确要求重构）
- ❌ 使用 `!important`
- ❌ 顶层使用 `:global`（`:global(.xxx) {}`），必须嵌套在局部类名内
- ❌ 深嵌套选择器（超过 4 层）
- ❌ 混用多种样式方案（如同时使用 CSS Modules 和 styled-components）
