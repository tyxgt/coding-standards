# ai-rules 团队落地改造方案

> 基于 v1.0.0 分析，针对 Umi + Ant Design + Less 技术栈、多 AI 编码工具并用的前端团队。
> 覆盖工具：Claude Code · Cursor · Trae · CodeBuddy
> 创建日期：2026-06-05

---

## 目录

- [背景与问题清单](#背景与问题清单)
- [改造方案总览](#改造方案总览)
- [Phase 1: 补坑 — 修复现有阻塞问题](#phase-1-补坑--修复现有阻塞问题)
- [Phase 2: 适配器一致性 — 统一 4 个工具的规则覆盖](#phase-2-适配器一致性--统一-4-个工具的规则覆盖)
- [Phase 3: 安装与更新 — 让团队能用起来](#phase-3-安装与更新--让团队能用起来)
- [Phase 4: 幻觉约束 — 针对 LLM 特有问题的规则增强](#phase-4-幻觉约束--针对-llm-特有问题的规则增强)
- [Phase 5: CI 与流程 — 长期可持续保障](#phase-5-ci-与流程--长期可持续保障)
- [实施优先级与工作量](#实施优先级与工作量)
- [验证方式](#验证方式)

---

## 背景与问题清单

现有问题：

| # | 问题 | 严重性 | 所在文件 |
|---|------|--------|---------|
| 1 | **INDEX.md 缺失** — Claude Code SKILL.md 引用的入口文件不存在 | ❌ 阻塞 | `adapters/claude-code/SKILL.md` 第 70 行 |
| 2 | **generate-adapters.sh 是空壳** — `"自动生成逻辑尚未实现"` | ❌ 阻塞 | `scripts/generate-adapters.sh` 第 18 行 |
| 3 | **lint-rules.md 有死链** — 引用已合并的 `file-conventions.md` | ⚠️ 误导 | `frontend-standards/lint-rules.md` 第 144 行 |
| 4 | **new-project-defaults.md 有玩笑行** — 需要清理 | 🔧 低优 | `frontend-standards/new-project-defaults.md` 第 60 行 |
| 5 | **安装脚本 macOS 路径问题** — `realpath --relative-to` 不存在 | ⚠️ 平台兼容 | `scripts/install.sh` 第 76 行 |
| 6 | **默认 copy 模式，更新不传播** — `git pull` 后规则过期 | ⚠️ 实战隐患 | `scripts/install.sh` 第 41 行 |
| 7 | **各工具适配器内容差异大** | ❌ 工具不一致 | `adapters/*/` 下全部文件 |
| 8 | **无任何校验/CI 机制** | ❌ 维护隐患 | 无 |
| 9 | **无 AI 自检流程** — 字段名幻觉等问题无约束 | ⚠️ 实战隐患 | 无 |

### 适配器内容差异现状

| 工具 | 适配器行数 | 说明 |
|------|-----------|------|
| Claude Code | 81 行索引 + 按需 Read 源文件 | ✅ 完整 |
| Cursor | 89+80 = 169 行内联（两个 .mdc） | ⚠️ 浓缩版，有遗漏 |
| Trae | 67 行索引 + 按需 Read 源文件 | ✅ 完整（同 Claude Code） |
| CodeBuddy | 52 行手写内联 | ❌ 严重缺失 |

### 技术栈假设匹配度

当前规范默认假设的技术栈：
- **框架**: Umi 3/4 ✅
- **组件库**: Ant Design ✅
- **样式方案**: CSS Modules + Less ✅
- **状态管理**: Dva / Redux Toolkit / Zustand ✅
- **API 请求**: axios + `code === 0` 约定 ✅
- **路径别名**: `@/` ✅
- **工具函数库**: ahooks ✅

> ✅ 全部匹配，无需做栈无关化改造。

---

## 改造方案总览

```
Phase 1: 补坑          优先级: P0    修复阻塞问题
Phase 2: 适配器一致性   优先级: P0    确保 4 个工具的 AI 行为一致
Phase 3: 安装与更新     优先级: P1    让开发者能用起来、能保持更新
Phase 4: 幻觉约束       优先级: P1    针对 LLM 特有问题的规则增强
Phase 5: CI 与流程      优先级: P2    长期可持续
```

---

## Phase 1: 补坑 — 修复现有阻塞问题

### 1.1 创建 `frontend-standards/INDEX.md`

规范源目录缺少入口文件。这是一个文件，内容应包括：

- 规范集概述和用途说明
- 项目类型识别工作流（目前散落在 SKILL.md 中）
- 完整的按需加载规则表（参照 SKILL.md 第 31-42 行）
- 跨项目通用规则（函数组件、no-any、useEffect 等）

**参考来源**：`adapters/claude-code/SKILL.md` 第 17-65 行可直接复用。

### 1.2 修复 `lint-rules.md` 死链

`lint-rules.md:144` 引用 `file-conventions.md` → 改为 `file-organization.md`

### 1.3 清理 `new-project-defaults.md` 玩笑行

删除第 60 行 `"每周一不需要专门的组件来渲染"`

### 1.4 修复 `install.sh` macOS 路径问题

```bash
# 当前（macOS 上不可用）：
AI_RULES_REL_PATH="$(realpath --relative-to="$TARGET_DIR" "$AI_RULES_DIR" 2>/dev/null || echo "")"

# 修复后（跨平台）：
AI_RULES_REL_PATH=$(python3 -c "import os.path; print(os.path.relpath('$AI_RULES_DIR', '$TARGET_DIR'))" 2>/dev/null)
```

### 涉及文件

- `frontend-standards/INDEX.md` — **新建**
- `frontend-standards/lint-rules.md` — 第 144 行
- `frontend-standards/new-project-defaults.md` — 第 60 行
- `scripts/install.sh` — 第 76 行

---

## Phase 2: 适配器一致性 — 统一 4 个工具的规则覆盖

### 2.1 在源文件中添加规则标签

在每个规范文件中，用 HTML 注释标记每条规则：

```markdown
<!-- @rule: no-any -->
<!-- @rule: function-component-only -->
<!-- @rule: import-order -->
```

这些标签是适配器生成的输入。

### 2.2 创建规则清单文件 `scripts/rules-manifest.json`

```json
{
  "version": "1.0.0",
  "rules": [
    { "id": "no-any", "source": "typescript.md", "importance": "critical", "targets": ["all"] },
    { "id": "no-var", "source": "lint-rules.md", "importance": "critical", "targets": ["all"] },
    { "id": "import-order", "source": "import-organization.md", "importance": "high", "targets": ["claude-code", "cursor", "trae"] },
    { "id": "dva-model-pattern", "source": "state-management.md", "importance": "medium", "targets": ["claude-code", "trae"] }
  ]
}
```

`targets` 控制规则进入哪个适配器。这对小适配器（CodeBuddy ~50 行）非常关键。

### 2.3 重写 `generate-adapters.sh`

推荐用 Node.js 重写（`scripts/generate-adapters.mjs`），前端团队最熟悉。

**核心生成逻辑**：

```
1. 读取 rules-manifest.json
2. 读取所有 @rule 标签从源文件
3. 对于每个工具：
   a. 筛选 importance 满足该工具容量要求的规则
   b. 从源文件中提取对应规则内容
   c. 组装成工具对应的输出格式
   d. 写入 adapters/<tool>/
4. 输出对比报告：各适配器包含的规则数
```

**各工具容量建议**：

| 工具 | 策略 | 行数上限 | 应包含规则数 |
|------|------|---------|------------|
| Claude Code | 索引 + Read 源文件 | 不限 | 全部 |
| Trae | 索引 + Read 源文件 | 不限 | 全部 |
| Cursor | 内联（两个 .mdc） | ~160 行 | critical + high |
| CodeBuddy | 内联 | ~80 行 | critical |
| Amazon Q | 内联 | ~80 行 | critical |

### 涉及文件

- `scripts/rules-manifest.json` — **新建**
- `scripts/generate-adapters.sh` — **重写为 .mjs**
- `adapters/*/` 下全部文件 — 改为自动生成
- `frontend-standards/*.md` — 全部 12 个文件添加 `@rule` 标签

---

## Phase 3: 安装与更新 — 让团队能用起来

### 3.1 默认改为 symlink 模式

`install.sh` 的 `MODE` 默认值从 `"copy"` 改为 `"symlink"`。这样 `git pull` 拉取新规则后自动生效。

### 3.2 安装时保存版本信息

安装脚本创建一个 `.ai-rules-version` 文件：

```
1.0.0
```

### 3.3 添加更新检测脚本

`scripts/check-updates.sh`：

```bash
bash ai-rules/scripts/check-updates.sh --target-dir .
# 输出: "当前版本: 1.0.0，最新版本: 1.1.0，可运行 install.sh 更新"
```

### 3.4 README 团队部署指引

补充一节"团队内部推广"，包含：
- 项目根目录运行一次安装
- 推荐写入 `package.json` 的 `postinstall` hook
- 或写入 `.husky/post-merge` 自动重新安装

### 涉及文件

- `scripts/install.sh` — 默认 symlink + 版本记录
- `scripts/check-updates.sh` — **新建**
- `README.md` — 增加团队部署小节

---

## Phase 4: 幻觉约束 — 针对 LLM 特有问题的规则增强

### 4.1 所有适配器末尾增加自检步骤

```markdown
### 代码生成后自检

- [ ] **字段名验证**：检查所有接口类型定义，字段名与 API 定义完全一致（大小写敏感）
- [ ] **幻觉字段扫描**：逐一确认没有 LLM 自行编造的字段
- [ ] **类型一致性**：interface 字段名在 API 调用处使用相同的字段名
- [ ] **命名规范**：所有新创建的文件、组件、变量是否符合命名规范
- [ ] **清理遗留**：是否有 console.log、TODO、注释掉的代码
- [ ] **副作用安全**：useEffect 依赖是否完整
```

### 4.2 新增文件：`api-field-consistency.md`

聚焦字段幻觉问题：
- 对比接口定义的检查流程
- 正确 vs 错误做法对比（优先使用你们项目真实的 API 定义举例）
- 要求 AI 在不确定字段名时**主动询问**，而不是自行推测

### 4.3 增强 ESLint 配置

- 启用 `@typescript-eslint/no-redundant-type-constituents`
- 确保 `no-unused-vars` 开启（变量定义了但未使用可能是幻觉字段）
- 推荐用 `tsd` 或 `vitest` 做类型级别的 API 响应验证

### 涉及文件

- `adapters/*/` — 全部 5 个适配器添加自检清单
- `frontend-standards/api-field-consistency.md` — **新建**

---

## Phase 5: CI 与流程 — 长期可持续保障

### 5.1 CI 适配器同步检测

```yaml
# 每次 PR 修改 frontend-standards/ 下的文件时触发
- name: Validate adapter consistency
  run: |
    bash scripts/generate-adapters.sh
    git diff --exit-code adapters/
```

### 5.2 CI 规则清单完整性检测

- 检查每个 `@rule` 标签是否在 `rules-manifest.json` 中有对应条目
- 检查每个源文件是否标注了 `@rule`

### 5.3 发布流程标准化

- 修改规范源文件 → 更新 CHANGELOG + VERSION → `generate-adapters.sh` → commit 适配器 → PR
- 升版本号时同步更新 SKILL.md 中的 `(v1.0.0)` 标记

### 涉及文件

- `.github/workflows/adapter-consistency.yml` — **新建**
- `scripts/generate-adapters.sh` — 确保 CI 中可运行
- `scripts/rules-manifest.json` — 完整性检查

---

## 文件依赖关系图

```
frontend-standards/*.md          ← 规范源（唯一权威）
         │
         ├── @rule 标签
         │      ↓
         ├── rules-manifest.json ← 规则清单（哪个规则放哪个适配器）
         │      ↓
         └── generate-adapters.mjs  →  adapters/*/  ← 自动生成
                                               │
                                               ↓
                                         install.sh → 目标项目
                                               │
                                               ↓
                                         .ai-rules-version  ← 版本追踪
                                               │
                                               ↓
                                         check-updates.sh  ← 检测新版本
```

---

## 实施优先级与工作量

| 优先级 | 阶段 | 工作量 | 依赖 | 交付价值 |
|--------|------|--------|------|---------|
| **P0** | Phase 1: 补坑 | 2 天 | 无 | 解决阻塞问题，让现有功能可用 |
| **P0** | Phase 2: 适配器一致性 | 5 天 | Phase 1 | 确保 5 个工具 AI 行为一致 |
| **P1** | Phase 3: 安装与更新 | 2 天 | 无 | 团队能部署并保持更新 |
| **P1** | Phase 4: 幻觉约束 | 2 天 | Phase 1 | 直接解决字段幻觉问题 |
| **P2** | Phase 5: CI 与流程 | 2 天 | Phase 2 | 长期可持续 |

**总计：约 13 个工作日**（单人全职），Phase 2 和 Phase 3 可并行推进。

---

## 验证方式

| 阶段 | 验证方法 |
|------|---------|
| Phase 1 | 读取 INDEX.md 确认存在；检查 lint-rules.md 死链已修复 |
| Phase 2 | 运行 `generate-adapters.sh` → 确认 `adapters/*/` 下文件被重新生成 → 核验 CodeBuddy 适配器包含 critical 规则 |
| Phase 3 | 创建临时目录运行 `install.sh` → 检查 SKILL.md 存在且路径正确 → 运行 `check-updates.sh` 确认版本对比正常 |
| Phase 4 | 用 Claude Code 生成一个假组件 → 检查输出末尾是否包含自检清单 |
| Phase 5 | 修改一个源文件并提交 PR → CI 应检测到适配器未同步并报错 |
