require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mandala = mandalas(:one)
    @tile = tiles(:one)
  end

  test "index requires authentication" do
    get api_v1_mandala_events_path(@mandala)
    assert_response :unauthorized
  end

  test "index lists the mandala's events chronologically" do
    rename_tile_to "First pass"
    rename_tile_to "Second pass"

    get api_v1_mandala_events_path(@mandala), headers: authorized_headers

    assert_response :success
    events = response.parsed_body
    assert_equal [ "tile_title_changed", "tile_title_changed" ], events.map { |event| event["action"] }
    assert_equal "First pass", events.first["particulars"]["new_title"]
    assert_equal "Second pass", events.second["particulars"]["new_title"]
    assert_equal "Tile", events.first["eventable_type"]
    assert_equal @tile.id, events.first["eventable_id"]
  end

  test "since returns only events after the cursor" do
    travel_to 1.hour.ago do
      rename_tile_to "Stale"
    end
    rename_tile_to "Fresh"

    get api_v1_mandala_events_path(@mandala, since: 30.minutes.ago.iso8601), headers: authorized_headers

    events = response.parsed_body
    assert_equal 1, events.size
    assert_equal "Fresh", events.first["particulars"]["new_title"]
  end

  test "a malformed since is a bad request" do
    get api_v1_mandala_events_path(@mandala, since: "yesterdayish"), headers: authorized_headers

    assert_response :bad_request
    assert response.parsed_body["errors"].any?
  end

  test "another user's mandala is not found" do
    get api_v1_mandala_events_path(mandalas(:two)), headers: authorized_headers

    assert_response :not_found
  end

  private

  def rename_tile_to(title)
    patch api_v1_tile_path(@tile), params: { tile: { title: title } },
          headers: authorized_headers, as: :json
    assert_response :success
  end
end
