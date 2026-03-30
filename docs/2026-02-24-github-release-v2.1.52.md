---
title: "Claude Code v2.1.52 リリース — Windows環境でのVS Codeエクステンションクラッシュを修正"
date: 2026-02-24
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.52"
identifier: "v2.1.52"
---

# Claude Code v2.1.52 リリース — Windows環境でのVS Codeエクステンションクラッシュを修正

## 概要

Claude Code v2.1.52 がリリースされました。このリリースはバグ修正に特化したパッチリリースであり、Windows環境のVS Codeユーザーに影響していた重大なエクステンションクラッシュの問題が解決されています。特にコマンド `claude-vscode.editor.openLast` が見つからないというエラーによりエクステンションが起動できなくなる問題が対象です。

## バグ修正

### VS Code: Windows環境でのエクステンションクラッシュ修正

**修正されたエラー**: `command 'claude-vscode.editor.openLast' not found`

Windows環境でClaude CodeのVS Codeエクステンションを使用している際、特定の条件下でエクステンションがクラッシュする問題が報告されていました。このエラーは、VS Codeのコマンドレジストリに `claude-vscode.editor.openLast` コマンドが登録されていない状態でそのコマンドを参照しようとした際に発生していました。

この種のエラーは、VS Codeエクステンションのライフサイクル管理において、コマンドの登録タイミングや初期化順序に起因するケースが多く見られます。Windows環境特有の動作差異が原因で、macOS や Linux では発生しにくい問題だったと考えられます。

修正によって、Windows上でもエクステンションが安定して起動・動作するようになりました。以前このエラーに遭遇していたユーザーは、v2.1.52 へのアップデートにより問題が解消されます。

## 技術的なポイント

- **対象プラットフォーム**: Windows（macOS・Linux では影響なし）
- **影響コンポーネント**: VS Codeエクステンション（`claude-vscode`）
- **エラーの性質**: コマンド未登録状態での参照によるランタイムクラッシュ
- **修正の範囲**: エクステンションの初期化処理またはコマンド登録のタイミングに関する修正
- **アップデート方法**: VS Code のエクステンション自動更新、または以下のコマンドで手動更新が可能です

```bash
npm install -g @anthropic-ai/claude-code@latest
```

## まとめ

v2.1.52 は Windows ユーザーにとって重要なパッチリリースです。VS Codeエクステンションのクラッシュはワークフローを大きく妨げる問題であるため、Windows環境でClaude Codeを利用している開発者は速やかなアップデートが推奨されます。

今後も Claude Code はプラットフォームをまたいだ安定性の向上を継続していくと期待されます。クロスプラットフォーム対応の品質維持は、多様な開発環境を持つチームにとって重要な要素であり、今回の修正はその取り組みの一環と言えます。
