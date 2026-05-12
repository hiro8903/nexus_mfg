# トラブルシューティング：問題と解決策の知見集

NexusMfg の開発中に遭遇する可能性のあるエラーや、環境固有の不具合、セキュリティ警告などの解決方法をまとめています。
チュートリアルの進行中に問題が発生した際は、まずこちらを確認してください。

## 🛡️ セキュリティ・依存関係
- [GitHub CI での Gem セキュリティエラー（脆弱性）の解消](./security/gem_vulnerability.md)
  - **症状**: GitHub へのプッシュ直後、`Vulnerabilities found!` というエラーで CI が止まる。
  - **解決**: ログから原因 Gem を特定し、`Gemfile` の制約修正や `bundle update` で安全なバージョンへ更新する。

## 🚀 CI・テスト実行
- [CI での LoadError (test/system ディレクトリ不在)](../chapters/02_authentication_and_i18n.md#section-7-quality)
  - **症状**: CI 環境で `cannot load such file -- test/system` というエラーが出る。
  - **原因**: Git が空のディレクトリを無視するため、環境構築に必要なフォルダが欠損している。
  - **解決**: `.keep` ファイルを配置してディレクトリ構造を Git に認識させる。

## 💻 開発環境（ローカル）
- （今後追加予定）

---
👈 [チュートリアル目次へ戻る](../index.md)
