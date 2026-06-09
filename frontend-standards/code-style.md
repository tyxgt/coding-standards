<!--
@ai-rules
@version: 2.0.0
@last-updated: 2026-06-08
@category: code-style
@summary: 基础格式、变量声明、运算符、函数复杂度、注释、调试、可访问性
-->

# 代码风格规范

## 基础格式

| 规则 | 要求 |
|------|------|
| 缩进 | 2 个空格，禁止使用 Tab |
| 字符串 | 单引号，除非字符串内包含单引号需要避免转义 |
| 语句结尾 | 必须加分号 |
| 对象花括号 | 内侧保留空格：`{ a: 1 }` |
| 数组方括号 | 内侧不留空格：`[1, 2]` |
| 尾逗号 | 禁止（对象、数组最后一个元素后不加逗号） |
| 文件末尾 | 保留一个空行 |
| 空白行 | 代码块之间最多允许两行空白行 |
| 单行长度 | 建议不超过 160 字符（长字符串、URL 等可忽略） |

## 换行与对齐

- 链式调用超过 3 层时换行书写
- 多行对象属性、数组元素、函数参数等，按 2 空格缩进对齐
- `switch` 语句中的 `case` 子句相对 `switch` 缩进一层（2 空格）
- 函数名与括号之间不要有空格（`fn()` 而非 `fn ()`）

```typescript
// ✅ 正确
const result = fetchData('/api/list')
  .then(transform)
  .then(filter)
  .catch(handleError);

// ✅ 多行对象
const config = {
  key: 'value',
  option: true,
};

// ✅ switch 缩进
switch (type) {
  case 'a':
    handleA();
    break;
  case 'b':
    handleB();
    break;
}
```

## 块语句

- 控制语句（`if`、`for`、`while` 等）**必须**使用花括号，即使只有一条语句
- `else` 中如果嵌套唯一的 `if`，直接使用 `else if`，避免"孤独的 if"

```typescript
// ✅ 正确
if (condition) {
  doSomething();
}

// ✅ else if 避免孤独的 if
if (a) {
  handleA();
} else if (b) {
  handleB();
} else {
  handleC();
}

// ❌ 错误：省略花括号
if (condition) doSomething();

// ❌ 错误：孤独的 if
if (a) {
  handleA();
} else {
  if (b) {
    handleB();
  }
}
```

## 变量声明与作用域

| 规则 | 说明 |
|------|------|
| 禁止 `var` | 统一使用 `const` / `let` |
| 优先 `const` | 只在需要重新赋值时使用 `let` |
| 初始化 | 不要将变量初始化为 `undefined`，直接声明赋值或用 `null` 表示空值 |
| 禁止 shadow | 内部作用域变量名不要覆盖外部作用域已有的变量名 |
| 禁止重复导入 | 合并同一模块的多次 import |

```typescript
// ✅ 正确
const maxCount = 100;
let currentIndex = 0;

// ✅ 使用 null 表示空值
let result = null;

// ❌ 错误
var oldWay = 'deprecated';                    // 禁止 var
let config = { mode: 'dev' };                 // 不会被重新赋值，应用 const
let data = undefined;                         // 不要初始化为 undefined
```

## 运算符与表达式

| 规则 | 说明 |
|------|------|
| 严格相等 | 使用 `===` 和 `!==`，禁止 `==` 和 `!=` |
| 嵌套三元 | 禁止嵌套三元表达式，保持可读性 |
| 链式赋值 | 避免链式赋值（`a = b = c = 1`） |
| 模板字符串 | 拼接字符串优先使用模板字符串 |
| new 调用 | 即使无参数也必须带括号（如 `new Date()`） |

```typescript
// ✅ 正确
const name = `Hello ${userName}`;
const isEqual = a === b;
const timestamp = new Date();

// ✅ 简单三元可接受
const label = isActive ? '启用' : '禁用';

// ❌ 错误
const isEqual = a == b;                                       // 禁止 ==
const label = type === 'a' ? 'A' : type === 'b' ? 'B' : 'C'; // 禁止嵌套三元
const html = '<div>' + text + '</div>';                       // 应使用模板字符串
```

## 函数与复杂度

| 规则 | 上限 |
|------|------|
| 回调嵌套 | 不超过 3 层 |
| 圈复杂度 | 不超过 6 |
| 单文件 | 建议不超过 300 行 |
| 空函数 | 禁止（除非有注释说明占位意图） |
| `continue` | 禁止使用（用条件判断改写） |
| 循环中 `await` | 避免（改为 `Promise.all` 或分批处理） |
| `arguments` | 用剩余参数替代（`...args`） |

```typescript
// ✅ 正确：分解复杂逻辑
async function fetchAllItems(ids: string[]) {
  const results = await Promise.all(
    ids.map(id => fetchItem(id))
  );
  return results;
}

// ✅ 正确：剩余参数
function sum(...numbers: number[]) {
  return numbers.reduce((a, b) => a + b, 0);
}

// ❌ 错误
for (const item of list) {
  if (item.disabled) continue;     // 禁止 continue
  process(item);
}

// 应改为
for (const item of list) {
  if (!item.disabled) {
    process(item);
  }
}
```

## 控制台与调试

- 不要在最终代码中保留 `console.log`
- 允许使用 `console.warn`、`console.error` 记录警告和错误
- 禁止提交 `debugger` 语句

## 注释规范

- 多行注释使用连续的单行注释 `// ...`，而不是 `/* ... */` 块注释（除非是 JSDoc）
- 公共函数、组件、类型定义应添加 JSDoc 风格的描述

```typescript
// ✅ 正确：连续单行注释
// 这是一个多行说明
// 用于描述下面的函数

// ✅ JSDoc 风格
/**
 * 获取用户列表
 * @param params - 查询参数
 * @returns 用户列表
 */
export function getUserList(params: QueryParams): Promise<User[]> {
  return request.get('/user/list', { params });
}

// ❌ 避免块注释描述内部逻辑（除非 JSDoc）
/* 这种注释风格只用于 JSDoc */
```

## 错误处理三态

每个数据请求的组件必须处理以下三种状态：

```tsx
function UserList() {
  const { data, isLoading, error } = useQuery(...);

  // 加载态
  if (isLoading) return <Spin tip="加载中..." />;

  // 错误态
  if (error) return <Result status="error" title="加载失败" subTitle={error.message} />;

  // 空态
  if (!data || data.length === 0) return <Empty description="暂无数据" />;

  // 正常渲染
  return <Table dataSource={data} />;
}
```

## 可访问性与性能

- 为图片提供 `alt` 属性，表单输入项绑定 `label`
- 可交互元素（按钮、链接）应具备键盘操作能力和焦点样式
- 避免不必要的 re-render，合理使用 `React.memo`、`useMemo`、`useCallback`

```tsx
// ✅ 正确
<img src="logo.png" alt="公司 Logo" />
<label htmlFor="username">用户名</label>
<input id="username" type="text" />

// ✅ 合理使用 memo
const ExpensiveList = React.memo(function ExpensiveList({ items }: Props) {
  return items.map(item => <ListItem key={item.id} {...item} />);
});
```

## 最终检查清单

提交代码前快速检查：

- [ ] 字段名是否与接口定义完全一致（大小写敏感）
- [ ] 是否有未使用的 import 或变量？
- [ ] 是否有 `console.log` 或 `debugger` 遗留？
- [ ] 文件名是否符合规范？
- [ ] 样式是否使用了项目对应的方案？
- [ ] 是否处理了加载态、空态、错误态？
- [ ] 是否修改了非本次任务的代码？

> *最终格式细节（如最大行宽、空行等）将由 ESLint / Prettier 自动修正，请运行 `npm run lint` 确保通过。*
