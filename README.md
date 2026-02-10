# Claude Code News & Deep Dive

Claude Code のニュース・更新情報を自動監視し、日本語の詳細な技術解説記事を生成するシステムです。

## 仕組み

GitHub Actions が毎日定時に以下のソースをチェックし、新しい情報が検出された場合のみ Claude Code CLI を使って記事を自動生成します。

**監視対象:**
- GitHub Releases（`anthropics/claude-code`）
- Changelog（Anthropic 公式ドキュメント）
- Anthropic Blog（Claude Code 関連記事）

**アーキテクチャ:**
```
GitHub Actions (毎日 09:00 UTC / 18:00 JST)
  └─ scripts/check-news.sh
       ├─ GitHub Releases API で新バージョン検出
       ├─ Changelog ページで新バージョン検出
       ├─ Anthropic Blog で Claude Code 関連の新記事検出
       ├─ data/processed.json と比較して新規項目のみ抽出
       ├─ 新規項目ごとに Claude Code CLI で日本語技術解説記事を生成
       ├─ processed.json を更新
       └─ 別ブランチで commit & push → Pull Request 作成
```

新規ニュースがない日は Claude Code API を呼び出さないため、コストを最小限に抑えられます。

## セットアップ

### 前提条件

- [Claude Code CLI](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code) がインストール済み
- `jq` コマンドが利用可能
- Anthropic API キー

### 手順

1. リポジトリをクローン
2. 初期データを投入（既存のリリース等を processed.json に記録し、初回の大量記事生成を防止）:
   ```bash
   bash scripts/seed-processed.sh
   ```
3. GitHub リポジトリの **Settings > Secrets and variables > Actions** で `ANTHROPIC_API_KEY` を追加
4. GitHub リポジトリの **Settings > Actions > General** で **Workflow permissions** を **Read and write permissions** に変更（ブランチ作成・PR 作成に必要）
5. GitHub Actions の **Actions** タブ > **Check Claude Code News** > **Run workflow** で手動テスト実行

## ファイル構成

```
├── CLAUDE.md                          # 記事生成ガイドライン
├── README.md
├── articles/                          # 生成された記事
│   └── YYYY-MM-DD-{source}-{id}.md
├── data/
│   └── processed.json                 # 処理済み項目の状態管理
├── scripts/
│   ├── check-news.sh                  # メインスクリプト
│   └── seed-processed.sh             # 初期データ投入
└── .github/workflows/
    └── check-news.yml                 # GitHub Actions ワークフロー
```

## 記事の命名規則

| ソース | ファイル名例 |
|--------|-------------|
| GitHub Release | `2026-02-07-github-release-v2.1.34.md` |
| Changelog | `2026-02-07-changelog-v2.1.34.md` |
| Blog | `2026-02-07-blog-claude-code-announcement.md` |

## ローカルでの実行

```bash
# 初期データ投入（初回のみ）
bash scripts/seed-processed.sh

# ニュースチェック＆記事生成
bash scripts/check-news.sh
```

## 設計上のポイント

- **ハイブリッド方式**: シェルスクリプトで軽量チェック、新規検出時のみ Claude Code CLI を起動
- **バースト対策**: 1回あたり最大5記事まで生成（残りは次回実行で処理）
- **エラー耐性**: 個別記事の生成失敗は他の記事に影響しない
- **部分実行対応**: 各項目処理後に即座に processed.json を更新
