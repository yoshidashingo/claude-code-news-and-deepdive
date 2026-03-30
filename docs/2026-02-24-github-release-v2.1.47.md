---
title: "Claude Code v2.1.47 リリース — Windows 対応強化・パフォーマンス改善・大量バグ修正"
date: 2026-02-24
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.47"
identifier: "v2.1.47"
---

# Claude Code v2.1.47 リリース — Windows 対応強化・パフォーマンス改善・大量バグ修正

## 概要

Claude Code v2.1.47 は 2026年2月18日にリリースされた大規模なアップデートです。Windows 環境に関する多数のバグが修正され、メモリ使用量の最適化と起動パフォーマンスの向上が図られました。さらに、エージェントやセッション管理に関わる重要なバグが多数修正され、日常的な開発ワークフローの安定性が大幅に改善されています。

## 新機能

### バックグラウンドエージェントのライフサイクル制御改善

バックグラウンドエージェントの制御方法が変更されました。従来は ESC を2回押すことで全バックグラウンドエージェントを終了させていましたが、今後は **`ctrl+f`** でまとめて終了させるようになりました。ESC を1回押すとメインスレッドのみをキャンセルし、バックグラウンドエージェントは継続して実行されます。これにより、エージェントのライフサイクルをより細かく制御できます。

### フック入力への `last_assistant_message` 追加

`Stop` および `SubagentStop` フックの入力データに `last_assistant_message` フィールドが追加されました。フックからアシスタントの最終回答テキストに直接アクセスできるようになり、トランスクリプトファイルを解析する手間が省けます。

### ステータスラインへの `added_dirs` 追加

ステータスライン JSON の `workspace` セクションに `added_dirs` フィールドが追加されました。`/add-dir` コマンドで追加したディレクトリを外部スクリプトから参照できます（[#26096](https://github.com/anthropics/claude-code/issues/26096)）。

### `chat:newline` キーバインドアクション

複数行入力のための設定可能なキーバインドアクション `chat:newline` が追加されました（[#26075](https://github.com/anthropics/claude-code/issues/26075)）。

### `/rename` コマンドがターミナルタブタイトルを更新

`/rename` コマンドでセッション名を変更すると、ターミナルのタブタイトルもデフォルトで更新されるようになりました（[#25789](https://github.com/anthropics/claude-code/issues/25789)）。

### リジュームピッカーの表示件数を拡大

`/resume` コマンドのセッション一覧に最初から表示される件数が 10 件から **50 件**に増加し、過去セッションをより素早く見つけられるようになりました（[#26123](https://github.com/anthropics/claude-code/issues/26123)）。

## 改善点

### 起動パフォーマンスの向上（約500ms 短縮）

`SessionStart` フックの実行を遅延させることで、インタラクティブな操作が可能になるまでの時間が約 **500ms** 短縮されました。

### `@` ファイルメンション のパフォーマンス向上

ファイル候補のインデックスを起動時にプリウォームし、セッションベースのキャッシュをバックグラウンド更新で活用することで、`@` によるファイルサジェストの表示速度が大幅に改善されました。

### メモリ使用量の最適化

長時間のセッションでメモリが増大する問題に対して複数の改善が入りました：

- API ストリームバッファ、エージェントコンテキスト、スキルの状態を使用後に解放
- エージェントタスク完了後にメッセージ履歴をトリミング
- プログレス更新における O(n²) のメッセージ蓄積を解消

### VS Code プランプレビューの改善

VS Code でのプランプレビューが改善されました：Claude が反復するたびに自動更新され、レビュー準備が整ったときのみコメントが有効化され、プランを却下しても Claude が修正できるようプレビューが開いたままになります。

### 設定バックアップファイルの整理

設定のバックアップファイルがホームディレクトリのルートから `~/.claude/backups/` に移動されました（[#26130](https://github.com/anthropics/claude-code/issues/26130)）。

## バグ修正

### Windows・WSL2 関連

Windows 環境に関する多数のバグが修正されました：

- **MSYS2/Cygwin シェルで bash ツール出力が無視される問題**を修正
- **`os.EOL`（`\r\n`）によって行カウントが常に 1 になる表示バグ**を修正
- **マークダウン出力の太字・色付きテキストが文字ズレする問題**（`\r\n` 起因）を修正
- **CWD 追跡用の一時ファイルが蓄積し続ける問題**を修正（[#17600](https://github.com/anthropics/claude-code/issues/17600)）
- **ドライブレターの大文字・小文字差異による worktree セッションマッチングの不具合**を修正（[#26123](https://github.com/anthropics/claude-code/issues/26123)）
- **ドライブレター差異で同一 CLAUDE.md が二重読み込みされる問題**を修正（[#25756](https://github.com/anthropics/claude-code/issues/25756)）
- **WSL2 で Windows が BMP 形式でコピーした画像の貼り付けが機能しない問題**を修正（[#25935](https://github.com/anthropics/claude-code/issues/25935)）
- **Windows/Git Bash ターミナルで Right Alt キーが `[25~` エスケープシーケンスを残す問題**を修正（[#25943](https://github.com/anthropics/claude-code/issues/25943)）
- **Windows でフック（PreToolUse/PostToolUse）が実行されない問題**を Git Bash を使用することで修正（[#25981](https://github.com/anthropics/claude-code/issues/25981)）

### エージェント・セッション管理

- **並行エージェント使用時に「thinking blocks cannot be modified」の API 400 エラーが発生する問題**を修正
- **コンテキスト圧縮後にプランモードが失われる問題**を修正（[#26061](https://github.com/anthropics/claude-code/issues/26061)）
- **`/rename` で設定したセッション名が会話再開後に失われる問題**を修正（[#23610](https://github.com/anthropics/claude-code/issues/23610)）
- **コンテキスト圧縮後にセッション名が失われる問題**を修正（[#26121](https://github.com/anthropics/claude-code/issues/26121)）
- **最初のメッセージが 16KB を超えるセッションが `/resume` リストから消える問題**を修正（[#26140](https://github.com/anthropics/claude-code/issues/26140)）
- **`/resume <session-id>` が 16KB 超セッションを見つけられない問題**を修正（[#25920](https://github.com/anthropics/claude-code/issues/25920)）
- **カスタムエージェントの `model` フィールドがチームメイトのスポーン時に無視される問題**を修正（[#26064](https://github.com/anthropics/claude-code/issues/26064)）
- **バックグラウンドエージェントの結果が最終回答でなくトランスクリプト生データを返す問題**を修正（[#26012](https://github.com/anthropics/claude-code/issues/26012)）
- **`/clear` コマンド後もステータスバーにセッション名が残る問題**を修正（[#26082](https://github.com/anthropics/claude-code/issues/26082)）
- **`/resume` が配列形式コンテンツや 16KB 超の最初のメッセージを持つセッションを無視する問題**を修正（[#25721](https://github.com/anthropics/claude-code/issues/25721)）

### ファイル・テキスト処理

- **FileWriteTool の行カウントで意図的な末尾の空行が `trimEnd()` によって削除される問題**を修正
- **Edit ツールが Unicode の「curly quotes」（`\u201c`/`\u201d`/`\u2018`/`\u2019`）をストレートクォートに変換してしまう問題**を修正（[#26141](https://github.com/anthropics/claude-code/issues/26141)）
- **マークダウン内のインラインコードスパンが bash コマンドとして誤解析される問題**を修正（[#25792](https://github.com/anthropics/claude-code/issues/25792)）
- **バックスラッシュ＋改行による継続行（`\` で複数行に分けたコマンド）が不正な空引数を生成する問題**を修正

### MCP・スキル・エージェント

- **NFS/FUSE ファイルシステムでユーザー定義エージェントが1ファイルしか読み込まれない問題**を修正（[#26044](https://github.com/anthropics/claude-code/issues/26044)）
- **プラグインエージェントスキルがベア名で参照した場合に無音でロード失敗する問題**を修正（[#25834](https://github.com/anthropics/claude-code/issues/25834)）
- **git worktree 実行時にカスタムエージェント・スキルが発見されない問題**を修正（[#25816](https://github.com/anthropics/claude-code/issues/25816)）
- **遅延ロード後に MCP サーバーが MCP 管理ダイアログに表示されない問題**を修正
- **SKILL.md の `name`/`description` が数値の場合にクラッシュする問題**を修正（[#25837](https://github.com/anthropics/claude-code/issues/25837)）
- **`argument-hint` に YAML シーケンス構文を使ったスキルで React クラッシュが発生する問題**を修正（[#25826](https://github.com/anthropics/claude-code/issues/25826)）

### その他の修正

- **多数の PDF ドキュメントを含む会話でコンテキスト圧縮が失敗する問題**を修正（[#26188](https://github.com/anthropics/claude-code/issues/26188)）
- **bash パーミッションクラシファイアが存在しない説明を生成してパーミッションを誤付与する問題**を修正
- **単一ファイルの書き込み/編集エラーが並列ファイル操作をすべて中断する問題**を修正
- **LSP `findReferences` が `.gitignore` 対象ファイル（`node_modules/`、`venv/` 等）の結果を返す問題**を修正（[#26051](https://github.com/anthropics/claude-code/issues/26051)）
- **macOS で読み取り専用 git コマンドが FSEvents ファイルウォッチャーのループを引き起こす問題**を `--no-optional-locks` フラグで修正（[#25750](https://github.com/anthropics/claude-code/issues/25750)）
- **ネスト済み Claude セッション内で `claude doctor` などの非インタラクティブサブコマンドがブロックされる問題**を修正（[#25803](https://github.com/anthropics/claude-code/issues/25803)）
- **zsh のヒアドキュメントがサンドボックスコマンドで「read-only file system」エラーになる問題**を修正（[#25990](https://github.com/anthropics/claude-code/issues/25990)）
- **`alwaysThinkingEnabled: true` が Bedrock および Vertex プロバイダーで機能しない問題**を修正（[#26074](https://github.com/anthropics/claude-code/issues/26074)）
- **`claude doctor` が mise/asdf 管理のインストールをネイティブインストールと誤判定する問題**を修正（[#26033](https://github.com/anthropics/claude-code/issues/26033)）
- **`/fork` コマンドをウェブ検索を使用したセッションで使うとクラッシュする問題**を修正（[#25811](https://github.com/anthropics/claude-code/issues/25811)）
- **複数行 bash コマンドへの「Always allow」が不正なパーミッションパターンを生成して設定を破損する問題**を修正（[#25909](https://github.com/anthropics/claude-code/issues/25909)）
- **コマンドが自身の作業ディレクトリを削除した後にシェルコマンドが永続的に失敗する問題**を修正（[#26136](https://github.com/anthropics/claude-code/issues/26136)）
- **CJK（日中韓）全角文字が TUI のタイムスタンプとレイアウトをずれさせる問題**を修正（[#26084](https://github.com/anthropics/claude-code/issues/26084)）
- **OSC 8 ハイパーリンクがテキストが複数行にわたる場合に最初の行でしかクリックできない問題**を修正

## 技術的なポイント

- **Windows 対応の大幅強化**: `\r\n` 改行コードに起因する表示バグ、MSYS2/Cygwin でのシェルインテグレーション問題、フックの実行方法を Git Bash に切り替えるなど、Windows 環境の本格的なサポートが進んでいます
- **メモリリーク対策の複数実装**: O(n²) のメッセージ蓄積解消、タスク完了後のコンテキスト解放など、長時間セッションのメモリ安定性が改善されました
- **セッション永続化の信頼性向上**: セッション名、プランモード、16KB 超のセッションの取り扱いなど、セッション状態の保持に関わる問題が網羅的に修正されています
- **bash パーミッションクラシファイアのセキュリティ修正**: ハルシネーションによって存在しない説明がパーミッションを誤付与するという重要なセキュリティバグが修正されました
- **CJK 対応**: 全角文字によるレイアウト崩れの修正は、日本語ユーザーにとって直接的な恩恵があります
- **フック機能の拡張**: `last_assistant_message` の追加により、Stop フックでのアシスタント応答への直接アクセスが容易になりました
- **エージェントのライフサイクル制御**: `ctrl+f` による一括終了と ESC による主スレッドのみのキャンセル分離で、マルチエージェント操作がより直感的になりました

## まとめ

v2.1.47 は新機能よりもバグ修正と安定性向上に重点を置いたリリースです。特に Windows 環境のサポートが大幅に強化されており、これまで Windows で発生していた多くの問題が解消されました。日本語環境においては CJK 全角文字のレイアウト修正が直接的な恩恵となります。

メモリ使用量の最適化と起動パフォーマンスの改善は長時間の開発セッションでの体験を向上させ、セッション管理周りの修正は重要な作業状態の喪失リスクを大幅に低減します。修正件数の多さからも、Claude Code チームが品質向上に注力していることがわかります。今後のリリースでもこうした安定性改善が継続されることが期待されます。
