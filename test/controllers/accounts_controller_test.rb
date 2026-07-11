require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(@user = users(:one)) }

  test "show renders the settings page" do
    get account_path

    assert_response :success
    assert_select "h1", "Account settings"
  end

  test "show requires authentication" do
    sign_out

    get account_path

    assert_redirected_to new_session_path
  end
end
