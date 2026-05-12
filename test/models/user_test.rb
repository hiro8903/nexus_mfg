require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires user_code" do
    user = User.new(name: "Test User", password: "password")
    assert_not user.valid?
    assert_not_empty user.errors[:user_code]
  end
end
