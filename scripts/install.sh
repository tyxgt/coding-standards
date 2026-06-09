#!/bin/bash
set -euo pipefail

# ==============================================================
# coding-standards 多工具适配器安装脚本
# 将前端编码规范安装到目标项目的各工具配置目录中
# ==============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODING_STANDARDS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
  echo "用法: $0 [选项]"
  echo ""
  echo "将 coding-standards 前端编码规范安装到目标项目中。"
  echo ""
  echo "选项:"
  echo "  --target-dir DIR   目标项目目录 (默认: 当前工作目录)"
  echo "  --tools TOOLS      要安装的工具，逗号分隔 (默认: all)"
  echo "                     可用: claude-code,cursor,trae,codebuddy"
  echo "  --mode MODE        安装模式: copy|symlink (默认: copy)"
  echo "  --coding-standards-path    指定从目标项目到 coding-standards 的路径 (默认: 自动检测)"
  echo "  --help             显示此帮助信息"
  echo ""
  echo "示例:"
  echo "  $0 --target-dir /path/to/your/project"
  echo "  $0 --tools cursor,codebuddy"
  echo "  $0 --target-dir . --mode symlink"
  exit 0
}

# 解析参数
TARGET_DIR="${PWD}"
TOOLS="all"
MODE="copy"
CODING_STANDARDS_REL_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-dir) TARGET_DIR="$2"; shift 2 ;;
    --tools) TOOLS="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --coding-standards-path) CODING_STANDARDS_REL_PATH="$2"; shift 2 ;;
    --help) usage ;;
    *) echo "未知选项: $1"; usage ;;
  esac
done

# 解析工具列表
if [ "$TOOLS" = "all" ]; then
  TOOL_LIST=("claude-code" "cursor" "trae" "codebuddy")
else
  IFS=',' read -ra TOOL_LIST <<< "$TOOLS"
fi

# 验证目标目录
if [ ! -d "$TARGET_DIR" ]; then
  echo -e "${RED}错误: 目标目录不存在: $TARGET_DIR${NC}"
  exit 1
fi

if [ "$TARGET_DIR" = "$CODING_STANDARDS_DIR" ]; then
  echo -e "${RED}错误: 目标目录不能是 coding-standards 项目目录本身${NC}"
  echo "请指定要安装到的前端项目目录。"
  exit 1
fi

# 计算 coding-standards 相对路径
if [ -z "$CODING_STANDARDS_REL_PATH" ]; then
  CODING_STANDARDS_REL_PATH="$(realpath --relative-to="$TARGET_DIR" "$CODING_STANDARDS_DIR" 2>/dev/null || echo "")"
  if [ -z "$CODING_STANDARDS_REL_PATH" ]; then
    # macOS 没有 realpath --relative-to
    CODING_STANDARDS_REL_PATH="coding-standards"
    echo -e "${YELLOW}⚠ 无法计算相对路径，使用默认值: $CODING_STANDARDS_REL_PATH${NC}"
  fi
fi

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  coding-standards 安装脚本${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo "  目标项目:   $TARGET_DIR"
echo "  coding-standards:   $CODING_STANDARDS_DIR"
echo "  相对路径:   $CODING_STANDARDS_REL_PATH"
echo "  工具:       ${TOOLS}"
echo "  模式:       $MODE"
echo ""

INSTALLED=()
SKIPPED=()

install_file() {
  local src="$1"
  local dst="$2"
  local placeholder_path="$3"

  mkdir -p "$(dirname "$dst")"

  if [ -n "$placeholder_path" ]; then
    # 含 {{CODING_STANDARDS_PATH}} 占位符 → 必须 sed 替换路径，无法使用符号链接
    sed "s|{{CODING_STANDARDS_PATH}}|$placeholder_path|g" "$src" > "$dst"
    echo -e "  ${GREEN}✓ 已创建 (路径替换):${NC} $dst"
    if [ "$MODE" = "symlink" ]; then
      echo -e "    ${YELLOW}📌 SKILL.md 含路径占位符 ${placeholder_path}，使用复制模式（符号链接不兼容）${NC}"
    fi
  elif [ "$MODE" = "symlink" ]; then
    # 无占位符 + symlink 模式 → 建立符号链接
    if [ -f "$dst" ] || [ -L "$dst" ]; then
      rm -f "$dst"
    fi
    ln -sf "$src" "$dst"
    echo -e "  ${GREEN}🔗 符号链接:${NC} $dst"
  else
    # 无占位符 + copy 模式 → 直接复制
    cp "$src" "$dst"
    echo -e "  ${GREEN}✓ 已创建:${NC} $dst"
  fi
  INSTALLED+=("$dst")
}

# ---- Claude Code ----
if [[ " ${TOOL_LIST[*]} " =~ " claude-code " ]]; then
  echo -e "${YELLOW}[Claude Code]${NC}"
  SRC="$CODING_STANDARDS_DIR/adapters/claude-code/SKILL.md"
  DST="$TARGET_DIR/.claude/skills/frontend-standards/SKILL.md"
  if [ -f "$SRC" ]; then
    install_file "$SRC" "$DST" "$CODING_STANDARDS_REL_PATH"
  else
    echo -e "  ${RED}✗ SKILL.md 模板文件不存在: $SRC${NC}"
    SKIPPED+=("Claude Code")
  fi
  echo ""
fi

# ---- Cursor ----
if [[ " ${TOOL_LIST[*]} " =~ " cursor " ]]; then
  echo -e "${YELLOW}[Cursor]${NC}"
  for f in "$CODING_STANDARDS_DIR"/adapters/cursor/*.mdc; do
    if [ -f "$f" ]; then
      DST="$TARGET_DIR/.cursor/rules/$(basename "$f")"
      install_file "$f" "$DST" ""
    fi
  done
  echo ""
fi

# ---- Trae ----
if [[ " ${TOOL_LIST[*]} " =~ " trae " ]]; then
  echo -e "${YELLOW}[Trae]${NC}"

  # 1. 安装 Skill（按需匹配触发）
  SRC="$CODING_STANDARDS_DIR/adapters/trae/SKILL.md"
  DST="$TARGET_DIR/.trae/skills/frontend-standards/SKILL.md"
  if [ -f "$SRC" ]; then
    install_file "$SRC" "$DST" "$CODING_STANDARDS_REL_PATH"
  else
    echo -e "  ${RED}✗ SKILL.md 模板文件不存在: $SRC${NC}"
    SKIPPED+=("Trae (skill)")
  fi

  # 2. 安装 Rule（alwaysApply，始终生效）
  RULE_SRC="$CODING_STANDARDS_DIR/adapters/trae/rules/frontend-standards.md"
  RULE_DST="$TARGET_DIR/.trae/rules/frontend-standards.md"
  if [ -f "$RULE_SRC" ]; then
    install_file "$RULE_SRC" "$RULE_DST" "$CODING_STANDARDS_REL_PATH"
  else
    echo -e "  ${RED}✗ Rule 模板文件不存在: $RULE_SRC${NC}"
    SKIPPED+=("Trae (rule)")
  fi

  echo ""
fi

# ---- CodeBuddy ----
if [[ " ${TOOL_LIST[*]} " =~ " codebuddy " ]]; then
  echo -e "${YELLOW}[CodeBuddy]${NC}"
  SRC="$CODING_STANDARDS_DIR/adapters/codebuddy/frontend-standards.md"
  DST="$TARGET_DIR/.codebuddy/rules/frontend-standards.md"
  if [ -f "$SRC" ]; then
    install_file "$SRC" "$DST" ""
  else
    echo -e "  ${RED}✗ 模板文件不存在: $SRC${NC}"
    SKIPPED+=("CodeBuddy")
  fi
  echo ""
fi

# ---- 结果汇总 ----
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  安装完成${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if [ ${#INSTALLED[@]} -gt 0 ]; then
  echo -e "${GREEN}已安装 ${#INSTALLED[@]} 个文件:${NC}"
  for f in "${INSTALLED[@]}"; do
    echo "  • $f"
  done
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo -e "${YELLOW}跳过的工具（模板文件缺失）: ${SKIPPED[*]}${NC}"
fi

echo ""
if [ "$MODE" = "symlink" ]; then
  echo -e "${GREEN}🔗 符号链接模式说明:${NC}"
  echo "  - Cursor/CodeBuddy 适配器 → 符号链接，修改 coding-standards 源文件自动同步"
  echo "  - Claude Code/Trae SKILL.md → 复制（含路径替换），需重新运行安装脚本以同步更新"
  echo ""
  echo -e "${YELLOW}更新 SKILL.md 后，重新运行安装:${NC}"
  echo "  bash $0 --target-dir \"$TARGET_DIR\" --tools claude-code,trae --mode symlink"
fi

echo -e "提示: 安装完成后，部分工具可能需要重启才能生效。"
echo "  - Cursor: 新建对话后自动加载"
echo "  - Claude Code: 立即生效（无需重启）"
echo "  - Trae: 新建对话后自动加载"
echo "  - CodeBuddy: 需要新建会话"
echo ""
echo "编辑规范: 修改 $CODING_STANDARDS_DIR/frontend-standards/ 下的文件即可更新规则。"
echo "更新适配器: 运行 $CODING_STANDARDS_DIR/scripts/generate-adapters.sh 重新生成适配器文件。"
