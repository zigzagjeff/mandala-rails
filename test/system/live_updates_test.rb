require "application_system_test_case"

class LiveUpdatesTest < ApplicationSystemTestCase
  # broadcast_refresh_later_to defers through Active Job (ruling R4); run it
  # inline so a broadcast raised in one session lands in the other during the
  # test. Scoped here so the rest of the suite keeps the :test adapter.
  setup do
    @queue_adapter, ActiveJob::Base.queue_adapter = ActiveJob::Base.queue_adapter, :inline
    sign_in_as users(:one)
  end

  teardown { ActiveJob::Base.queue_adapter = @queue_adapter }

  # #68: an edit in one session must surface live in another viewing the same
  # chart, through turbo_stream_from's cable subscription and the Event
  # broadcast. Two sessions, same account (charts are user-scoped).
  test "a tile rename surfaces live in another session on the same chart" do
    visit chart_path(charts(:one))
    wait_for_cable_connection

    using_session("second viewer") do
      sign_in_as users(:one)
      visit chart_path(charts(:one))
      wait_for_cable_connection
      assert_text "BFP Community"
    end

    rename_tile tiles(:one), to: "Renamed Live"
    assert_text "Renamed Live"

    using_session("second viewer") do
      assert_text "Renamed Live"
    end
  end
end
