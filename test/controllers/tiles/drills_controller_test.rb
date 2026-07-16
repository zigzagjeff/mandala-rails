require "test_helper"

class Tiles::DrillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mandala = mandalas(:one)
    @tile = tiles(:one)
    sign_in_as(@user)
  end

  test "drill creates a child grid on first call" do
    assert_nil @tile.child_grid
    post mandala_tile_drill_path(@mandala, @tile)
    assert_redirected_to mandala_grid_path(@mandala, @tile.reload.child_grid)
  end

  test "drill navigates to existing child grid on second call" do
    existing = @tile.drill
    post mandala_tile_drill_path(@mandala, @tile)
    assert_redirected_to mandala_grid_path(@mandala, existing)
    assert_equal 1, @mandala.grids.where(parent_tile: @tile).count
  end

  test "drill on the center tile redirects back to the mandala" do
    center = @tile.grid.tiles.create!(position: 4)
    post mandala_tile_drill_path(@mandala, center)
    assert_redirected_to mandala_path(@mandala)
  end

  test "drill cannot touch another user's tile" do
    post mandala_tile_drill_path(mandalas(:two), tiles(:two))
    assert_response :not_found
  end
end
