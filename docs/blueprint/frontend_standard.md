# NexusMfg フロントエンド開発標準 (Tailwind CSS v4)

本システムでは、Rails 8 と Tailwind CSS v4 を組み合わせた最新のフロントエンド構成を採用しています。開発者が一貫した手法でUIを構築するための鉄則をここにまとめます。

---

## 1. 開発のサイクル：`bin/dev` の使用

Rails 8 において Tailwind CSS の変更をリアルタイムに反映させるには、CSSを監視・ビルドするプロセスを同時に動かす必要があります。

- **推奨コマンド**:
```bash
bin/dev
```

> [!IMPORTANT]
> `rails s` だけでは Tailwind のビルドプロセスが起動しません。スタイルの変更が画面に反映されない場合は、必ず `bin/dev` でサーバーを起動しているか確認してください。

---

## 2. 物理構成：Source (設計図) と Build (成果物) の分離

Tailwind v4 の環境では、2 つの似たような CSS ファイルが存在します。**編集すべきファイルを間違えると、書いたコードが自動生成プロセスによって消滅します。**

### ✍️ 開発者が編集するファイル (Source)
- **パス**: `app/assets/tailwind/application.css`
- **内容**: `@import "tailwindcss";` や、独自のカスタムCSS、`@apply` を用いた共通パーツ定義などをここに記述します。

### 🚫 触ってはいけないファイル (Build)
- **パス**: `app/assets/builds/tailwind.css`
- **理由**: このファイルは Rails のビルドプロセスによって自動生成される「成果物」です。直接書き換えても、**ファイルを保存した瞬間に上書きされ、修正はすべて消えます。**

---

## 3. アセットの読み込み（魔法の1行）

Rails 8 のレイアウトファイル（`application.html.erb`）では、以下の 1 行だけで Tailwind を含むすべてのスタイルシートが自動的に読み込まれます。

```erb
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
```

- **仕組み**: `Propshaft`（アセット管理エンジン）が、`app/assets/builds/` 内のファイルを自動的に検出し、適切に配信します。

---

## 4. トラブルシューティング（アセットの確認）

「書いたスタイルが当たらない」などの不具合が起きた際は、Rails が正しくファイルを認識しているか（台帳に載っているか）を確認します。

### 監督（Propshaft）の認識確認
```bash
bin/rails runner 'puts Rails.application.assets.load_path.assets.map(&:logical_path).inspect'
```
結果に `tailwind.css` が含まれていれば、配信の準備は整っています。

### 巡回ルートの確認
```bash
bin/rails runner 'puts Rails.application.assets.load_path.paths.map(&:to_s).inspect'
```
監督がどこを探しているかを表示します。通常は `app/assets/builds` が含まれている必要があります。
