require "test_helper"

class GridTest < ActiveSupport::TestCase
  test "root? is true when parent_tile_id is nil" do
    assert grids(:one).root?
  end

  test "root? is false when parent_tile_id is set" do
    chart = charts(:one)
    parent_tile = tiles(:one)
    child_grid = chart.grids.create!(parent_tile: parent_tile)
    assert_not child_grid.root?
  end

  test "belongs to chart" do
    assert_equal charts(:one), grids(:one).chart
  end

  test "center_tile returns the tile at the center position" do
    center = grids(:one).tiles.create!(position: 4, title: "My Goal")
    assert_equal center, grids(:one).center_tile
  end
end
