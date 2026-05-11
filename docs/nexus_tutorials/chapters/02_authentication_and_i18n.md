# 第2章：認証基盤の構築と日本語化

本章では、Rails 8 で導入された標準認証機能をベースに、業務システム特有の要件である**「ユーザーコード（社員番号等）によるログイン」**を実現します。
まずは「Railsの標準（英語）のまま」機能を作り上げ、その後に**「なぜ体系的な日本語化（I18n）が必要なのか」**を実機で体験しながら、現場で使える強固な基盤を整えます。

---

## 💎 この章の目標

- **Git ブランチ管理の習得**: 機能単位で作業用ブランチを作成し、完了後にマージする本番同様のフローを実践する。
- **Rails 8 標準認証の解剖**: ジェネレーターが自動生成するファイル群の役割を、精査する。
- **要件適応（Customization）**: `email_address` という標準仕様を、業務上必須な `user_code` へカスタマイズする。
- **TDD（テスト駆動開発）の追体験**: RED（期待された失敗）から GREEN（成功）へ至る、エンジニアの心理プロセスを習得する。
- **I18n 翻訳の習得**: **Lazy Lookup** と **ActiveRecord 翻訳** を用い、大規模開発に耐えうる文言管理基盤を構築する。

---

## 🗺️ 目次
1. [準備：作業ブランチの作成](#section-1-prep)
2. [準備：ライブラリの有効化（bcrypt）](#section-2-lib)
3. [破壊：テストの先行作成（RED）](#section-3-tdd)
4. [構築：認証基盤の実装（GREEN）](#section-4-auth)
5. [装飾：ログイン画面の構築](#section-5-ui)
6. [日本語化（I18n）の徹底](#section-6-i18n)
7. [最終検証：全テストのパスと品質管理](#section-7-quality)
8. [作業の完了：GitHub への送信と同期](#section-8-finish)
9. [学習ノート](#section-9-※)

---

| [◀ 第1章：プロジェクトの初期設定](./01_initial_setup.md) | [⬆ 目次](../index.md#chap-2) | 第3章 ▶（未定） |
|:---:|:---:|:---:|

---

## <a id="section-1-prep"></a>1. 準備：作業ブランチの作成

プロの開発現場では、`main` ブランチ（本番環境に直結する歴史）を汚さないよう、必ず機能ごとに「作業用ブランチ」を作成します。

[(プロジェクト内ならどこでも可) (main)]
```bash
# 最新の状態であることを確認
git switch main
git pull origin main

# 第2章用の作業ブランチを作成して、そこへ切り替える
# -c は "Create（作成）" の略。新しい歴史の枝を作り、そこへ一気に移動（switch）します。
git switch -c feat/chapter02-auth-i18n
```

> 💡 **コマンドの豆知識**: `git checkout -b` という古い書き方でも動作しますが、最新の Git ではブランチの切り替えに特化した `git switch` の使用が推奨されています。詳細は本章末尾の <a id="ref-1"></a>[**※1**](#appendix-1) を参照してください。

### ✅ 次へ進むための確認事項
- [ ] `git branch` を実行し、現在 `feat/chapter02-auth-i18n` ブランチにいることが確認できること。

---

## <a id="section-2-lib"></a>2. 準備：ライブラリの有効化

まず、認証の核となるパスワードのハッシュ化ライブラリ **bcrypt** <a id="ref-2"></a>[**※2**](#appendix-2)を有効化します（👉 [公式・一次ソース (Resource Hub)](../resource_hub.md#tech-bcrypt)）。

### Gemfile の修正
Rails 生成直後の `Gemfile` では、セキュリティ上の理由から `bcrypt` がコメントアウトされています。
生パスワードをデータベースにそのまま保存することは、貴重品を鍵をかけずに道端に置いておくようなものです。`bcrypt` はこれを「一方向ハッシュ化」し、絶対的な安全性を担保します。

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`Gemfile`](file:///Users/dev/work/environment/nexus_mfg/Gemfile)
```ruby
# ===== 変更箇所: bcrypt の有効化 =====
# # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"
gem "bcrypt", "~> 3.1.7" # ←コメントアウトを外して有効化
```

> **サバイバル情報**: `bundle` コマンドが見つからない、または PATH 関連エラーが出た場合は、<a id="ref-3"></a>[**※3**](#appendix-3) を参照してください。

設定を変更したら、ターミナルでライブラリを物理的にインストールします <a id="ref-4"></a>[**※4**](#appendix-4)。

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
```bash
bundle install
```

### ✅ 次へ進むための確認事項
- [ ] ターミナルでエラーが出ず、`bundle install` が正常に完了していること。

---

## <a id="section-3-tdd"></a>3. 認証基盤の生成と RED Phase（期待される失敗）

フレームワークの力を最大限に活かすため、**「まず標準の機能を作り出し、それを我々の要件（user_code）に書き換えて壊す」**という順序で進めます <a id="ref-5"></a>[**※5**](#appendix-5)。

### 認証ファイル群の生成
[environment/nexus_mfg (feat/chapter02-auth-i18n)]
ターミナルで以下を実行します。これにより、Rails 8 独自の強固な認証ロジックが物理ファイルとして書き出されます。（生成物の詳細は <a id="ref-6"></a>[**※6**](#appendix-6)）
```bash
bin/rails generate authentication
```

### フィクスチャ（テスト用データ）の書き換え
ジェネレーターが作ってくれたテストユーザーを、今回の要件である「ユーザーコードを持ったユーザー」に書き換えます。

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`test/fixtures/users.yml`](file:///Users/dev/work/environment/nexus_mfg/test/fixtures/users.yml)
```yaml
one:
  # ===== 変更箇所: email_address を user_code と name に書き換え =====
  # email_address: "one@example.com"
  user_code: "EMP001"
  name: "山田 太郎"
  password_digest: <%= BCrypt::Password.create("password") %>
```

### テスト要件の設定（RED Phase）
標準では `email_address` となっているテストを、`user_code` を使う形式へ上書きします。これはシステムに対して「これからはユーザーコードでログインしろ」という**期待（要求）**の表明です。

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`test/integration/authentication_test.rb`](file:///Users/dev/work/environment/nexus_mfg/test/integration/authentication_test.rb)
```ruby
require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "ユーザーコードによるログイン成功" do
    # ===== 変更箇所: email_address を user_code に変更 =====
    # post session_url, params: { email_address: @user.email_address, password: "password" }
    post session_url, params: { user_code: @user.user_code, password: "password" }
    assert_redirected_to root_url
  end

  test "不正な user_code / パスワードによるログイン失敗" do
    # ===== 変更箇所: email_address を user_code に変更 =====
    # post session_url, params: { email_address: @user.email_address, password: "wrong_password" }
    post session_url, params: { user_code: @user.user_code, password: "wrong_password" }
    assert_response :unauthorized

    # ===== 変更箇所: 不正なIDの種類を email_address から user_code へ変更 =====
    # post session_url, params: { email_address: "invalid@example.com", password: "password" }
    post session_url, params: { user_code: "INVALID_CODE", password: "password" }
    assert_response :unauthorized
  end

  test "認証が必要な画面への非ログインアクセス制限" do
    get root_url
    assert_redirected_to new_session_url
  end
end
```

### テストの実行（RED の確認）
テストを実行すると、「user_code なんてカラムは知らない」と怒られて**失敗**します。これこそが「期待された失敗（RED）」です。

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
```bash
bundle exec rails test test/integration/authentication_test.rb
```
*(設計の意図は <a id="ref-7"></a>[**※7**](#appendix-7) 参照)*

### ✅ 次へ進むための確認事項
- [ ] テストが意図的に **FAIL（または ERROR）** となり、「user_code というパラメータが不明である」などのメッセージを確認できたこと。

---

## <a id="section-4-auth"></a>4. GREEN Phase：要件への適合（埋め込み日本語による GREEN）

赤字になったテストを合格させるため、実装を要件へ適合させます。この段階では、**「日本向けのアプリなんだから、ログイン画面のアラートくらいは日本語で見せたい」**という直感的な実装を行います。

### データベースとモデルの修正
（このセクションにおける物理置換の重要性については <a id="ref-8"></a>[**※8**](#appendix-8) を参照してください）

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`db/migrate/YYYYMMDDHHMMSS_create_users.rb`](file:///Users/dev/work/environment/nexus_mfg/db/migrate/20260421020413_create_users.rb)
```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      # ===== 変更箇所: email_address を user_code に変更し、nameを追加 =====
      # t.string :email_address, null: false
      t.string :user_code, null: false
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    # ===== 変更箇所: インデックスも user_code に変更 =====
    # add_index :users, :email_address, unique: true
    add_index :users, :user_code, unique: true
  end
end
```

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`app/models/user.rb`](file:///Users/dev/work/environment/nexus_mfg/app/models/user.rb)
```ruby
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # ===== 変更箇所: normalizes を削除し、バリデーションを追加 =====
  # normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :user_code, presence: true, uniqueness: true
  validates :name, presence: true
end
```

### セッションコントローラーの修正（日本語ハードコード）
[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`app/controllers/sessions_controller.rb`](file:///Users/dev/work/environment/nexus_mfg/app/controllers/sessions_controller.rb)
認証キーを `user_code` へ変更し、ログイン失敗時のメッセージに**日本語を直接書き込みます**。

> [!NOTE]
> **ブルートフォース攻撃対策**: 下記コード内の `rate_limit` 定義により、短時間の過剰なログイン試行を物理的に遮断します。（詳細は <a id="ref-6"></a>[**※6**](#appendix-6) 参照）

```ruby
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    # ===== 変更箇所: 認証キーを user_code へ変更（アラートは日本語で直接記述） =====
    # if user = User.authenticate_by(params.permit(:email_address, :password))
    if user = User.authenticate_by(params.permit(:user_code, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      # flashは意図的に日本語でハードコードし、後で I18n 管理に移行する際の「管理の不便さ」を体験します
      # flash.now[:alert] = "Try again later."
      flash.now[:alert] = "ユーザーコードまたはパスワードが正しくありません。"
      render :new, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
```

### ルーティングの修正
[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`config/routes.rb`](file:///Users/dev/work/environment/nexus_mfg/config/routes.rb)

先ほどのジェネレーターによって、ファイルの冒頭に認証用のルートが自動追加されています。今回は業務要件に基づき、ユーザー自身によるパスワードリセットを禁止するため、該当行をコメントアウトして無効化します。

```ruby
Rails.application.routes.draw do
  resource :session
  
  # ===== 修正: ジェネレーターが生成した不要な機能を無効化 =====
  # resources :passwords, param: :token
  
  # ... (以下、既存の設定) ...
```

### データベース構築とシード
[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`db/seeds.rb`](file:///Users/dev/work/environment/nexus_mfg/db/seeds.rb)
```ruby
# ===== 変更箇所: 初期ユーザーの生成スクリプトを追加 =====
User.find_or_create_by!(user_code: "EMP001") do |user|
  user.name = "山田 太郎"
  user.password = "password"
end

puts "Seed: Created EMP001 user."
```

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
```bash
bin/rails db:migrate
bin/rails db:seed
```

### ✅ 次へ進むための確認事項
- [ ] マイグレーションが成功し、`Seed: Created EMP001 user.` という出力が表示されること。
- [ ] ターミナルでエラーが起きていないこと。

---

## <a id="section-5-ui"></a>5. UIの構築と英語UIの体験（Pain Phase）

機能もテストも GREEN。しかし、画面を動かすと **「英語表記のまま現場で使えるか？」** という問いに直面します。

### ホームコントローラーの作成
[environment/nexus_mfg (feat/chapter02-auth-i18n)]
```bash
bin/rails generate controller Home index
```

**変更ファイル**: [`config/routes.rb`](file:///Users/dev/work/environment/nexus_mfg/config/routes.rb)

コントローラーの生成により `get "home/index"` が自動追加されています。次に、ファイル末尾にある `root` 設定のコメントアウトを書き換え、アプリ起動時の初期画面をダッシュボードに設定します。

```ruby
Rails.application.routes.draw do
  get "home/index" # ← ジェネレーターによって追加済み
  # ... (中略) ...

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index" # ← コメントを外して書き換え
end
```

### ログイン画面の改修（英語と日本語の混在実装）
[environment/nexus_mfg (feat/chapter02-auth-i18n)]
**変更ファイル**: [`app/views/sessions/new.html.erb`](file:///Users/dev/work/environment/nexus_mfg/app/views/sessions/new.html.erb)

ジェネレーターが生成したタイトルやボタンは英語のまま残し、今回新しく追加したラベルやプレースホルダーは日本語（カタカナ）で直接書き込んでみます。あえて「チグハグ」な状態を作ることで、管理の難しさを体験します。

```erb
<%# ... (先頭のflashエラー表示部分は変更なし) ... %>

  <h1 class="font-bold text-4xl">Sign in</h1>

  <%= form_with url: session_url, class: "contents" do |form| %>
    <div class="my-5">
      <%# ===== 変更箇所: 自分で追加した部分は日本語（カタカナなど）で直接入力する ===== %>
      <%= form.label :user_code, "ユーザーコード" %>
      <%= form.text_field :user_code, required: true, autofocus: true, autocomplete: "username", placeholder: "ユーザーコードを入力してください", value: params[:user_code], class: "block shadow rounded-md border border-gray-400 outline-none px-3 py-2 mt-2 w-full" %>
    </div>
    
    <%# ... (password 部分は変更なし) ... %>

    <div class="col-span-6 sm:flex sm:items-center sm:gap-4">
      <%= form.submit "Sign in", class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white inline-block font-medium cursor-pointer" %>
      
      <%# ===== 変更箇所: 業務要件に基づきパスワードリセットリンクを削除 ===== %>
      <%# <div class="mt-4 sm:mt-0"> %>
      <%#   <%= link_to "Forgot password?", new_password_path, class: "text-blue-600 hover:text-blue-700 hover:underline" %> %>
      <%# </div> %>
    </div>
  <% end %>
</div>
```

### 動作検証（不便さの体験）
[environment/nexus_mfg (feat/chapter02-auth-i18n)]
```bash
bin/dev
```

**【ブラウザで以下を体験してください】**
1. 画面にはデカデカと **「Sign in」** と表示されている（ジェネレーターが生成した英語デフォルトの状態）。
2. デタラメな情報を入れて送信ボタンを押す。
3. 画面上部には、先ほどコードに直接書いた **「ユーザーコードまたはパスワードが正しくありません。」** という日本語のエラーが出る。
4. 正しい情報（`EMP001` / `password`）を入れてログインする。無事ログインでき、エラーメッセージも日本語になりました。しかし、画面を見ると **「Sign in（英語）」** というジェネレーター由来のデフォルト表記と、 **「ユーザーコード（日本語）」** という開発者が手動で入れた表記が混在し、プロダクトとして非常にチグハグで不完全な状態です。

この「管理上の不利益（Pain）」を解決するのが I18n です。

### ✅ 次へ進むための確認事項
- [ ] ローカル環境で「英語テキスト（Flashメッセージ）」が表示されることを実機で体験できたこと。
- [ ] 正しい情報（`EMP001` / `password`）でログインできること。

---

## <a id="section-6-i18n"></a>6. 国際化（I18n）の導入（Solution Phase）

全ての UI 文字列を一つの「辞書（`.yml`）」に集約し管理する、Railsの**I18n (Internationalization)**という機能を導入します。

### タイムゾーンとデフォルト言語の設定
**変更ファイル**: [`config/application.rb`](file:///Users/dev/work/environment/nexus_mfg/config/application.rb)
```ruby
require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module NexusMfg
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    # ===== 変更箇所: タイムゾーンとI18nの設定を追加 =====
    # config.time_zone = "Central Time (US & Canada)"
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [:ja, :en]
  end
end
```

### 辞書ファイル（ja.yml）の作成と ActiveRecord 翻訳
翻訳には主に2つのアプローチを活用します。
1. **ActiveRecord I18n**: モデル名やDBの属性名を定義。
2. **Lazy Lookup (遅延評価)**: ビューごとの固有テキストを定義。
（実務で使える完全な4層構造テンプレートは <a id="ref-9"></a>[**※9**](#appendix-9) を参照してください）

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
```bash
touch config/locales/ja.yml
```

**新規作成ファイル**: [`config/locales/ja.yml`](file:///Users/dev/work/environment/nexus_mfg/config/locales/ja.yml)
```yaml
ja:
  # 1. ActiveRecord I18n (モデル・属性の翻訳)
  activerecord:
    models:
      user: "ユーザー"
    attributes:
      user:
        user_code: "ユーザーコード"
        name: "氏名"
        password: "パスワード"

  # 全体共通の語彙
  app:
    name: "Nexus MFG"

  navigation:
    logout: "ログアウト"
    logout_confirm: "ログアウトしますか？"

  # 2. Lazy Lookup 用 (コントローラーやビューごとの翻訳)
  sessions:
    new: # app/views/sessions/new.html.erb に対応
      title: "ログイン"
      user_code_placeholder: "例: EMP001"
      password_placeholder: "パスワードを入力"
      submit: "ログイン"
    create: # app/controllers/sessions_controller.rb に対応
      alert: "ユーザーコードまたはパスワードが正しくありません。"
  
  home:
    index: # app/views/home/index.html.erb に対応
      title: "ダッシュボード"
      welcome: "ようこそ、Nexus MFG へ"
      description: "製造現場の業務管理システムです。"
```

### セッションコントローラーの I18n 完全管理化
**変更ファイル**: [`app/controllers/sessions_controller.rb`](file:///Users/dev/work/environment/nexus_mfg/app/controllers/sessions_controller.rb)
```ruby
  def create
    if user = User.authenticate_by(params.permit(:user_code, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      # ===== 変更箇所: Yaml 参照（Lazy Lookup）に移行 =====
      flash.now[:alert] = t(".alert")
      render :new, status: :unauthorized
    end
  end
```

### ログイン画面の日本語化（Lazy Lookupの実践）
**変更ファイル**: [`app/views/sessions/new.html.erb`](file:///Users/dev/work/environment/nexus_mfg/app/views/sessions/new.html.erb)
```erb
<% content_for :title, t(".title") + " | " + t("app.name") %>

<div class="mx-auto md:w-2/3 w-full">
  <h1 class="font-bold text-4xl mb-6"><%= t(".title") %></h1>

  <%= form_with url: session_url, class: "contents" do |form| %>
    <div class="my-5">
      <%= form.label :user_code %>
      <%= form.text_field :user_code,
            required: true, autofocus: true, autocomplete: "username",
            placeholder: t(".user_code_placeholder"),
            value: params[:user_code],
            class: "block shadow-sm rounded-md border border-gray-400 focus:outline-blue-600 px-3 py-2 mt-2 w-full" %>
    </div>

    <div class="my-5">
      <%= form.label :password %>
      <%= form.password_field :password,
            required: true, autocomplete: "current-password",
            placeholder: t(".password_placeholder"), maxlength: 72,
            class: "block shadow-sm rounded-md border border-gray-400 focus:outline-blue-600 px-3 py-2 mt-2 w-full" %>
    </div>

    <div class="col-span-6 sm:flex sm:items-center sm:gap-4">
      <%= form.submit t(".submit"),
            class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white inline-block font-medium cursor-pointer" %>
    </div>
  <% end %>
</div>
```

> [!TIP]
> 💡 ログインフォームにおける `autocomplete` 属性の重要な役割については、学習ノートの <a id="ref-10"></a>[**※10**](#appendix-10) で詳しく解説しています。

### ダッシュボード画面の日本語化
**変更ファイル**: [`app/views/home/index.html.erb`](file:///Users/dev/work/environment/nexus_mfg/app/views/home/index.html.erb)
```erb
<% content_for :title, t("home.index.title") + " | " + t("app.name") %>

<div class="w-full">
  <h1 class="font-bold text-4xl mb-4"><%= t("home.index.title") %></h1>
  <p class="text-gray-600"><%= t("home.index.welcome") %></p>
  <p class="text-gray-500 text-sm mt-1"><%= t("home.index.description") %></p>
</div>
```

### レイアウトの修正 (ナビゲーションバーの追加)
**変更ファイル**: [`app/views/layouts/application.html.erb`](file:///Users/dev/work/environment/nexus_mfg/app/views/layouts/application.html.erb)
```erb
<!DOCTYPE html>
<html lang="ja">
  <head>
    <title><%= content_for(:title) || "Nexus Mfg" %></title>
    <!-- ... (中略) ... -->
  </head>

  <body>
    <% if authenticated? %>
      <nav class="fixed top-0 left-0 right-0 z-10 bg-white border-b border-gray-200 px-5 py-3 flex items-center justify-between">
        <span class="font-semibold text-gray-800"><%= t("app.name") %></span>
        <div class="flex items-center gap-4">
          <%= button_to t("navigation.logout"), session_path,
                method: :delete,
                data: { turbo_confirm: t("navigation.logout_confirm") },
                class: "text-sm text-gray-600 hover:text-red-600 cursor-pointer bg-transparent border-0" %>
        </div>
      </nav>
    <% end %>

    <main class="container mx-auto mt-28 px-5 flex">
      <%= yield %>
    </main>
  </body>
</html>
```

### 再度の動作検証
再度ブラウザでリロードし、一貫した日本語インターフェースであることを確認してください。

確認ができたら、ターミナルで `Ctrl` + `C` を押し、一旦サーバーを停止させておきましょう。この後の Git 操作にサーバーの起動は不要です。

（将来、辞書ファイルが肥大化した際の分割戦略については <a id="ref-11"></a>[**※11**](#appendix-11) を参照してください）
### ✅ 次へ進むための確認事項
- [ ] 全ての画面文言が日本語で統一されており、`ja.yml` で一括管理できていること。

---

## <a id="section-7-quality"></a>7. 最終検証：全テストのパスと品質管理

これまでの作業で、目標としていた認証機能と日本語化は完成しました。しかし、プロの開発現場では「自分が作った機能が動く」だけでは不十分です。**「システム全体のテストが GREEN であること」**、そして**「コードが規約通りに美しく書かれていること」**が求められます。

### 7.1 全テストの実行と「予期せぬ失敗」の検知

まず、アプリケーションに含まれる全てのテストを実行してみましょう。

```bash
bin/rails test
```

### 7.2 【Pain Phase】エラーメッセージの解読

実行すると、先ほど作成した統合テスト（`authentication_test.rb`）以外で、大量の **Error (E)** や **Failure (F)** が発生するはずです。

**主なエラーの内容例：**
```text
ActiveModel::UnknownAttributeError: unknown attribute 'email_address' for User.
```

**なぜこれが起きるのか？**
Rails 8 の `authentication` ジェネレーターは、利便性のために標準的なテストファイルを自動生成します。しかし、それらは「メールアドレスによる認証」を前提としています。我々は ADR 001 に基づき、これを `user_code`（社員番号）へ**攻めのカスタマイズ**を行ったため、自動生成されたテストと不整合が起きているのです。

### 7.3 テストの是正（Diff-Teaching）

これらの「古くなったテスト」を、現在の仕様に合わせて修正します。

#### ① モデルテストの修正
**変更ファイル**: [`test/models/user_test.rb`](file:///Users/dev/work/environment/nexus_mfg/test/models/user_test.rb)
`email_address` の正規化テストを削除し、`user_code` の存在チェックに変更します。

```ruby
require "test_helper"

class UserTest < ActiveSupport::TestCase
  <%# ===== 変更箇所: email_address 関連のテストを削除し、user_code の検証に変更 ===== %>
  <%# test "downcases and strips email_address" do %>
  <%#   user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ") %>
  <%#   assert_equal("downcased@example.com", user.email_address) %>
  <%# end %>

  test "requires user_code" do
    user = User.new(name: "Test User", password: "password")
    assert_not user.valid?
    assert_not_empty user.errors[:user_code]
  end
end
```

#### ② セッションコントローラーテストの修正
**変更ファイル**: [`test/controllers/sessions_controller_test.rb`](file:///Users/dev/work/environment/nexus_mfg/test/controllers/sessions_controller_test.rb)
認証キーを `user_code` に変更し、失敗時のアサーションを最新の仕様（`unauthorized`）に合わせます。

```ruby
  # ... (前略)
  test "create with valid credentials" do
    <%# ===== 変更箇所: email_address -> user_code ===== %>
    <%# post session_path, params: { email_address: @user.email_address, password: "password" } %>
    post session_path, params: { user_code: @user.user_code, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    <%# ===== 変更箇所: email_address -> user_code, 期待値を unauthorized へ変更 ===== %>
    <%# post session_path, params: { email_address: @user.email_address, password: "wrong" } %>
    <%# assert_redirected_to new_session_path %>
    post session_path, params: { user_code: @user.user_code, password: "wrong" }

    assert_response :unauthorized
    assert_nil cookies[:session_id]
  end
  # ... (後略)
```

#### ③ ホームコントローラーテストの修正
**変更ファイル**: [`test/controllers/home_controller_test.rb`](file:///Users/dev/work/environment/nexus_mfg/test/controllers/home_controller_test.rb)
ログインが必要になったため、テスト内でログイン処理を追加します。

```ruby
class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    <%# ===== 変更箇所: ログイン済みの状態を作ってからアクセスする ===== %>
    sign_in_as(User.take)
    get root_url
    assert_response :success
  end
end
```

### 7.4 不要なテストファイルの削除

ADR 001 に基づき、パスワードリセット機能（`passwords_controller`）は無効化しました。したがって、それに関連する自動生成テストも不要です。

```bash
# 不要になったテストファイルを物理的に削除
rm test/controllers/passwords_controller_test.rb
rm test/mailers/passwords_mailer_test.rb
```

### 7.5 Lint（RuboCop）による磨き上げ

最後に、コードの「見た目」を規約通りに整えます。ジェネレーターが生成したコードには、稀に行末のスペースなどの軽微な規約違反が含まれることがあります。

このコマンドは、引数を指定しない場合**プロジェクト全体のファイル**をスキャンしてチェックを行います。<a id="ref-15"></a>[**※15**](#appendix-15)

```bash
# 規約違反を検出し、安全なもの（コードの動作に影響しないもの）だけを自動修正（-a）する
bundle exec rubocop -a
```

> 💡 **コマンドの使い分け：`-a` と `-A`**
> - **`-a` (小文字)**: 「安全な修正」のみを行います。インデントやスペースの調整など、コードの動作が変わらないことが保証されている項目が対象です。
> - **`-A` (大文字)**: 「全ての修正」を行います。便利ですが、稀にプログラムの挙動が変わってしまうリスクがあるため、実務では実行後のテスト確認が必須です。まずは `-a` で試し、残ったものを手動で直すのがプロの堅実なやり方です。

全てのテストを再度実行し、`0 failures, 0 errors` になることを確認してください。

### ✅ 次へ進むための確認事項
- [ ] `bin/rails test` ですべてのテストが GREEN になっていること。
- [ ] `rubocop` で規約違反が残っていないこと。

---

## <a id="section-8-finish"></a>8. 作業の完了：GitHub への送信と同期

実装が完了し、テストも GREEN になりました。最後に作業内容を保存し、プロの開発現場と同じ「ブランチを介した同期」を行います。

[environment/nexus_mfg (feat/chapter02-auth-i18n)]
```bash
# 1. 変更内容をコミット（歴史の登録）
# メッセージはプロの開発現場で一般的な「英語 + Conventional Commits」形式を採用します ※12 参照
git add .
git commit -m "feat: implement users authentication and i18n setup" <a id="ref-12"></a>[**※12**](#appendix-12)

# 2. GitHub（リモート）へ自分のブランチを送信（プッシュ）
git push origin feat/chapter02-auth-i18n
```

### 💡 GitHub 上での操作（Pull Request）
ブラウザで GitHub を開き、Pull Request を作成してマージを行います [👉 **公式：Pull Request の作成**](../resource_hub.md#tech-github)。
マージの際は、歴史を綺麗にまとめる「Squash merge」が推奨されます <a id="ref-13"></a>[**※13**](#appendix-13)。

### ローカル環境の同期
マージ完了後、手元の PC へ最新状態を反映させます <a id="ref-14"></a>[**※14**](#appendix-14)。

[environment/nexus_mfg (main)]
```bash
# 3. main ブランチへ切り替え、GitHub 上の最新の歴史を取り込む（同期）
git switch main
git pull origin main

# 4. ローカルに残った作業ブランチを削除する
git branch -d feat/chapter02-auth-i18n

# 5. ブランチ一覧で確認
git branch
```

これで第2章の全工程が完了です。

### ✅ 次へ進むための確認事項
- [ ] ローカルの `main` ブランチが最新になり、作業ブランチが削除されていること。

---

| [◀ 第1章：プロジェクトの初期設定](./01_initial_setup.md) | [⬆ 目次](../index.md#chap-2) | 第3章 ▶（未定） |
|:---:|:---:|:---:|

---

## <a id="section-9-※"></a>学習ノート

### <a id="appendix-1"></a>**[※1 git switch / restore：モダンな Git 操作への刷新](#ref-1)**
2019年以降、Git は `checkout` の役割を 2 つの専用コマンドに分け、より安全な操作を提供しています。
- **git switch**: ブランチの切り替え（移動）に特化。`-c` で作成と切り替えを同時に行います。
- **git restore**: ファイルを過去の歴史から復元（戻す）することに特化。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-git)
👈 [本編（1. 準備：作業ブランチの作成）へ戻る](#section-1-prep)

### <a id="appendix-2"></a>**[※2 bcrypt の深層：パスワードハッシュ化の核心](#ref-2)**
パスワードを不可逆的な「ハッシュ値」に変換します。ソルトやストレッチングといった防御層により、DB漏洩時の被害を最小限に抑えます。
👉 [Resource Hub](../resource_hub.md#tech-bcrypt)
👈 [本編（2. 準備：ライブラリの有効化）へ戻る](#section-2-lib)

### <a id="appendix-3"></a>**[※3 Survival Strategy: bin/dev 起動失敗の PATH 対策](#ref-3)**
もし `bundle` 等が「見つからない」エラーで失敗したら、`eval "$(rbenv init -)"` で環境をリセットしてください。
👈 [本編（2. 準備：ライブラリの有効化）へ戻る](#section-2-lib)

### <a id="appendix-4"></a>**[※4 「物理的にインストールする」の実態](#ref-4)**
`bundle install` は、プログラムを Mac 内にコピーし、その CPU で動く形式にビルド（組み立て）し、`Gemfile.lock` にその状態を厳格に記録する行為です。
👈 [本編（2. 準備：ライブラリの有効化）へ戻る](#section-2-lib)

### <a id="appendix-5"></a>**[※5 破壊と構築：エンジニアがエラーを「歓迎」する理由](#ref-5)**
TDD（テスト駆動開発）における「失敗するテスト（RED）」は、理想（要件）の表明です。エラーは失敗ではなく、「次に何をすべきか」を教えてくれる親切な案内役です。
👈 [本編（3. 破壊：テストの先行作成）へ戻る](#section-3-tdd)

### <a id="appendix-6"></a>**[※6 認証ジェネレーターと多層防御](#ref-6)**
Rails 8 のジェネレーターは、モデル、コントローラー、セキュリティ（rate_limit）、共有ロジックの 4 層構造を自動生成します。Gem（ブラックボックス）ではなくプロジェクト内のコードとして生成されるため、将来のカスタマイズが容易です。
👉 [Resource Hub](../resource_hub.md#tech-rails-auth)
👈 [本編（3. 破壊：テストの先行作成）へ戻る](#section-3-tdd)

### <a id="appendix-7"></a>**[※7 TDD (RED/GREEN/REFACTOR) の本質](#ref-7)**
仕様が要件に合っていない時、まず「失敗するテスト」を書くことでゴールを明確にします。そのエラーメッセージを道標として改修を進めるのがプロの作法です。
👉 [Resource Hub](../resource_hub.md#tech-rails)
👈 [本編（3. 破壊：テストの先行作成）へ戻る](#section-3-tdd)

### <a id="appendix-8"></a>**[※8 email_address から user_code への物理置換](#ref-8)**
標準仕様を DB スキーマレベルから業務要件に適合させることが本章の核心です。メールを持たない作業員でもシステムを使えるようにするための必須の工程です。
👈 [本編（4. 構築：認証基盤の実装）へ戻る](#section-4-auth)

### <a id="appendix-9"></a>**[※9 実践的な I18n 辞書ファイルの構造と拡張](#ref-9)**

Railsの I18n 管理では、YAML の構造理解と、2 つの呼び出しメソッド（`t` と `l`）の使い分けが重要です。

#### 1. メソッドの使い分け：`t` と `l`

| メソッド | 正称 | 役割 | 具体例 |
| :--- | :--- | :--- | :--- |
| **`t`** | **t**ranslate | **言葉**（テキスト）を翻訳する | `t("app.name")`, `t(".title")` |
| **`l`** | **l**ocalize | **データ**（日付・時刻）を国ごとの書式に整える | `l(Time.now)`, `l(date, format: :short)` |

> [!TIP]
> **迷ったら**: 「いつ・何時」を表示するなら `l`、それ以外の名前やメッセージなら `t` と覚えましょう。

#### 2. `t` メソッドの呼び出しパターン

| パターン | 書き方（View内） | 特徴 |
| :--- | :--- | :--- |
| **絶対パス** | `t("app.name")` | どの画面からでも同じ値を呼び出せる。共通語彙に使う。 |
| **相対パス** | `t(".title")` | **ドットから始める**。今表示しているビューの階層（例: `sessions.new`）をRailsが補う。画面固有の文言に使う。 |

#### 3. `l` メソッドと自作フォーマットの定義
日付の表示形式は、`ja.yml` で自作できます。

**YAML定義例 (`ja.yml`):**
```yaml
ja:
  time:
    formats:
      default: "%Y/%m/%d %H:%M:%S"
      short: "%m/%d %H:%M"
      long_jp: "%Y年%m月%d日(%a) %H時%M分" # 自作のフォーマット名
```

**呼び出し例:**
*   `l(Time.now)` → `2026/05/11 11:08:23` （デフォルト）
*   `l(Time.now, format: :short)` → `05/11 11:08`
*   `l(Time.now, format: :long_jp)` → `2026年05月11日(月) 11時08分`

#### 4. I18n 辞書ファイルの網羅的な構成サンプル

```yaml
ja:
  # --- A. フレームワーク予約層（Railsが自動参照する） ---
  activerecord:
    models:
      user: "ユーザー"
      item: "品目"
    attributes:
      user:                  # モデルごとにネストを分ける
        name: "氏名"
        user_code: "ユーザーコード"
      item:
        name: "品目名称"
        price: "標準単価"
      supplier:
        company_name: "会社名"

    # Enum（列挙型）の翻訳：モデル名 > 属性名 の順で定義
    enums:
      item:
        status:
          draft: "下書き"
          active: "稼働中"
          discontinued: "廃止"

  # --- B. システム共通層（絶対パス t("app.name") で参照） ---
  app:
    name: "Nexus MFG"
  common:
    buttons:
      save: "保存"
      edit: "編集"
      delete: "削除"
      cancel: "キャンセル"

  # --- C. 画面固有層（相対パス t(".title") で参照） ---
  # app/views/items/index.html.erb に対応
  items:
    index:
      title: "品目マスタ一覧"
      new_link: "新規品目登録"
```

👉 [Resource Hub (Rails I18n)](../resource_hub.md#tech-rails-i18n) / [標準の日本語設定 (GitHub)](https://github.com/svenfuchs/rails-i18n/blob/master/rails/locale/ja.yml)
👈 [本編（6. 国際化（I18n）の導入）へ戻る](#section-6-i18n)

### <a id="appendix-10"></a>**[※10 autocomplete 属性：ブラウザと対話するためのセマンティクス](#ref-10)**
HTML5 の世界共通規格です。ブラウザやパスワードマネージャーに対して「この入力欄がログイン ID である」といった意味を伝え、オートフィルや安全なパスワード生成を補助します。
👉 [MDN Web Docs - autocomplete](https://developer.mozilla.org/ja/docs/Web/HTML/Attributes/autocomplete)
👈 [本編（6. 国際化（I18n）の導入）へ戻る](#section-6-i18n)

### <a id="appendix-11"></a>**[※11 辞書ファイル（ja.yml）の分割戦略](#ref-11)**
開発が進みファイルが数千行になった際は、`config/locales/ja/` などのサブフォルダに分割して管理します。これにより、競合を避け、保守性を高めることができます。
👈 [本編（6. 国際化（I18n）の導入）へ戻る](#section-6-i18n)

### <a id="appendix-12"></a>**[※12 Conventional Commits：プロの履歴管理術](#ref-12)**
`feat:` や `fix:` といった型を用いる規約です。ログの可視性が高まり、後から「なぜこの変更をしたか」を追いやすくなります。
👉 [Resource Hub](../resource_hub.md#tech-conventional-commits)
👈 [本編（7. 作業の完了とマージ）へ戻る](#section-7-finish)

### <a id="appendix-13"></a>**[※13 Squash Merge：歴史を綺麗にする押しつぶしマージ](#ref-13)**
複数の細かいコミットを、マージ時に一つの綺麗なコミットにまとめ上げる手法です。`main` ブランチの歴史が機能単位で整理され、視認性が向上します。
👈 [本編（7. 作業の完了とマージ）へ戻る](#section-7-finish)

### <a id="appendix-14"></a>**[※14 ブランチの「使い捨て」と同期の鉄則](#ref-14)**
マージが終わった作業ブランチはすぐに削除し、常に最新の `main` から新しいブランチを生やすのが、歴史を汚さずエラーを避けるプロの作法です。
👈 [本編（7. 作業の完了とマージ）へ戻る](#section-7-finish)

### <a id="appendix-15"></a>**[※15 RuboCop：コードの品質と一貫性の守護者](#ref-15)**

#### 1. 「リント」と「リンター」の定義
*   **リント (Lint)**: ソースコードを解析して、バグの原因になりそうな箇所や、読みにくい書き方を自動で検知する**工程や行為**のことです。語源は「毛玉取り」で、プログラムの「些細なノイズ」を取り除くという意味が込められています。
*   **リンター (Linter)**: リントを実行する**ツールそのもの**のことです。今回のケースでは、**RuboCop** がリンターに当たります。

#### 2. RuboCop の役割
RuboCop は **Ruby 言語専用**のリンターです。世界中の Ruby エンジニアが合意した「Ruby スタイルガイド」を基準にコードをチェックします。
*   **Cop（コップ）**: RuboCop が備えている一つ一つの「ルール」のことです。警察官（Cop）のようにコードを監視していることから、こう呼ばれます。
*   **オートコレクト**: 本章で使用したように、検知した違反を自動で修正してくれる強力な機能です。
*   **拡張性（Rails への対応）**: 基本は Ruby 用ですが、**プラグイン（追加の Gem）**を導入することで Rails 特有のルールもチェックできます。本プロジェクトでは `Gemfile` に Rails 8 公式推奨の **`rubocop-rails-omakase`** という Gem を導入しており、Rails のベストプラクティスに基づいたチェックも同時に行われています。

#### 3. 他の言語との比較
プロの開発現場では、どの言語を使っても必ず「リンター（リント工程）」が存在します。
*   **JavaScript / TypeScript**: ESLint
*   **Python**: Flake8, Ruff
*   **CSS**: Stylelint

#### 4. なぜ導入が必要なのか？
「動けばいい」だけのコードは、時間が経つとチームメンバーや将来の自分でも読み解けない「負債」になります。リンターを導入することで、**「誰が書いても、NexusMfg の規約に沿った美しいコード」**を保ち、バグの混入を未然に防ぐことができます。

👉 [Resource Hub (RuboCop)](../resource_hub.md#tech-rubocop)
👈 [本編（7. 最終検証：全テストのパスと品質管理）へ戻る](#section-7-quality)

---

| [◀ 第1章：プロジェクトの初期設定](./01_initial_setup.md) | [⬆ 目次](../index.md#chap-2) | 第3章 ▶（未定） |
|:---:|:---:|:---:|
