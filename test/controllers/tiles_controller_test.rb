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

  test "drill on the center tile redirects back to the chart" do
    center = @tile.grid.tiles.create!(position: 4)
    get drill_chart_tile_path(@chart, center)
    assert_redirected_to chart_path(@chart)
  end

  # --- rename ---

  test "rename renders an in-place title form inside the tile frame" do
    get rename_chart_tile_path(@chart, @tile)
    assert_response :success
    assert_select "turbo-frame#tile_#{@tile.id}" do
      assert_select "form[action=?]", chart_tile_path(@chart, @tile)
      assert_select "input[name='tile[title]'][maxlength=?]", Tile::TITLE_MAX_LENGTH.to_s
    end
  end

  # --- update ---

  test "update of a root-grid tile redirects to the chart" do
    patch chart_tile_path(@chart, @tile), params: { tile: { title: "Updated" } }
    assert_redirected_to chart_path(@chart)
  end

  test "update of a sub-grid tile redirects to its grid" do
    child_grid = @tile.find_or_create_child_grid!
    sub_tile = child_grid.tiles.find_by(position: 0)
    patch chart_tile_path(@chart, sub_tile), params: { tile: { title: "Updated" } }
    assert_redirected_to chart_grid_path(@chart, child_grid)
  end

  test "update saves changes" do
    patch chart_tile_path(@chart, @tile), params: { tile: { title: "Changed Title" } }
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
