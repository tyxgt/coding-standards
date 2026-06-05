<!--
@ai-rules
@version: 2.0.0
@last-updated: 2026-06-05
@category: naming
@summary: 目录命名、文件命名规范
-->
# 前端命名规范

## 目录命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面目录 | PascalCase | `AlgorithmConfig/`、`DecisionFlows/` |
| 组件/布局/工具目录 | camelCase | `formItem/`、`leftMenu/`、`basicLayout/`、`utils/` |
| 服务/状态管理目录 | camelCase | `services/`、`models/`、`stores/` |
| 类型定义目录 | 项目已有风格 | `types/` 或 `typings/` |

**原则**：页面级目录用 PascalCase（对应路由的组件名），功能模块目录用 camelCase。

## 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面/组件入口 | `index.tsx` | `pages/AlgorithmConfig/index.tsx` |
| 样式文件 | `index.less` 或 `index.css` | 与组件同目录 |
| 类型定义 | `types.ts` | `pages/AlgorithmConfig/types.ts` |
| 常量/枚举 | `constants.ts` | `pages/AlgorithmConfig/constants.ts` |
| 工具函数 | `utils.ts` | `pages/AlgorithmConfig/utils.ts` |
| 表格列配置 | `columns.tsx` | `pages/AlgorithmConfig/columns.tsx` |
| 子页面组件 | 按组件用途命名 | `DetailModal.tsx`、`EditForm.tsx` |
| React Hook | `useXxx.ts` | `useAuth.ts`、`usePagination.ts` |
| 网络请求封装 | 按资源命名 | `userApi.ts`、`orderApi.ts` |

**原则**：
- 每个组件/页面目录下的入口文件统一为 `index.tsx`，方便导入
- 辅助文件按职责命名，不混合在一个文件中
- Hook 文件以 `use` 前缀开头
- 避免缩写，除非是广泛接受的缩写（`API`、`URL`、`ref`）

## 页面目录结构

```
pages/PageName/
├── index.tsx         # 页面入口
├── index.less        # 页面样式
├── types.ts          # 页面类型定义
├── constants.ts      # 页面常量/枚举
├── columns.tsx       # 表格列配置（如需要）
├── utils.ts          # 页面工具函数
├── components/       # 页面级私有组件
│   └── SomePart/
│       ├── index.tsx
│       └── index.less
└── hooks/            # 页面级自定义 Hooks
    └── useSomething.ts
```
