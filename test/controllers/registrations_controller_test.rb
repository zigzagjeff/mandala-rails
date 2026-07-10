require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "new form names its fields the way create permits them" do
    get new_registration_path

    assert_select "form[action=?]", registrations_path do
      assert_select "input[name=?]", "email_address"
      assert_select "input[name=?]", "password"
      assert_select "input[name=?]", "password_confirmation"
    end
  end

  test "create with valid params starts a session and redirects" do
    assert_difference "User.count", 1 do
      post registrations_path, params: { email_address: "new-signup@example.com", password: "a-secure-passphrase", password_confirmation: "a-secure-passphrase" }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with a taken email re-renders with an error" do
    assert_no_difference "User.count" do
      post registrations_path, params: { email_address: @user.email_address, password: "a-secure-passphrase", password_confirmation: "a-secure-passphrase" }
    end

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
    assert_select "div", /Email address has already been taken/
  end

  test "create with a password below the minimum length re-renders with an error" do
    assert_no_difference "User.count" do
      post registrations_path, params: { email_address: "new-signup@example.com", password: "short", password_confirmation: "short" }
    end

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
    assert_select "div", /Password is too short/
  end

  test "create with mismatched password confirmation re-renders with an error" do
    assert_no_difference "User.count" do
      post registrations_path, params: { email_address: "new-signup@example.com", password: "a-secure-passphrase", password_confirmation: "a-different-passphrase" }
    end

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
    assert_select "div", /Password confirmation doesn't match/
  end

  test "create rate limits repeated attempts" do
    11.times do |i|
      post registrations_path, params: { email_address: "signup-#{i}@example.com", password: "a-secure-passphrase", password_confirmation: "a-secure-passphrase" }
    end

    assert_redirected_to new_registration_path
    follow_redirect!
    assert_select "div", /Try again later/
  end
end
