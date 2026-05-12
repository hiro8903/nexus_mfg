# 👁️ 第2章教程 真・Cold Start 再監査ログ (audit_06)

- **監査日**: 2026-04-22
- **監査者**: E2E Tester
- **監査対象**: `docs/nexus_tutorials/chapters/02_authentication_and_i18n.md`
- **判定**: ❌ **不合格 (FAIL) - 重大な欠落と整合性エラー**

## 📋 監査ラウンド 4（I18nの整合性再検証）

### 1. 物理的な再現性と Git ワークフロー
- **ブランチ管理**: ✅ **PASS**
  - `[Branch: ...]` の明記により読者の迷子が防がれており、最終段階の `main` への合流・プッシュ・削除のフローも物理状態と正しく一致する。
- **教育的ストーリー**: ✅ **PASS**
  - Pain Phase（英語UIの使いにくさ）から Solution Phase（I18nによる統治）へのカタルシスが美しく構成されている。

### 2. Zero-Knowledge での潜伏バグ（FAIL理由）

しかし、コードのコピペ検証において、以下の**2点の致命的な欠落・不整合**が発覚した。読者がこの通りにコピペ実行した場合、エラーで進行不能、または不完全な状態に陥る。

#### 🚨 欠陥1：Lazy Lookup のスコープ不一致（Translation Missing）
- **発生箇所**: `SessionsController#create`
- **事象**:
  教程では `create` アクション内で `flash.now[:alert] = t(".alert")` と記述させている。Rails の Lazy Lookup の仕様では、これは `sessions.create.alert` を参照しにいく。
  しかし、直前で提供されている `ja.yml` のスニペットでは、`alert` キーが `sessions.new.alert` 配下に配置されている（`create` ブロックが存在しない）。
- **結果**: 読者がパスワードを間違えた際、「ユーザーコードまたは...」ではなく、`Translation missing: ja.sessions.create.alert` という醜いシステムエラーが画面に露出してしまう。

#### 🚨 欠陥2：ホーム画面（Dashboard）のビュー修正手順の完全欠落
- **発生箇所**: Step 5 冒頭 〜 Step 6 末尾
- **事象**: 
  Step 5 で `bin/rails generate controller Home index` を実行させ、Step 6 の `ja.yml` では `home.index.title` や `welcome` などを定義させている。
  しかし、**肝心の `app/views/home/index.html.erb` を編集してその翻訳を呼び出す手順が、チュートリアルから完全に抜け落ちている。**
- **結果**: ダッシュボードの画面はジェネレーターが吐き出した `Home#index Find me in app/views/home/index.html.erb` のままであり、設定した「ようこそ」の文字が一生画面に出力されない。

---

## 🔧 是正要求事項 (Requirement for Tech Writer / Architect)

1. **ja.yml の構造修正**:
   `sessions:` 配下に `create:` ブロックを新設し、そこに `alert:` を移動（またはコピー）すること。
2. **Home#index ビュー手順の追加**:
   Step 6 の末尾または `ja.yml` の説明の後に、`app/views/home/index.html.erb` を上記 I18n（Lazy Lookup）を用いて日本語化するコードブロックの書き換え手順を明記すること。

上記是正後、再度 E2E Tester へ監査を依頼せよ。
