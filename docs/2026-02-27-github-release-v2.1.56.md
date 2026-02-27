---
title: "Claude Code v2.1.56 リリース - VS Code 拡張機能のクラッシュ修正"
date: 2026-02-27
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.56"
identifier: "v2.1.56"
---

# Claude Code v2.1.56 リリース - VS Code 拡張機能のクラッシュ修正

## 概要

Claude Code v2.1.56 がリリースされました。本バージョンは VS Code 拡張機能で発生していたクラッシュ問題を修正するバグフィックスリリースです。具体的には、`command 'claude-vscode.editor.openLast' not found` というエラーによるクラッシュの原因がさらに特定・修正されました。

## バグ修正

### VS Code: `claude-vscode.editor.openLast` コマンドが見つからないクラッシュの修正

VS Code 拡張機能において、`command 'claude-vscode.editor.openLast' not found` というエラーメッセージとともにクラッシュが発生する問題が修正されました。

このバグは以前のバージョンでも部分的に対処されていましたが、v2.1.56 ではクラッシュを引き起こす別の原因が特定され、さらなる修正が加えられています。`editor.openLast` コマンドは、Claude Code の VS Code 拡張機能が以前のエディタ状態を復元する際に使用されるコマンドです。このコマンドが拡張機能の初期化タイミングや特定の状態において未登録のまま呼び出されることで、クラッシュが発生していたと考えられます。

## 技術的なポイント

- **対象**: VS Code 拡張機能 (`claude-vscode`)
- **修正内容**: `claude-vscode.editor.openLast` コマンドが見つからないことによるクラッシュの追加原因を修正
- **継続的な改善**: 同一のクラッシュ問題に対して複数のリリースをまたいで段階的に修正が行われており、根本原因の徹底した調査・対処が進められています
- **影響範囲**: VS Code 上で Claude Code 拡張機能を利用しているユーザー全般

## まとめ

v2.1.56 は VS Code 拡張機能の安定性向上を目的としたパッチリリースです。`claude-vscode.editor.openLast` コマンド関連のクラッシュは以前から報告されていた問題であり、今回のリリースでさらなる修正が施されました。VS Code で Claude Code を利用している方は、最新バージョンへのアップデートを推奨します。引き続き同様のクラッシュが発生する場合は、[GitHub の Issue トラッカー](https://github.com/anthropics/claude-code/issues)に報告することで、開発チームの調査に役立てることができます。
