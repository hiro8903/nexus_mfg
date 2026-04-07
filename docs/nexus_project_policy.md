# NexusMfg プロジェクト方針書 (Project Policy)

本ドキュメントは、NexusMfgプロジェクトの全体ビジョン、および設計判断の根拠となるエンジニアリングポリシーをまとめた「憲法」です。再構築にあたり、常にこの方針に立ち返ります。

## 1. 最終ビジョン (The Vision)
資材の調達から在庫管理、生産実績、そして将来の受注予測までを一元管理し、製造現場の「モノ」と「データ」を完全に同期させる、高精度な製造コアシステム（Nexus）を構築する。

---

## 2. 主要な設計意思決定 (Key Design Decisions)
本プロジェクトにおける重要な設計判断の詳細は、以下のドキュメントに集約されています。

- [**認証方式とユーザー識別体系**](./decisions/01_auth_and_identity.md)
    - ユーザーコードによるログインと、役割ベースの権限（RBAC）について。
- [**組織・拠点・保管場所の構造**](./decisions/02_organization_and_base.md)
    - 物理的なの「拠点/場所」と、論理的な「組織」の分離定義について。
- [**統合品目マスタと調達フロー**](./decisions/03_item_procurement_traceability.md)
    - 商品と部品の一律管理および、要求から在庫化までのトレーサビリティ。
- [**データ整合性とUI思想**](./decisions/04_data_policy_and_ui.md)
    - 論理削除（discard）の採用と、エージェント自律によるプレミアムUIの構築。
- [**将来の拡張・高度化構想**](./decisions/05_ideal_future_concepts.md)
    - 単価管理の分離や、あらゆる現場作業を「工程」として統合する理想形について。

---

## 3. 技術設計図 (Technical Blueprints)
実装の迷いをなくすための具体的な設計図です。

- [**理想のDB設計図 (DBML)**](file:///Users/dev/work/environment/nexus_mfg/docs/blueprint/ideal_schema.dbml)
- [**全体ER図 (Mermaid)**](file:///Users/dev/work/environment/nexus_mfg/docs/blueprint/er_diagram.md)
- [**用語集 (Glossary)**](file:///Users/dev/work/environment/nexus_mfg/docs/blueprint/glossary.md)

---

## 4. Rails 8 における追加方針
- **Zero-Config 優先**: Rails 8 の標準機能を最大限に活用し、外部ライブラリへの依存を最小限に抑える。
- **Authentication**: `bin/rails generate authentication` をベースに、独自のユーザーコード認証を拡張実装する。
- **エージェント運用**: [**AIエージェント行動規範**](file:///Users/dev/work/environment/nexus_mfg/docs/nexus_agent/behavior_guidelines.md) に基づき、格闘記録（Records）と道標（Tutorials）を徹底して残す。
