<!--
@ai-rules
@version: 2.0.0
@last-updated: 2026-06-05
@category: api
@summary: 请求封装(axios)、按模块定义API、错误处理拦截器、字段准确性
-->
# API 请求规范

## 核心原则

1. **请求封装统一**：所有请求通过统一的请求实例发出
2. **配置集中管理**：API URL 集中定义，不散落在各页面
3. **错误处理统一**：全局统一处理通用错误，页面处理业务错误
4. **响应类型明确**：API 响应有完整的 TypeScript 类型定义
5. **字段严格遵循接口定义**：生成代码时字段名必须与用户提供的接口定义完全一致（大小写敏感），不得自行编造、添加、遗漏或修改字段名

## 请求封装

### 创建请求实例

```typescript
// src/services/request.ts
import axios, { AxiosInstance } from 'axios';
import { message } from 'antd';

const request: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 30000,
});

// 请求拦截器：添加 token
request.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 响应拦截器：统一处理返回数据和错误
request.interceptors.response.use(
  (response) => {
    const { code, data, msg } = response.data;
    if (code === 0) return data;
    message.error(msg || '请求失败');
    return Promise.reject(new Error(msg));
  },
  (error) => {
    if (error.response?.status === 401) {
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
import type { PaginatedResponse } from '@/types';

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

// API 方法：get/create/update/delete 前缀
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
export const apiConfig = {
  getList: ['/api/list', 'get', 'xxx', true],
  addItem: ['/api/add', 'post', 'xxx'],
  updateItem: ['/api/update', 'put', 'xxx'],
  deleteItem: ['/api/delete', 'delete', 'xxx'],
};
```

## 字段严格遵循接口定义

生成代码时，类型和参数的字段名必须与接口定义完全一致：

```typescript
// ✅ 接口定义含 riskLevel → 类型定义也用 riskLevel
interface RiskItem {
  riskLevel: string;    // ✅ 正确：字段名与接口定义一致
  riskName: string;
  status: number;
  createdAt: string;
}

// ❌ 自行编造、拼错、遗漏字段
// riskId, risklevel, RiskLevel, riskScore — 接口未定义的字段不能出现
```

| 规则 | 说明 |
|------|------|
| **字段名必须完全匹配** | 接口定义 `riskLevel`，代码就用 `riskLevel` |
| **大小写敏感** | `riskLevel` 不写成 `risklevel` 或 `RiskLevel` |
| **不添加接口不存在的字段** | 不在类型定义或请求参数中添加多余字段 |
| **不遗漏字段** | 接口定义中明确给出的字段，类型定义中都要包含 |

## 错误处理

```
请求发起
  → 请求拦截器（添加 token）
  → 服务端处理
  → 响应拦截器
    ├── code === 0 → 返回 data
    ├── code !== 0 → message 提示，reject 错误
    ├── 401 → 跳转登录
    └── 网络错误 → 提示"网络错误，请稍后重试"
```

页面层使用 try-catch 处理业务逻辑错误（如创建成功后的列表刷新），通用错误由拦截器统一处理。

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
