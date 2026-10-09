#!/usr/bin/env bash
# Usage: ./publish.sh <report.html> <YYYY-MM-DD> [surge|gh]
# Stage the report into /<date>/index.html, make it the homepage, rebuild archive.html, then deploy.
set -euo pipefail
SRC="$1"; D="$2"; TARGET="${3:-none}"
SITE="$(cd "$(dirname "$0")" && pwd)"
python3 /workspace/product-radar-sample/tools/inline_play_patch.py "$SRC" >/dev/null
mkdir -p "$SITE/$D"; cp "$SRC" "$SITE/$D/index.html"; cp "$SRC" "$SITE/index.html"
{ echo '<!doctype html><meta charset="utf-8"><title>产品雷达 · 往期</title><body style="font-family:system-ui;max-width:640px;margin:40px auto"><h2>产品雷达 · 往期日报</h2><ul>'
  for d in $(ls -d "$SITE"/20??-??-?? | xargs -n1 basename | sort -r); do echo "<li><a href=\"./$d/\">$d</a></li>"; done
  echo '</ul></body>'; } > "$SITE/archive.html"
case "$TARGET" in
  surge) npx --yes surge "$SITE" "${SURGE_DOMAIN:?set SURGE_DOMAIN e.g. product-radar-xxx.surge.sh}" ;;
  gh)    cd "$SITE" && git add -A && git commit -qm "report $D" && git push -q origin HEAD:main ;;
  *)     echo "staged only (no deploy)";;
esac
