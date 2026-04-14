# 第1章：プロジェクトの初期設定とバージョン管理

この章では、NexusMfg プロジェクトの基盤となるアプリケーションの生成と、安全な開発を継続するためのバージョン管理（Git）の設定を行います。

## 学習のゴール
- Rails 8 の新しいアプリケーションを正しく生成できる
- `Gemfile` の環境依存によるトラブルを自力で解消できる
- Git を使って「歴史の保存（コミット）」と「GitHub へのアップロード」ができる
- アプリケーションを自力で起動・視認・安全に停止できる

---

## 1. ワークスペース（作業ディレクトリ）の準備

まずは、アプリケーションのソースコード群を格納するための土台となるディレクトリを作成し、そこへ作業場所を移します。実務ではターミナル上で「自分が今どのパス（場所）にいるか（＝カレントディレクトリ）」を常に意識することが重要です。

- **コマンド**:
```bash
mkdir environment
cd environment
```

### コマンドの解説
- `mkdir environment`: `environment` という名前の新しいディレクトリ（フォルダ）を作成します。<a id="ref-1"></a>[※1](#appendix-1)
- `cd environment`: 作成したディレクトリの中に、ターミナルの作業場所を移動させます。<a id="ref-2"></a>[※2](#appendix-2)

### ✅ 次へ進むための確認事項
- [ ] ターミナルでエラーが出ず、カレントディレクトリが `environment` になっていること。

---

## 2. アプリケーションの生成

### ステップ1：ソースコードの展開
Rails 8 のオプションを指定してアプリの雛形を生成します。

- **コマンド**:
```bash
rails new nexus_mfg --css tailwind --javascript importmap
```

### コマンドの解説
- `nexus_mfg`: カレントディレクトリ直下にこの名前のディレクトリが作成され、その中にRailsのソースコード群が一式展開されます。
- `--css tailwind`: モダンなデザインを素早く実現する Tailwind CSS を導入します。<a id="ref-3"></a>[※3](#appendix-3)
- `--javascript importmap`: ビルド不要で JavaScript を動かせる Importmap を設定します。<a id="ref-4"></a>[※4](#appendix-4)

> 💡 **現場の知恵**：もし既にフォルダを作成済みの場所で展開したい場合は <a id="ref-5"></a>[※5](#appendix-5) を参照。

### ✅ 次へ進むための確認事項
- [ ] `environment` ディレクトリ内に `nexus_mfg` フォルダができていること。

### ステップ2：環境依存バグ（Gemfileの地雷）の撤去
特定の環境（主に Windows 混在環境）でエラーを招く `Gemfile` の記述を修正します。

- **対象ファイル**: `nexus_mfg/Gemfile` (28行目付近)
```diff
- gem "tzinfo-data", platforms: %i[ windows jruby ]
+ gem "tzinfo-data", platforms: %i[ mingw x64_mingw mswin mswin64 jruby ]
```
> 📚 **根拠と詳細**: なぜこの修正が必要なのか、シンボルの意味などは <a id="ref-a1"></a>[※A-1](#appendix-a1) で詳細に解体説明しています。

- **環境の反映**:
```bash
cd nexus_mfg
bundle install
```

### コマンドの解説
- `bundle install`: `Gemfile` の内容を読み込み、必要なライブラリを調達・固定します。<a id="ref-b1"></a>[※B-1](#appendix-b1)

### ✅ 次へ進むための確認事項
- [ ] `bundle install` が `Bundle complete!` と表示されて終了すること。

---

## 3. リモートリポジトリ（GitHub）への接続

### ステップ1：.gitignore によるリポジトリの清浄化
リポジトリに含めるべきではない「秘密情報」や「ゴミファイル」を除外します。

- **対象ファイル**: `.gitignore` (末尾に追記)
```text
/.antigravity
.DS_Store
/.vscode/
```
> **負の説明**: 設定しない場合のセキュリティリスクについては <a id="ref-a2"></a>[※A-2](#appendix-a2) を参照。

### ステップ2：初回コミット
現在の状態を「最初の歴史」として Git に刻みます。

- **コマンド**:
```bash
git init
git add .
git commit -m "Initialize project"
```

### コマンドの解説
- `git init`: この場所で Git による履歴管理を開始します。<a id="ref-0"></a>[※0](#appendix-0)
- `git add .`: すべての変更を「仮置き場」に登録します。<a id="ref-6"></a>[※6](#appendix-6)
- `git commit -m "..."`: 仮置き場の内容を「歴史」として確定させます。<a id="ref-7"></a>[※7](#appendix-7)

> 💡 **脱出策**：間違えて `add` した時やファイルを消しすぎた時は <a id="ref-8"></a>[※8](#appendix-8) を参照。

### ステップ3：リモートへのアップロード
GitHub 上の保管庫と紐付け、手元の歴史を送信します。

- **コマンド**:
```bash
git remote add origin https://github.com/<account>/nexus_mfg.git
git push -u origin main
```

### コマンドの解説
- `git remote add origin`: GitHub の場所を `origin`（源流）という名前で登録します。<a id="ref-9"></a>[※9](#appendix-9)
- `git push -u origin main`: `main` ブランチの歴史を初めて GitHub へ送信します。`-u` は、次回から `git push` だけで済むようにするための設定です。<a id="ref-10"></a>[※10](#appendix-10)

---

## 4. アプリケーションの稼働確認

- **コマンド**:
```bash
./bin/dev
```

### コマンドの解説
- `./bin/dev`: Rails サーバーと CSS ビルダーを同時に起動します。
- **視認**: ブラウザで [http://localhost:3000](http://localhost:3000) を開き "It's Rails!" を確認。
- **停止**: `Ctrl` + `C` を同時に押すとサーバーが止まります。

> ⚠️ **警告：もしサーバーを止め忘れたら？**
> 次回の起動時に「Address already in use（場所が使われています）」と怒られます。その際の「ゾンビプロセス討伐」の手順は <a id="ref-12"></a>[※12](#appendix-12) を参照してください。

> 💡 **もし `./bin/dev` 自体が失敗したら？**
> 「Foreman が見つからない」等の PATH 関連エラーが出た場合の対策は <a id="ref-11"></a>[※11](#appendix-11) を参照してください。

### ✅ 次へ進むための確認事項
- [ ] ブラウザで [http://localhost:3000](http://localhost:3000) にアクセスし、"It's Rails!" と表示されること。
- [ ] `Ctrl` + `C` でサーバーが正常に停止すること。

---

◀ 前の章（なし） | [⬆ 目次](../index.md#chap-1) | 次の章 ▶（準備中）

---

## 🎯 Appendix: 最高解像度の用語・概念解説

<a id="appendix-0"></a>
### **[[※0 git init（履歴管理の開始）](#ref-0)]**
`git init` は "Initialize"（初期化）の略で、現在のディレクトリを Git リポジトリとして初期化するコマンドです。
- **何が起こるか？**: カレントディレクトリに `.git` という隠しフォルダ（ドットで始まるため通常は表示されない）が作成されます。この `.git` フォルダの中に、これ以降のすべての変更履歴・ブランチ情報・設定が格納されます。
- **解体**: `init` は "Initialize"（初期化する）の略です。「この場所をバージョン管理の対象にします」という宣言です。
- **もしやらなかったら？**: `git add` や `git commit` などの Git コマンドが一切使えず、`fatal: not a git repository` というエラーになります。つまり、歴史を記録する「台帳」そのものが存在しない状態です。
- **注意**: `git init` は一つのプロジェクトにつき一度だけ実行します。すでに `.git` フォルダが存在する場所で再実行しても壊れることはありませんが、通常は不要です。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-git)

<a id="appendix-1"></a>
### **[[※1 mkdir（ディレクトリ作成）](#ref-1)]**
`mkdir` は "Make Directory"。
`-p` オプションは、親ディレクトリが存在しない場合に自動的に作成するオプションです。`mkdir -p a/b/c` と打つと、`a`、`a/b`、`a/b/c` の3つのディレクトリが順番に作成されます。
- **豆知識**: コンピュータの世界では「フォルダ」のことを「ディレクトリ」と呼びます。
- **もし間違えたら？**: `rmdir 名前` で空のディレクトリを消せます。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-terminal-fs)

<a id="appendix-2"></a>
### **[[※2 cd（ディレクトリ移動）](#ref-2)]**
`cd` は "Change Directory"。
- **豆知識**: `cd ..` と打つと「一つ上の階層」へ、`cd -` と打つと「直前にいた場所」へ戻れます。
- **重要概念**: 常に自分がどこにいるか（カレントディレクトリ）を意識するのがプロへの第一歩です。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-terminal-fs)

<a id="appendix-3"></a>
### **[[※3 Tailwind CSS の選択理由](#ref-3)]**
- **なぜ使うの？**: HTMLの中に短いクラス名（例: `bg-blue-500`）を書くだけでモダンな画面が作れるため、CSSファイルと往復し、直接記述する手間が省けます。
- **別の選択肢**: `Bootstrap`（昔からある有名な枠組み）などを指定できます（例: `--css bootstrap`）。
- **もしつけなかったら？**: Railsは特定のデザインセットを用意してくれません。完全に"まっさらなCSS"を1から自力で書くことになります。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-tailwind)

<a id="appendix-4"></a>
### **[[※4 Importmap の選択理由](#ref-4)]**
- **なぜ使うの？**: ブラウザ上で JavaScript をそのまま動かす仕組みです。
- **もし使わなかったら？**: `Node.js` や `Webpacker` といった非常に重くて複雑な設定が必要になり、初心者が「ソースコードを書く前」に挫折する大きな原因になります。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-importmap)

<a id="appendix-5"></a>
### **[[※5 rails new .（カレントディレクトリへの展開）](#ref-5)]**
- **なぜこれを使う？**: すでに `mkdir` でフォルダを作ってしまった場合、`rails new .` と打つことで「今いる場所」にファイルを展開できます。
- **注意点**: 既存ファイルがある場合は `-f` (force) オプションを付けて強制上書きする必要があります。
- **警告**: 実務では混乱を避けるため、親ディレクトリで `rails new アプリ名` を実行するのが「正道」です。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-rails)

<a id="appendix-a1"></a>
### **[[※A-1 Gemfile プラットフォーム名の解体と Mac での解決理由](#ref-a1)]**
- **`platforms: %i[...]`**:
    - **`platforms:`**: Ruby の「ハッシュ（連想配列）」という仕組みで、`Gem` に対して「特定の条件下（プラットフォーム）でのみ有効にせよ」という命令を渡しています。
    - **`%i[...]`**: Ruby 特有の書き方で、「文字」ではなく「シンボル（内部的な識別子）」の配列を、カンマなしで効率よく作る記法です。
- **プラットフォームの種類**:
    - **`mingw` / `x64_mingw` / `mswin` / `mswin64`**: これらはすべて Windows の内部環境を指します。
    - **`jruby`**: Java の上で動く Ruby 環境を指します。
- **真相**: Mac は OS 自体に最新の時差データを持つため、本来 `tzinfo-data` は不要です。しかし、旧来の Rails の記述（`:windows`）だと、Mac 用の Bundler が自分も対象かどうかを判断できず、不整合を起こしてパースエラーを吐くことがあります。具体的に Windows 用の環境名を一文字残らず書き下ろすことで、「これは Mac 用ではない」ことを Bundler に 100% 正確に認識させ、エラーを回避しています。
👉 [一次ソース：Bundler: Gemfile Platforms](https://bundler.io/v2.5/man/gemfile.5.html#PLATFORMS) / [Resource Hub](../resource_hub.md#tech-bundler)

<a id="appendix-a2"></a>
### **[[※A-2 .gitignore を設定しない場合の具体的恐怖](#ref-a2)]**
1. **秘密の漏洩**: パスワードが含まれる設定ファイルを GitHub に上げると悪用され、クラウドの利用料金が数百万に及ぶなどの実害が出る恐怖があります。
2. **容量の圧迫**: 不要なライブラリを含めると、リポジトリが肥大化し操作が遅くなります。
3. **環境汚染**: `.DS_Store` 等が混ざると、チームメンバーの環境で予期せぬエラーを招きます。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-git)

<a id="appendix-6"></a>
### **[[※6 git add .（ステージング / 仮置き場）](#ref-6)]**
Git にとっての「シャッターを切る前の準備」です。
- **例え話**: 集合写真で「誰をアルバムに載せるか」を決めて、ひな壇に並べる行為に似ています。まだ歴史には残りません。
- **対象の絞り込み**: 特定のファイルだけを選びたい場合は `git add ファイル名` を使い、`git status` で状態を確認する癖をつけましょう。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-git)

<a id="appendix-7"></a>
### **[[※7 git commit -m と「良いコミットメッセージ」](#ref-7)]**
歴史のラベル（アルバムへの貼り付け）です。
- **なぜ -m ？**: "Message" の略です。`git commit -m "Initialize project"` のように「なぜこれをしたか」を記述します。
- **もし -m を忘れたら？**: ターミナル上で強制的に Vim などのテキストエディタが起動し、初心者は「画面の戻り方がわからない！」とパニックになりがちです。最初は必ず `-m` を使いましょう。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-git)

<a id="appendix-8"></a>
### **[[※8 git checkout -f / git restore（歴史による救済）](#ref-8)]**
「手元でミスをして戻せなくなった」時の救済措置です。最後にコミットした「健全な歴史」の状態まで、すべてのファイルを強制的に巻き戻すことができます。一種の「タイムマシン」のような機能です。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-git)

<a id="appendix-9"></a>
### **[[※9 git remote add origin（遠い場所へのあだ名）](#ref-9)]**
GitHub などの外部サーバーを「リモート」と呼び、最初に同期する場所を慣習的に `origin`（源流）と名付けます。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-github)

<a id="appendix-10"></a>
### **[[※10 git push -u（上流工程の固定）](#ref-10)]**
- **なぜ -u ？**: "Set Upstream" の略です。初回に一度設定すれば、次からは `git push` だけ打てば GitHub へ送信されるようになります。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-git)

<a id="appendix-11"></a>
### **[[※11 Survival Strategy: bin/dev 起動失敗の PATH 対策](#ref-11)]**
もし `./bin/dev` が「Foreman が見つからない」等のエラーで失敗したら、ターミナルが最新の Ruby の場所を見失っています。
```bash
eval "$(rbenv init -)"
```
この呪文で環境をリセット（再読み込み）して再試行してください。
- **解体**: `eval` はシェルに「この文字列をコマンドとして実行せよ」と命じる組み込み関数です。`$(rbenv init -)` は rbenv の初期化スクリプトを出力するサブコマンドで、`-` はシェルの種類を自動判別するフラグです。
- **もしやらなかったら？**: ターミナルが古い Ruby（またはシステム Ruby）を参照し続け、`foreman` 等の Gem が見つからないエラーが永遠に解消されません。

<a id="appendix-12"></a>
### **[[※12 Survival Strategy: ゾンビプロセスの討伐（lsof / kill / ps）](#ref-12)]**
サーバーを起動しようとして `Address already in use` というエラーが出たら、前回のサーバーが「幽霊（ゾンビ）」としてメモリに居座っています。

#### 方法1：ポート番号から犯人を特定する（lsof）
最も確実で簡単な方法です。3000番ポートを握りしめている犯人を探します。
- **コマンド**: `lsof -i :3000`
- **表示例**:
  ```text
  COMMAND   PID  USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
  ruby     3964   dev   12u  IPv6  0x...      0t0  TCP  *:3000
  ```
  `PID` 列に表示されている番号（この例では `3964`）が討伐対象の ID です。

#### 方法2：プロセス名から犯人を特定する（ps aux）
`lsof` が使えない環境や、より詳細な起動状況を確認したい場合に使います。

##### 💡 初学者向け：シンプルな検索と「自分自身」の判別
- **コマンド**: `ps aux | grep rails`
- **表示例と解読**:
  ```text
  USER        PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
  dev        3964   0.0  0.0  4100...    496  s005  R+    9:47AM   0:00.00 /Users/dev/.../bin/rails server
  dev        4012   0.0  0.0  4100...    400  s005  S+    9:48AM   0:00.00 grep rails
  ```
  1. `USER`: 実行しているユーザー名（あなた）
  2. **`PID`**: **【重要】目的のプロセスID。** 2番目の数字です。
  3. `COMMAND`: 実際に動いているプログラム名。

> ⚠️ **自分自身の grep に騙されないで！**
> サーバーを起動させていなくても、検索結果には必ず1行 `/usr/bin/grep rails` と書かれた行が表示されます。これは「検索しているあなた自身の動作」が表示されているだけなので、無視して構いません。
> トドメを刺すべき相手は、右側に `bin/rails server` や `bin/dev` と書かれている行であることを、右端をよく見て判断してください。

##### 🛠️ 効率化：複数の一括検索とノイズの自動排除
複数のキーワードで一気に探し出し、かつ自分自身のプロセス（grep自身）を表示させないプロの書き方です。
- **コマンド**: `ps aux | grep -E "bin/dev|foreman|rails" | grep -v grep`
- **コマンドの解体**:
  1. `grep -E "A|B|C"`: 「A または B または C」のいずれかに一致する行をすべて探します。
  2. `| grep -v grep`: `-v` は「一致しない行だけを表示せよ」という命令です。これにより、検索結果から「grep自身」を自動的に除外し、討伐対象のプロセスだけを抽出できます。

#### 討伐の実行（kill）
特定した `PID` を用いて、トドメを刺します。
- **コマンド**: `kill -9 <PID番号>`
- **フラグの意味**: `-9` は「問答無用で今すぐ終了せよ」という最強の強制終了フラグです。

- **もし放置したら？**: 古いサーバーがポートを独り占めし続けるため、永遠に新しい画面を確認できなくなります。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-process-mgmt)

<a id="appendix-b1"></a>
### **[[※B-1 bundle install（ライブラリの調達と固定）](#ref-b1)]**
`bundle`（Bundler）は、Ruby 用のライブラリ（Gem）を管理する専任マネージャーです。
`Gemfile` に書かれた希望リストを読み取り、インターネットから必要な Gem を取ってきて、プロジェクト専用の「道具箱」を整理します。この際、`Gemfile.lock` というファイルが生成され、パソコンの環境（Mac/Windows）によらずチーム全員が全く同じバージョンの Gem を使えるよう、環境ががっちりと固定（ロック）されます。
👉 [公式リファレンス (Resource Hub) ](../resource_hub.md#tech-bundler)
