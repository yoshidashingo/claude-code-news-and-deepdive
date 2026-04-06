---
title: "Claude Code v2.1.47 リリース — 大規模バグ修正とパフォーマンス改善"
date: 2026-02-23
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.47"
identifier: "v2.1.47"
---

# Claude Code v2.1.47 リリース — 大規模バグ修正とパフォーマンス改善

## 概要

Claude Code v2.1.47 は2026年2月18日にリリースされ、60件を超える修正・改善が含まれる大規模アップデートです。Windows 環境の安定性向上、セッション管理のバグ修正、メモリ・起動時間のパフォーマンス改善が主なテーマとなっています。新機能としては `chat:newline` キーバインドやフックへの `last_assistant_message` フィールド追加なども含まれます。

## 新機能

### `chat:newline` キーバインドアクション

複数行入力のキー操作をカスタマイズできる `chat:newline` キーバインドアクションが追加されました（[#26075](https://github.com/anthropics/claude-code/issues/26075)）。`~/.claude/keybindings.json` で任意のキーに割り当てることで、Shift+Enter 以外のキーで改行を入力できるようになります。

### フックへの `last_assistant_message` フィールド追加

`Stop` および `SubagentStop` フックの入力データに `last_assistant_message` フィールドが追加されました。フックスクリプトがトランスクリプトファイルをパースせずにアシスタントの最終応答テキストを直接参照できるため、フック実装が大幅にシンプルになります。

```json
{
  "hook_event_name": "Stop",
  "last_assistant_message": "タスクが完了しました。",
  ...
}
```

### ステータスラインへの `added_dirs` 追加

ステータスライン JSON の `workspace` セクションに `added_dirs` フィールドが追加されました（[#26096](https://github.com/anthropics/claude-code/issues/26096)）。`/add-dir` コマンドで追加したディレクトリが外部スクリプトから参照できるようになります。

### バックグラウンドエージェントの終了操作変更

バックグラウンドエージェントをすべて終了する操作が、ESC キーの二重押しから `ctrl+f` に変更されました。ESC キーはメインスレッドのキャンセルのみに使用され、バックグラウンドエージェントは引き続き実行を続けます。エージェントのライフサイクルをより細かく制御できるようになりました。

## 改善点

### 起動パフォーマンスの向上（約500ms 短縮）

`SessionStart` フックの実行を遅延させることで、インタラクティブになるまでの時間が約500ms 短縮されました。Claude Code を頻繁に起動する開発者にとって体感できるレスポンス改善です。

### `@` ファイルメンションのパフォーマンス向上

起動時にインデックスをウォームアップし、セッションベースのキャッシュとバックグラウンドリフレッシュを活用することで、`@` によるファイル候補の表示が高速化されました。大規模なコードベースでの補完レスポンスが向上します。

### メモリ使用量の改善

長時間セッションでのメモリ使用量が複数の改善によって削減されました。

- API ストリームバッファ、エージェントコンテキスト、スキル状態を使用後に解放
- エージェントタスクのメッセージ履歴をタスク完了後にトリム
- 進捗更新における O(n²) のメッセージ蓄積を解消

### VS Code プランプレビューの改善

VS Code のプランプレビュー機能が強化されました。

- Claude がプランを繰り返し更新する際に自動更新
- レビュー準備完了時のみコメント入力が有効になる
- 却下時もプレビューが開いたままになり、Claude が修正を行える

### 再開ピッカーの初期表示件数を拡大

`/resume` コマンドで表示されるセッション数が10件から50件に増加しました（[#26123](https://github.com/anthropics/claude-code/issues/26123)）。多数のセッションを持つ開発者が目的のセッションをより素早く見つけられます。

### チームメイトナビゲーションの簡略化

チームメイト（複数エージェント）間のナビゲーションが、Shift+Up と Shift+Down の両方から Shift+Down のみ（ラップアラウンド付き）に簡略化されました。

### `/rename` コマンドがターミナルタブタイトルを更新

`/rename` コマンドでセッション名を変更すると、デフォルトでターミナルタブのタイトルも更新されるようになりました（[#25789](https://github.com/anthropics/claude-code/issues/25789)）。

## バグ修正

### Windows 関連

Windows 環境における多数の問題が修正されました。

- **改行コードによるレンダリングバグ**: `os.EOL`（`\r\n`）が原因で行カウントが常に1と表示される問題、および太字・色付きテキストが誤った文字位置にシフトする問題を修正
- **MSYS2/Cygwin での bash 出力消失**: bash ツールの出力がサイレントに破棄される問題を修正
- **CWD トラッキング一時ファイルの蓄積**: 一時ファイルが無限に蓄積し続ける問題を修正（[#17600](https://github.com/anthropics/claude-code/issues/17600)）
- **ドライブレター大文字小文字の不一致**: セッションマッチングと CLAUDE.md 読み込みで同一ファイルが二重にロードされる問題を修正（[#25756](https://github.com/anthropics/claude-code/issues/25756)）
- **Right Alt キーのエスケープシーケンス残留**: `[25~` という文字列が入力フィールドに残る問題を修正（[#25943](https://github.com/anthropics/claude-code/issues/25943)）
- **フック（PreToolUse/PostToolUse）の実行失敗**: Git Bash を使用することで cmd.exe での実行失敗を修正（[#25981](https://github.com/anthropics/claude-code/issues/25981)）
- **WSL2 での画像ペースト**: Windows が BMP 形式でコピーした画像のペーストに対応（[#25935](https://github.com/anthropics/claude-code/issues/25935)）

### セッション・コンテキスト管理

- **カスタムセッションタイトルの消失**: `/rename` で設定したタイトルが再開後に消える問題を修正（[#23610](https://github.com/anthropics/claude-code/issues/23610)）
- **コンテキスト圧縮後のセッション名消失**: 圧縮後もカスタムタイトルが保持されるよう修正（[#26121](https://github.com/anthropics/claude-code/issues/26121)）
- **16KB超のセッションが `/resume` 一覧から消える**: 大容量の初回メッセージを持つセッションも正常に表示されるよう修正（[#26140](https://github.com/anthropics/claude-code/issues/26140)）
- **コンテキスト圧縮後のプランモード消失**: 圧縮後に計画モードから実装モードに切り替わってしまう問題を修正（[#26061](https://github.com/anthropics/claude-code/issues/26061)）
- **PDF 文書が多い場合の圧縮失敗**: 圧縮 API 送信前にドキュメントブロックと画像を除去することで修正（[#26188](https://github.com/anthropics/claude-code/issues/26188)）
- **`/clear` 後のステータスバーにセッション名が残る**: 修正済み（[#26082](https://github.com/anthropics/claude-code/issues/26082)）

### エージェント・ツール

- **並行エージェントでの API 400 エラー**: thinking blocks が変更できないというエラーが concurrent エージェントのストリーミングコンテンツブロックの混在により発生していた問題を修正
- **並列ファイル書き込みの中断**: 1ファイルのエラーが他の並列ファイル書き込みを中止させる問題を修正（独立した処理は続行されるように）
- **NFS/FUSE ファイルシステムでのエージェント読み込み失敗**: ゼロ inode を報告するファイルシステムで1ファイルしか読み込まれない問題を修正（[#26044](https://github.com/anthropics/claude-code/issues/26044)）
- **プラグインエージェントスキルの読み込み失敗**: ベア名（完全修飾プラグイン名でなく）での参照時にサイレントに失敗する問題を修正（[#25834](https://github.com/anthropics/claude-code/issues/25834)）
- **バックグラウンドエージェントが生のトランスクリプトを返す**: 最終回答の代わりに生データが返される問題を修正（[#26012](https://github.com/anthropics/claude-code/issues/26012)）
- **カスタムエージェントの `model` フィールドが無視される**: `.claude/agents/*.md` で指定したモデルがチームメイト生成時に反映されない問題を修正（[#26064](https://github.com/anthropics/claude-code/issues/26064)）
- **git worktree でのカスタムエージェント・スキル未検出**: メインリポジトリの `.claude/agents/` と `.claude/skills/` も含まれるよう修正（[#25816](https://github.com/anthropics/claude-code/issues/25816)）

### セキュリティ・権限

- **bash 権限クラシファイアの誤判定**: 返されたマッチ説明が実際の入力ルールに対応していることを検証するよう修正。ハルシネーションされた説明が誤って権限を付与する問題を防止
- **複数行 bash コマンドの「Always allow」が設定を破壊**: 無効なパーミッションパターンが生成されて設定ファイルを破損する問題を修正（[#25909](https://github.com/anthropics/claude-code/issues/25909)）

### ファイル・テキスト処理

- **FileWriteTool の末尾空白行の消失**: `trimEnd()` により意図した末尾空白行が削除される問題を修正
- **Edit ツールでの Unicode 曲引用符の破損**: `\u201c\u201d \u2018\u2019`（いわゆる「スマートクォート」）が直線引用符に置き換えられる問題を修正（[#26141](https://github.com/anthropics/claude-code/issues/26141)）
- **バックスラッシュ改行継続コマンドの誤動作**: `\` で複数行に分割したコマンドが余分な空引数を生成し、コマンド実行が壊れる問題を修正
- **インラインコードスパンが bash コマンドとして誤解釈**: マークダウンの `` `code` `` 記法が bash コマンドとして解析される問題を修正（[#25792](https://github.com/anthropics/claude-code/issues/25792)）

### UI・表示

- **CJK 全角文字によるタイムスタンプのレイアウト崩れ**: TUI でのタイムスタンプや UI 要素の配置ずれを修正（[#26084](https://github.com/anthropics/claude-code/issues/26084)）
- **Warp ターミナルの誤った Shift+Enter 設定プロンプト**: ネイティブサポート済みなのにセットアップを促す問題を修正（[#25957](https://github.com/anthropics/claude-code/issues/25957)）
- **折りたたまれたツール結果のヒントテキスト溢れ**: 狭いターミナルで先頭から切り詰めるよう修正
- **エージェント進捗インジケーターの誤ったツール使用カウント**: 膨張した数値が表示される問題を修正（[#26023](https://github.com/anthropics/claude-code/issues/26023)）
- **スピナーの「0 tokens」カウンター**: トークン受信前に0と表示される問題を修正（[#26105](https://github.com/anthropics/claude-code/issues/26105)）
- **OSC 8 ハイパーリンクが複数行にまたがる際のクリック不可**: リンクテキストが複数行にわたる場合も全行クリック可能に修正
- **VS Code での AskUserQuestion ダイアログ表示中のメッセージ淡色化**: 修正済み（[#26078](https://github.com/anthropics/claude-code/issues/26078)）

### その他

- **`alwaysThinkingEnabled: true` が Bedrock/Vertex で無効**: settings.json の設定が Bedrock および Vertex プロバイダーで反映されない問題を修正（[#26074](https://github.com/anthropics/claude-code/issues/26074)）
- **LSP が gitignore ファイルを返す**: `findReferences` などの操作が `node_modules/` や `venv/` を含む結果を返す問題を修正（[#26051](https://github.com/anthropics/claude-code/issues/26051)）
- **`claude doctor` のインストール種別誤判定**: mise/asdf 管理のインストールがネイティブとして誤分類される問題を修正（[#26033](https://github.com/anthropics/claude-code/issues/26033)）
- **zsh heredoc の「read-only file system」エラー**: サンドボックス化されたコマンドで heredoc が失敗する問題を修正（[#25990](https://github.com/anthropics/claude-code/issues/25990)）
- **設定バックアップファイルの移動**: ホームディレクトリのルートから `~/.claude/backups/` に移動し、ホームディレクトリの散乱を解消（[#26130](https://github.com/anthropics/claude-code/issues/26130)）
- **`/fork` コマンドのクラッシュ**: web 検索を使用したセッションで `/fork` 実行時にクラッシュする問題を修正（[#25811](https://github.com/anthropics/claude-code/issues/25811)）
- **macOS のファイルウォッチャーループ**: 読み取り専用 git コマンドが `--no-optional-locks` フラグで FSEvents ループを引き起こす問題を修正（[#25750](https://github.com/anthropics/claude-code/issues/25750)）
- **`tool_decision` OTel テレメトリイベントの未送信**: ヘッドレス/SDK モードでイベントが発行されない問題を修正（[#26059](https://github.com/anthropics/claude-code/issues/26059)）

## 技術的なポイント

- **bash 権限クラシファイアのセキュリティ強化**: ハルシネーションによるルール説明の誤マッチを防ぐバリデーションが追加されました。自動権限付与ロジックの信頼性が向上しています
- **O(n²) メモリ問題の解消**: 長時間のエージェントセッションで進捗更新のたびにメッセージが蓄積する二次的なメモリ増加が修正されました。大規模タスクの安定性が向上します
- **Windows 改行コード問題への包括的対応**: `\r\n` が原因の行カウント誤り、テキストシフト、bash 出力消失など複数の独立した問題が一括修正されました
- **セッション圧縮の堅牢性向上**: PDF ドキュメントが多い場合の圧縮失敗、圧縮後のプランモード消失、圧縮後のセッション名消失がすべて修正されました
- **フックシステムの拡張**: `last_assistant_message` の追加により、外部スクリプトとの連携がより容易になりました。ポストプロセッシングやログ収集などの用途に活用できます
- **`chat:newline` キーバインドのカスタマイズ**: ターミナルによって Shift+Enter が使いにくい場合に、任意のキーで改行を入力できる柔軟性が提供されます

## まとめ

v2.1.47 は新機能の追加よりもバグ修正と安定性向上に重点を置いたリリースです。特に Windows ユーザーにとっては多数の問題が解消され、実用性が大きく向上しています。また、メモリ使用量の削減と起動時間の短縮は、日常的に Claude Code を使用する開発者全員に恩恵をもたらします。

セッション管理の信頼性向上（タイトル保持、大容量セッションの取り扱い改善）や、エージェント機能のバグ修正も重要な改善点です。複数エージェントを活用した大規模タスクをより安定して実行できるようになりました。今後のバージョンでは、これらの安定性改善を土台にした新機能追加が期待されます。
