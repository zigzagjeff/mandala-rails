require "test_helper"

class AccountClosuresControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(@user = users(:one)) }

  test "new renders the confirmation form" do
    get new_account_closure_path

    assert_response :success
    assert_select "form[action=?]", account_closure_path do
      assert_select "input[name=?]", "password"
    end
  end

  test "create with the correct password schedules deletion and mails the user" do
    post account_closure_path, params: { password: "password" }

    assert @user.reload.closed?
    assert_enqueued_with job: Users::IncinerationJob
    assert_enqueued_with job: Closures::ScheduledJob
    assert_redirected_to account_path
  end

  test "create with a wrong password leaves the account open" do
    post account_closure_path, params: { password: "wrong" }

    assert_not @user.reload.closed?
    assert_redirected_to new_account_closure_path
    follow_redirect!
    assert_select "div", /Incorrect password/
  end

  test "destroy cancels a scheduled deletion" do
    @user.close

    delete account_closure_path

    assert_not @user.reload.closed?
    assert_redirected_to account_path
  end

  test "create requires authentication" do
    sign_out

    post account_closure_path, params: { password: "password" }

    assert_redirected_to new_session_path
    assert_not @user.reload.closed?
  end
end
