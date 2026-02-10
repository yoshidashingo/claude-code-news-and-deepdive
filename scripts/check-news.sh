#!/usr/bin/env bash
# check-news.sh - Claude Code のニュースをチェックし、新規項目があれば記事を生成する
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROCESSED_FILE="$REPO_ROOT/data/processed.json"
ARTICLES_DIR="$REPO_ROOT/articles"
TODAY=$(date -u +"%Y-%m-%d")
MAX_ARTICLES=5
ARTICLES_GENERATED=0
NEW_ITEMS_FOUND=0

# processed.json が存在しない場合はエラー
if [ ! -f "$PROCESSED_FILE" ]; then
  echo "Error: $PROCESSED_FILE not found. Run scripts/seed-processed.sh first."
  exit 1
fi

# jq が利用可能か確認
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed."
  exit 1
fi

# claude CLI が利用可能か確認
if ! command -v claude &> /dev/null; then
  echo "Error: claude CLI is required but not installed."
  echo "Install with: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

echo "=== Claude Code News Check ($(date -u +"%Y-%m-%dT%H:%M:%SZ")) ==="

# --- ユーティリティ関数 ---

# processed.json に項目を追加する
add_to_processed() {
  local key="$1"
  local value="$2"
  local tmp=$(mktemp)
  jq --arg v "$value" ".${key} += [\$v] | .${key} |= unique" "$PROCESSED_FILE" > "$tmp" \
    && mv "$tmp" "$PROCESSED_FILE"
}

# processed.json の last_checked を更新する
update_last_checked() {
  local tmp=$(mktemp)
  jq --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '.last_checked = $ts' "$PROCESSED_FILE" > "$tmp" \
    && mv "$tmp" "$PROCESSED_FILE"
}

# 記事生成上限チェック
check_limit() {
  if [ "$ARTICLES_GENERATED" -ge "$MAX_ARTICLES" ]; then
    echo "  -> Max articles ($MAX_ARTICLES) reached. Remaining items will be processed next run."
    return 1
  fi
  return 0
}

# Claude CLI で記事を生成する
generate_article() {
  local source_type="$1"
  local identifier="$2"
  local source_url="$3"
  local extra_context="$4"
  local filename="${TODAY}-${source_type}-${identifier}.md"
  local filepath="${ARTICLES_DIR}/${filename}"

  # 既に記事が存在する場合はスキップ
  if [ -f "$filepath" ]; then
    echo "  -> Article already exists: $filename"
    return 0
  fi

  echo "  -> Generating article: $filename"

  local prompt="以下の情報源に基づいて、CLAUDE.md のガイドラインに従って日本語の技術解説記事を生成してください。

ソースタイプ: ${source_type}
識別子: ${identifier}
ソースURL: ${source_url}
日付: ${TODAY}
出力ファイル: ${filepath}

${extra_context}

まず WebFetch ツールでソースURLにアクセスして最新情報を取得し、次に CLAUDE.md を読んでガイドラインを確認し、記事を生成して ${filepath} に書き込んでください。"

  # claude CLI を実行
  if claude -p "$prompt" \
    --allowedTools "WebFetch,Read,Write,Glob" \
    --max-turns 15 \
    2>&1; then
    echo "  -> Article generated successfully: $filename"
    ARTICLES_GENERATED=$((ARTICLES_GENERATED + 1))
    return 0
  else
    echo "  -> Warning: Failed to generate article: $filename"
    return 1
  fi
}

# --- Source 1: GitHub Releases ---
echo ""
echo "[1/3] Checking GitHub Releases..."
RELEASES_JSON=$(curl -sf "https://api.github.com/repos/anthropics/claude-code/releases?per_page=10" || echo "[]")
RELEASE_TAGS=$(echo "$RELEASES_JSON" | jq -r '.[].tag_name // empty')

NEW_RELEASES=()
for tag in $RELEASE_TAGS; do
  if ! jq -e --arg t "$tag" '.github_releases | index($t)' "$PROCESSED_FILE" > /dev/null 2>&1; then
    NEW_RELEASES+=("$tag")
  fi
done

if [ ${#NEW_RELEASES[@]} -eq 0 ]; then
  echo "  No new releases found."
else
  echo "  Found ${#NEW_RELEASES[@]} new release(s): ${NEW_RELEASES[*]}"
  NEW_ITEMS_FOUND=$((NEW_ITEMS_FOUND + ${#NEW_RELEASES[@]}))
  for tag in "${NEW_RELEASES[@]}"; do
    check_limit || break

    # リリースの詳細情報を取得
    RELEASE_BODY=$(echo "$RELEASES_JSON" | jq -r --arg t "$tag" '.[] | select(.tag_name == $t) | .body // ""')
    RELEASE_URL="https://github.com/anthropics/claude-code/releases/tag/${tag}"

    generate_article "github-release" "$tag" "$RELEASE_URL" \
      "リリースノート概要:
${RELEASE_BODY}" || true

    # 成功・失敗に関わらず処理済みに追加（無限リトライ防止）
    add_to_processed "github_releases" "$tag"
  done
fi

# --- Source 2: Changelog ---
echo ""
echo "[2/3] Checking Changelog..."
# Changelog ページは JS レンダリングのため、GitHub の raw CHANGELOG.md を使用
CHANGELOG_RAW_URL="https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md"
CHANGELOG_MD=$(curl -sfL "$CHANGELOG_RAW_URL" || echo "")

if [ -n "$CHANGELOG_MD" ]; then
  # "## X.Y.Z" 形式のバージョン見出しを抽出
  CHANGELOG_VERSIONS=$(echo "$CHANGELOG_MD" | grep -oE '^## [0-9]+\.[0-9]+\.[0-9]+' | sed 's/^## //' | sort -uV)

  NEW_VERSIONS=()
  for version in $CHANGELOG_VERSIONS; do
    if ! jq -e --arg v "$version" '.changelog_versions | index($v)' "$PROCESSED_FILE" > /dev/null 2>&1; then
      NEW_VERSIONS+=("$version")
    fi
  done

  if [ ${#NEW_VERSIONS[@]} -eq 0 ]; then
    echo "  No new changelog versions found."
  else
    echo "  Found ${#NEW_VERSIONS[@]} new version(s): ${NEW_VERSIONS[*]}"
    NEW_ITEMS_FOUND=$((NEW_ITEMS_FOUND + ${#NEW_VERSIONS[@]}))
    for version in "${NEW_VERSIONS[@]}"; do
      check_limit || break

      CHANGELOG_URL="https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md"
      generate_article "changelog" "$version" "$CHANGELOG_URL" \
        "Changelog のバージョン ${version} に関する変更点を解説してください。
ソースの raw URL: ${CHANGELOG_RAW_URL}" || true

      add_to_processed "changelog_versions" "$version"
    done
  fi
else
  echo "  Warning: Could not fetch changelog."
fi

# --- Source 3: Anthropic Blog ---
echo ""
echo "[3/3] Checking Anthropic Blog..."
BLOG_HTML=$(curl -sf "https://www.anthropic.com/news" || echo "")

if [ -n "$BLOG_HTML" ]; then
  BLOG_SLUGS=$(echo "$BLOG_HTML" | grep -oE 'href="/news/[^"]+' | sed 's|href="/news/||' | sort -u)

  # Claude Code 関連のキーワードでフィルタ
  KEYWORD_PATTERN="claude-code|claude-opus|claude-sonnet|agent-sdk|claude-4|model-context-protocol|mcp|computer-use|tool-use|claude-cli"
  FILTERED_SLUGS=$(echo "$BLOG_SLUGS" | grep -iE "$KEYWORD_PATTERN" || echo "")

  NEW_SLUGS=()
  for slug in $FILTERED_SLUGS; do
    if [ -z "$slug" ]; then continue; fi
    if ! jq -e --arg s "$slug" '.blog_slugs | index($s)' "$PROCESSED_FILE" > /dev/null 2>&1; then
      NEW_SLUGS+=("$slug")
    fi
  done

  if [ ${#NEW_SLUGS[@]} -eq 0 ]; then
    echo "  No new relevant blog posts found."
  else
    echo "  Found ${#NEW_SLUGS[@]} new blog post(s): ${NEW_SLUGS[*]}"
    NEW_ITEMS_FOUND=$((NEW_ITEMS_FOUND + ${#NEW_SLUGS[@]}))
    for slug in "${NEW_SLUGS[@]}"; do
      check_limit || break

      BLOG_URL="https://www.anthropic.com/news/${slug}"
      generate_article "blog" "$slug" "$BLOG_URL" \
        "Anthropic 公式ブログの記事を日本語で解説してください。" || true

      add_to_processed "blog_slugs" "$slug"
    done
  fi
else
  echo "  Warning: Could not fetch blog."
fi

# --- 完了 ---
if [ "$NEW_ITEMS_FOUND" -gt 0 ]; then
  update_last_checked
fi

echo ""
echo "=== Done ==="
echo "New items found: $NEW_ITEMS_FOUND"
echo "Articles generated: $ARTICLES_GENERATED"
if [ "$NEW_ITEMS_FOUND" -gt 0 ]; then
  echo "Last checked: $(jq -r '.last_checked' "$PROCESSED_FILE")"
else
  echo "No updates found. Skipping last_checked update."
fi
