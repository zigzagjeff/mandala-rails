require "test_helper"

class Chart::EventableTest < ActiveSupport::TestCase
  setup do
    Current.user = users(:one)
  end

  test "creating a chart records chart_created" do
    chart = Current.user.charts.create!(title: "Fresh Start", mode: "planning")

    event = chart.events.last
    assert_equal "chart_created", event.action
    assert_equal chart, event.eventable
    assert_equal Current.user, event.creator
  end

  test "retitling a chart records the old and new titles" do
    chart = charts(:one)
    chart.update!(title: "Sharper Focus")

    event = chart.events.chronologically.last
    assert_equal "chart_title_changed", event.action
    assert_equal "My Planning Mandala", event.particulars["old_title"]
    assert_equal "Sharper Focus", event.particulars["new_title"]
  end

  test "switching mode records the old and new modes" do
    chart = charts(:one)
    chart.update!(mode: "brainstorm")

    event = chart.events.chronologically.last
    assert_equal "chart_mode_changed", event.action
    assert_equal "planning", event.particulars["old_mode"]
    assert_equal "brainstorm", event.particulars["new_mode"]
  end

  test "saving without changes records nothing" do
    assert_no_difference "Event.count" do
      charts(:one).update!(title: charts(:one).title)
    end
  end

  test "nothing is recorded without a Current user" do
    Current.user = nil

    assert_no_difference "Event.count" do
      users(:one).charts.create!(title: "Console Chart", mode: "planning")
    end
  end
end
