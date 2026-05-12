# 🗺️ 第2章 実装計画書 (Chapter 2: Plan & Tasks)

## 📌 章のテーマ: 「認証基盤の構築と日本語化（Identity & Localization）」

第1章で確立した「NexusMfg」の雛形に対し、業務システムの心臓部である「利用者管理」と、現場での使いやすさを左右する「日本語化」を実装する。

### 🎯 最終ゴール (Goal) ✅ 完了
- [x] システム全体が正確な日本語（Rails i18n）で表示されていること。
- [x] 管理者が発行した「ユーザーコード」によるログインが実現されていること（ADR 001準拠）。
- [x] Rails 8 標準の認証機能をベースにしつつ、業務要件に合わない不要な機能が排除されていること。

---

## 🛠️ エージェント別タスクボード (Task Board by Agent)

### 🧪 QA Tester (TDD・要件証明) ✅ 完了
- [x] **RED テストの先行作成**: Backend 実装前に、以下の要件を満たすテストコード（Minitest）を作成・物理実行し、RED（失敗）を確認。
    - ユーザーコードによるログイン成功。
    - 不正なユーザーコード/パスワードによるログイン失敗。
    - 認証が必要な画面への非ログイン時のアクセス制限。
- [x] **RED 記録の保存**: 「なぜ落ちるのか」という意図を明確にした攻撃的なテスト設計ログを残す。
- [x] **GREEN 検証**: Backend 実装後にテストを再実行し、すべて PASS（GREEN）することを確認。（最終結果: 3 runs, 4 assertions, 0 failures）

### ⚙️ Backend Agent (ロジック実装・GREEN化) ✅ 完了
- [x] **日本語化設定**: `config/application.rb` に `config.i18n.default_locale = :ja` を追加。
- [x] **認証基盤生成**: Rails 8 `bin/rails generate authentication` を実行。
- [x] **テストを GREEN にする実装**:
    - `User` モデルを `user_code` 仕様へ変更（Migration含む。`email_address` → `user_code`、`name` カラム追加）。
    - `SessionsController` を修正し、認証失敗時に `401 Unauthorized` を返すよう調整。
- [x] **シードデータ**: 初期ユーザー作成。（`HomeController` および `root_url` 設定も含む）

### 🎨 Frontend Agent (UI/UX デザイン) ✅ 完了
- [x] **ログインUI実装**: 作成直後のデフォルトまたは使用技術の最低限のテンプレートで実装。日本語ログイン画面の構築。（デザインやUX向上は別の章で実施予定）
- [x] **View の I18n 化**: `config/locales/ja.yml` を新規作成し、sessions / home / navigation / app の4ドメインのハードコードを排除。
    - **追加成果**: Flash メッセージの Lazy Lookup 化（`sessions.create.alert`）まで徹底。

### 🕵️ E2E Tester (品質監査) ✅ 完了
- [x] **実機ブラウザ検証** (`bin/dev` 起動後):
    - ログイン画面が日本語で正しく表示されること。
    - 正しい `user_code` + パスワードでログインし、ダッシュボードへ遷移すること。
    - 誤情報でログイン失敗し、エラーが日本語で表示されること。
    - ログイン状態でナビゲーションバーに「ログアウト」が表示されること。
    - 未ログイン状態でダッシュボードへ直接アクセスするとログイン画面へリダイレクトされること。
- [x] **audit ログの作成**: 検証結果を `docs/nexus_records/logs/chapter02/` 配下の `audit_01.md` 〜 `audit_03.md` に記録し、Backend/Frontend の実装品質を担保。

### 🏛️ Architect (全体コードレビュー) ✅ 完了
- [x] **ADR 準拠確認**: `user_code` 仕様・不要機能（PWリセット）の排除を確認。
- [x] **品質ゲート承認**: E2E Tester の監査に基づき、Tech Writer への教程執筆指示。
- [x] **実態と教程の同期**: `config/application.rb` のタイムゾーン設定漏れを検知・修正。

### 📝 Tech Writer (教育・ドキュメント) ✅ 完了
- [x] **第2章教程作成**: TDD プロセス、Pain体験、I18n 導入を含む高解像度教程を執筆。
- [x] **技術解体**: Appendix で bcrypt、Auth Generator、I18n（Lazy Lookup 等）、Git（switch/restore/Commit規則）を最高解像度で解説。
- [x] **Diff-Teaching の徹底**: ジェネレーター生成コードの改変プロセスをコメントアウト形式で提示。

### 🕵️ E2E Tester (Cold Start 最終監査) ✅ 完了
- [x] **Cold Start Test**: 教程通りのコピペ再現性確認。
    - 計5回の徹底監査（audit_04 〜 audit_07）を実施。
    - **摘出・修正**: `ja.yml` の階層不備、ダッシュボード手順の欠落、`touch` コマンドやフラグの解説不足をすべて解消。
- [x] **三重埋め込みチェック**: リンク整合性の最終監査を完了。

---

## 📅 TDD 運用プロトコル (Workflow)

1.  ✅ **分身 (Branch)**: `feat/chapter02-auth-i18n` を作成。
    - **【微修正】**: 途中から Git コマンドを `checkout` から `switch` へ近代化して運用。
2.  ✅ **破壊 (RED)**: **QA Tester** がテストを書き、失敗（RED）を証明。
3.  ✅ **構築 (GREEN)**: **Backend** が実装を行い、テストを成功（GREEN）させる。
4.  ✅ **装飾 (UI)**: **Frontend** が UI と I18n 化を整える。
5.  ✅ **検証 (Audit)**: **E2E Tester** が実機ブラウザ検証 (`audit_01-03`) を実施。
6.  ✅ **査察 (Architect Review)**: **Architect** が全体レビューし、執筆号令。
7.  ✅ **記録 (Docs)**: **Tech Writer** が教程化。
8.  ✅ **証明 (Final Audit)**: **E2E Tester** が Cold Start 監査 (`audit_04-07`) を完遂。
9.  🔄 **統合 (Merge)**: `main` への最終マージ（※現在この最終段階）。

---

## 🕵️ Architect's Directive (号令)
本計画書にある全項目は、一分の妥協もなく「Copy-Paste Perfect」の基準で完遂された。特に、当初計画に存在しなかった「Flashメッセージの完全I18n化」や「モダンGitコマンドへの刷新」など、教育的品質を高めるための自発的な改善が多数盛り込まれた。第3章では、この強固な基盤の上に、本アプリの業務核である「生産マスターデータ管理」を構築する。
