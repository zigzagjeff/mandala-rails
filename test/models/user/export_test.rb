require "test_helper"

class User::ExportTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "the document carries the account and only this user's mandalas" do
    document = JSON.parse(User::Export.new(@user).export_json)

    assert_equal @user.email_address, document.dig("account", "email_address")
    titles = document["mandalas"].map { |mandala| mandala["title"] }
    assert_equal [ mandalas(:one).title ], titles
  end

  test "tile bodies are exported as HTML" do
    tiles(:one).update!(body: "<strong>Ship it</strong>")

    document = JSON.parse(User::Export.new(@user).export_json)
    body = document.dig("mandalas", 0, "grid", "tiles", 0, "body")

    assert_includes body, "Ship it"
    assert_includes body, "<strong>"
  end

  test "mandala events ride along in the export" do
    mandalas(:one).events.create!(action: "mandala_created", creator: @user, eventable: mandalas(:one))

    document = JSON.parse(User::Export.new(@user).export_json)

    actions = document.dig("mandalas", 0, "events").map { |event| event["action"] }
    assert_equal [ "mandala_created" ], actions
  end
end
