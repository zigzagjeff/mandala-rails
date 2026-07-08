require "test_helper"

class Api::V1::GridsControllerTest < ActionDispatch::IntegrationTest
  test "show embeds the grid's tiles without bodies" do
    grid = tiles(:one).drill

    get api_v1_grid_path(grid), headers: authorized_headers

    assert_response :success
    assert_equal 1, response.parsed_body["depth"]
    assert_equal tiles(:one).id, response.parsed_body["parent_tile_id"]

    tiles = response.parsed_body["tiles"]
    assert_equal 9, tiles.size
    assert_equal tiles(:one).title, tiles.find { |t| t["position"] == 4 }["title"]
    assert tiles.all? { |t| t.key?("agentic_summary") && t.key?("heading_level") }
    assert tiles.none? { |t| t.key?("body") }
  end

  test "show cannot reach another user's grid" do
    get api_v1_grid_path(grids(:two)), headers: authorized_headers
    assert_response :not_found
  end
end
