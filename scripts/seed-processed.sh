#!/usr/bin/env bash
# seed-processed.sh - 初期状態の processed.json を生成する
# 既存のリリース・Changelog・ブログ記事を取得し、
# 初回 check-news.sh 実行時に大量記事が生成されるのを防止する
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROCESSED_FILE="$REPO_ROOT/data/processed.json"

echo "=== Seeding processed.json ==="

# --- GitHub Releases ---
echo "[1/3] Fetching GitHub Releases..."
RELEASES_JSON=$(curl -sf "https://api.github.com/repos/anthropics/claude-code/releases?per_page=100" || echo "[]")
RELEASE_TAGS=$(echo "$RELEASES_JSON" | jq -r '.[].tag_name // empty' | sort -V)
RELEASE_ARRAY=$(echo "$RELEASE_TAGS" | jq -R -s 'split("\n") | map(select(. != ""))')
echo "  Found $(echo "$RELEASE_ARRAY" | jq 'length') releases"

# --- Changelog Versions ---
echo "[2/3] Fetching Changelog versions..."
# Changelog ページは JS レンダリングのため、GitHub の raw CHANGELOG.md を使用
CHANGELOG_URL="https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md"
CHANGELOG_MD=$(curl -sfL "$CHANGELOG_URL" || echo "")
if [ -n "$CHANGELOG_MD" ]; then
  # "## X.Y.Z" 形式のバージョン見出しを抽出
  CHANGELOG_VERSIONS=$(echo "$CHANGELOG_MD" | grep -oE '^## [0-9]+\.[0-9]+\.[0-9]+' | sed 's/^## //' | sort -uV)
  CHANGELOG_ARRAY=$(echo "$CHANGELOG_VERSIONS" | jq -R -s 'split("\n") | map(select(. != ""))')
else
  echo "  Warning: Could not fetch changelog"
  CHANGELOG_ARRAY="[]"
fi
echo "  Found $(echo "$CHANGELOG_ARRAY" | jq 'length') changelog versions"

# --- Anthropic Blog ---
echo "[3/3] Fetching Anthropic Blog slugs..."
BLOG_HTML=$(curl -sf "https://www.anthropic.com/news" || echo "")
if [ -n "$BLOG_HTML" ]; then
  # ブログ記事のスラッグを抽出 (href="/news/slug-here" パターン)
  BLOG_SLUGS=$(echo "$BLOG_HTML" | grep -oE 'href="/news/[^"]+' | sed 's|href="/news/||' | sort -u)
  # Claude Code 関連のキーワードでフィルタ
  KEYWORD_PATTERN="claude-code|claude-opus|claude-sonnet|agent-sdk|claude-4|model-context-protocol|mcp|computer-use|tool-use|claude-cli"
  FILTERED_SLUGS=$(echo "$BLOG_SLUGS" | grep -iE "$KEYWORD_PATTERN" || echo "")
  # フィルタされていない全スラッグも保存（見逃し防止）
  ALL_BLOG_SLUGS=$(echo "$BLOG_SLUGS" | jq -R -s 'split("\n") | map(select(. != ""))')
else
  echo "  Warning: Could not fetch blog"
  ALL_BLOG_SLUGS="[]"
fi
echo "  Found $(echo "$ALL_BLOG_SLUGS" | jq 'length') blog slugs"

# --- processed.json を生成 ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq -n \
  --argjson releases "$RELEASE_ARRAY" \
  --argjson changelog "$CHANGELOG_ARRAY" \
  --argjson blogs "$ALL_BLOG_SLUGS" \
  --arg ts "$TIMESTAMP" \
  '{
    github_releases: $releases,
    changelog_versions: $changelog,
    blog_slugs: $blogs,
    last_checked: $ts
  }' > "$PROCESSED_FILE"

echo ""
echo "=== Done ==="
echo "Wrote to: $PROCESSED_FILE"
echo "  Releases:  $(jq '.github_releases | length' "$PROCESSED_FILE")"
echo "  Changelog: $(jq '.changelog_versions | length' "$PROCESSED_FILE")"
echo "  Blog:      $(jq '.blog_slugs | length' "$PROCESSED_FILE")"
