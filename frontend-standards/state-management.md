<!--
@ai-rules
@version: 1.0.0
@last-updated: 2026-06-05
@category: state
@summary: 状态层级决策、Dva/ReduxToolkit/Zustand模式、本地状态规范
-->
# 状态管理规范

## 核心原则

1. **就近原则**：状态尽量放在需要它的最近层级，不要过早提升到全局
2. **单向数据流**：数据变化可追踪，避免直接修改状态
3. **不可变性**：永远不直接修改 state，使用不可变更新方式
4. **按需选择**：根据项目已有的状态管理方案编写，不引入新方案

## 状态层级决策

```
┌─────────────────────────────────────┐
│         全局共享状态                   │  ← Dva / Redux Toolkit / Zustand
│  (用户信息、权限、全局配置)            │
├─────────────────────────────────────┤
│         页面级共享状态                 │  ← useContext + useReducer
│  (页面筛选条件、Tab 切换)              │
├─────────────────────────────────────┤
│         组件本地状态                   │  ← useState / useReducer
│  (表单输入、弹窗显隐、加载状态)         │
└─────────────────────────────────────┘
```

### 状态放置决策

| 状态类型 | 推荐位置 | 示例 |
|----------|----------|------|
| 表单输入 | 组件本地 useState | `const [name, setName] = useState('')` |
| 弹窗/下拉显隐 | 组件本地 useState | `const [visible, setVisible] = useState(false)` |
| 组件加载/错误 | 组件本地 useState | `const [loading, setLoading] = useState(false)` |
| 页面筛选条件 | 页面级 state 或 URL | `const [filters, setFilters] = useState({})` |
| 页面列表数据 | 页面级 state 或自定义 Hook | `useUserList()` |
| 用户登录信息 | 全局 store | Redux/Dva model |
| 权限数据 | 全局 store | Redux/Dva model |
| 全局主题/配置 | 全局 store 或 Context | `ThemeContext` |
| 多页面共享数据 | 全局 store | 提升到全局 |

## Dva 模式

如项目使用 Dva，按以下约定编写：

```typescript
// src/models/user.ts
export default {
  namespace: 'user',  // model 名称，用于 connect

  state: {
    list: [],
    currentUser: null,
    loading: false,
  },

  effects: {
    *fetchList({ payload }, { call, put }) {
      yield put({ type: 'setLoading', payload: true });
      try {
        const response = yield call(api.getUserList, payload);
        yield put({ type: 'setList', payload: response.data });
      } catch (error) {
        // 错误已在 request 拦截器中统一处理
      } finally {
        yield put({ type: 'setLoading', payload: false });
      }
    },
  },

  reducers: {
    setList(state, { payload }) {
      return { ...state, list: payload };
    },
    setLoading(state, { payload }) {
      return { ...state, loading: payload };
    },
    clear() {
      return { list: [], currentUser: null, loading: false };
    },
  },
};
```

```tsx
// 在页面组件中使用 Dva
import { connect } from 'umi';
import type { Dispatch } from 'umi';

interface UserListProps {
  userList: any[];
  dispatch: Dispatch;
}

const UserListPage: React.FC<UserListProps> = ({ userList, dispatch }) => {
  const handleFetch = () => {
    dispatch({ type: 'user/fetchList', payload: { page: 1 } });
  };

  return <Table dataSource={userList} />;
};

export default connect((state: any) => ({
  userList: state.user.list,
}))(UserListPage);
```

## Redux Toolkit 模式

如项目使用 Redux Toolkit，按以下约定编写：

```typescript
// src/stores/userSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

interface UserState {
  list: User[];
  loading: boolean;
}

const initialState: UserState = {
  list: [],
  loading: false,
};

export const fetchUserList = createAsyncThunk(
  'user/fetchList',
  async (params: ListParams) => {
    const response = await api.getUserList(params);
    return response.data;
  }
);

const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    clearList(state) {
      state.list = [];
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUserList.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchUserList.fulfilled, (state, action) => {
        state.list = action.payload;
        state.loading = false;
      })
      .addCase(fetchUserList.rejected, (state) => {
        state.loading = false;
      });
  },
});

export const { clearList } = userSlice.actions;
export default userSlice.reducer;
```

```tsx
// 在页面中使用 Redux Toolkit
import { useSelector, useDispatch } from 'react-redux';
import { fetchUserList, clearList } from '@/stores/userSlice';

const UserListPage: React.FC = () => {
  const dispatch = useDispatch();
  const { list, loading } = useSelector((state: RootState) => state.user);

  const handleFetch = () => {
    dispatch(fetchUserList({ page: 1 }));
  };

  return <Table dataSource={list} loading={loading} />;
};
```

## Zustand 模式

如项目使用 Zustand：

```typescript
// src/stores/useUserStore.ts
import { create } from 'zustand';

interface UserStore {
  users: User[];
  loading: boolean;
  error: Error | null;
  fetchUsers: (params: ListParams) => Promise<void>;
  clearUsers: () => void;
}

export const useUserStore = create<UserStore>((set) => ({
  users: [],
  loading: false,
  error: null,

  fetchUsers: async (params) => {
    set({ loading: true, error: null });
    try {
      const data = await api.getUserList(params);
      set({ users: data, loading: false });
    } catch (error) {
      set({ error: error as Error, loading: false });
    }
  },

  clearUsers: () => set({ users: [], error: null }),
}));

// 页面中使用
// const { users, loading, fetchUsers } = useUserStore();
```

## 组件本地状态规范

```tsx
// ✅ useState：单一值
const [count, setCount] = useState(0);
const [visible, setVisible] = useState(false);

// ✅ useState：简单对象
const [formData, setFormData] = useState({ name: '', age: 0 });

// ✅ useReducer：复杂关联状态
const [state, dispatch] = useReducer(reducer, initialState);

// ✅ 避免：过多分散的 useState 导致 props drilling
// 此时考虑 useReducer 或提升状态

// ✅ 状态更新保持不可变
setFormData(prev => ({ ...prev, name: 'new' }));  // ✅
// formData.name = 'new'; setFormData(formData);    // ❌ 直接修改
```

## 禁止事项

- ❌ 直接修改 state（`state.xxx = value`）
- ❌ 在 reducers 或状态更新函数中执行副作用
- ❌ 在渲染函数中直接调用状态更新函数
- ❌ 将不必要的状态放入全局 store（能放在本地的就放本地）
- ❌ 在项目中混用多种状态管理方案（除非正在迁移）
