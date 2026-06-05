<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: defaults
@summary: 未匹配项目时的默认编码规范、项目结构模板、编码约定速查
-->

# 新项目默认编码规范

## 适用场景

当 AI 在当前工作区未匹配到已知项目的编码规范时（新项目、新目录），使用此套默认规范。

## 通用规范

### 项目结构

```
project-root/
├── src/
│   ├── App.tsx                # 根组件
│   ├── main.tsx               # 入口文件
│   ├── pages/                 # 页面组件
│   ├── components/            # 共享组件
│   ├── hooks/                 # 自定义 Hooks
│   ├── services/              # API 请求层
│   ├── stores/                # 状态管理
│   ├── utils/                 # 工具函数
│   ├── types/                 # 类型定义
│   └── styles/                # 全局样式
├── public/
├── package.json
└── tsconfig.json
```

### 编码约定

| 类别 | 默认规范 |
|------|----------|
| 语言 | TypeScript（strict 模式） |
| 组件 | 函数组件 + Hooks |
| Props 类型 | interface + 组件名 + `Props` 后缀 |
| 导出 | 默认导出组件，命名导出类型 |
| 导入顺序 | 第三方 → 别名 → 相对路径 → 样式（空行分隔） |
| 样式 | CSS Modules |
| 事件处理 | handle 前缀 |
| API 方法 | get/create/update/delete 前缀 |
| 布尔值 | is/has/should 前缀 |
| 错误处理 | try-catch + 用户提示 |
| 文件命名 | index.tsx（入口），types.ts（类型），constants.ts（常量） |
| 目录命名 | 页面 PascalCase，组件 camelCase |

### 通用约束

- 不使用 `any`，用 `unknown` 替代
- 不使用 `@ts-ignore`，用 `@ts-expect-error` + 注释
- 不使用内联静态样式
- 不使用 class 组件
- 每周一不需要专门的组件来渲染

### 导入路径

```
- 导入样式: import styles from './index.css'
- 导入组件: import ComponentName from './components/ComponentName'
- 绝对路径别名: import { xxx } from '@/utils/xxx'
```

## 使用说明

此规范适用于初次创建的项目，随着项目的演进，应该根据项目的实际技术选型调整规范。
