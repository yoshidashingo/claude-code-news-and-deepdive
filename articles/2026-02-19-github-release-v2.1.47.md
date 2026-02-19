---
title: "Claude Code v2.1.47 リリース — 大規模バグ修正と Windows / エージェント安定性の大幅向上"
date: 2026-02-19
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.47"
identifier: "v2.1.47"
---

# Claude Code v2.1.47 リリース — 大規模バグ修正と Windows / エージェント安定性の大幅向上

## 概要

Claude Code v2.1.47 は、Windows 環境での互換性向上、エージェント・セッション管理の安定化、パフォーマンス改善を中心とした大規模なアップデートです。50 件を超えるバグ修正と複数の新機能・改善が含まれており、特に長時間セッションや並列エージェントを利用する開発者に恩恵があります。

## 新機能

### バックグラウンドエージェントのライフサイクル制御改善

バックグラウンドエージェントの制御方法が変更されました。従来は ESC を二度押しすることで全エージェントを終了していましたが、**`ctrl+f` で全バックグラウンドエージェントを強制終了**できるようになりました。また、ESC でメインスレッドをキャンセルしてもバックグラウンドエージェントは継続して動作するようになり、エージェントのライフサイクルをより細かく制御できます。

### Hook 入力への `last_assistant_message` フィールド追加

Stop および SubagentStop フックの入力に `last_assistant_message` フィールドが追加されました。これにより、フック実行時にトランスクリプトファイルをパースすることなく、最終的なアシスタントの応答テキストに直接アクセスできます。

```json
{
  "session_id": "...",
  "last_assistant_message": "実装が完了しました。..."
}
```

### VS Code プランプレビューの改善

VS Code 統合でのプランプレビューが強化されました。

- Claude が反復処理を行うたびにプレビューが**自動更新**されます
- プランが確定して初めてコメント機能が有効になります
- プランを却下してもプレビューが開いたままになり、Claude が修正しやすくなりました

### その他の新機能

- `chat:newline` キーバインドアクション追加により、複数行入力の方法を設定ファイルでカスタマイズ可能になりました（[#26075](https://github.com/anthropics/claude-code/issues/26075)）
- ステータスラインの JSON `workspace` セクションに `added_dirs` フィールドが追加され、`/add-dir` で追加したディレクトリを外部スクリプトから参照できます（[#26096](https://github.com/anthropics/claude-code/issues/26096)）
- `/rename` コマンドがデフォルトでターミナルタブのタイトルも更新するようになりました（[#25789](https://github.com/anthropics/claude-code/issues/25789)）
- チームメイトナビゲーションが Shift+Down のみ（ラップあり）に簡略化されました

## 改善点

### パフォーマンス・メモリ使用量

- **起動時間の短縮**: SessionStart フックの実行を遅延させることで、インタラクティブになるまでの時間を**約 500ms 削減**しました
- **メモリ使用量の削減**: API ストリームバッファ、エージェントコンテキスト、スキル状態を使用後に解放するよう改善。また、エージェントタスクのメッセージ履歴をタスク完了後にトリミングすることで長時間セッションでのメモリ効率が向上しました
- **O(n²) 問題の解消**: エージェントの進捗更新でメッセージが O(n²) で蓄積されていた問題を修正
- **`@` ファイルメンション高速化**: スタートアップ時にインデックスをプリウォームし、セッションベースのキャッシュとバックグラウンドリフレッシュを使用することでファイル候補の表示が高速化されました

### セッション管理

- resume ピッカーの初期表示セッション数が 10 から **50 に増加**し、セッション検索が高速になりました（[#26123](https://github.com/anthropics/claude-code/issues/26123)）
- コンフィグバックアップファイルがホームディレクトリのルートから `~/.claude/backups/` に移動しました（[#26130](https://github.com/anthropics/claude-code/issues/26130)）

## バグ修正

### Windows / WSL2 関連

Windows 環境での安定性が大幅に改善されました。

- **ターミナルレンダリング**: `os.EOL`（`\r\n`）が原因で行数が常に 1 と表示されていた問題、および Markdown の太字・カラーテキストが誤った文字にずれる問題を修正
- **MSYS2 / Cygwin**: bash ツールの出力が無音で破棄されていた問題を修正
- **CWD トラッキング**: 一時ファイルが無限に蓄積されていた問題を修正（[#17600](https://github.com/anthropics/claude-code/issues/17600)）
- **ドライブレター**: パスのドライブレターの大小が異なる場合にワークツリーセッションが正しくマッチしない問題を修正。`CLAUDE.md` が二重に読み込まれる問題も修正（[#25756](https://github.com/anthropics/claude-code/issues/25756)）
- **フック実行**: PreToolUse / PostToolUse フックが cmd.exe ではなく Git Bash を使うようになり、Windows で正常に実行されるようになりました（[#25981](https://github.com/anthropics/claude-code/issues/25981)）
- **Right Alt キー**: Windows/Git Bash ターミナルで `[25~` というエスケープシーケンスが入力フィールドに残る問題を修正（[#25943](https://github.com/anthropics/claude-code/issues/25943)）
- **WSL2 画像貼り付け**: Windows が BMP 形式でコピーした画像を WSL2 で貼り付けられない問題を修正（[#25935](https://github.com/anthropics/claude-code/issues/25935)）

### エージェント・セッション管理

- **並列エージェントの API エラー**: 並列エージェント実行時に "thinking blocks cannot be modified" という API 400 エラーが発生していた問題を修正
- **プランモードの喪失**: コンテキスト圧縮後にプランモードが失われ、計画フェーズから実装フェーズに切り替わってしまう問題を修正（[#26061](https://github.com/anthropics/claude-code/issues/26061)）
- **セッション名の保持**: `/rename` で設定したセッション名がコンテキスト圧縮後やセッション再開後に失われる問題を修正（[#23610](https://github.com/anthropics/claude-code/issues/23610)、[#26121](https://github.com/anthropics/claude-code/issues/26121)）
- **大きな初回メッセージ**: 最初のメッセージが 16KB を超えるセッションが `/resume` リストから消える問題を修正（[#25721](https://github.com/anthropics/claude-code/issues/25721)、[#26140](https://github.com/anthropics/claude-code/issues/26140)）
- **バックグラウンドエージェント**: 最終回答ではなく生のトランスクリプトデータが返されていた問題を修正（[#26012](https://github.com/anthropics/claude-code/issues/26012)）
- **並列ファイル操作**: 1 つのファイル書き込み・編集エラーが他の並列ファイル操作をすべて中断していた問題を修正

### カスタムエージェント・スキル

- **Git ワークツリー**: ワークツリーから実行した際にプロジェクトレベルの `.claude/agents/` と `.claude/skills/` が検索対象に含まれない問題を修正（[#25816](https://github.com/anthropics/claude-code/issues/25816)）
- **カスタムエージェントの `model` フィールド**: チームメイトとしてスポーンする際に `model` フィールドが無視されていた問題を修正（[#26064](https://github.com/anthropics/claude-code/issues/26064)）
- **NFS / FUSE ファイルシステム**: inode がゼロと報告されるファイルシステムでユーザー定義エージェントが 1 ファイルしか読み込まれない問題を修正（[#26044](https://github.com/anthropics/claude-code/issues/26044)）
- **プラグインエージェントスキル**: 完全修飾名ではなくベア名で参照した場合にスキルが読み込まれない問題を修正（[#25834](https://github.com/anthropics/claude-code/issues/25834)）
- **SKILL.md の数値フィールド**: `name` や `description` が数値（例: `name: 3000`）の場合にクラッシュしていた問題を修正（[#25837](https://github.com/anthropics/claude-code/issues/25837)）

### その他の修正

- **PDF 圧縮**: 多数の PDF ドキュメントを含むセッションで圧縮が失敗する問題を修正（[#26188](https://github.com/anthropics/claude-code/issues/26188)）
- **bash 権限クラシファイア**: 返却されるマッチの説明が実際の入力ルールに対応しているか検証することで、幻覚的な説明が誤って権限を付与する問題を修正
- **CJK 文字**: TUI でのタイムスタンプやレイアウト要素のずれを修正（[#26084](https://github.com/anthropics/claude-code/issues/26084)）
- **Unicode 曲引用符**: Edit ツールが `\u201c\u201d \u2018\u2019`（いわゆるスマートクォート）を直線引用符に変換してしまう問題を修正（[#26141](https://github.com/anthropics/claude-code/issues/26141)）
- **LSP 操作**: `findReferences` などが `node_modules/` や `venv/` などの gitignore 対象ファイルを返す問題を修正（[#26051](https://github.com/anthropics/claude-code/issues/26051)）
- **macOS FSEvents**: 読み取り専用の git コマンドが `--no-optional-locks` フラグなしで実行されてファイル監視ループが発生していた問題を修正（[#25750](https://github.com/anthropics/claude-code/issues/25750)）
- **バックスラッシュ改行続行**: 複数行にまたがる bash コマンドで余分な空引数が生成される問題を修正
- **`alwaysThinkingEnabled`**: Bedrock および Vertex プロバイダーで設定が反映されない問題を修正（[#26074](https://github.com/anthropics/claude-code/issues/26074)）
- **`/clear` 後のステータスバー**: クリア後もセッション名が残る問題を修正（[#26082](https://github.com/anthropics/claude-code/issues/26082)）
- **MCP サーバー**: 遅延ロード後に MCP 管理ダイアログにサーバーが表示されない問題を修正
- **OSC 8 ハイパーリンク**: リンクテキストが複数行にわたる場合に最初の行しかクリックできない問題を修正

## 技術的なポイント

- **Windows 対応の徹底**: `\r\n` 行末文字・ドライブレター大小・Git Bash / MSYS2 / Cygwin 環境など、Windows 固有の多様なエッジケースが集中的に修正されました。Windows や WSL2 で Claude Code を使っている開発者は積極的にアップデートすることを推奨します
- **長時間・並列エージェントセッションの安定化**: メモリリーク相当の問題（O(n²) 蓄積、API バッファの未解放）が複数修正され、長時間の自律エージェント実行が以前より安定します
- **Hook エコシステムの強化**: `last_assistant_message` フィールドの追加により、Stop フック内でエージェントの最終応答を解析・処理するワークフローが構築しやすくなりました
- **bash 権限の堅牢化**: 権限クラシファイアの幻覚的な説明による誤った権限付与が防止され、セキュリティ上の信頼性が向上しました
- **ファイル整合性**: Unicode スマートクォートや FileWriteTool のトレイリング空行など、ファイル内容が意図せず変更される問題が修正され、Edit/Write ツールの信頼性が向上しました

## まとめ

v2.1.47 は新機能こそ少ないものの、Windows 環境の互換性、長時間エージェントセッションの安定性、セッション管理の信頼性という 3 つの観点で大きな品質向上をもたらすリリースです。特に Windows / WSL2 ユーザーや、複数の並列エージェントを組み合わせた複雑なワークフローを運用している開発者にとって、実運用上の問題が多数解消されています。また、Hook 入力の拡張や `added_dirs` のステータスライン公開など、外部スクリプトや自動化パイプラインとの連携を強化する改善も含まれており、Claude Code エコシステムの拡張性向上が着実に進んでいます。
