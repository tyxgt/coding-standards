---
alwaysApply: true
description: 前端编码通用规范。始终生效，确保所有前端代码（新建页面、实现功能、编写组件、审查代码）遵循编码规范。
---

# 前端编码通用规范 (v2.0.0)

在涉及任何前端代码时，必须遵循以下规则：

## 通用规则

- 函数组件 + Hooks，不使用 class 组件
- TypeScript 启用 strict 模式
- Props 接口定义在组件文件顶部（`interface 组件名 + Props`）
- 默认导出组件，命名导出类型
- 列表 key 使用唯一且稳定的值
- 使用 try-catch 处理异步错误
- 本地配置优先，不破坏已有代码

## 自查清单

- [ ] 字段名与接口定义完全一致（大小写敏感）
- [ ] 无未使用的 import 或变量
- [ ] 无 `console.log` 或 `debugger` 遗留
- [ ] 无 TODO/FIXME/HACK 注释应处理
- [ ] 文件名符合命名规范（页面 PascalCase、组件 camelCase、Hook useXxx.ts）
- [ ] 样式使用项目对应方案（CSS Modules / Tailwind / Less）
- [ ] 无静态内联样式（`style={{}}`），应提取到 CSS Modules
- [ ] import 分组顺序正确（核心库 → UI 库 → 工具库 → `@/` → 相对路径 → 样式 → 类型）
- [ ] 无 TypeScript 禁止语法（`any`、`@ts-ignore`、`!` 非空断言、`Function` 类型）
- [ ] 状态放在正确层级（就近原则）
- [ ] 未修改非本次任务的代码

## 详细规范

详细规范文件位于 `{{CODING_STANDARDS_PATH}}/frontend-standards/` 目录下。
当执行具体任务（创建组件、编写 API、管理状态、组织文件等）时，
应根据任务类型使用 `Read` 工具按需加载对应的规范文件。

| 当前任务 | 需要加载的文件 |
|----------|---------------|
| 创建/修改组件 | `naming-conventions.md` → `component-patterns.md` → `react-jsx.md` |
| 编写组件逻辑/JSX | `react-jsx.md` |
| 添加 import 语句 | `import-organization.md` |
| 管理状态 | `state-management.md` |
| 编写 API 调用 | `api-requests.md` |
| 编写样式 | `styling.md` |
| 编写类型定义 | `typescript.md` |
| 组织文件/目录 | `file-organization.md` |
| 代码格式/风格 | `code-style.md` |
