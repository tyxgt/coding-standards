<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: import
@summary: 导入分组顺序、路径别名(@/)、类型导入、循环依赖禁止
-->
# 前端导入规范

## 导入分组顺序

所有 import 语句按以下分组顺序排列，组间用空行分隔：

```tsx
// 1. 核心库（React、React Router 等）
import React, { useState, useEffect } from 'react';
import { useParams, history } from 'umi';

// 2. 第三方 UI 库（Ant Design、ProComponents 等）
import { Button, Table, Modal, message } from 'antd';
import { ProTable } from '@ant-design/pro-table';

// 3. 第三方工具库
import { useRequest } from 'ahooks';
import classNames from 'classnames';
import { format } from 'date-fns';

// 4. 内部模块/工具函数（@/ 别名导入）
import { serviceApi } from '@/service';
import { formatDate } from '@/utils/format';
import { useAuth } from '@/hooks/useAuth';

// 5. 相对路径导入（同级或子级）
import { UserTable } from './components/UserTable';
import { StatusConfig } from './constants';
import type { UserData } from './types';

// 6. 样式导入
import styles from './index.less';

// 7. 类型导入（使用 import type 语法）
import type { TableProps } from 'antd';
import type { User } from '@/types';
```

**规则**：
- 同类导入按字母序排列
- 各分组之间空一行
- type import 统一放在最后或与源导入合并（按项目已有风格）

## 路径别名

### 常用别名映射

| 别名 | 路径 | 说明 |
|------|------|------|
| `@/` | `src/` | 源码根目录 |
| `@@/` | `src/.umi/` | Umi 运行时生成目录 |
| `@components/` | `src/components/` | 全局组件（如配置） |
| `@utils/` | `src/utils/` | 工具函数（如配置） |

### 使用规范

```tsx
// ✅ 引用 src/ 下任意位置时使用 @/ 别名
import { apiConfig } from '@/service/api';
import { globalModel } from '@/models';
import { PageHeader } from '@/components/PageHeader';

// ✅ 引用同级或子级模块时使用相对路径
import { StatusTag } from './components/StatusTag';
import { getStatusColor } from './utils';

// ✅ 引用父级模块时使用相对路径
import { formatTime } from '../utils';

// ❌ 避免：在同一个模块内混用 @/ 和相对路径指向同一目录
// ❌ 避免：相对路径出现 ../../../ 超过 3 层
```

**原则**：
- `@/` 别名主要用于跨目录引用，同一页面目录内使用相对路径
- 相对路径回退不超过 3 层（`../../../`），超过则改用 `@/`
- 路径别名在 `tsconfig.json` 的 `paths` 中配置

## 导入方式

### 默认导入 vs 命名导入

```tsx
// ✅ 默认导入（用于组件/页面入口）
import UserTable from './components/UserTable';

// ✅ 命名导入（用于工具函数、类型、多个导出）
import { getUserList, createUser } from '@/services/userApi';
import { Status } from './constants';

// ✅ 同时导入默认和命名
import React, { useState, useEffect } from 'react';
```

### 按需导入

```tsx
// ✅ 从 Ant Design 按需导入（减少打包体积）
import { Button, Table, Modal } from 'antd';

// ❌ 避免全量导入
import antd from 'antd';
```

## 类型导入

```tsx
// ✅ 使用 import type 语法（编译时会被移除）
import type { TableProps } from 'antd';
import type { User, Role } from '@/types';

// ✅ 混合导入时，用 type 关键字标注类型
import { useRequest, type PaginationParams } from 'ahooks';

// 或者拆分两条导入（更清晰）
import { useRequest } from 'ahooks';
import type { PaginationParams } from 'ahooks';
```

## 循环依赖禁止

```typescript
// ❌ 禁止：A 引用 B，B 又引用 A
// a.ts
import { helperB } from './b';
export const helperA = () => helperB();

// b.ts
import { helperA } from './a';  // 循环依赖！
export const helperB = () => helperA();

// ✅ 解决：抽取公共依赖到第三个文件
// shared.ts
export const sharedLogic = () => { ... };

// a.ts
import { sharedLogic } from './shared';

// b.ts
import { sharedLogic } from './shared';
```

## 导入路径选择速查表

| 引用位置 | 目标位置 | 推荐方式 |
|----------|----------|----------|
| 同一目录下 | 同级文件 | 相对路径 `./xxx` |
| 同一页面内 | 子目录 | 相对路径 `./components/xxx` |
| 同一页面内 | 父目录 | 相对路径 `../xxx` |
| 不同页面 | src 下 | `@/pages/xxx` 或 `@/components/xxx` |
| 跨大目录 | utils/services/models | `@/utils/xxx` |
| 第三方库 | - | 直接包名 |
