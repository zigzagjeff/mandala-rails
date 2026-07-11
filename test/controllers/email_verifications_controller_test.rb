require "test_helper"

class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:unverified) }

  test "show renders the confirmation page without verifying" do
    get email_verification_path(@user.email_verification_token)

    assert_response :success
    assert_not @user.reload.verified?
  end

  test "show with an invalid token redirects with an alert" do
    sign_in_as @user

    get email_verification_path("not-a-real-token")

    assert_redirected_to root_path
    follow_redirect!
    assert_select "div", /invalid or has expired/
  end

  test "update verifies the account and confirms it" do
    sign_in_as @user

    patch email_verification_path(@user.email_verification_token)

    assert @user.reload.verified?
    assert_redirected_to root_path
    follow_redirect!
    assert_select "div", /has been verified/
  end

  test "update with an invalid token verifies nothing and says so" do
    sign_in_as @user

    patch email_verification_path("not-a-real-token")

    assert_not @user.reload.verified?
    assert_redirected_to root_path
    follow_redirect!
    assert_select "div", /invalid or has expired/
  end

  test "update works when clicked while signed out" do
    patch email_verification_path(@user.email_verification_token)

    assert @user.reload.verified?
    assert_redirected_to root_path
  end

  test "create resends the verification email to the current user" do
    sign_in_as @user

    assert_enqueued_with job: Verifications::VerifyJob, args: [ @user ] do
      post email_verifications_path
    end
    assert_redirected_to root_path

    assert_emails 1 do
      perform_enqueued_jobs
    end
  end

  test "create requires authentication" do
    post email_verifications_path

    assert_redirected_to new_session_path
  end
end
