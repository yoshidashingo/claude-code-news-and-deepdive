---
title: "Claude Code v2.1.52 リリース: Windows での VS Code 拡張クラッシュを修正"
date: 2026-02-25
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.52"
identifier: "v2.1.52"
---

# Claude Code v2.1.52 リリース: Windows での VS Code 拡張クラッシュを修正

## 概要

Claude Code v2.1.52 は、Windows 環境で発生していた VS Code 拡張機能のクラッシュ問題を修正するバグフィックスリリースです。`"command 'claude-vscode.editor.openLast' not found"` というエラーにより拡張機能が強制終了する問題が解消されました。

## バグ修正

### VS Code: Windows でのクラッシュ修正

Windows 上で Claude Code の VS Code 拡張機能を使用していたユーザーが、以下のエラーとともに拡張機能がクラッシュする問題が報告されていました。

```
command 'claude-vscode.editor.openLast' not found
```

このエラーは `claude-vscode.editor.openLast` コマンドが VS Code のコマンドパレットに登録されていないにもかかわらず、拡張機能が内部でそのコマンドを呼び出そうとしたことが原因と考えられます。Windows 固有の環境差異によってコマンドの登録が正常に行われない状況で発生していた問題で、今回のリリースで修正されました。

## 技術的なポイント

- **対象プラットフォーム**: Windows のみで再現する問題であり、macOS や Linux では影響を受けません
- **影響する機能**: VS Code 拡張機能の起動・動作全般。コマンドが見つからないエラーにより拡張機能全体がクラッシュしていました
- **修正の性質**: ピンポイントのバグフィックスリリースであり、新機能の追加や既存機能への変更はありません

## まとめ

v2.1.52 は Windows ユーザーに影響していたクリティカルな互換性問題を解消する単一のバグ修正リリースです。Windows 上で Claude Code の VS Code 拡張機能がクラッシュしていた方は、このバージョンへアップデートすることで問題が解消されます。`npm update -g @anthropic-ai/claude-code` または VS Code の拡張機能マネージャーからアップデートを適用してください。
