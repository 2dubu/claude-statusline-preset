#!/usr/bin/env bash
#
# statusbar 프리셋 원클릭 설치.
#   ① ccstatusline 번들 확보(없으면 npm pack, 그것도 안 되면 npx 폴백)
#   ② 위젯 설정 + 모델 헬퍼를 홈에 symlink (편집이 이 레포에 바로 반영됨)
#   ③ ~/.claude/settings.json 의 statusLine 만 머지(나머지 설정 보존, 자동 백업)
#
# 재실행 안전(idempotent). 다른 맥: 레포 clone 후 `./setup.sh` 한 번.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CCSL_VER="2.2.19"
TOOLS="$HOME/.claude/tools"

log() { printf '  %s\n' "$*"; }
echo "▶ statusbar 프리셋 설치 (repo: $REPO)"

mkdir -p "$HOME/.config/ccstatusline" "$TOOLS/ccstatusline/dist"

# ── ② 설정/헬퍼 symlink (홈 → 레포). 기존 '실파일'은 백업 후 교체 ──
link() { # link <repo-상대경로> <홈-절대경로>
  local src="$REPO/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%s)"
    log "기존 파일 백업: $dest.bak.*"
  fi
  ln -sfn "$src" "$dest"
  log "symlink: ${dest/#$HOME/~} → ${src/#$HOME/~}"
}
link "home/.config/ccstatusline/settings.json" "$HOME/.config/ccstatusline/settings.json"
link "home/.claude/tools/cc-model.js"           "$TOOLS/cc-model.js"

# ── ① ccstatusline 번들 dist 확보 ──
DIST="$TOOLS/ccstatusline/dist/ccstatusline.js"
have=""
[ -f "$TOOLS/ccstatusline/package.json" ] && \
  have=$(node -pe "require('$TOOLS/ccstatusline/package.json').version" 2>/dev/null || true)
USE_NPX=0
if [ "$have" = "$CCSL_VER" ]; then
  log "ccstatusline@$CCSL_VER 이미 설치됨"
elif command -v npm >/dev/null 2>&1; then
  tmp=$(mktemp -d)
  ( cd "$tmp" && npm pack "ccstatusline@$CCSL_VER" >/dev/null 2>&1 && tar xzf ccstatusline-*.tgz ) || true
  if [ -f "$tmp/package/dist/ccstatusline.js" ]; then
    cp "$tmp/package/dist/ccstatusline.js" "$DIST"
    cp "$tmp/package/package.json" "$TOOLS/ccstatusline/package.json"
    log "ccstatusline@$CCSL_VER 설치 (npm pack)"
  else
    USE_NPX=1; log "npm pack 실패 — statusLine 을 npx 폴백으로 설정"
  fi
  rm -rf "$tmp"
else
  USE_NPX=1; log "npm 없음 — statusLine 을 npx 폴백으로 설정"
fi

# ── ③ ~/.claude/settings.json 의 statusLine 머지 (다른 키 보존, 백업) ──
CMD="node ~/.claude/tools/ccstatusline/dist/ccstatusline.js"
[ "$USE_NPX" = 1 ] && CMD="npx -y ccstatusline@$CCSL_VER"
CMD="$CMD" node - <<'NODE'
const fs = require("fs"), path = require("path");
const home = process.env.HOME || require("os").homedir();
const p = path.join(home, ".claude", "settings.json");
let j = {};
try { j = JSON.parse(fs.readFileSync(p, "utf8")); } catch (e) {}
if (fs.existsSync(p)) fs.copyFileSync(p, p + ".bak");
j.statusLine = { type: "command", command: process.env.CMD, padding: 0 };
fs.mkdirSync(path.dirname(p), { recursive: true });
fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
console.log("  ~/.claude/settings.json statusLine 머지 완료 (백업: settings.json.bak)");
NODE

echo "▶ 완료! Claude Code 상태바는 다음 새로고침에 반영됩니다."
