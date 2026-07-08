require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @chart = charts(:one)
    @user = users(:one)
  end

  test "chronologically orders oldest first, id breaking ties" do
    latest = record_event_at 1.minute.ago
    earliest = record_event_at 1.hour.ago

    assert_equal [ earliest, latest ], @chart.events.chronologically.to_a
  end

  test "since returns only events strictly after the cursor" do
    cursor = 30.minutes.ago
    record_event_at 1.hour.ago
    at_cursor = record_event_at cursor
    after_cursor = record_event_at 1.minute.ago

    assert_equal [ after_cursor ], @chart.events.since(cursor).to_a
    assert_not_includes @chart.events.since(cursor), at_cursor
  end

  test "since without a cursor returns everything" do
    event = record_event_at 1.hour.ago

    assert_includes @chart.events.since(nil), event
  end

  test "suppressing_recording restores recording even when the block raises" do
    assert Event.recording

    assert_raises(RuntimeError) do
      Event.suppressing_recording do
        assert_not Event.recording
        raise "boom"
      end
    end

    assert Event.recording
  end

  private

  def record_event_at(time)
    travel_to time do
      @chart.events.create!(creator: @user, eventable: @chart, action: "chart_created")
    end
  end
end
