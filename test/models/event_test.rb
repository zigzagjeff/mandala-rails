require "test_helper"
require "turbo/broadcastable/test_helper"

class EventTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  setup do
    @mandala = mandalas(:one)
    @user = users(:one)
  end

  test "chronologically orders oldest first, id breaking ties" do
    latest = record_event_at 1.minute.ago
    earliest = record_event_at 1.hour.ago

    assert_equal [ earliest, latest ], @mandala.events.chronologically.to_a
  end

  test "since returns only events strictly after the cursor" do
    cursor = 30.minutes.ago
    record_event_at 1.hour.ago
    at_cursor = record_event_at cursor
    after_cursor = record_event_at 1.minute.ago

    assert_equal [ after_cursor ], @mandala.events.since(cursor).to_a
    assert_not_includes @mandala.events.since(cursor), at_cursor
  end

  test "since without a cursor returns everything" do
    event = record_event_at 1.hour.ago

    assert_includes @mandala.events.since(nil), event
  end

  test "recording an event broadcasts a refresh to the mandala" do
    Current.user = @user

    perform_enqueued_jobs do
      assert_turbo_stream_broadcasts @mandala, count: 1 do
        tiles(:one).update!(title: "Live update")
      end
    end
  end

  test "suppressed recording broadcasts nothing" do
    Current.user = @user

    perform_enqueued_jobs do
      assert_no_turbo_stream_broadcasts @mandala do
        Event.suppressing_recording { tiles(:one).update!(title: "Quiet update") }
      end
    end
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
      @mandala.events.create!(creator: @user, eventable: @mandala, action: "mandala_created")
    end
  end
end
