<!--
@ai-rules
@version: 2.0.0
@last-updated: 2026-06-05
@category: styling
@summary: 样式方案选择、核心约束、禁止事项
-->

# 前端样式规范

## 核心原则

1. **CSS Modules 优先**：组件样式默认使用 CSS Modules，避免样式冲突
2. **约定优于配置**：遵循项目已有的样式方案，不引入新方案
3. **避免内联样式**：除动态计算的样式值外，不使用内联样式
4. **全局覆盖集中管理**：框架级样式覆盖写在全局样式文件（如 `global.less`）中

## 样式方案选择

| 项目特征 | 推荐方案 |
|----------|----------|
| Umi 2/3 项目（Less 内置） | Less + CSS Modules |
| Vite 项目 | CSS Modules 或 Tailwind CSS |
| 已有 Tailwind 的项目 | 继续使用 Tailwind |
| 已有 styled-components 项目 | 继续使用，不混用 |

## 关键约束

| 类别 | 规范 |
|------|------|
| 组件样式 | CSS Modules，camelCase 命名（`styles.container`） |
| 全局样式 | kebab-case 命名，放 `global.less` |
| 动态样式 | 使用 `style` 属性（仅动态计算值） |
| 颜色值 | 使用变量（Less 变量或 CSS 变量） |
| 选择器嵌套 | 不超过 3 层 |
| 内联样式 | 仅动态值使用，静态样式放入 CSS 文件 |
| `!important` | 禁止使用（除非覆盖第三方库） |

## 全局 vs 组件样式

```tsx
// ✅ 组件样式：使用 CSS Modules
import styles from './index.less';
<div className={styles.container} />

// ✅ 全局样式：使用字符串 className
<div className="page-container" />
```

## 禁止事项

- ❌ 使用内联样式写静态样式（`style={{ color: 'red' }}`）
- ❌ 在 JSX 中直接用 `className="xxx"` 引用非全局样式
- ❌ 使用 `!important`
- ❌ 深嵌套选择器（超过 4 层）
- ❌ 混用多种样式方案（如同时使用 CSS Modules 和 styled-components）
