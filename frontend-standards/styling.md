<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: styling
@summary: CSS Modules优先、Less规范、全局样式、CSS变量、响应式规范
-->

# 前端样式规范

## 核心原则

1. **CSS Modules 优先**：组件样式默认使用 CSS Modules，避免样式冲突
2. **约定优于配置**：遵循项目已有的样式方案
3. **避免内联样式**：除动态计算的样式值外，不使用内联样式
4. **全局覆盖集中管理**：框架级样式覆盖写在全局样式文件中

## 样式方案选择

| 项目特征 | 推荐方案 |
|----------|----------|
| Umi 2/3 项目（Less 内置） | Less + CSS Modules |
| Vite 项目 | CSS Modules 或 Tailwind CSS |
| 已有 Tailwind 的项目 | 继续使用 Tailwind |
| 已有 styled-components 项目 | 继续使用，不混用 |

**原则**：跟随项目的现有方案，不引入新的样式方案。

## CSS Modules 规范

### 命名约定

```less
// 组件样式文件：index.less（CSS Modules 模式）

// ✅ 使用 camelCase 命名（JS 中引用更方便）
.container { }
.formItem { }
.headerWrapper { }
.actionButton { }

// ✅ 嵌套表示子元素
.card {
  &-header { }  // JS 中使用 styles['card-header']
  &-body { }    // JS 中使用 styles['card-body']
}

// ✅ 使用 composes 复用样式
.baseButton {
  padding: 8px 16px;
  border-radius: 4px;
}

.primaryButton {
  composes: baseButton;
  background-color: #1890ff;
  color: #fff;
}
```

### 在组件中使用

```tsx
// ✅ 标准用法
import styles from './index.less';

const MyComponent: React.FC = () => (
  <div className={styles.container}>
    <div className={styles.formItem}>
      <span className={styles.label}>名称:</span>
    </div>
    <Button className={styles.actionButton}>提交</Button>
  </div>
);
```

### 多 class 拼接

```tsx
// ✅ 使用 classnames 库（推荐）
import classNames from 'classnames';

<div className={classNames(styles.baseButton, {
  [styles.primary]: type === 'primary',
  [styles.disabled]: disabled,
})} />

// ✅ 模板字符串拼接（简单场景）
<div className={`${styles.footer} ${isFixed ? styles.fixed : ''}`} />
```

## 全局样式规范

### 全局样式文件

```less
// src/global.less
// 用于覆盖框架默认样式和定义全局通用样式

// ✅ 全局样式使用 kebab-case（非 CSS Modules 不受前缀影响）
.page-container {
  padding: 24px;
}

.global-header {
  height: 48px;
  background: #fff;
}

// ✅ 覆盖 Ant Design 默认样式
.ant-table {
  &.custom-table {
    .ant-table-thead > tr > th {
      background: #fafafa;
    }
  }
}
```

### 全局样式使用场景

```tsx
// ✅ 全局样式：使用字符串 className（不加 styles. 前缀）
<div className="page-container">
  <Table className="custom-table" />
</div>

// ❌ 避免在全局样式文件中定义组件专属样式
// 组件专属样式应放在组件的 CSS Modules 文件中
```

## Less 规范（如项目使用 Less）

```less
// ✅ 使用变量
@primary-color: #1890ff;
@border-color: #e8e8e8;
@font-size-base: 14px;
@spacing-base: 16px;

.container {
  color: @primary-color;
  border: 1px solid @border-color;
  font-size: @font-size-base;
  padding: @spacing-base;
}

// ✅ 使用嵌套（不超过 3 层）
.card {
  &-header {
    font-weight: bold;

    .title {
      font-size: 16px;
    }
  }

  &-body {
    padding: 16px;
  }
}

// ✅ 使用 mixin 复用
.flex-center() {
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-wrapper {
  .flex-center();
}
```

## CSS 变量规范（不使用 Less 的项目）

```css
/* ✅ 使用 CSS 自定义属性 */
:root {
  --primary-color: #1890ff;
  --border-radius: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
}

.container {
  color: var(--primary-color);
  padding: var(--spacing-md);
  border-radius: var(--border-radius);
}
```

## 响应式规范

```less
// ✅ 在样式文件中使用媒体查询
.responsive-container {
  display: grid;
  grid-template-columns: repeat(4, 1fr);

  @media (max-width: 1200px) {
    grid-template-columns: repeat(3, 1fr);
  }

  @media (max-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
  }
}

// ❌ 避免在 JS 中直接监听窗口大小（除非必要）
// 优先使用 CSS 媒体查询
```

## 样式规范速查

| 类别 | 规范 |
|------|------|
| 组件样式 | CSS Modules，camelCase 命名 |
| 全局样式 | kebab-case 命名，放 global.less |
| 动态样式 | 使用 style 属性（仅动态计算值） |
| 颜色值 | 使用变量（Less 变量或 CSS 变量） |
| 选择器嵌套 | 不超过 3 层 |
| 内联样式 | 仅动态值使用，静态样式放入 CSS 文件 |
| !important | 禁止使用（除非覆盖第三方库） |
| 单位 | 使用 px 或 rem（跟随项目） |

## 禁止事项

- ❌ 使用内联样式写静态样式（`style={{ color: 'red' }}`）
- ❌ 在 JSX 中直接用 `className="xxx"` 引用非全局样式
- ❌ 使用 `!important`
- ❌ 深嵌套选择器（超过 4 层）
- ❌ 混用多种样式方案（如同时使用 CSS Modules 和 styled-components）
