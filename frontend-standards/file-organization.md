<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: file-organization
@summary: 目录结构规范 + 文件拆分约定 + 组件/页面文件组织模式
-->

# 前端文件组织规范

> 由 `directory-structure.md` 和 `file-conventions.md` 合并

## 核心原则

1. **按功能/领域组织**，而非按文件类型——将相关的组件、样式、类型放在一起
2. **一个文件一个职责**——文件与其导出的主要内容同名，不过度堆积
3. **就近放置**——相关的类型、常量、工具函数放在使用处附近
4. **适时提取**——当内容在 2+ 个地方使用时，提取到共享位置
5. **避免深度嵌套**——目录层级不超过 4 层
6. **页面即目录**——每个页面是一个目录，入口为 `index.tsx`

---

## 典型项目目录结构

```
src/
├── app.tsx                    # 应用入口/运行时配置
├── global.ts                  # 全局 JS 逻辑
├── global.less                # 全局样式（覆盖框架默认样式）
├── access.ts                  # 权限控制配置
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
│       ├── hooks/             # 页面私有 Hook
│       │   └── useConfigData.ts
│       └── subpages/          # 子页面（二级路由）
│           └── Detail/
│               ├── index.tsx
│               └── index.less
├── components/                # 全局共享组件
│   └── PageHeader/
│       ├── index.tsx
│       ├── index.less
│       └── types.ts
├── layouts/                   # 布局组件
│   ├── BasicLayout/
│   │   ├── index.tsx
│   │   └── index.less
│   └── Sidebar/
│       ├── index.tsx
│       └── index.less
├── models/                    # 全局状态管理（Dva 风格）
├── stores/                    # 全局状态管理（Redux Toolkit / Zustand 风格）
├── services/                  # API 服务层
│   ├── request.ts             # 请求封装
│   └── api/
│       ├── index.ts
│       ├── userApi.ts
│       └── orderApi.ts
├── utils/                     # 全局工具函数
├── hooks/                     # 全局自定义 Hooks
├── types/                     # 全局类型定义
├── constants/                 # 全局常量
├── assets/
│   └── images/
├── config/                    # 项目配置
│   └── route.ts
└── locales/                   # 国际化
    ├── zh-CN.ts
    └── en-US.ts
```

---

## 文件拆分决策

```
一个文件是否需要拆分？
│
├── 文件超过 300 行？
│   └── 是 → 拆分
│
├── 组件包含多个不直接相关的逻辑？
│   └── 是 → 拆分
│
├── 类型定义超过 50 行？
│   └── 是 → 提取到 types.ts
│
├── 常量/枚举超过 20 行？
│   └── 是 → 提取到 constants.ts
│
├── 工具函数在 2+ 地方使用？
│   └── 是 → 提取到 utils.ts
│
└── 以上都不是 → 不需要拆分
```

---

## 各文件类型模式

### index.tsx（组件/页面入口）

```tsx
interface PageHeaderProps {      // 1. Props 类型（文件顶部）
  title: string;
  extra?: React.ReactNode;
}

const PageHeader: React.FC<PageHeaderProps> = ({ title, extra }) => {  // 2. 组件
  return (
    <div>
      <h1>{title}</h1>
      {extra && <div>{extra}</div>}
    </div>
  );
};

export default PageHeader;       // 3. 默认导出
```

- 职责：组件实现 + 默认导出
- 行数：不超过 300 行

### types.ts（类型定义）

```typescript
// 页面/组件内部使用的类型
export interface SearchParams {
  keyword?: string;
  status?: number;
  dateRange?: [string, string];
}

export interface TableRecord {
  id: string;
  name: string;
  status: number;
  createdAt: string;
}

export type ModalMode = 'create' | 'edit' | 'view';
```

- 职责：集中管理当前模块内使用的类型
- 类型定义超过 50 行时提取到 types.ts
- 导出所有类型，供外部使用

### constants.ts（常量/枚举）

```typescript
export const PAGE_SIZE = 20;
export const DEFAULT_PAGE = 1;

export enum Status {
  Inactive = 0,
  Active = 1,
}

export const StatusMap: Record<number, { text: string; color: string }> = {
  [Status.Inactive]: { text: '停用', color: 'default' },
  [Status.Active]: { text: '启用', color: 'success' },
};
```

- 常量/枚举超过 10 行时提取到 constants.ts

### columns.tsx（表格列配置）

```tsx
// 当表格列配置复杂（超过 5 列）或有多套列配置时使用
export const getColumns = (handleEdit: (record: TableRecord) => void): ColumnsType<TableRecord> => [
  {
    title: '名称',
    dataIndex: 'name',
    key: 'name',
  },
  // ...
];
```

### utils.ts（工具函数）

```typescript
// 纯函数为主（输入决定输出，无副作用）
export function formatDate(date: string | Date, format = 'YYYY-MM-DD HH:mm:ss'): string {
  return dayjs(date).format(format);
}

export function normalizeSearchParams(params: SearchParams): Record<string, any> {
  // 去掉空值
}
```

### hooks / useXxx.ts（自定义 Hooks）

```typescript
export function usePagination(initialPage = 1, initialPageSize = 20) {
  const [page, setPage] = useState(initialPage);
  const [pageSize, setPageSize] = useState(initialPageSize);
  return { page, pageSize, onChange };
}
```

---

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

### 提取到共享位置的原则

```
                    ┌──────────────────────┐
                    │  页面内专有 (私有)      │
                    │  pages/PageName/xxx    │
                    └──────────────────────┘
                              ↓ 被 2+ 页面使用
                    ┌──────────────────────┐
                    │  全局共享              │
                    │  src/components/      │
                    │  src/hooks/           │
                    │  src/utils/           │
                    └──────────────────────┘
                              ↓ 与业务无关
                    ┌──────────────────────┐
                    │  可提取为 npm 包       │
                    └──────────────────────┘
```

---

## 文件组织速查

| 文件 | 何时创建 | 最大行数 |
|------|----------|----------|
| `index.tsx` | 每个组件/页面 | 300 行 |
| `types.ts` | 类型定义 > 20 行 | 不限 |
| `constants.ts` | 常量/枚举 > 10 行 | 不限 |
| `utils.ts` | 工具函数 > 2 个 | 不限 |
| `columns.tsx` | Table 列 > 5 列 | 不限 |
| `hooks/useXxx.ts` | 自定义 Hook | 100 行 |
| `index.less` | 每个组件/页面 | 200 行 |

## 移动端项目

对于移动端（antd-mobile / 小程序）项目，遵循以上相同的原则，但注意：
- 页面目录按 Tab/模块组织
- 组件层次更浅（移动端组件复用度更高）
- 样式文件使用对应预处理器
