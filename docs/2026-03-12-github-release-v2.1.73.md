---
title: "Claude Code v2.1.73 リリース — modelOverrides 設定、パフォーマンス改善、多数のバグ修正"
date: 2026-03-12
source: github-release
source_url: "https://github.com/anthropics/claude-code/releases/tag/v2.1.73"
identifier: "v2.1.73"
---

# Claude Code v2.1.73 リリース — modelOverrides 設定、パフォーマンス改善、多数のバグ修正

## 概要

Claude Code v2.1.73 では、カスタムプロバイダーのモデル ID をマッピングできる `modelOverrides` 設定の追加、CPU 使用率 100% やフリーズを引き起こしていた複数のパフォーマンス問題の修正、Bedrock・Vertex・Microsoft Foundry 環境での Subagent モデル管理の改善など、幅広い変更が行われました。また、Bedrock/Vertex/Foundry 環境でのデフォルト Opus モデルが Opus 4.6 に更新されました。

## 新機能

### `modelOverrides` 設定の追加

モデルピッカーのエントリをカスタムプロバイダーのモデル ID にマッピングする `modelOverrides` 設定が追加されました。これにより、例えば AWS Bedrock の Inference Profile ARN を指定するといった柔軟なモデル設定が可能になります。

```json
{
  "modelOverrides": {
    "opus": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-opus-4-6",
    "sonnet": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-sonnet-4-6"
  }
}
```

エンタープライズ環境で特定の Inference Profile を使用している場合や、カスタムファインチューンモデルを利用している場合に特に有用な機能です。

### SSL 証明書エラー時のガイダンス強化

OAuth ログインや接続確認が SSL 証明書エラーで失敗した場合に、具体的な対処方法が案内されるようになりました。企業のプロキシ環境や `NODE_EXTRA_CA_CERTS` 環境変数の設定が必要なケースで、ユーザーが問題を自己解決しやすくなります。

## 改善点

### Up 矢印キーの動作改善

Claude の処理を中断した後に Up 矢印キーを押すと、中断されたプロンプトの復元と会話の巻き戻しが 1 ステップで行われるようになりました。従来は別々の操作が必要でしたが、よりスムーズなワークフローが実現します。

### IDE 検出速度の向上

起動時の IDE 検出処理が高速化されました。

### macOS でのクリップボード画像ペースト高速化

macOS 環境でのクリップボードからの画像ペースト処理のパフォーマンスが改善されました。

### `/effort` コマンドのリアルタイム変更対応

`/effort` コマンドが Claude の応答中でも変更できるようになりました。既に `/model` コマンドで実現されていた動作に合わせた改善です。

### Voice Mode の接続リトライ改善

Push-to-talk を素早く再プレスした際の一時的な接続エラーに対して、自動リトライが行われるようになりました。

### Remote Control のスポーンモード選択プロンプト改善

Remote Control のスポーンモード選択プロンプトにより多くのコンテキスト情報が表示されるようになりました。

### Bedrock/Vertex/Foundry でのデフォルト Opus モデル変更

Bedrock、Vertex、Microsoft Foundry 環境でのデフォルト Opus モデルが **Opus 4.6**（旧: Opus 4.1）に更新されました。これらのプラットフォームを利用している場合、特別な設定変更なく最新の Opus モデルが使用されます。

## バグ修正

### パフォーマンス・安定性

- **複雑な bash コマンドでの CPU 使用率 100%・フリーズ修正**: 権限プロンプトが表示される際に複雑な bash コマンドで発生していたフリーズと CPU 使用率 100% のループが修正されました。
- **スキルファイル大量変更時のデッドロック修正**: `.claude/skills/` ディレクトリに多数のスキルファイルがあるリポジトリで `git pull` を実行した際など、多数のスキルファイルが同時に変更された場合に Claude Code がフリーズするデッドロックが修正されました。
- **同一プロジェクトディレクトリでの複数セッション時の Bash ツール出力消失修正**: 同じプロジェクトディレクトリで複数の Claude Code セッションを実行した際に Bash ツールの出力が失われる問題が修正されました。

### Subagent・セッション管理

- **Bedrock/Vertex/Foundry での Subagent モデルのサイレントダウングレード修正**: `model: opus`/`sonnet`/`haiku` を指定した Subagent が、Bedrock、Vertex、Microsoft Foundry 上で古いモデルバージョンにサイレントダウングレードされていた問題が修正されました。
- **Subagent 終了時のバックグラウンド bash プロセスのクリーンアップ修正**: Subagent が生成したバックグラウンド bash プロセスが、エージェント終了後も残り続ける問題が修正されました。
- **`/resume` で現在のセッションが表示される問題の修正**: `/resume` コマンドのピッカーに現在のセッションが表示されていた問題が修正されました。
- **`--resume` や `--continue` でのセッション再開時に SessionStart フックが 2 回発火する問題の修正**
- **JSON 出力フックが毎ターンにノーオペレーションの system-reminder メッセージを挿入する問題の修正**

### Voice Mode

- **低速接続時のセッション破損修正**: 低速接続で新しい録音が重なった際に Voice Mode のセッションが破損する問題が修正されました。

### Linux

- **Linux サンドボックスで "ripgrep (rg) not found" エラーが発生する問題の修正**: ネイティブビルドでの Linux サンドボックス起動時に発生するエラーが修正されました。
- **Amazon Linux 2 等の glibc 2.26 環境での Linux ネイティブモジュール読み込み失敗の修正**

### その他のプラットフォーム

- **Remote Control 経由での画像受信時の "media_type: Field required" API エラーの修正**
- **Windows での `/heapdump` 失敗の修正**: Desktop フォルダが既に存在する場合に `EEXIST` エラーで `/heapdump` が失敗する問題が修正されました。
- **VSCode: プロキシ環境や Bedrock/Vertex で Claude 4.5 モデルを使用した際の HTTP 400 エラーの修正**
- **`/ide` コマンドで `onInstall is not defined` クラッシュが発生する問題の修正**: 拡張機能の自動インストール時に発生するクラッシュが修正されました。
- **Bedrock/Vertex/Foundry およびテレメトリ無効時に `/loop` が利用できない問題の修正**

## 非推奨 (Deprecated)

### `/output-style` コマンドの非推奨化

`/output-style` コマンドが非推奨となり、`/config` の使用が推奨されます。出力スタイルはプロンプトキャッシュの効率化のため、セッション開始時に固定されるようになりました。既存のワークフローで `/output-style` を使用している場合は、`/config` への移行を検討してください。

## 技術的なポイント

- **`modelOverrides` により、Bedrock Inference Profile ARN など環境固有のモデル ID を柔軟にマッピング可能になった**。エンタープライズ環境での運用管理が容易になります。
- **スキルファイルの大量変更時のデッドロック修正**は、大規模リポジトリで `.claude/skills/` を活用しているチームにとって重要な安定性改善です。
- **Subagent のモデルサイレントダウングレード修正**により、Bedrock/Vertex/Foundry 環境でも意図したモデルバージョンで Subagent が動作することが保証されます。
- **Bedrock/Vertex/Foundry でのデフォルト Opus が 4.6 に更新**されたことで、これらのプラットフォームのユーザーも最新モデルの恩恵を受けられます。
- **`/output-style` の非推奨化**はプロンプトキャッシングの最適化が目的であり、出力スタイルをセッション開始時に固定することでキャッシュヒット率が向上します。
- **SSL 証明書エラーへの対応ガイダンス追加**は、企業プロキシ環境での導入障壁を下げる実用的な改善です。

## まとめ

v2.1.73 は、新機能の追加よりも安定性・パフォーマンス・信頼性の向上に重点を置いたリリースです。特に、CPU 使用率 100% のフリーズやデッドロックといった深刻なパフォーマンス問題の修正は、多くのユーザーが体感できる改善です。

エンタープライズ環境向けには `modelOverrides` 設定が強力なツールとなり、Bedrock や Vertex を活用している組織での柔軟なモデル管理が可能になります。また、Subagent のモデルダウングレード修正により、マルチエージェントワークフローの信頼性も向上しています。

`/output-style` から `/config` への移行を検討しているユーザーは、早めの対応を推奨します。
