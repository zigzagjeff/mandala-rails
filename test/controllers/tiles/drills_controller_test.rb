require "test_helper"

class Tiles::DrillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @chart = charts(:one)
    @tile = tiles(:one)
    sign_in_as(@user)
  end

  test "drill creates a child grid on first call" do
    assert_nil @tile.child_grid
    post chart_tile_drill_path(@chart, @tile)
    assert_redirected_to chart_grid_path(@chart, @tile.reload.child_grid)
  end

  test "drill navigates to existing child grid on second call" do
    existing = @tile.drill
    post chart_tile_drill_path(@chart, @tile)
    assert_redirected_to chart_grid_path(@chart, existing)
    assert_equal 1, @chart.grids.where(parent_tile: @tile).count
  end

  test "drill on the center tile redirects back to the chart" do
    center = @tile.grid.tiles.create!(position: 4)
    post chart_tile_drill_path(@chart, center)
    assert_redirected_to chart_path(@chart)
  end

  test "drill cannot touch another user's tile" do
    post chart_tile_drill_path(charts(:two), tiles(:two))
    assert_response :not_found
  end
end
