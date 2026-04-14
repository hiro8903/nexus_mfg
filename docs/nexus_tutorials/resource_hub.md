# NexusMfg: 公式リソースハブ (Official Resource Hub)

本プロジェクトで使用されている技術やサービスの、公式ドキュメント（一次ソース）を集約したポータルページです。実装やトラブルシューティングの際は、まずこれらの「正解」を参照してください。

## 1. バージョン管理・インフラ

<a id="tech-git"></a>
- [**Git 公式ドキュメント**](https://git-scm.com/doc)
    - Git の基本的な使い方、コマンドのリファレンス（add, commit, push, branch等）。

<a id="tech-github"></a>
- [**GitHub Docs**](https://docs.github.com/en)
    - リモートリポジトリの管理（remote add）、Pull Request、GitHub Actions 等の詳細。

<a id="tech-bundler"></a>
- [**Bundler: Gemfile Platforms**](https://bundler.io/v2.5/man/gemfile.5.html#PLATFORMS)
    - `Gemfile` におけるプラットフォーム指定（`mingw`, `x64_mingw`, `jruby` 等）の厳密な定義と、`:windows` シンボルへの集約に関する公式リファレンス。

## 2. フレームワーク・言語 (Next Steps)

<a id="tech-rails"></a>
- [**Ruby on Rails Guides**](https://guides.rubyonrails.org/)
    - Rails 8 の新機能を含む、網羅的なガイド。

<a id="tech-tailwind"></a>
- [**Tailwind CSS Documentation**](https://tailwindcss.com/docs)
    - スタイルシステム、ユーティリティクラス（bg-blue-500 など）のリファレンス。

<a id="tech-importmap"></a>
- [**importmap-rails 公式リポジトリ (GitHub)**](https://github.com/rails/importmap-rails)
    - Node.js やビルドツール不要でモダンなJavaScriptを管理する Rails 8 標準機能の詳細。

## 3. OS 基本コマンド（ターミナル操作）

<a id="tech-terminal-fs"></a>
- [**mkdir(1) - Linux man page**](https://man7.org/linux/man-pages/man1/mkdir.1.html)
    - ディレクトリ作成コマンド `mkdir` の公式リファレンス。`-p` オプション等の詳細。
- [**cd(1p) - POSIX man page**](https://man7.org/linux/man-pages/man1/cd.1p.html)
    - シェル組み込みコマンド `cd`（Change Directory）の POSIX 仕様に基づく公式リファレンス。

<a id="tech-process-mgmt"></a>
- [**ps(1) - Linux man page**](https://man7.org/linux/man-pages/man1/ps.1.html)
    - 実行中プロセスの一覧表示コマンド `ps` の公式リファレンス。`aux` オプション等の詳細。
- [**kill(1) - Linux man page**](https://man7.org/linux/man-pages/man1/kill.1.html)
    - プロセスへのシグナル送信コマンド `kill` の公式リファレンス。`-9`（SIGKILL）等の詳細。
- [**lsof(8) - Linux man page**](https://man7.org/linux/man-pages/man8/lsof.8.html)
    - オープン中のファイル・ポートを一覧するコマンド `lsof` の公式リファレンス。`-i` オプション等の詳細。

---
**エージェント行動規範に基づき、新しい技術が導入されるたびに本ハブを更新し、品質を維持します（追加前にURLの有効性を検証済み）。**

