<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: api
@summary: 请求封装(axios)、按模块定义API、错误处理拦截器、加载状态管理
-->
# API 请求规范

## 核心原则

1. **请求封装统一**：所有请求通过统一的请求实例发出
2. **配置集中管理**：API URL 集中定义，不散落在各页面
3. **错误处理统一**：全局统一处理通用错误，页面处理业务错误
4. **响应类型明确**：API 响应有完整的 TypeScript 类型定义
5. **字段严格遵循接口定义**：生成代码时字段名必须与用户提供的接口定义完全一致（大小写敏感），不得自行编造、添加、遗漏或修改字段名。接口定义 `riskLevel` → 代码使用 `riskLevel`，不生成 `riskId` / `risklevel` / `riskScore` 等无关字段

## 请求封装

### 创建请求实例

```typescript
// src/services/request.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { message } from 'antd';

const request: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    // 添加 token
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// 响应拦截器
request.interceptors.response.use(
  (response: AxiosResponse) => {
    const { code, data, msg } = response.data;
    if (code === 0) {
      return data;  // 直接返回数据
    }
    message.error(msg || '请求失败');
    return Promise.reject(new Error(msg));
  },
  (error) => {
    if (error.response?.status === 401) {
      // 跳转登录
      window.location.href = '/login';
    } else {
      message.error('网络错误，请稍后重试');
    }
    return Promise.reject(error);
  }
);

export default request;
```

### 按模块封装 API

```typescript
// src/services/api/userApi.ts
import request from '@/services/request';

// 完整类型定义
export interface UserQueryParams {
  page: number;
  pageSize: number;
  keyword?: string;
  status?: number;
}

export interface UserItem {
  id: string;
  name: string;
  email: string;
  role: string;
  status: number;
  createdAt: string;
}

export interface PaginatedResponse<T> {
  list: T[];
  total: number;
  page: number;
  pageSize: number;
}
```

### 字段严格遵循接口定义

生成代码时，类型和参数的字段名必须与接口定义完全一致：

```typescript
// 假设用户提供的接口定义包含以下字段：
// riskLevel, riskName, status, createdAt

// ✅ 正确：字段名与接口定义完全一致（大小写敏感）
interface RiskItem {
  riskLevel: string;
  riskName: string;
  status: number;
  createdAt: string;
}

// ❌ 错误：自行编造、拼错、遗漏字段
interface RiskItem {
  riskId: string;          // ❌ 接口定义的是 riskLevel，不是 riskId
  risklevel: string;       // ❌ 大小写不一致
  riskScore: string;       // ❌ 接口没有这个字段
  status: number;
  // ❌ 遗漏 createdAt
}

// ❌ 错误：请求参数中添加接口不存在的字段
function getRiskList(params: {
  page: number;
  pageSize: number;
  riskLevel?: string;
  riskType?: string;    // ❌ 接口中没有 riskType
}): Promise<PaginatedResponse<RiskItem>> {
  return request.get('/risk/list', { params });
}
```

关键规则：

| 规则 | 说明 |
|------|------|
| **字段名必须完全匹配** | 接口定义 `riskLevel`，代码就用 `riskLevel`，不生成 `riskId`、`riskLevelStatus` |
| **大小写敏感** | `riskLevel` 不写成 `risklevel` 或 `RiskLevel` |
| **不添加接口不存在的字段** | 不在类型定义或请求参数中添加多余的字段 |
| **不遗漏字段** | 接口定义中明确给出的字段，类型定义中都要包含 |
| **响应字段同理** | 解析响应时也使用接口定义的字段名 |

API 方法定义：

```typescript
// API 方法：get/post/put/delete 前缀
export function getUserList(params: UserQueryParams): Promise<PaginatedResponse<UserItem>> {
  return request.get('/user/list', { params });
}

export function createUser(data: Partial<UserItem>): Promise<UserItem> {
  return request.post('/user/create', data);
}

export function updateUser(id: string, data: Partial<UserItem>): Promise<UserItem> {
  return request.put(`/user/${id}`, data);
}

export function deleteUser(id: string): Promise<void> {
  return request.delete(`/user/${id}`);
}
```

### Dva API 配置风格（Umi 项目）

```typescript
// src/service/api/index.ts
// 格式：[url, method, mockId, isNoSceneId?]
export const apiConfig = {
  getList: ['/api/list', 'get', 'xxx', true],
  addItem: ['/api/add', 'post', 'xxx'],
  updateItem: ['/api/update', 'put', 'xxx'],
  deleteItem: ['/api/delete', 'delete', 'xxx'],
};

// 页面中使用
import { serviceApi } from '@/service';
import { apiConfig } from '@/service/api';

const data = await serviceApi(apiConfig.getList, { page: 1 });
```

## 页面中调用 API

```tsx
// ✅ 在 Hooks 或 effects 中调用
const UserListPage: React.FC = () => {
  const [data, setData] = useState<UserItem[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchData = useCallback(async (params: UserQueryParams) => {
    setLoading(true);
    try {
      const result = await getUserList(params);
      setData(result.list);
    } catch (error) {
      // 错误已在拦截器中统一处理
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData({ page: 1, pageSize: 20 });
  }, [fetchData]);

  return <Table dataSource={data} loading={loading} />;
};
```

### 使用 ahooks useRequest（如项目已引入）

```tsx
import { useRequest } from 'ahooks';

const UserListPage: React.FC = () => {
  const { data, loading, error, refresh } = useRequest(
    () => getUserList({ page: 1, pageSize: 20 }),
    {
      refreshDeps: [],  // 依赖变化时重新请求
      onError: (err) => {
        message.error(err.message);
      },
    }
  );

  return <Table dataSource={data?.list} loading={loading} />;
};
```

## 错误处理规范

```
请求发起
  → 请求拦截器（添加 token 等）
  → 服务端处理
  → 响应拦截器
    ├── code === 0 → 返回 data，调用方正常使用
    ├── code !== 0 → message 提示，reject 错误
    ├── 401 → 跳转登录
    └── 网络错误 → 提示"网络错误"
```

### 页面级错误处理

```typescript
// ✅ 使用 try-catch 处理业务逻辑错误
try {
  await createUser(data);
  message.success('创建成功');
  refresh();  // 刷新列表
} catch (error) {
  // 不需要重复提示通用错误，拦截器已处理
  console.error('创建用户失败:', error);
}
```

## 加载状态管理

```tsx
// ✅ 统一 loading 状态覆盖
<Table
  dataSource={list}
  loading={loading}
/>

// ✅ 按钮加载状态
<Button loading={submitLoading} onClick={handleSubmit}>
  提交
</Button>

// ✅ Spin 覆盖层
<Spin spinning={pageLoading}>
  <div>{content}</div>
</Spin>
```

## 请求规范速查

| 场景 | 做法 |
|------|------|
| API 定义 | 按模块集中到 `services/api/` 下文件 |
| 函数命名 | `getXxx`（查询）/ `createXxx`（新增）/ `updateXxx`（修改）/ `deleteXxx`（删除） |
| 请求方法 | 遵循 RESTful：GET 查询、POST 创建、PUT 更新、DELETE 删除 |
| 参数传递 | GET 用 `params`，POST/PUT 用 `data` |
| 类型定义 | 每个 API 函数的入参和出参都要有类型 |
| 字段准确性 | 严格使用接口定义的字段名（大小写敏感），不自行编造 |
| 错误处理 | 拦截器处理通用错误，页面处理业务错误 |
| 加载状态 | 每个请求都需要有对应的 loading 状态 |
