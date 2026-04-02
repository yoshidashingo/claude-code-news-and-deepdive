---
title: "Claude Code v2.1.56 リリース - VS Code 拡張機能のクラッシュ修正"
date: 2026-02-25
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.56"
identifier: "v2.1.56"
---

# Claude Code v2.1.56 リリース - VS Code 拡張機能のクラッシュ修正

## 概要

Claude Code v2.1.56 が 2026年2月25日にリリースされました。本リリースは VS Code 拡張機能の安定性向上を目的としたパッチリリースです。`command 'claude-vscode.editor.openLast' not found` というエラーによるクラッシュの原因をさらに修正しており、開発者が安定した環境で Claude Code を利用できるよう改善されています。

## バグ修正

### VS Code: `claude-vscode.editor.openLast` コマンドが見つからないクラッシュの修正

VS Code 拡張機能において、`command 'claude-vscode.editor.openLast' not found` というエラーが発生し、拡張機能がクラッシュする問題が修正されました。

このエラーは、Claude Code の VS Code 拡張機能が内部的に `claude-vscode.editor.openLast` コマンドを呼び出そうとした際に、コマンドが VS Code のコマンドレジストリに登録されていない状態でアクセスされることで発生します。コマンドの登録タイミングや拡張機能のライフサイクルに関わる問題が原因として考えられます。

今回のリリースノートでは「**another cause**（別の原因）」と記載されており、同エラーに対する修正が今回で初めてではないことを示しています。過去のバージョンでも同様のクラッシュに対応してきており、本バージョンではさらに別のコードパスにおける発生原因を特定・修正しています。

エラーが発生していた主なシナリオとしては以下が考えられます。

- VS Code の起動直後や拡張機能の初期化タイミングでコマンドにアクセスした場合
- 特定の操作フローにおいて、コマンドの登録が完了する前に呼び出しが行われた場合

## 技術的なポイント

- **対象**: VS Code 拡張機能（`claude-vscode`）
- **修正内容**: `claude-vscode.editor.openLast` コマンドが未登録の状態で呼び出されることによるクラッシュの防止
- **再発防止の観点**: 同一エラーに対して複数のリリースにわたり修正が行われており、コマンド登録のライフサイクル管理における複数の問題箇所が順次対応されていることがわかります
- **影響範囲**: VS Code 上で Claude Code を利用しているユーザー全般
- **リリース種別**: パッチリリース（安定性改善）

## まとめ

v2.1.56 は VS Code 拡張機能の安定性をさらに高める小規模なパッチリリースです。`claude-vscode.editor.openLast` コマンドに起因するクラッシュは、過去のバージョンから継続的に対応が進められており、本バージョンでも新たな原因箇所が修正されました。

VS Code で Claude Code を使用していて、エラーポップアップやクラッシュが発生していたユーザーには、本バージョンへのアップデートが推奨されます。アップデートは以下のコマンドで実行できます。

```bash
npm install -g @anthropic-ai/claude-code@latest
```

今後も同様の安定性改善が継続されることが期待されます。
