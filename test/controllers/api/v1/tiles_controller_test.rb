require "test_helper"

class Api::V1::TilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tile = tiles(:one)
  end

  test "show returns the full tile with body as plain text" do
    @tile.update!(body: "<p>Deep thoughts</p>")

    get api_v1_tile_path(@tile), headers: authorized_headers

    assert_response :success
    assert_equal @tile.title, response.parsed_body["title"]
    assert_equal "Deep thoughts", response.parsed_body["body"]
  end

  test "update writes title and agentic_summary" do
    patch api_v1_tile_path(@tile),
          params: { tile: { title: "Renamed by agent", agentic_summary: "<community_growth>BFP community building</community_growth>" } },
          headers: authorized_headers, as: :json

    assert_response :success
    @tile.reload
    assert_equal "Renamed by agent", @tile.title
    assert_equal "<community_growth>BFP community building</community_growth>", @tile.agentic_summary
  end

  # body stays writable by design: AGENTS.md's contract is that agents write it
  # only when the user directs them to draft — the capability is deliberate,
  # not an oversight in the permit (#90).
  test "update writes body when the user directs a draft" do
    assert_difference "Event.count", 1 do
      patch api_v1_tile_path(@tile),
            params: { tile: { body: "<p>Drafted on the user's behalf</p>" } },
            headers: authorized_headers, as: :json
    end

    assert_response :success
    assert_equal "Drafted on the user's behalf", @tile.reload.body.to_plain_text
    assert_equal "tile_body_changed", @tile.events.last.action
  end

  test "update with an overlong title returns errors" do
    patch api_v1_tile_path(@tile),
          params: { tile: { title: "a" * (Tile::TITLE_MAX_LENGTH + 1) } },
          headers: authorized_headers, as: :json

    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].any?
  end

  test "drill creates the child grid and returns it" do
    assert_difference "Grid.count", 1 do
      post drill_api_v1_tile_path(@tile), headers: authorized_headers
    end
    assert_response :success
    assert_equal @tile.id, response.parsed_body["parent_tile_id"]
    assert_equal 9, response.parsed_body["tiles"].size
  end

  test "drill is idempotent" do
    existing = @tile.drill
    assert_no_difference "Grid.count" do
      post drill_api_v1_tile_path(@tile), headers: authorized_headers
    end
    assert_equal existing.id, response.parsed_body["id"]
  end

  test "drill on an undrillable tile is rejected" do
    task_tile = @tile.drill.tiles.first
    post drill_api_v1_tile_path(task_tile), headers: authorized_headers
    assert_response :unprocessable_entity
  end

  test "drill on a blank tile is rejected" do
    blank = @tile.grid.tiles.create!(position: 0)

    assert_no_difference "Grid.count" do
      post drill_api_v1_tile_path(blank), headers: authorized_headers
    end

    assert_response :unprocessable_entity
  end

  test "tiles of another user are not reachable" do
    get api_v1_tile_path(tiles(:two)), headers: authorized_headers
    assert_response :not_found
  end
end
