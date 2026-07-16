require "test_helper"

class DataExportsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(@user = users(:one)) }

  test "show returns the user's data as a JSON download" do
    get data_export_path

    assert_response :success
    assert_equal "application/json", response.media_type
    assert_match "attachment", response.headers["Content-Disposition"]

    document = JSON.parse(response.body)
    assert_equal @user.email_address, document.dig("account", "email_address")
    assert_equal @user.mandalas.count, document["mandalas"].length
  end

  test "show scopes the export to the current user" do
    get data_export_path

    titles = JSON.parse(response.body)["mandalas"].map { |mandala| mandala["title"] }
    assert_includes titles, mandalas(:one).title
    assert_not_includes titles, mandalas(:two).title
  end

  test "show requires authentication" do
    sign_out

    get data_export_path

    assert_redirected_to new_session_path
  end
end
