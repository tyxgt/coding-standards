# Changelog

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
  - `adapters/amazon-q/frontend-standards.md` — Amazon Q Developer 规则
- `scripts/install.sh` — 一键安装到目标项目
- `scripts/generate-adapters.sh` — 从规范源重新生成适配器

### 移除
- `index.md`（已替换为 `INDEX.md`）
- `directory-structure.md`（已合入 `file-organization.md`）
- `file-conventions.md`（已合入 `file-organization.md`）
