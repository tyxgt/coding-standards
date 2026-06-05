#!/bin/bash
set -euo pipefail

# ==============================================================
# ai-rules 适配器生成脚本
# 从 canonical 规范源重新生成所有工具适配器文件
# 在修改 frontend-standards/ 下的规范后运行此脚本
# ==============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_RULES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== ai-rules 适配器生成脚本 ==="
echo "规范源: $AI_RULES_DIR/frontend-standards/"
echo "适配器: $AI_RULES_DIR/adapters/"
echo ""

echo "注意: 当前适配器模板为手写优化版本，自动生成逻辑尚未实现。"
echo ""
echo "适配器文件清单（保持不变）:"
echo ""

find "$AI_RULES_DIR/adapters" -type f | sort | while read -r f; do
  REL="${f#$AI_RULES_DIR/}"
  SIZE=$(wc -c < "$f" | tr -d ' ')
  echo "  • $REL (${SIZE}B)"
done

echo ""
echo "如规范文件有更新，请手动同步以下适配器的内容:"
echo ""

check_feature() {
  local file="$1"
  local feature="$2"
  if grep -qi "$feature" "$file" 2>/dev/null; then
    echo "  ✓ $feature"
  else
    echo "  ✗ $feature (可能需要更新)"
  fi
}

echo "--- Cursor 010-frontend-core.mdc ---"
check_feature "$AI_RULES_DIR/adapters/cursor/010-frontend-core.mdc" "命名规范"
check_feature "$AI_RULES_DIR/adapters/cursor/010-frontend-core.mdc" "组件"
check_feature "$AI_RULES_DIR/adapters/cursor/010-frontend-core.mdc" "TypeScript"
check_feature "$AI_RULES_DIR/adapters/cursor/010-frontend-core.mdc" "样式"

echo ""
echo "--- CodeBuddy frontend-standards.md ---"
check_feature "$AI_RULES_DIR/adapters/codebuddy/frontend-standards.md" "命名"
check_feature "$AI_RULES_DIR/adapters/codebuddy/frontend-standards.md" "组件"
check_feature "$AI_RULES_DIR/adapters/codebuddy/frontend-standards.md" "导入"

echo ""
echo "--- Amazon Q frontend-standards.md ---"
check_feature "$AI_RULES_DIR/adapters/amazon-q/frontend-standards.md" "Naming"
check_feature "$AI_RULES_DIR/adapters/amazon-q/frontend-standards.md" "TypeScript"
check_feature "$AI_RULES_DIR/adapters/amazon-q/frontend-standards.md" "Prohibitions"

echo ""
echo "完成。请手动检查上述标记项，确保与 canonical 规范一致。"
echo "提示: 将 generate-adapters.sh 添加到 git pre-commit hook 可以自动检查。"
