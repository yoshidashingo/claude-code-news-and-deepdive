---
title: "Claude Code v2.1.68 リリース: Opus 4.6 のデフォルト effort 設定と ultrathink の復活"
date: 2026-03-07
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.68"
identifier: "v2.1.68"
---

# Claude Code v2.1.68 リリース: Opus 4.6 のデフォルト effort 設定と ultrathink の復活

## 概要

Claude Code v2.1.68 では、Opus 4.6 モデルの推論 effort レベルに関する重要な変更が加えられました。Max および Team プランのユーザー向けに medium effort がデフォルトとなり、一時的に削除されていた `ultrathink` キーワードが復活しました。また、ファーストパーティ API から Opus 4 および Opus 4.1 が削除され、これらのモデルを利用していたユーザーは自動的に Opus 4.6 へ移行されます。

## 新機能

### ultrathink キーワードの復活

`ultrathink` キーワードが再導入されました。このキーワードをプロンプトに含めることで、次のターンの推論に **high effort** を適用できます。複雑な問題や深い分析が必要なタスクで、より高い品質の回答を引き出したい場合に有効です。

```
ultrathink このアーキテクチャの設計上の問題点を洗い出してください
```

## 改善点

### Opus 4.6 のデフォルト effort が medium に変更

Max および Team プランのユーザーに対して、Opus 4.6 モデルの推論 effort がデフォルトで **medium effort** に設定されるようになりました。

Anthropic は medium effort を「速度と徹底性のバランスがとれたスイートスポット」と位置付けており、大多数のタスクに対して適切な品質を維持しつつ、応答速度も確保できるとしています。

effort レベルはいつでも `/model` コマンドから変更可能です。high effort が必要な場合は `ultrathink` キーワードを使用するか、`/model` で設定を調整してください。

## Breaking Changes

### Opus 4 および Opus 4.1 の廃止

ファーストパーティ API 上の Claude Code から **Opus 4** と **Opus 4.1** が削除されました。これらのモデルをピン留め設定していたユーザーは、自動的に **Opus 4.6** へ移行されます。

手動での対応は不要ですが、Opus 4.6 は推論 effort の概念を持つモデルであるため、旧モデルと動作特性が異なる点に注意してください。サードパーティの API キー（Anthropic API を直接利用している場合）を使用しているユーザーへの影響は記載されていません。

## 技術的なポイント

- **effort レベルの体系**: Opus 4.6 は low / medium / high の 3 段階の推論 effort をサポートしており、タスクの複雑さに応じて使い分けることで、コストとレイテンシのトレードオフを制御できます
- **ultrathink の活用**: `think`（low/medium effort）と `ultrathink`（high effort）というキーワードを使い分けることで、ターンごとに動的に effort を調整できます
- **モデルの移行**: Opus 4 系から Opus 4.6 への移行は自動化されており、ユーザー側での設定変更は不要です
- **`/model` コマンド**: effort レベルや使用モデルを対話的に変更できるため、用途に応じた柔軟な設定が可能です

## まとめ

v2.1.68 は、Opus 4.6 を中心としたモデルラインナップの整理と、推論 effort の制御機能の改善を目的としたリリースです。medium effort のデフォルト化により、多くのユーザーが意識せずとも速度と品質のバランスを得られるようになります。一方、`ultrathink` の復活により、高度な分析が必要な場面でも明示的に高品質な推論を引き出せる手段が用意されました。Opus 4 系の廃止は旧モデルへの依存を解消するための措置であり、今後は Opus 4.6 を中心に機能が強化されていくことが予想されます。
