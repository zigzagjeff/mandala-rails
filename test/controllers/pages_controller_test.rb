require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "privacy policy is reachable without signing in" do
    get privacy_path
    assert_response :success
    assert_in_body "Privacy Policy"
  end

  test "terms of service is reachable without signing in" do
    get terms_path
    assert_response :success
    assert_in_body "Terms of Service"
  end

  test "legal notice is reachable without signing in" do
    get legal_path
    assert_response :success
    assert_in_body "Legal Notice"
  end
end
