# AI 编码规范规则集

> 一套规范源，适配多款 AI 编码工具。
> 当前覆盖：**Claude Code · Cursor · Trae · CodeBuddy**

---

## 快速开始

```bash
# 将 coding-standards 放到你的项目目录下，然后运行：
bash coding-standards/scripts/install.sh --target-dir /path/to/your/project

# 或只安装特定工具：
bash coding-standards/scripts/install.sh --target-dir . --tools cursor,codebuddy

# 使用符号链接模式（规范更新后自动同步）：
bash coding-standards/scripts/install.sh --target-dir . --mode symlink
```

安装后，重启对应工具的编辑器/会话即可生效。

---

## 目录结构

```
coding-standards/
├── README.md                        # 本文档
├── VERSION                          # 版本号 (2.0.0)
├── CHANGELOG.md                     # 版本历史
│
├── frontend-standards/              # 规范源文件（唯一权威来源）
│   ├── naming-conventions.md        # 目录命名 + 文件命名
│   ├── file-organization.md         # 目录结构 + 文件拆分
│   ├── component-patterns.md        # 组件约束 + 注释规范
│   ├── react-jsx.md                 # React/JSX 格式 + Hooks 规则
│   ├── code-style.md                # 基础格式 + 变量声明 + 函数复杂度
│   ├── import-organization.md       # 导入顺序 + 路径别名
│   ├── state-management.md          # 状态管理（Dva/RTK/Zustand）
│   ├── api-requests.md              # API 请求 + 错误处理
│   ├── styling.md                   # 样式方案 + 核心约束
│   └── typescript.md                # TS 配置 + 禁止事项
│
├── adapters/                        # 工具适配器模板
│   ├── claude-code/SKILL.md         # → .claude/skills/frontend-standards/
│   ├── cursor/010-frontend-core.mdc # → .cursor/rules/
│   ├── cursor/020-frontend-imports-state.mdc # → .cursor/rules/
│   ├── trae/SKILL.md                # → .trae/skills/frontend-standards/
│   └── codebuddy/frontend-standards.md # → .codebuddy/rules/
│
└── scripts/
    ├── install.sh                   # 一键安装到目标项目
    └── generate-adapters.sh         # 验证适配器与规范源一致性
```

---

## 设计理念

### 单源规范

所有规范内容写在 `frontend-standards/` 目录下。修改规范时只改这里，无需逐个修改工具配置。

### 渐进加载

AI 工具有限的上下文窗口需要精打细算。本规范集采用按需加载策略：

- **Claude Code / Trae**：SKILL.md 仅包含索引和工作流，AI 通过 `Read` 指令按需加载具体规范文件
- **Cursor / CodeBuddy**：规则内容直接内联在适配文件中，但经过高度浓缩，只包含最常用规则

### 本地优先

项目中的 `.prettierrc`、`.eslintrc`、`.editorconfig` 等配置文件**优先级高于本规范集**。本规范仅在本地配置未覆盖时生效。

---

## 各工具集成说明

### Claude Code

| 项目 | 说明 |
|------|------|
| 安装位置 | `.claude/skills/frontend-standards/SKILL.md` |
| 加载方式 | 对话中自动匹配 `description` 后触发 |
| 规则读取 | Skill 通知 Claude 按需 `Read` 规范文件 |

### Cursor

| 项目 | 说明 |
|------|------|
| 安装位置 | `.cursor/rules/010-frontend-core.mdc` + `020-frontend-imports-state.mdc` |
| 加载方式 | `alwaysApply: true`（全局）、globs 文件匹配自动触发 |
| 规则读取 | 规则完全内联，不依赖外部文件 |
| 注意事项 | 安装后需**重启 Cursor / 新建对话**才能生效 |

### Trae

| 项目 | 说明 |
|------|------|
| 安装位置 | `.trae/skills/frontend-standards/SKILL.md` |
| 加载方式 | 对话中自动匹配 `description` 后触发 |
| 触发时机 | Plan 阶段和编码阶段都应主动调用，不要依赖自动匹配 |
| 规则读取 | 同 Claude Code，按需加载 |
| 注意事项 | 安装脚本会替换 `{{CODING_STANDARDS_PATH}}` 占位符 |

### CodeBuddy

| 项目 | 说明 |
|------|------|
| 安装位置 | `.codebuddy/rules/frontend-standards.md` |
| 加载方式 | `alwaysApply: true`，每次会话自动加载 |
| 规则读取 | 完全内联，约 35 行 |
| 注意事项 | 安装后需**新建会话**才能生效 |

---

## 自定义规范

1. 编辑 `frontend-standards/` 下的规范文件
2. 运行 `scripts/generate-adapters.sh` 检查适配器是否需要同步
3. 运行 `scripts/install.sh` 重新部署到项目

### 添加新的规范类别

如需添加其他类型的规范（后端、数据库等），按相同模式创建目录：

```
coding-standards/
├── frontend-standards/    # 前端规范
├── backend-standards/     # 后端规范（待添加）
└── database-standards/    # 数据库规范（待添加）
```

在每个新目录下创建规范文件，然后为每个工具创建对应的适配器模板放在 `adapters/<tool>/` 下，最后更新 `install.sh`。

---

## 版本管理

版本号遵循语义化版本规范（SemVer）：

- **主版本号**：不兼容的规范内容变更
- **次版本号**：新增规范类别或规则
- **修订号**：规则修正、文案优化

当前版本：`2.0.0`

---

## 维护

### 更新规范

```bash
# 1. 修改规范源文件
vim frontend-standards/naming-conventions.md

# 2. 检查适配器是否需要同步
bash scripts/generate-adapters.sh

# 3. 更新 CHANGELOG.md
# 4. 提交并打 tag
git add .
git commit -m "feat: update naming conventions"
git tag v1.0.1
```

### 更新适配器

适配器中的 `010-frontend-core.mdc`、`codebuddy/frontend-standards.md` 为手写浓缩版本。修改规范源后，需要手动同步这些文件中的关键规则。

---

## FAQ

**Q: 为什么 Cursor/CodeBuddy 的适配器是内联的，而 Claude Code/Trae 是用 Read 加载的？**

A: Cursor 目前不支持 `@file` 引用（功能已确认损坏），且没有等价的 Read 机制。Claude Code 和 Trae 的 Skill 系统支持在 SKILL.md 中通过 Read 指令按需加载规范文件，因此可以采用渐进加载策略。

**Q: 安装脚本报 "无法计算相对路径"？**

A: macOS 缺少 `realpath --relative-to` 命令。可以手动指定路径：
```bash
bash coding-standards/scripts/install.sh --target-dir . --coding-standards-path coding-standards
```

**Q: 如何只给部分工具安装？**

A: 使用 `--tools` 参数指定要安装的工具列表：
```bash
bash coding-standards/scripts/install.sh --tools cursor,codebuddy
```

**Q: 如何卸载？**

A: 删除对应工具目录下的适配器文件即可：
```bash
rm -rf .claude/skills/frontend-standards/
rm -f .cursor/rules/010-frontend-core.mdc
rm -f .cursor/rules/020-frontend-imports-state.mdc
rm -rf .trae/skills/frontend-standards/
rm -f .codebuddy/rules/frontend-standards.md
```
