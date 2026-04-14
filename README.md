# 🏭 NexusMfg: 製造業向け基盤アプリケーション (Tutorial-Driven Portfolio)

NexusMfg は、Rails 8 を基盤とした製造業向け基盤（ERP/MES）の学習用リファレンス実装、およびポートフォリオです。

単なる完成形を目指すのではなく、**「実装の正道を整理し、その周辺の学びをチュートリアルとして体系化する」** ことで、必要とされる技術的判断とその裏側にある設計思想を、誰もが追体験できる再現性の高い学習プラットフォームを目指しています。制作プロセスそのものを『教える前提』で言語化・体系化することは、技術への理解を深め、自己のスキルを血肉化するための究極の学習プロセスであると考えています。

---

## 🚀 素早いセットアップ (Quick Start)

### 1. 動作環境
- **OS**: macOS Sequoia 15.4.1 (Apple Silicon / M2)
- **Ruby**: 3.4.1 (or latest stable)
- **Framework**: Rails 8.1.3
- **CSS**: Tailwind CSS

### 2. インストール & 起動
```bash
# 依存関係のインストール
bundle install

# サーバーの起動 (Puma + TailwindCSS watcher)
./bin/dev
```

---

## 📖 教育リソースと格闘の記録 (Tutorials & Records)

本プロジェクトの核心は、コードそのものではなく、そこに至るまでの「教育的プロセス」にあります。

- [**NexusMfg チュートリアルポータル（目次）**](docs/nexus_tutorials/index.md)
    - 第1章から順を追って、設計判断と実装の「王道」を学べます。
- [**開発・監査ログ (Records)**](docs/nexus_records/logs/)
    - AIエージェントと人間が、どのようにエラーと格闘し、品質を担保したかの生々しい記録です。

---

## 🏛️ プロジェクトの特筆すべき設計
- **チュートリアル駆動開発**: 実装の各ステップにおいて、なぜその手順を踏むのか、もしやらなかったらどうなるのか（Negative Logic）を徹底的に解説したドキュメントと並走します。
- **NexusMfg 連携アーキテクチャ**: コード（App）と並走して、全ての設計、教訓、エラー解決プロセスが `docs/` および AI エージェント（`.antigravity/`）との対話を通じて動的に記録・更新されます。
- **Rails 標準の活用**: `Propshaft`, `Importmap`, `Solid Queue` 等、Rails 8 が提供する標準機能を最大限に活用した実装を目指します。

---

## 🧭 プロジェクト方針と設計図 (Policy & Blueprints)

### 1. 最終ビジョン (The Vision)
資材の調達から在庫管理、生産実績、そして将来の受注予測までを一元管理し、製造現場の「モノ」と「データ」を完全に同期させる、高精度な製造コアシステム（Nexus）を構築する。

### 2. 主要な設計意思決定 (Key Design Decisions - ADR)
- [**認証方式とユーザー識別体系**](docs/decisions/001-authentication-choice.md)
- [**組織・拠点・保管場所の構造**](docs/decisions/002-personnel-and-organization-structure.md) / [**名称の変更 (Facility -> Site)**](docs/decisions/008-rename-facility-to-site.md)
- [**統合品目マスタと調達フロー**](docs/decisions/007-item-master-and-bom-integration.md) / [**調達トレーサビリティ**](docs/decisions/010-ideal-procurement-and-traceability.md)
- [**論理削除の方針**](docs/decisions/004-logical-deletion-policy.md) / [**UIスタックの選定**](docs/decisions/005-frontend-stack-selection.md)
- [**将来の拡張・高度化構想**](docs/decisions/012-ideal-unified-process-and-extended-results.md)

### 3. 技術設計図 (Technical Blueprints)
- [**理想のDB設計図 (DBML)**](docs/blueprint/ideal_schema.dbml)
- [**全体ER図 (Mermaid)**](docs/blueprint/er_diagram.md)
- [**用語集 (Glossary)**](docs/blueprint/glossary.md)

---

## ⚖️ 免責事項とライセンス (Disclaimer & License)

### ⚠️ 免責事項
- 本リポジトリは、学習およびポートフォリオを目的として作成されています。
- **AI ツールの活用について**: 本プロジェクトの設計・実装・ドキュメント作成には、AI搭載コーディングエディタ（Antigravity）をパートナーとして活用しています。AIとの対話を通じた「最高解像度の思考プロセス」の記録そのものが、本プロジェクトの価値の一部です。

### 📄 ライセンス
このプロジェクトは [MIT License](./LICENSE) のもとで公開しています。教育やポートフォリオの参考にされる方は、ご自由にどうぞ。
