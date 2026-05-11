require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  # ---------------------------------------------------------------------------
  # 🎓 教育的注釈: このテストは RED フェーズの証明として作成された。
  # ADR 001 および課題要件に基づき、Email ではなく user_code による認証を要求する。
  # 
  # なぜこのテストが必要か (Why Logic):
  # 1. 業務システムにおいて「誰が操作しているか」の識別は信頼性の根幹である。
  # 2. 社員番号(user_code) ログインは現場要件であり、Rails 標準の Email 前提を破壊して再定義する必要がある。
  # 
  # もしこのテストがなければ (Negative Logic):
  # 開発者が Rails 標準のジェネレーターをそのまま使い、現場で使えない「Email ログイン」を
  # 実装してしまうリスクを早期に検知できない。
  # ---------------------------------------------------------------------------

  setup do
    @user = users(:one)
  end

  test "ユーザーコードによるログイン成功" do
    # 期待値: 正しい user_code とパスワードでログインでき、ルートにリダイレクトされること
    post session_url, params: { user_code: @user.user_code, password: "password" }
    assert_redirected_to root_url
    # セッションにユーザーIDが保存されていることを暗黙的に期待（または認証ヘルパーで確認）
  end

  test "不正な user_code / パスワードによるログイン失敗" do
    # 期待値: 間違ったパスコードではログインできず、未認可(unauthorized)または再表示されること
    post session_url, params: { user_code: @user.user_code, password: "wrong_password" }
    assert_response :unauthorized

    post session_url, params: { user_code: "INVALID_CODE", password: "password" }
    assert_response :unauthorized
  end

  test "認証が必要な画面への非ログインアクセス制限" do
    # 期待値: ログインしていない状態で保護されたリソース（例: root）にアクセスするとログイン画面へ飛ばされること
    get root_url
    assert_redirected_to new_session_url
  end
end
