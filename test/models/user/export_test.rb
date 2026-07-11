require "test_helper"

class User::ExportTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "the document carries the account and only this user's charts" do
    document = JSON.parse(User::Export.new(@user).export_json)

    assert_equal @user.email_address, document.dig("account", "email_address")
    titles = document["charts"].map { |chart| chart["title"] }
    assert_equal [ charts(:one).title ], titles
  end

  test "tile bodies are exported as HTML" do
    tiles(:one).update!(body: "<strong>Ship it</strong>")

    document = JSON.parse(User::Export.new(@user).export_json)
    body = document.dig("charts", 0, "grid", "tiles", 0, "body")

    assert_includes body, "Ship it"
    assert_includes body, "<strong>"
  end

  test "chart events ride along in the export" do
    charts(:one).events.create!(action: "chart_created", creator: @user, eventable: charts(:one))

    document = JSON.parse(User::Export.new(@user).export_json)

    actions = document.dig("charts", 0, "events").map { |event| event["action"] }
    assert_equal [ "chart_created" ], actions
  end
end
