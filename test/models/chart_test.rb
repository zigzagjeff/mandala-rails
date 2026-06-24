require "test_helper"

class ChartTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email_address: "test_chart_#{SecureRandom.hex(4)}@example.com", password: "password")
  end

  test "allows creating up to 9 charts" do
    8.times { |i| @user.charts.create!(title: "Chart #{i}", mode: "planning") }
    chart = @user.charts.build(title: "Chart 9", mode: "planning")
    assert chart.valid?, "Expected 9th chart to be valid"
  end

  test "rejects a 10th chart" do
    9.times { |i| @user.charts.create!(title: "Chart #{i}", mode: "planning") }
    chart = @user.charts.build(title: "Over the limit", mode: "planning")
    assert_not chart.valid?
    assert_includes chart.errors[:base].first, "9-chart limit"
  end

  test "LIMIT constant is 9" do
    assert_equal 9, Chart::LIMIT
  end
end
