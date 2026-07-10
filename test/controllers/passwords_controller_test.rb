require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_password_path
    assert_response :success
  end

  # create no longer looks the user up in-request (it would leak which emails
  # exist); it always enqueues the job, which does the lookup. These two tests
  # assert the request does identical work either way and only a real user gets
  # mail (C5.15 — the old mailer-enqueue-on-hit assertions no longer hold).
  test "create enqueues the reset and delivers it to a known user" do
    assert_enqueued_with job: Passwords::ResetJob, args: [ @user.email_address ] do
      post passwords_path, params: { email_address: @user.email_address }
    end
    assert_redirected_to new_session_path

    assert_emails 1 do
      perform_enqueued_jobs
    end

    follow_redirect!
    assert_notice "reset instructions sent"
  end

  test "create enqueues the same job for an unknown user but delivers no mail" do
    assert_enqueued_with job: Passwords::ResetJob, args: [ "missing-user@example.com" ] do
      post passwords_path, params: { email_address: "missing-user@example.com" }
    end
    assert_redirected_to new_session_path

    assert_no_emails do
      perform_enqueued_jobs
    end

    follow_redirect!
    assert_notice "reset instructions sent"
  end

  test "create rate limits repeated resets for one account even across IPs" do
    6.times do |i|
      post passwords_path,
        params: { email_address: @user.email_address },
        headers: { "REMOTE_ADDR" => "10.0.0.#{i}" }
    end

    assert_redirected_to new_password_path
    follow_redirect!
    assert_notice "Try again later"
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice "reset link is invalid"
  end

  test "update" do
    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "a-secure-passphrase", password_confirmation: "a-secure-passphrase" }
      assert_redirected_to new_session_path
    end

    follow_redirect!
    assert_notice "Password has been reset"
  end

  test "update with a password below the minimum length" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "short", password_confirmation: "short" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "Password is too short"
  end

  test "update with non matching passwords" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "a-secure-passphrase", password_confirmation: "a-different-passphrase" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_notice "Password confirmation"
  end

  private
    def assert_notice(text)
      assert_select "div", /#{text}/
    end
end
