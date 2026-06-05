<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: naming
@summary: 目录命名、文件命名、JS/TS变量/函数命名、样式命名规范
-->
# 前端命名规范

## 目录命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面目录 | PascalCase | `AlgorithmConfig/`、`DecisionFlows/` |
| 组件目录 | camelCase | `formItem/`、`leftMenu/`、`header/` |
| 布局目录 | camelCase | `basicLayout/`、`sidebar/` |
| 工具/工具函数 | camelCase | `utils/`、`helpers/` |
| 服务/API 层 | camelCase | `services/`、`api/` |
| 状态管理 | camelCase | `models/`、`stores/`、`slices/` |
| 类型定义 | 项目已有风格 | `types/` 或 `typings/` |

**原则**：页面级目录用 PascalCase（对应路由的组件名），功能模块目录用 camelCase。

## 文件命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 页面入口 | `index.tsx` | `pages/AlgorithmConfig/index.tsx` |
| 组件入口 | `index.tsx` | `components/formItem/index.tsx` |
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

## JavaScript/TypeScript 命名

| 类型 | 规范 | 示例 |
|------|------|------|
| 变量 | camelCase | `userList`、`formData`、`tableColumns` |
| 常量 | camelCase 或 UPPER_SNAKE | `pageSize`、`MAX_COUNT`（纯数字常量用大写） |
| 布尔值 | `is`/`has`/`should`/`can` 前缀 | `isVisible`、`hasPermission`、`shouldRender` |
| 函数 | camelCase，动词开头 | `fetchData()`、`handleSubmit()`、`validateForm()` |
| 事件处理 | `handle` 前缀 | `handleClick`、`handleSearch`、`handlePageChange` |
| 组件 | PascalCase | `UserTable`、`PermissionTree`、`SearchForm` |
| Props 接口 | 组件名 + `Props` | `UserTableProps`、`SearchFormProps` |
| 状态类型 | 组件名 + `State` | `DashboardState`、`FormState` |
| API 方法 | `get`/`post`/`fetch`/`query` 前缀 | `getUserList()`、`submitOrder()` |
| 回调 Props | `on` 前缀 | `onChange`、`onSubmit`、`onCancel` |
| 枚举 | PascalCase（枚举名+成员） | `enum Status { Active, Inactive }` |
| 泛型参数 | 大写单字母或描述性 | `T`、`K`、`V`、`TResponse` |
| 私有函数 | `_` 前缀（不强制） | `_formatDate()`、`_transformData()` |

## 样式命名

| 类型 | 规范 | 示例 |
|------|------|------|
| CSS Modules | camelCase | `styles.container`、`styles.formItem` |
| BEM（不使用 CSS Modules 时） | block\_\_element--modifier | `form__item--error` |
| 全局样式 | kebab-case | `.page-container`、`.global-header` |

## 目录结构中的文件约定

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

## 命名原则总结

1. **一致性**：同一项目中同一类事物的命名方式要保持一致
2. **自解释**：命名应能反映其用途，不需要额外注释
3. **避免缩写**：除非是广泛接受的缩写（`API`、`URL`、`ref`），否则不要缩写
4. **单数/复数**：集合类型用复数（`userList`），单一个体用单数（`userItem`）
5. **否定布尔值**：避免否定词前缀（用 `isEnabled` 而非 `isDisabled`）
