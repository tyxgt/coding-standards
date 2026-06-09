<!--
@coding-standards
@version: 2.0.0
@last-updated: 2026-06-05
@category: file-organization
@summary: 目录结构、文件拆分决策、组件/文件位置原则
@trigger:
  - 设计项目目录结构
  - 拆分或合并文件
  - 决定文件放置位置
-->

# 前端文件组织规范

## 核心原则

1. **按功能/领域组织**，而非按文件类型——将相关的组件、样式、类型放在一起
2. **一个文件一个职责**——文件与其导出的主要内容同名
3. **就近放置**——相关的类型、常量、工具函数放在使用处附近
4. **适时提取**——当内容在 2+ 个地方使用时，提取到共享位置
5. **避免深度嵌套**——目录层级不超过 4 层
6. **页面即目录**——每个页面是一个目录，入口为 `index.tsx`

## 典型目录结构

```
src/
├── pages/                     # 页面组件（与路由一一对应）
│   ├── index.tsx              # 首页
│   ├── Login/
│   │   ├── index.tsx
│   │   ├── index.less
│   │   └── types.ts
│   └── AlgorithmConfig/
│       ├── index.tsx
│       ├── index.less
│       ├── types.ts
│       ├── constants.ts
│       ├── columns.tsx
│       ├── utils.ts
│       ├── components/        # 页面私有组件
│       │   └── ConfigForm/
│       │       ├── index.tsx
│       │       └── index.less
│       └── hooks/             # 页面私有 Hook
│           └── useConfigData.ts
├── components/                # 全局共享组件
├── layouts/                   # 布局组件
├── models/ 或 stores/         # 全局状态管理
├── services/
│   ├── request.ts             # 请求封装
│   └── api/                   # 按模块的 API 定义
├── utils/                     # 全局工具函数
├── hooks/                     # 全局自定义 Hooks
├── types/                     # 全局类型定义
├── constants/                 # 全局常量
└── config/                    # 项目配置
```

## 文件拆分决策

```
文件超过 300 行？────────是──→ 拆分
│
组件含多个不相关逻辑？──是──→ 拆分
│
类型定义超过 50 行？────是──→ 提取到 types.ts
│
常量/枚举超过 20 行？───是──→ 提取到 constants.ts
│
工具函数在 2+ 地方使用？─是──→ 提取到 utils.ts
│
以上都不是 ──────────────→ 不需要拆分
```

## 目录位置决策

| 场景 | 推荐位置 |
|------|----------|
| 仅在单个页面使用的组件 | `pages/PageName/components/` |
| 2+ 页面使用的组件 | `src/components/` |
| 全局共享的类型 | `src/types/` |
| 页面内使用的类型 | `pages/PageName/types.ts` |
| 全站常量 | `src/constants/` |
| 页面内常量 | `pages/PageName/constants.ts` |
| 全局工具函数 | `src/utils/` |
| 页面内工具函数 | `pages/PageName/utils.ts` |

提取到共享位置的原则：页面专有 → 被 2+ 页面使用 → 全局共享 → 与业务无关可提取为 npm 包。
