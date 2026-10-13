#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
mkdir -p lovegame
rm -f lovegame/fourth-counsel.love
(cd lovegame && zip -qr fourth-counsel.love conf.lua main.lua case_data.lua assets)
rm -rf docs/* docs/.[!.]* docs/..?* 2>/dev/null || true
npx love.js lovegame/fourth-counsel.love docs -c -t "Fourth Counsel"
# Keep generated JavaScript diffs stable across love.js versions/platforms.
sed -i 's/[[:space:]]*$//' docs/game.js
sed -i 's/[[:space:]]*$//' docs/index.html
# Cache-bust the loader and package URL whenever the bundled game changes.
BUILD_ID="$(sed -n 's/.*"package_uuid":"\([^"]*\)".*/\1/p' docs/game.js | tail -1)"
sed -i "s#src=\"game.js\"#src=\"game.js?v=${BUILD_ID}\"#" docs/index.html
sed -i "s#REMOTE_PACKAGE_BASE = 'game.data';#REMOTE_PACKAGE_BASE = 'game.data?v=${BUILD_ID}';#" docs/game.js
touch docs/.nojekyll
cat >> docs/theme/love.css <<'CSS'

html, body { width: 100%; height: 100%; min-height: 100%; }
body { overflow: hidden; background: #090d1a; color: #fdf4d3; text-align: center; }
center { width: 100%; height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; }
center > div { width: 100%; }
h1 { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0,0,0,0); }
#canvas, #loadingCanvas { width: min(100vw, calc((100vh - 72px) * 1.7778)); height: auto; max-height: calc(100vh - 72px); margin: 0 auto; }
footer { position: static; width: 100%; padding: 8px; color: #bac6e4; background: #090d1a; font-size: 12px; }
footer p { margin: 0; }
footer a, footer a:link, footer a:visited { color: #f7c944; }
footer button { color: #10162a; background: #f7c944; border: 0; border-radius: 5px; padding: 5px 10px; cursor: pointer; }
@media (max-aspect-ratio: 1/1) { #canvas, #loadingCanvas { width: 100vw; max-height: calc(100vh - 72px); } }
@media (orientation: portrait) and (max-width: 800px) {
  body::before { content: "Rotate your device to landscape to play"; position: fixed; inset: 0; z-index: 10; display: flex; align-items: center; justify-content: center; padding: 32px; color: #fdf4d3; background: #090d1a; font: bold 24px Arial, sans-serif; }
}
CSS
