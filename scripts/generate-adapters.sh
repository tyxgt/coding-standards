#!/bin/bash
set -euo pipefail

# ==============================================================
# coding-standards 适配器同步验证脚本
# 验证各工具适配器是否与 canonical 规范源保持同步。
# 在修改 frontend-standards/ 下的规范后运行此脚本检查一致性。
#
# 用法:
#   bash scripts/generate-adapters.sh          # 检查所有适配器
#   bash scripts/generate-adapters.sh --fix    # 尝试自动修复（生成提示）
# ==============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODING_STANDARDS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIX_MODE=false

if [[ "${1:-}" == "--fix" ]]; then
  FIX_MODE=true
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

HAS_ERROR=false
HAS_WARNING=false

# ==============================================================
# 工具函数
# ==============================================================

# 检测文件变更时间：如果 source 比 adapter 新，则报告可能的漂移
check_freshness() {
  local source="$1"
  local adapter="$2"
  local label="$3"

  if [ ! -f "$adapter" ]; then
    echo -e "  ${RED}✗ 适配器文件不存在${NC}: $adapter"
    return 1
  fi

  local source_mtime=$(stat -f "%m" "$source" 2>/dev/null || stat -c "%Y" "$source" 2>/dev/null || echo "0")
  local adapter_mtime=$(stat -f "%m" "$adapter" 2>/dev/null || stat -c "%Y" "$adapter" 2>/dev/null || echo "0")

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

# ==============================================================
# 适配器列表
# ==============================================================

ADAPTER_DIR="$CODING_STANDARDS_DIR/adapters"
FRONTEND_DIR="$CODING_STANDARDS_DIR/frontend-standards"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  coding-standards 适配器同步验证${NC}"
echo -e "${CYAN}================================${NC}"
echo ""
echo -e "规范源目录: ${FRONTEND_DIR}"
echo -e "适配器目录: ${ADAPTER_DIR}"
echo -e "修复模式:   ${FIX_MODE}"
echo ""

# ==============================================================
# 1. 文件变更时间检测
# ==============================================================
echo -e "${YELLOW}--- 1. 文件变更时间检测 ---${NC}"
echo ""

check_source_freshness() {
  local source_file="$1"
  local adapter_file="$CODING_STANDARDS_DIR/$2"

  if [ -f "$source_file" ] && [ -f "$adapter_file" ]; then
    echo -e "  $(basename "$source_file") → $2"
    check_freshness "$source_file" "$adapter_file" "" && echo -e "  ${GREEN}✓ 适配器是最新的${NC}" || true
    echo ""
  fi
}

# 重新组织：对每个适配器，检查相关的所有 source 文件
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

echo ""

# ==============================================================
# 2. 规则覆盖检测
# ==============================================================
echo -e "${YELLOW}--- 2. 规则覆盖检测 ---${NC}"
echo ""

# --- Cursor 010-frontend-core.mdc ---
CURSOR_010="$ADAPTER_DIR/cursor/010-frontend-core.mdc"
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

# --- Cursor 020-frontend-imports-state.mdc ---
CURSOR_020="$ADAPTER_DIR/cursor/020-frontend-imports-state.mdc"
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

# --- CodeBuddy frontend-standards.md ---
CODEBUDDY="$ADAPTER_DIR/codebuddy/frontend-standards.md"
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

# ==============================================================
# 3. SKILL.md 同步检查（Claude Code vs Trae）
# ==============================================================
echo -e "${YELLOW}--- 3. Claude Code vs Trae SKILL.md 一致性检测 ---${NC}"
echo ""

CLAUDE_SKILL="$ADAPTER_DIR/claude-code/SKILL.md"
TRAE_SKILL="$ADAPTER_DIR/trae/SKILL.md"

if [ -f "$CLAUDE_SKILL" ] && [ -f "$TRAE_SKILL" ]; then
  # 检查任务映射表行数
  CLAUDE_TASK_LINES=$(grep -c '|.*\..*md|' "$CLAUDE_SKILL" 2>/dev/null || echo "0")
  TRAE_TASK_LINES=$(grep -c '|.*\..*md|' "$TRAE_SKILL" 2>/dev/null || echo "0")

  echo -e "  Claude Code 任务映射条目: $(grep -c '|.*\..*md.*|' "$CLAUDE_SKILL" 2>/dev/null || echo "0")"
  echo -e "  Trae        任务映射条目: $(grep -c '|.*\..*md.*|' "$TRAE_SKILL" 2>/dev/null || echo "0")"

  # 检查 react-jsx.md 是否在 Trae 中缺失
  if grep -q "react-jsx" "$CLAUDE_SKILL" 2>/dev/null; then
    if ! grep -q "react-jsx" "$TRAE_SKILL" 2>/dev/null; then
      echo -e "  ${YELLOW}⚠ Trae SKILL.md 缺少 react-jsx.md 条目${NC}"
      HAS_WARNING=true
    fi
  fi

  if grep -q "code-style" "$CLAUDE_SKILL" 2>/dev/null; then
    if ! grep -q "code-style" "$TRAE_SKILL" 2>/dev/null; then
      echo -e "  ${YELLOW}⚠ Trae SKILL.md 缺少 code-style.md 条目${NC}"
      HAS_WARNING=true
    fi
  fi

  # 检查通用规则数量
  CLAUDE_RULES=$(grep -c '^- ' "$CLAUDE_SKILL" 2>/dev/null || echo "0")
  TRAE_RULES=$(grep -c '^- ' "$TRAE_SKILL" 2>/dev/null || echo "0")
  echo -e "  Claude Code 通用规则: $CLAUDE_RULES 条"
  echo -e "  Trae        通用规则: $TRAE_RULES 条"

  if ! diff <(grep '^- ' "$CLAUDE_SKILL" 2>/dev/null) <(grep '^- ' "$TRAE_SKILL" 2>/dev/null) >/dev/null 2>&1; then
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
  echo -e "  ${YELLOW}⚠  SKILL.md 文件缺失，跳过对比${NC}"
  HAS_WARNING=true
fi

echo ""

# ==============================================================
# 4. 结果汇总
# ==============================================================
echo -e "${YELLOW}--- 4. 结果汇总 ---${NC}"
echo ""

if $HAS_ERROR; then
  echo -e "${RED}✗ 发现适配器与规范源之间存在差异。${NC}"
  echo -e "${RED}  请根据上述提示更新对应的适配器文件。${NC}"
  echo ""
  echo "更新指引:"
  echo "  adapters/cursor/010-frontend-core.mdc         → 编辑内联规则"
  echo "  adapters/cursor/020-frontend-imports-state.mdc → 编辑内联规则"
  echo "  adapters/codebuddy/frontend-standards.md       → 编辑内联规则"
  exit 1
elif $HAS_WARNING; then
  echo -e "${YELLOW}⚠ 存在警告（非阻塞），建议查看上述标注项。${NC}"
  exit 0
else
  echo -e "${GREEN}✓ 所有适配器与规范源保持一致！${NC}"
  exit 0
fi
