#!/usr/bin/env bash
# Build dist/<name>-<version>.tgz in the layout Cribl App Platform installs:
#   package.json, default/{proxies,policies}.yml, static/...
set -euo pipefail
cd "$(dirname "$0")/.."
name=$(node -p 'require("./package.json").name' 2>/dev/null || python3 -c 'import json;print(json.load(open("package.json"))["name"])')
ver=$(node -p 'require("./package.json").version' 2>/dev/null || python3 -c 'import json;print(json.load(open("package.json"))["version"])')
grep -q 'assets/index-' static/index.html
for f in $(grep -o 'assets/[^"]*' static/index.html); do test -f "static/$f" || { echo "missing static/$f" >&2; exit 1; }; done
mkdir -p dist
out="dist/${name}-${ver}.tgz"
find . -name .DS_Store -delete
COPYFILE_DISABLE=1 tar --no-xattrs -czf "$out" package.json default static 2>/dev/null \
  || COPYFILE_DISABLE=1 tar -czf "$out" package.json default static
echo "built $out"; tar tzf "$out"
