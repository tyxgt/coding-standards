<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: lint
@summary: 变量与类型、代码格式、控制流复杂度、导入与模块、注释规范
-->

# 代码质量规则集

## 概述

本文档收录了项目约定的 ESLint 风格代码质量规则。AI 生成代码时应遵循以下规则约束，这些规则与项目本地 ESLint 配置（如有）保持一致，本地配置优先。

> 参考 [前端编码规范](index.md) 的"本地配置优先"原则：项目本地 `.eslintrc` 等配置文件的规则优先级高于本规范集。

## 规则分类

### 变量与赋值

| 规则 | 含义 | 级别 |
|------|------|------|
| `no-var` | 声明变量不要使用 `var`，尽量使用 `const` / `let` | error |
| `block-scoped-var` | 禁用 `var`，使用块级作用域变量 | error |
| `no-const-assign` | `const` 声明的变量不能被修改 | warning |
| `no-undef-init` | 不允许将变量显式初始化为 `undefined` | warning |
| `no-multi-assign` | 禁止链式赋值（如 `a = b = c`） | error |
| `no-shadow` | 外部作用域中的变量不能与内部作用域中的变量或参数同名 | error |

### 类型与运算符

| 规则 | 含义 | 级别 |
|------|------|------|
| `@typescript-eslint/no-explicit-any` | 禁用 `any` 类型 | warning |
| `eqeqeq` | 必须使用 `===` / `!==` 代替 `==` / `!=` | warning |
| `no-proto` | 禁止使用 `__proto__`，改用 `getPrototypeOf` | error |

### 代码格式

| 规则 | 含义 | 级别 |
|------|------|------|
| `indent` | 缩进 2 个空格 | error |
| `max-len` | 单行代码长度不超过 160 个字符 | error |
| `quotes` | 禁用单引号以外的引号风格 | warning |
| `comma-dangle` | 禁止使用尾逗号 | error |
| `block-spacing` | 语句之间用空格隔开 | warning |
| `func-call-spacing` | 不允许函数名和调用它的左括号之间有空格 | error |
| `no-extra-semi` | 禁止多余的分号 | error |
| `no-multiple-empty-lines` | 每个代码块之间最多两行空格 | warning |
| `no-floating-decimal` | 小数点前后不能缺少数字 | warning |
| `new-parens` | `new` 关键字调用不带参数的构造函数时需加 `()` | warning |
| `newline-per-chained-call` | 链式调用需换行 | warning |

### 控制流与复杂度

| 规则 | 含义 | 级别 |
|------|------|------|
| `complexity` | 函数内最大环路复杂度不超过 6（即条件数量不超过 6 个） | error |
| `max-nested-callbacks` | 回调函数最多嵌套 3 层 | error |
| `no-nested-ternary` | 不允许嵌套三元表达式 | error |
| `no-else-return` | `if` 语句中存在 `return` 后不需要 `else` | error |
| `no-lonely-if` | `else` 里嵌套 `if` 时使用 `else if` 合并 | error |
| `no-await-in-loop` | `for` 循环里不能有 `await`，建议使用 `Promise.all()` | warning |
| `no-continue` | 不允许使用 `continue` 语句 | warning |
| `no-fallthrough` | `switch` 语句中缺少 `break` | error |
| `no-empty` | 块语句中的内容不能为空 | warning |
| `no-empty-function` | 禁止出现空函数 | warning |

### 导入与模块

| 规则 | 含义 | 级别 |
|------|------|------|
| `no-duplicate-imports` | 合并来自同一模块的导入 | error |
| `global-require` | `require()` 语句必须位于模块顶层 | warning |

### 字符串与对象

| 规则 | 含义 | 级别 |
|------|------|------|
| `prefer-template` | 拼接字符串使用模板字符串，而不是 `+` 串联 | warning |
| `object-shorthand` | 简化对象字面值方法和属性 | warning |

### 注释

| 规则 | 含义 | 级别 |
|------|------|------|
| `multiline-comment-style` | 多行备注使用两行 `//`，不合并成 `/**/` | error |

### 其他

| 规则 | 含义 | 级别 |
|------|------|------|
| `no-unused-vars` | 没有使用的变量 | warning |
| `max-lines` | 文件行数不超过 300 行 | warning |

---

## 完整规则一览

```
@typescript-eslint/no-explicit-any  → 禁用 any 类型                          (warning)
block-scoped-var                    → 禁用 var                               (error)
block-spacing                       → 语句之间用空格隔开                      (warning)
comma-dangle                        → 禁止使用尾逗号                          (error)
complexity                          → 最大环路复杂度不超过 6                   (error)
eqeqeq                              → 使用类型相等的运算符                     (warning)
func-call-spacing                   → 函数名与左括号之间无空格                  (error)
global-require                      → require 位于模块顶层                    (warning)
indent                              → 缩进 2 格                              (error)
max-len                             → 单行代码不超过 160 字符                 (error)
max-lines                           → 文件不超过 300 行                       (warning)
max-nested-callbacks                → 回调嵌套不超过 3 层                      (error)
multiline-comment-style             → 多行注释用 //，不用 /**/                (error)
new-parens                          → new 构造函数需加 ()                     (warning)
newline-per-chained-call            → 链式调用需换行                           (warning)
no-await-in-loop                    → 循环中不使用 await                      (warning)
no-const-assign                     → const 变量不可修改                      (warning)
no-continue                         → 不允许使用 continue                     (warning)
no-duplicate-imports                → 合并同一模块的导入                       (error)
no-else-return                      → if 有 return 则不需要 else              (error)
no-empty                            → 块语句内容不能为空                       (warning)
no-empty-function                   → 禁止空函数                              (warning)
no-extra-semi                       → 禁止多余分号                            (error)
no-fallthrough                      → switch 缺少 break                       (error)
no-floating-decimal                 → 小数点前后不能缺少数字                   (warning)
no-lonely-if                        → else 嵌套 if 改用 else if               (error)
no-multi-assign                     → 禁止链式赋值                            (error)
no-multiple-empty-lines             → 代码块间最多两行空格                     (warning)
no-nested-ternary                   → 不允许嵌套三元表达式                     (error)
no-proto                            → 禁止使用 __proto__                      (error)
no-shadow                           → 禁止变量与外层作用域同名                 (error)
no-undef-init                       → 不将变量初始化为 undefined               (warning)
no-unused-vars                      → 没有使用的变量                           (warning)
no-var                              → 不使用 var                              (error)
object-shorthand                    → 简化对象字面值                           (warning)
prefer-template                     → 使用模板字符串拼接                       (warning)
quotes                              → 禁用单引号以外的引号                     (warning)
```

## 配套规范

- [代码格式规范](styling.md) — CSS/Less 样式格式约定
- [TypeScript 规范](typescript.md) — TypeScript 类型约束
- [组件编写规范](component-patterns.md) — 组件复杂度与结构约束
- [文件组织约定](file-conventions.md) — 文件大小与拆分约束
- [注释规范](comments.md) — 代码注释约定
