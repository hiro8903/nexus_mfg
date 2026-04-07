# NexusMfg (製造管理統合コアシステム)

NexusMfg は、製造現場における「受注・計画・調達・在庫」の全プロセスを一元管理するための製造管理統合プラットフォームです。

本プロジェクトは、**AI（Antigravity）をパートナーとした「AI駆動型開発」のポートフォリオ**として構築されています。単に正常に動作するアプリケーションを構築するだけでなく、その設計思想から実装の過程、トラブルシューティングの記録に至るまで、開発の全貌をドキュメント化して管理することを目的とした学習・教育用リポジトリです。

---

## 💎 プロジェクトの特徴 (Key Concepts)

### 1. ドキュメント駆動設計 (Standardized Documentation)
「読めば誰でも同じものを作れる、あるいは迷わずに保守できる」状態を目指し、以下の3層構造でドキュメントを管理しています。
- **[ブループリント・要件定義](./docs/blueprint/)**: ビジネスの目的と物理的な設計の定義。
- **[アーキテクチャ意思決定 (ADR)](./docs/decisions/)**: なぜその設計やライブラリを選んだのかという思考の記録。
- **[チュートリアルポータル](./docs/nexus_tutorials/00_tutorial_index.md)**: ゼロから一歩ずつ実装を進めるための学習ガイド。

### 2. 生きた開発記録 (Activity Logs)
AIと開発者がどのようなやり取りをし、どのようなエラーに直面し、どう解決したかという「実装の足跡」を逐一記録しています。
- **[作業ログの一覧はこちら](./docs/nexus_records/logs/)**

---

## 🚀 技術スタック (Technology Stack)

- **Framework**: Ruby on Rails 8.1+
- **Database**: SQLite3
- **Styling**: Tailwind CSS v4 (Standard Mode)
- **Asset Pipeline**: Propshaft (+ tailwindcss-rails)
- **Development Tool**: `bin/dev` による統合プロセス管理

---

## 🛠 開発の始め方 (Quick Start)

フロントエンドのビルドと Rails サーバーを同時に起動するため、必ず以下のコマンドを使用してください。
```bash
$ bin/dev
# ブラウザで http://localhost:3000 にアクセス
```

詳細なフロントエンドの開発ルールについては、[フロントエンド開発標準](./docs/blueprint/frontend_standard.md) を参照してください。

---

## ⚖️ ライセンス (License)

このプロジェクトは [MIT License](./LICENSE) のもとで公開しています。
学習やポートフォリオの参考にされる方は、ご自由にどうぞ。
