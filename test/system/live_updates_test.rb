require "application_system_test_case"

class LiveUpdatesTest < ApplicationSystemTestCase
  # broadcast_refresh_later_to defers through Active Job (ruling R4); run it
  # inline so the broadcast reaches the browser during the test. Scoped here
  # so the rest of the suite keeps the :test adapter.
  setup do
    @queue_adapter, ActiveJob::Base.queue_adapter = ActiveJob::Base.queue_adapter, :inline
    sign_in_as users(:one)
  end

  teardown { ActiveJob::Base.queue_adapter = @queue_adapter }

  # #68: a write from outside this browser — an agent over the API, or another
  # session — surfaces live through turbo_stream_from's cable subscription and
  # the Event broadcast, with no reload here. This is the headline of #68 and
  # the reason the missing cable client (#124) went unnoticed.
  test "an out-of-band tile change surfaces live on the mandala" do
    visit mandala_path(mandalas(:one))
    wait_for_cable_connection
    assert_text "BFP Community"

    Current.user = users(:one)
    tiles(:one).update!(title: "Renamed Live")

    assert_text "Renamed Live"
  end
end
