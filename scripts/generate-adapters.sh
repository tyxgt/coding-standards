#!/bin/bash
# ==============================================================
# coding-standards 适配器同步验证 + 生成脚本
# 双模式：
#   --check    验证各工具适配器是否与规范源保持同步（默认模式）
#   --generate 从规范源自动生成适配器内联内容
# ==============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODING_STANDARDS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ADAPTER_DIR="$CODING_STANDARDS_DIR/adapters"
FRONTEND_DIR="$CODING_STANDARDS_DIR/frontend-standards"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

HAS_ERROR=false
HAS_WARNING=false
CHECK_MODE=false
GENERATE_MODE=false
FIX_MODE=false

usage() {
  echo "用法: $0 [选项]"
  echo ""
  echo "双模式脚本：验证适配器一致性 或 从规范源自动生成适配器。"
  echo ""
  echo "选项:"
  echo "  --check     验证适配器与规范源一致性 (默认未指定flag时的行为)"
  echo "  --generate  从规范源自动生成适配器内联内容"
  echo "  --fix       尝试自动修复（目前仅 check 模式下有效）"
  echo "  --help      显示此帮助"
  echo ""
  echo "示例:"
  echo "  $0                               # 检查所有适配器"
  echo "  $0 --check                       # 同上，显式指定"
  echo "  $0 --generate                    # 生成适配器"
  echo "  $0 --generate --check            # 生成后再检查一致性"
  exit 0
}

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) CHECK_MODE=true; shift ;;
    --generate) GENERATE_MODE=true; shift ;;
    --fix) FIX_MODE=true; shift ;;
    --help) usage ;;
    *) echo "未知选项: $1"; usage ;;
  esac
done

# 未指定任何模式 → 默认 check
if ! $CHECK_MODE && ! $GENERATE_MODE; then
  CHECK_MODE=true
fi

# ==============================================================
# 工具函数
# ==============================================================

# 检测文件变更时间：如果 source 比 adapter 新，则报告可能的漂移
check_freshness() {
  local source="$1"
  local adapter="$2"

  if [ ! -f "$adapter" ]; then
    echo -e "  ${RED}✗ 适配器文件不存在${NC}: $adapter"
    return 1
  fi

  local source_mtime adapter_mtime
  source_mtime=$(stat -f "%m" "$source" 2>/dev/null || stat -c "%Y" "$source" 2>/dev/null || echo "0")
  adapter_mtime=$(stat -f "%m" "$adapter" 2>/dev/null || stat -c "%Y" "$adapter" 2>/dev/null || echo "0")

  if [ "$source_mtime" -gt "$adapter_mtime" ] 2>/dev/null; then
    echo -e "  ${YELLOW}⚠ 规范源文件已更新（适配器可能过时）${NC}"
    echo -e "    source:  $(basename "$source") ($(date -r "$source" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "?"))"
    echo -e "    adapter: $(basename "$adapter") ($(date -r "$adapter" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "?"))"
    return 2
  fi
  return 0
}

# 检查适配器是否包含某条规则（模糊匹配）
check_rule() {
  local adapter="$1"
  local pattern="$2"
  local rule_name="$3"

  if grep -qi "$pattern" "$adapter" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $rule_name"
    return 0
  else
    echo -e "  ${RED}✗ 缺失${NC}: $rule_name (未匹配 \"$pattern\")"
    HAS_ERROR=true
    return 1
  fi
}

# 检查 source 文件新旧
check_source_freshness() {
  local source_file="$1"
  local adapter_file="$CODING_STANDARDS_DIR/$2"

  if [ -f "$source_file" ] && [ -f "$adapter_file" ]; then
    echo -e "  $(basename "$source_file") → $2"
    check_freshness "$source_file" "$adapter_file" && echo -e "  ${GREEN}✓ 适配器是最新的${NC}" || true
    echo ""
  fi
}

# 从 source 文件提取规范表格行
extract_table_rows() {
  local source="$1"
  local keywords="$2"
  local max_lines="${3:-10}"

  if [ ! -f "$source" ]; then
    return
  fi

  if [ -n "$keywords" ]; then
    grep -E "^\|.*($keywords).*\|" "$source" 2>/dev/null | head -n "$max_lines" || true
  else
    # 不指定关键词时提取所有表格行（跳过表头对齐行）
    grep -E "^\|.+\|" "$source" 2>/dev/null | grep -v "^\|---" | head -n "$max_lines" || true
  fi
}

# 从 source 文件提取规范列表项
extract_list_items() {
  local source="$1"
  local keywords="$2"
  local max_lines="${3:-15}"

  if [ ! -f "$source" ]; then
    return
  fi

  if [ -n "$keywords" ]; then
    grep -E "^- .*($keywords).*" "$source" 2>/dev/null | head -n "$max_lines" || true
  else
    grep -E "^- " "$source" 2>/dev/null | head -n "$max_lines" || true
  fi
}

# ==============================================================
# 1. CHECK 模式：验证适配器一致性
# ==============================================================
run_check() {
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}  coding-standards 适配器同步验证${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""
  echo -e "规范源目录: ${FRONTEND_DIR}"
  echo -e "适配器目录: ${ADAPTER_DIR}"
  echo ""

  # --- 1. 文件变更时间检测 ---
  echo -e "${YELLOW}--- 1. 文件变更时间检测 ---${NC}"
  echo ""

  local adapter_rel
  for adapter_rel in "adapters/cursor/010-frontend-core.mdc" "adapters/cursor/020-frontend-imports-state.mdc" "adapters/codebuddy/frontend-standards.md"; do
    echo -e "  ${CYAN}$adapter_rel${NC}"
    adapter_file="$CODING_STANDARDS_DIR/$adapter_rel"
    if [ ! -f "$adapter_file" ]; then
      echo -e "  ${RED}✗ 文件不存在${NC}"
      echo ""
      continue
    fi

    case "$adapter_rel" in
      "adapters/cursor/010-frontend-core.mdc")
        for src in "naming-conventions.md" "component-patterns.md" "styling.md" "typescript.md"; do
          check_source_freshness "$FRONTEND_DIR/$src" "$adapter_rel"
        done
        ;;
      "adapters/cursor/020-frontend-imports-state.mdc")
        for src in "import-organization.md" "state-management.md" "api-requests.md"; do
          check_source_freshness "$FRONTEND_DIR/$src" "$adapter_rel"
        done
        ;;
      "adapters/codebuddy/frontend-standards.md")
        for src in "naming-conventions.md" "component-patterns.md" "import-organization.md" "state-management.md" "styling.md" "typescript.md" "api-requests.md"; do
          check_source_freshness "$FRONTEND_DIR/$src" "$adapter_rel"
        done
        ;;
    esac
  done

  # --- 2. 规则覆盖检测 ---
  echo -e "${YELLOW}--- 2. 规则覆盖检测 ---${NC}"
  echo ""

  # Cursor 010-frontend-core.mdc
  local CURSOR_010="$ADAPTER_DIR/cursor/010-frontend-core.mdc"
  echo -e "${CYAN}[Cursor 010-frontend-core.mdc]${NC}"
  echo -e "  对应规范源: naming-conventions.md, component-patterns.md, styling.md, typescript.md"
  echo ""

  check_rule "$CURSOR_010" "PascalCase\|页面.*PascalCase" "页面目录 PascalCase 命名"
  check_rule "$CURSOR_010" "camelCase\|组件.*camelCase" "组件目录 camelCase 命名"
  check_rule "$CURSOR_010" "index\.tsx" "文件入口 index.tsx"
  check_rule "$CURSOR_010" "use[A-Z]" "Hook 文件 useXxx.ts"
  check_rule "$CURSOR_010" "300.*行\|≤ 300" "单文件 ≤ 300 行"
  check_rule "$CURSOR_010" "8.*个\|≤ 8" "Props ≤ 8 个"
  check_rule "$CURSOR_010" "useEffect.*4\|≤.*useEffect\|4 个" "useEffect ≤ 4 个"
  check_rule "$CURSOR_010" "CSS Modules\|CSS Modules" "CSS Modules 组件样式"
  check_rule "$CURSOR_010" "camelCase.*命名\|styles\.container" "camelCase 样式命名"
  check_rule "$CURSOR_010" "global\.less\|kebab-case.*全局" "全局样式 kebab-case"
  check_rule "$CURSOR_010" "!important\|禁止.*!important" "禁止 !important"
  check_rule "$CURSOR_010" "interface.*Props\|Props.*interface" "Props 用 interface"
  check_rule "$CURSOR_010" "import type\|类型导入" "import type 类型导入"
  check_rule "$CURSOR_010" "@ts-ignore\|@ts-expect-error" "禁止 @ts-ignore"
  check_rule "$CURSOR_010" "非空断言\|!.*断言" "禁止 ! 非空断言"
  check_rule "$CURSOR_010" "any" "禁止 any"
  check_rule "$CURSOR_010" "内联.*样式\|内联静态" "禁止内联静态样式"
  echo ""

  # Cursor 020-frontend-imports-state.mdc
  local CURSOR_020="$ADAPTER_DIR/cursor/020-frontend-imports-state.mdc"
  echo -e "${CYAN}[Cursor 020-frontend-imports-state.mdc]${NC}"
  echo -e "  对应规范源: import-organization.md, state-management.md, api-requests.md"
  echo ""

  check_rule "$CURSOR_020" "React.*antd.*ahooks.*@/.*相对.*样式.*import type\|React.*antd\|第.*方\|内部别名\|相对路径\|样式.*导入\|类型导入" "Import 7 组分组顺序"
  check_rule "$CURSOR_020" "@/.*->.*src\|@/.*→.*src\|路径别名" "路径别名 @/ → src/"
  check_rule "$CURSOR_020" "3 层\|不超过.*3" "相对路径不超过 3 层"
  check_rule "$CURSOR_020" "useState.*store\|本地.*useState\|全局.*store\|Dva\|RTK\|Zustand" "状态管理: 本地 useState / 全局 store"
  check_rule "$CURSOR_020" "就近\|最近层级" "状态就近原则"
  check_rule "$CURSOR_020" "不直接修改 state\|直接修改" "禁止直接修改 state"
  check_rule "$CURSOR_020" "不混用\|多种.*状态管理" "不混用状态管理方案"
  check_rule "$CURSOR_020" "axios.*create\|baseURL\|intercept" "统一请求实例 + 拦截器"
  check_rule "$CURSOR_020" "code.*0.*data\|401.*登录" "响应处理: code===0 / 401"
  check_rule "$CURSOR_020" "字段名.*接口\|大小写" "字段名与接口定义一致"
  check_rule "$CURSOR_020" "loading\|loading 状态" "每个请求对应 loading 状态"
  echo ""

  # CodeBuddy frontend-standards.md
  local CODEBUDDY="$ADAPTER_DIR/codebuddy/frontend-standards.md"
  echo -e "${CYAN}[CodeBuddy frontend-standards.md]${NC}"
  echo -e "  对应规范源: 所有 10 个文件（内联嵌入）"
  echo ""

  check_rule "$CODEBUDDY" "PascalCase\|页面.*PascalCase" "页面目录 PascalCase 命名"
  check_rule "$CODEBUDDY" "index\.tsx.*useXxx\|入口.*index" "文件入口 index.tsx + Hook useXxx.ts"
  check_rule "$CODEBUDDY" "300.*行\|≤ 300" "单文件 ≤ 300 行"
  check_rule "$CODEBUDDY" "8.*个\|≤ 8" "Props ≤ 8 个"
  check_rule "$CODEBUDDY" "Props.*type.*state.*effect.*渲染\|Props 类型.*组件.*state" "组件结构顺序"
  check_rule "$CODEBUDDY" "默认导出\|命名导出" "默认导出组件，命名导出类型"
  check_rule "$CODEBUDDY" "核心库.*UI 库.*工具库.*@/.*相对路径\|导入.*顺序" "Import 7 组分组顺序"
  check_rule "$CODEBUDDY" "@/.*别名\|@/.*跨目录\|相对路径.*3 层" "路径别名 @/ + 相对路径 ≤ 3 层"
  check_rule "$CODEBUDDY" "useState.*store\|本地.*useState\|全局.*Dva\|RTK\|Zustand" "状态管理: 本地 / 全局"
  check_rule "$CODEBUDDY" "就近\|就近原则" "状态就近原则"
  check_rule "$CODEBUDDY" "CSS Modules\|Less.*CSS\|Tailwind" "CSS Modules / Less / Tailwind"
  check_rule "$CODEBUDDY" "!important\|禁止.*!important" "禁止 !important"
  check_rule "$CODEBUDDY" "内联静态\|内联.*样式" "禁止内联静态样式"
  check_rule "$CODEBUDDY" "interface.*Props\|Props.*interface\|import type" "Props interface + import type"
  check_rule "$CODEBUDDY" "@ts-ignore.*非空\|@ts-ignore.*Function" "禁止 @ts-ignore/!/Function"
  check_rule "$CODEBUDDY" "any" "禁止 any"
  check_rule "$CODEBUDDY" "统一请求.*拦截器\|intercept" "统一请求实例 + 拦截器"
  check_rule "$CODEBUDDY" "字段名.*接口\|大小写.*敏感" "字段名与接口定义一致"
  check_rule "$CODEBUDDY" "loading\|loading 状态" "每个请求对应 loading 状态"
  check_rule "$CODEBUDDY" "本地配置优先\|本地.*优先" "本地配置优先"
  echo ""

  # --- 3. SKILL.md 同步检查（Claude Code vs Trae） ---
  echo -e "${YELLOW}--- 3. Claude Code vs Trae SKILL.md 一致性检测 ---${NC}"
  echo ""

  local CLAUDE_SKILL="$ADAPTER_DIR/claude-code/SKILL.md"
  local TRAE_SKILL="$ADAPTER_DIR/trae/SKILL.md"

  if [ -f "$CLAUDE_SKILL" ] && [ -f "$TRAE_SKILL" ]; then
    echo -e "  Claude Code 任务映射条目: $(grep -c '|.*\..*md.*|' "$CLAUDE_SKILL" 2>/dev/null || echo "0")"
    echo -e "  Trae        任务映射条目: $(grep -c '|.*\..*md.*|' "$TRAE_SKILL" 2>/dev/null || echo "0")"

    if grep -q "react-jsx" "$CLAUDE_SKILL" 2>/dev/null && ! grep -q "react-jsx" "$TRAE_SKILL" 2>/dev/null; then
      echo -e "  ${YELLOW}⚠ Trae SKILL.md 缺少 react-jsx.md 条目${NC}"
      HAS_WARNING=true
    fi
    if grep -q "code-style" "$CLAUDE_SKILL" 2>/dev/null && ! grep -q "code-style" "$TRAE_SKILL" 2>/dev/null; then
      echo -e "  ${YELLOW}⚠ Trae SKILL.md 缺少 code-style.md 条目${NC}"
      HAS_WARNING=true
    fi

    local CLAUDE_RULES TRAE_RULES
    CLAUDE_RULES=$(grep -c '^- ' "$CLAUDE_SKILL" 2>/dev/null || echo "0")
    TRAE_RULES=$(grep -c '^- ' "$TRAE_SKILL" 2>/dev/null || echo "0")
    echo -e "  Claude Code 通用规则: $CLAUDE_RULES 条"
    echo -e "  Trae        通用规则: $TRAE_RULES 条"

    if diff <(grep '^- ' "$CLAUDE_SKILL" 2>/dev/null) <(grep '^- ' "$TRAE_SKILL" 2>/dev/null) >/dev/null 2>&1; then
      :
    else
      echo -e "  ${YELLOW}⚠ 两套 SKILL.md 的通用规则条目不同${NC}"
      HAS_WARNING=true
    fi
    echo ""
    if $HAS_WARNING; then
      echo -e "  ${YELLOW}建议: 手动同步两个 SKILL.md 文件以保持一致${NC}"
    else
      echo -e "  ${GREEN}✓ Claude Code 和 Trae SKILL.md 保持一致${NC}"
    fi
  else
    echo -e "  ${YELLOW}⚠ SKILL.md 文件缺失，跳过对比${NC}"
    HAS_WARNING=true
  fi
  echo ""

  # --- 4. @trigger 对齐检测（新增） ---
  echo -e "${YELLOW}--- 4. @trigger 与 SKILL.md 任务表对齐检测 ---${NC}"
  echo ""

  check_trigger_alignment
  echo ""
}

# ==============================================================
# @trigger 对齐检测
# ==============================================================
check_trigger_alignment() {
  local trig_mismatch=false

  echo -e "  验证每个规范文件的 @trigger 是否在 SKILL.md 任务表中被覆盖:"
  echo ""

  local skill_files=("$CODING_STANDARDS_DIR/SKILL.md" "$ADAPTER_DIR/claude-code/SKILL.md" "$ADAPTER_DIR/trae/SKILL.md")
  # source 文件列表（不需要关联数组，逐项处理即可）
  local sources=("naming-conventions.md" "file-organization.md" "component-patterns.md" "react-jsx.md" "code-style.md" "import-organization.md" "state-management.md" "api-requests.md" "styling.md" "typescript.md")

  for file in "${skill_files[@]}"; do
    local fname
    fname=$(basename "$file")
    if [ ! -f "$file" ]; then
      echo -e "  ${YELLOW}⚠ 跳过（文件不存在）: $fname${NC}"
      continue
    fi

    local all_covered=true
    local src_file
    for src_file in "${sources[@]}"; do
      if ! grep -q "$src_file" "$file" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠ $fname 未引用 $src_file${NC}"
        all_covered=false
      fi
    done

    if $all_covered; then
      echo -e "  ${GREEN}✓${NC} $fname 所有 @trigger 均在任务表中有对应条目"
    else
      echo -e "  ${YELLOW}⚠ $fname 存在未全部引用的 source 文件${NC}"
      trig_mismatch=true
    fi
    echo ""
  done

  if $trig_mismatch; then
    echo -e "  ${YELLOW}建议: 如修改了规范文件的 @trigger，请同步更新 SKILL.md 任务表和附录${NC}"
    HAS_WARNING=true
  else
    echo -e "  ${GREEN}✓ 所有 @trigger 与 SKILL.md 任务表对齐${NC}"
  fi
}

# ==============================================================
# 2. GENERATE 模式：从规范源生成适配器
# ==============================================================

# 生成 Cursor 010-frontend-core.mdc
generate_cursor_010() {
  local output="$ADAPTER_DIR/cursor/010-frontend-core.mdc"
  echo -e "  生成 ${CYAN}adapters/cursor/010-frontend-core.mdc${NC}"

  cat > "$output" << 'MDEOF'
---
description: 前端编码规范核心（命名、组件约束、样式方案、TypeScript禁止项）
globs: "*.tsx,*.ts,*.jsx,*.js,*.less,*.css"
alwaysApply: true
---

# 前端编码规范核心 (v2.0.0)

## 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
MDEOF

  # 从 naming-conventions.md 提取命名表格行
  extract_table_rows "$FRONTEND_DIR/naming-conventions.md" "页面目录|组件.*目录|入口|Hook|样式文件|类型定义|工具函数|表格列配置|子页面|网络请求" 10 >> "$output"

  cat >> "$output" << 'MDEOF'

## 组件约束

MDEOF

  # 从 component-patterns.md 提取组件大小限制（表格行）
  extract_table_rows "$FRONTEND_DIR/component-patterns.md" "单文件最大|Props.*数量|useEffect|条件渲染" 4 >> "$output"
  # 结构顺序（来自 component-patterns.md 的编号列表，浓缩为一行）
  echo "- 结构顺序：Props 类型 → 组件 → state → effect → 事件 → 渲染" >> "$output"
  # 导出约定
  grep -E "默认导出|命名导出" "$FRONTEND_DIR/component-patterns.md" 2>/dev/null | head -2 >> "$output" || true

  cat >> "$output" << 'MDEOF'

## 样式规范

| 类别 | 规范 |
|------|------|
MDEOF

  # 从 styling.md 提取样式方案表
  extract_table_rows "$FRONTEND_DIR/styling.md" "CSS Modules|全局样式|方案选择|!important|选择器嵌套" 6 >> "$output"

  cat >> "$output" << 'MDEOF'

## TypeScript

MDEOF

  # 从 typescript.md 提取类型规则和禁止项
  echo "- Props 定义用 interface，联合类型用 type" >> "$output"
  echo "- import type 用于类型导入" >> "$output"
  # 提取禁止项列表
  extract_list_items "$FRONTEND_DIR/typescript.md" "any|@ts-ignore|非空|Function|基本类型" 5 >> "$output"

  cat >> "$output" << 'MDEOF'

## 禁止

- ❌ `any`、`@ts-ignore`
- ❌ 内联静态样式
- ❌ 直接修改 state
- ❌ 循环依赖，嵌套三元
- ❌ `console.log` 遗留到生产
MDEOF

  echo -e "    ${GREEN}✓${NC} 已生成 ($(wc -l < "$output") 行)"
}

# 生成 Cursor 020-frontend-imports-state.mdc
generate_cursor_020() {
  local output="$ADAPTER_DIR/cursor/020-frontend-imports-state.mdc"
  echo -e "  生成 ${CYAN}adapters/cursor/020-frontend-imports-state.mdc${NC}"

  cat > "$output" << 'MDEOF'
---
description: 导入规范、状态管理、API 请求模式
globs: "*.tsx,*.ts,*.jsx,*.js"
alwaysApply: false
---

# 导入与状态管理 (v2.0.0)

## 导入分组顺序

每组空一行，同类按字母序：

1. 核心库（React 等）
2. 第三方 UI 库（antd 等）
3. 第三方工具库（ahooks 等）
4. 内部别名（`@/`）
5. 相对路径
6. 样式（`import styles`）
7. 类型导入（`import type`）

### 路径别名
- `@/` → `src/`，同一页面内用相对路径
- 相对路径不超过 3 层，超过用 `@/`

## 状态管理决策

| 状态类型 | 推荐位置 |
|----------|----------|
MDEOF

  # 从 state-management.md 提取状态管理决策表
  extract_table_rows "$FRONTEND_DIR/state-management.md" "表单输入|用户登录|弹窗|权限|加载状态" 4 >> "$output"

  cat >> "$output" << 'MDEOF'

- 就近原则：状态放在需要它的最近层级
- 不直接修改 state；不混用多种状态管理方案

## API 请求模式

```typescript
// 统一请求实例 + 拦截器
const request = axios.create({ baseURL: '/api', timeout: 30000 });
// 响应 code === 0 → data，401 → 登录页，其他 → 错误提示
```

- 按模块封装 API，函数命名 `getXxx/createXxx/updateXxx/deleteXxx`
- 字段名必须与接口定义完全一致（大小写敏感）
- 每个请求有对应的 loading 状态
MDEOF

  echo -e "    ${GREEN}✓${NC} 已生成 ($(wc -l < "$output") 行)"
}

# 生成 CodeBuddy frontend-standards.md
generate_codebuddy() {
  local output="$ADAPTER_DIR/codebuddy/frontend-standards.md"
  echo -e "  生成 ${CYAN}adapters/codebuddy/frontend-standards.md${NC}"

  cat > "$output" << 'MDEOF'
---
description: 前端编码规范 - 命名、组件约束、导入、状态管理、样式、TypeScript
alwaysApply: true
enabled: true
paths:
  - "src/**/*.{ts,tsx,js,jsx,less,css}"
updatedAt: "2026-06-05"
---

# 前端编码规范 (v2.0.0)

## 命名
- 目录：页面 PascalCase，组件 camelCase
- 文件：入口 `index.tsx`，Hook `useXxx.ts`

## 组件
- 单文件 ≤ 300 行，Props ≤ 8 个
MDEOF

  echo "- 结构：Props 类型 → 组件 → state → effect → 事件 → 渲染" >> "$output"
  echo "- 默认导出组件，命名导出类型" >> "$output"

  cat >> "$output" << 'MDEOF'

## 导入
顺序：核心库 → UI 库 → 工具库 → `@/` 别名 → 相对路径 → 样式 → `import type`
每组空一行。`@/` 跨目录，相对路径不超过 3 层。

## 状态管理
- 就近原则：本地用 useState，全局用 Dva/RTK/Zustand
- 不直接修改 state，不混用方案

## 样式
- CSS Modules 优先，camelCase 命名（`styles.container` ✅，禁止 `styles['kebab-case']` ❌）
MDEOF

  # 从 styling.md 提取方案选择规则
  grep -E "Umi.*Less|Vite.*CSS Modules|Tailwind|禁止内联|!important|选择器嵌套" "$FRONTEND_DIR/styling.md" 2>/dev/null | head -6 >> "$output" || true

  cat >> "$output" << 'MDEOF'

## TypeScript
- Props 用 `interface`，联合类型用 `type`
- `import type` 用于类型导入
- 禁止 `@ts-ignore`、`!` 非空断言、`Function` 类型

## API
- 统一请求实例 + 拦截器，code === 0 → data，401 → 登录页
- 字段名必须与接口定义完全一致（大小写敏感）
- 每个请求有对应 loading 状态

## 禁止
- `any`、`@ts-ignore`、class 组件、内联静态样式
- 直接修改 state、循环依赖、`console.log` 遗留到生产
- 本地配置优先于本规范，不修改已有代码
MDEOF

  echo -e "    ${GREEN}✓${NC} 已生成 ($(wc -l < "$output") 行)"
}

# ==============================================================
# 生成模式入口
# ==============================================================
run_generate() {
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}  coding-standards 适配器自动生成${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""
  echo -e "规范源目录: ${FRONTEND_DIR}"
  echo -e "适配器目录: ${ADAPTER_DIR}"
  echo ""

  local GENERATED=0

  # 生成 Cursor 适配器
  if [ -d "$ADAPTER_DIR/cursor" ]; then
    echo -e "${YELLOW}[Cursor]${NC}"
    generate_cursor_010
    generate_cursor_020
    GENERATED=$((GENERATED + 2))
    echo ""
  fi

  # 生成 CodeBuddy 适配器
  if [ -d "$ADAPTER_DIR/codebuddy" ]; then
    echo -e "${YELLOW}[CodeBuddy]${NC}"
    generate_codebuddy
    GENERATED=$((GENERATED + 1))
    echo ""
  fi

  echo -e "${GREEN}✓ 已生成 $GENERATED 个适配器文件${NC}"
  echo ""
  echo -e "${YELLOW}提示: 运行 $0 --check 验证生成的内容是否完整${NC}"
  echo ""
}

# ==============================================================
# 结果汇总
# ==============================================================
print_summary() {
  if $CHECK_MODE; then
    echo -e "${YELLOW}--- 5. 结果汇总 ---${NC}"
    echo ""
    if $HAS_ERROR; then
      echo -e "${RED}✗ 发现适配器与规范源之间存在差异。${NC}"
      echo -e "${RED}  请根据上述提示更新对应的适配器文件。${NC}"
      echo ""
      echo "更新指引:"
      echo "  adapters/cursor/010-frontend-core.mdc         → 编辑内联规则或运行 --generate"
      echo "  adapters/cursor/020-frontend-imports-state.mdc → 编辑内联规则或运行 --generate"
      echo "  adapters/codebuddy/frontend-standards.md       → 编辑内联规则或运行 --generate"
      exit 1
    elif $HAS_WARNING; then
      echo -e "${YELLOW}⚠ 存在警告（非阻塞），建议查看上述标注项。${NC}"
      exit 0
    else
      echo -e "${GREEN}✓ 所有适配器与规范源保持一致！${NC}"
      exit 0
    fi
  fi
}

# ==============================================================
# 主逻辑
# ==============================================================

if $GENERATE_MODE; then
  run_generate
fi

if $CHECK_MODE; then
  run_check
  print_summary
fi
