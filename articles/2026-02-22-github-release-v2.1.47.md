---
title: "Claude Code v2.1.47 リリース — 大規模バグ修正とパフォーマンス改善"
date: 2026-02-22
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.47"
identifier: "v2.1.47"
---

# Claude Code v2.1.47 リリース — 大規模バグ修正とパフォーマンス改善

## 概要

Claude Code v2.1.47 は、Windows 対応の強化、メモリ・起動パフォーマンスの改善、エージェント/セッション管理の安定性向上を中心とした大規模リリースです。60 件以上のバグ修正と複数の新機能が含まれており、特に Windows ユーザーや長時間セッションを利用する開発者にとって恩恵の大きいアップデートです。

## 新機能

### バックグラウンドエージェントの制御改善

バックグラウンドエージェントの停止操作が変更されました。これまでの `ESC` 二度押しから **`ctrl+f`** に変更されています。

```
# 変更前: ESC を2回押してバックグラウンドエージェントを停止
# 変更後: ctrl+f で全バックグラウンドエージェントを停止
```

あわせて、`ESC` でメインスレッドをキャンセルしてもバックグラウンドエージェントは継続して実行されるようになりました。エージェントのライフサイクル管理がより柔軟になっています。

### フックへの `last_assistant_message` フィールド追加

`Stop` および `SubagentStop` フックの入力に `last_assistant_message` フィールドが追加されました。これにより、フックスクリプトがトランスクリプトファイルを直接パースしなくても、アシスタントの最終応答テキストを取得できるようになります。

### `chat:newline` キーバインドアクション

複数行入力の改行操作を設定ファイルからカスタマイズできる `chat:newline` キーバインドアクションが追加されました（[#26075](https://github.com/anthropics/claude-code/issues/26075)）。

### ステータスライン JSON への `added_dirs` 追加

`/add-dir` で追加されたディレクトリが、ステータスライン JSON の `workspace` セクションに `added_dirs` として公開されるようになりました（[#26096](https://github.com/anthropics/claude-code/issues/26096)）。外部スクリプトからワークスペース情報を取得する際に活用できます。

## 改善点

### VS Code プランプレビューの強化

VS Code でのプランプレビュー機能が大幅に改善されました。

- Claude が反復するたびにプレビューが**自動更新**されるようになりました
- プランがレビュー可能な状態になって初めてコメント機能が有効化されます
- プランを拒否した際もプレビューが開いたまま維持され、Claude が修正しやすくなっています

### 起動パフォーマンスの改善（約 500ms 短縮）

`SessionStart` フックの実行を遅延させることで、インタラクティブ操作が可能になるまでの時間が **約 500ms 短縮**されました。

### メモリ使用量の改善

長時間セッションでのメモリ使用量が複数の観点から改善されています。

- API ストリームバッファ、エージェントコンテキスト、スキルの状態を使用後に解放
- エージェントタスク完了後にメッセージ履歴をトリミング
- プログレス更新における **O(n²) のメッセージ蓄積を排除**

### `@` ファイルメンションの高速化

起動時にインデックスをプリウォームし、セッションベースのキャッシュとバックグラウンド更新を利用することで、`@` ファイルメンションの候補が素早く表示されるようになりました。

### チームメイトナビゲーションのシンプル化

チームメイト間のナビゲーションが `Shift+Up` / `Shift+Down` から **`Shift+Down`（ラップアラウンド付き）のみ**にシンプル化されました。

## バグ修正

### Windows 対応の強化

Windows 環境での多数のバグが修正されています。

- **ターミナルレンダリング**: `os.EOL`（`\r\n`）に起因する行数表示の誤り（常に 1 を表示）と太字・色付きテキストの文字ずれを修正
- **MSYS2 / Cygwin**: bash ツールの出力がサイレントに破棄される問題を修正
- **CWD トラッキング**: 一時ファイルが無限に蓄積される問題を修正（[#17600](https://github.com/anthropics/claude-code/issues/17600)）
- **ドライブレターの大文字小文字**: ワークツリーセッションマッチングと `CLAUDE.md` の二重読み込みを修正
- **フックの実行**: `cmd.exe` の代わりに Git Bash を使用することで `PreToolUse`/`PostToolUse` フックがサイレントに失敗する問題を修正（[#25981](https://github.com/anthropics/claude-code/issues/25981)）
- **Right Alt キー**: `[25~` エスケープシーケンスが入力フィールドに残る問題を修正（[#25943](https://github.com/anthropics/claude-code/issues/25943)）

### セッション管理

- `/rename` で設定したカスタムセッションタイトルがセッション再開後やコンテキストコンパクション後に失われる問題を修正（[#23610](https://github.com/anthropics/claude-code/issues/23610)、[#26121](https://github.com/anthropics/claude-code/issues/26121)）
- 最初のメッセージが 16KB を超えるセッションが `/resume` リストから消える問題を修正（[#26140](https://github.com/anthropics/claude-code/issues/26140)）
- コンテキストコンパクション後にプランモードが失われ、実装モードに切り替わる問題を修正（[#26061](https://github.com/anthropics/claude-code/issues/26061)）
- `/clear` コマンド後もステータスバーにセッション名が残る問題を修正（[#26082](https://github.com/anthropics/claude-code/issues/26082)）
- `/resume` ピッカーの初期表示セッション数を 10 から **50** に増加（[#26123](https://github.com/anthropics/claude-code/issues/26123)）

### エージェント・スキル

- NFS/FUSE ファイルシステム（inode が 0 を報告）でユーザー定義エージェントが 1 ファイルしか読み込まれない問題を修正（[#26044](https://github.com/anthropics/claude-code/issues/26044)）
- ベア名で参照されたプラグインエージェントスキルがサイレントに読み込まれない問題を修正（[#25834](https://github.com/anthropics/claude-code/issues/25834)）
- git ワークツリーからカスタムエージェント・スキルが検出されない問題を修正。メインリポジトリの `.claude/agents/` と `.claude/skills/` が参照されるようになりました（[#25816](https://github.com/anthropics/claude-code/issues/25816)）
- カスタムエージェントの `model` フィールドがチームメイトスポーン時に無視される問題を修正（[#26064](https://github.com/anthropics/claude-code/issues/26064)）
- 並行エージェントセッションで "thinking blocks cannot be modified" という API 400 エラーが発生する問題を修正
- バックグラウンドエージェントの結果がトランスクリプト生データではなく最終回答を返すよう修正（[#26012](https://github.com/anthropics/claude-code/issues/26012)）

### セキュリティ

bash パーミッションクラシファイアが、返されたマッチ説明が実際の入力ルールに対応しているかを検証するようになりました。これにより、ハルシネーションによる説明が不正にパーミッションを付与するのを防ぎます。

### その他の主なバグ修正

- **PDF コンパクション**: 大量の PDF ドキュメントを含む会話でコンパクションが失敗する問題を修正（[#26188](https://github.com/anthropics/claude-code/issues/26188)）
- **FileWriteTool**: 意図的なトレーリング空白行が `trimEnd()` で削除される問題を修正
- **Edit ツール**: Unicode の曲線引用符（`\u201c\u201d` `\u2018\u2019`）が直線引用符に置換される問題を修正（[#26141](https://github.com/anthropics/claude-code/issues/26141)）
- **LSP**: `findReferences` などがgitignore 対象ファイル（`node_modules/`、`venv/` 等）を返す問題を修正（[#26051](https://github.com/anthropics/claude-code/issues/26051)）
- **macOS**: 読み取り専用 git コマンドが `--no-optional-locks` フラグ追加により FSEvents ファイルウォッチャーのループを引き起こす問題を修正（[#25750](https://github.com/anthropics/claude-code/issues/25750)）
- **WSL2**: Windows が BMP フォーマットでコピーした画像を貼り付けられない問題を修正（[#25935](https://github.com/anthropics/claude-code/issues/25935)）
- **バックスラッシュ改行**: 複数行に分割したコマンド（`\` による継続行）で余分な空引数が生成される問題を修正
- **設定バックアップ**: バックアップファイルをホームディレクトリのルートから `~/.claude/backups/` に移動（[#26130](https://github.com/anthropics/claude-code/issues/26130)）
- **CJK 文字**: 全角文字によるタイムスタンプとレイアウト要素のずれを修正（[#26084](https://github.com/anthropics/claude-code/issues/26084)）
- **スラッシュコマンド**: 多数のユーザースキルがインストールされている場合に組み込みスラッシュコマンドがオートコンプリートに表示されない問題を修正（[#22020](https://github.com/anthropics/claude-code/issues/22020)）

## 技術的なポイント

- **O(n²) メッセージ蓄積の排除**: 長時間エージェントセッションでのメモリリークに相当するパフォーマンス問題が修正されました。大規模プロジェクトでの長時間実行時に効果が現れます
- **bash パーミッション検証の強化**: クラシファイアがルールの実在確認を行うことでセキュリティが向上しています
- **Windows フック実行の改善**: `PreToolUse`/`PostToolUse` フックが `cmd.exe` ではなく Git Bash 経由で実行されるようになり、シェルスクリプトの互換性が高まりました
- **`last_assistant_message` フック入力**: CI/CD パイプラインでフックを活用している場合、トランスクリプトの解析なしに最終応答テキストを取得できるため、ポストプロセッシングが簡略化されます
- **`--no-optional-locks` の適用**: macOS で git コマンドがファイルウォッチャーと干渉する問題の根本原因に対処しており、他の git ベースの IDE でも参考になる修正です

## まとめ

v2.1.47 は新機能よりもバグ修正と安定性向上に重点を置いたリリースです。特に Windows 環境での信頼性が大幅に改善されており、Windows ユーザーには早めのアップデートをお勧めします。また、起動時間の短縮とメモリ使用量の改善により、日常的な開発ワークフローでの体験も向上しています。バックグラウンドエージェントの制御変更（`ESC` 二度押し → `ctrl+f`）は操作に影響するため、習慣を更新するよう注意してください。
