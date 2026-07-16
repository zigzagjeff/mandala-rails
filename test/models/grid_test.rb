require "test_helper"

class GridTest < ActiveSupport::TestCase
  test "root? is true when parent_tile_id is nil" do
    assert grids(:one).root?
  end

  test "root? is false when parent_tile_id is set" do
    mandala = mandalas(:one)
    parent_tile = tiles(:one)
    child_grid = mandala.grids.create!(parent_tile: parent_tile)
    assert_not child_grid.root?
  end

  test "belongs to mandala" do
    assert_equal mandalas(:one), grids(:one).mandala
  end

  test "center_tile returns the tile at the center position" do
    center = grids(:one).tiles.create!(position: 4, title: "My Goal")
    assert_equal center, grids(:one).center_tile
  end
end
