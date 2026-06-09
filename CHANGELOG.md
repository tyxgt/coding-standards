# Changelog

## 2.0.0 (2026-06-05)

### 移除
- 删除 `frontend-standards/lint-rules.md`：所有规则为 LLM 默认行为，无实际约束价值
- 删除 `frontend-standards/new-project-defaults.md`：内容为其他文件的冗余总结
- 删除 `frontend-standards/comments.md`：核心约束（TODO 格式、JSX 注释）合并入 `component-patterns.md`

### 简化
- `naming-conventions.md`：清除通用 JS/TS 命名规则，仅保留目录命名、文件命名等项目特有规则
- `component-patterns.md`：清除通用组件模板，保留大小限制、导出约定、拆分原则，合并注释规范
- `typescript.md`：清除通用 TypeScript 用法，保留 tsconfig paths、StatusConfig 模式、禁止列表
- `styling.md`：清除通用 CSS/Less 用法，保留样式方案选择表和项目特有约束
- `import-organization.md`：清除通用导入语法示例，保留分组顺序和路径别名规则
- `file-organization.md`：清除各文件类型编写模板，保留目录结构布局和拆分决策
- `state-management.md`：精简通用状态使用示例，保留 Dva/RTK/Zustand 项目模式
- `api-requests.md`：精简页面调用示例，保留拦截器模式、字段准确性和模块组织

### 适配器同步
- 更新所有 4 个适配器（Claude Code、Trae、Cursor、CodeBuddy）以匹配简化的规范源文件
- 适配器中的通用规则已移除，仅保留项目特有约束

## 1.0.0 (2026-06-05)

### 重构
- 规范源文件重组：`index.md` → `INDEX.md`，去敏（移除内部业务项目名）
- 合并 `directory-structure.md` + `file-conventions.md` → `file-organization.md`
- 新增渐进加载策略，指导 AI 按需读取规范文件

### 新增
- `VERSION` 文件：版本号追踪
- `CHANGELOG.md`：版本历史
- 多工具适配器模板：
  - `adapters/claude-code/SKILL.md` — Claude Code Skill 入口
  - `adapters/cursor/*.mdc` — Cursor 规则文件
  - `adapters/trae/SKILL.md` — Trae Skill 入口
  - `adapters/codebuddy/frontend-standards.md` — CodeBuddy 规则
- `scripts/install.sh` — 一键安装到目标项目
- `scripts/generate-adapters.sh` — 从规范源重新生成适配器

### 移除
- `index.md`（已替换为 `INDEX.md`）
- `directory-structure.md`（已合入 `file-organization.md`）
- `file-conventions.md`（已合入 `file-organization.md`）
