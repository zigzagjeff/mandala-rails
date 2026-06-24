require "test_helper"

class TilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @chart = charts(:one)
    @tile = tiles(:one)
    sign_in_as(@user)
  end

  # --- drill ---

  test "drill creates a child grid on first call" do
    assert_nil @tile.child_grid
    get drill_chart_tile_path(@chart, @tile)
    assert_redirected_to chart_grid_path(@chart, @tile.reload.child_grid)
  end

  test "drill navigates to existing child grid on second call" do
    existing = @tile.find_or_create_child_grid!
    get drill_chart_tile_path(@chart, @tile)
    assert_redirected_to chart_grid_path(@chart, existing)
    assert_equal 1, @chart.grids.where(parent_tile: @tile).count
  end

  # --- update ---

  test "update responds with turbo stream" do
    patch chart_tile_path(@chart, @tile),
          params: { tile: { title: "Updated" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "update saves changes" do
    patch chart_tile_path(@chart, @tile),
          params: { tile: { title: "Changed Title" } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_equal "Changed Title", @tile.reload.title
  end

  test "update cannot modify another user's tile" do
    other_chart = charts(:two)
    other_tile = tiles(:two)
    patch chart_tile_path(other_chart, other_tile),
          params: { tile: { title: "Hijacked" } }
    assert_response :not_found
    assert_equal tiles(:two).title, other_tile.reload.title
  end
end
