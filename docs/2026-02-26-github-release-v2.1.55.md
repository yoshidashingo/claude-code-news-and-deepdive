---
title: "Claude Code v2.1.55 リリース: Windows での BashTool EINVAL エラーを修正"
date: 2026-02-26
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.55"
identifier: "v2.1.55"
---

# Claude Code v2.1.55 リリース: Windows での BashTool EINVAL エラーを修正

## 概要

Claude Code v2.1.55 では、Windows 環境で BashTool が `EINVAL` エラーで失敗する問題が修正されました。このバグ修正により、Windows ユーザーが BashTool を安定して利用できるようになります。

## バグ修正

### Windows での BashTool EINVAL エラーの解消

今回のリリースの主な変更点は、Windows 環境において BashTool が `EINVAL`（Invalid Argument）エラーで失敗していた問題の修正です。

`EINVAL` エラーは、システムコールに渡された引数が無効な場合に発生するエラーコードです。Windows と Unix 系 OS（macOS、Linux）ではプロセス管理やファイルシステムの扱いに差異があるため、クロスプラットフォーム対応のツールでは、こうした OS 固有の問題が発生することがあります。

この修正により、Windows ユーザーは BashTool を通じてシェルコマンドを実行する際に、以前は発生していたエラーを回避でき、より安定した開発体験が得られます。

## 技術的なポイント

- **対象プラットフォーム**: Windows 環境に固有のバグ修正
- **エラーの性質**: `EINVAL`（errno 22）は「不正な引数」を意味する POSIX 標準のエラーコードで、Windows 上での Node.js または子プロセスの生成に関連する引数の非互換性が原因と考えられます
- **影響範囲**: BashTool を使用するすべての Windows ユーザーが対象
- **macOS・Linux ユーザーへの影響**: なし（Windows 固有の修正）

## まとめ

v2.1.55 は Windows ユーザー向けのバグ修正リリースです。BashTool の `EINVAL` エラーが解消されたことで、Windows 環境での Claude Code の信頼性が向上しました。Windows 上で Claude Code を利用している開発者は、速やかにアップデートすることをお勧めします。

```bash
npm update -g @anthropic-ai/claude-code
```
