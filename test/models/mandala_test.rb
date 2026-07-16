require "test_helper"

class MandalaTest < ActiveSupport::TestCase
  # --- validations ---

  test "requires title" do
    mandala = users(:one).mandalas.build
    assert_not mandala.valid?
    assert mandala.errors[:title].any?
  end

  # --- root_grid ---

  test "root_grid returns the grid with no parent_tile_id" do
    assert_equal grids(:one), mandalas(:one).root_grid
  end

  # --- center_tile ---

  test "center_tile returns the root grid's center tile" do
    center = grids(:one).tiles.create!(position: 4, title: "Run a marathon")
    assert_equal center, mandalas(:one).center_tile
  end

  test "center_tile is nil when the center tile does not exist" do
    assert_nil mandalas(:one).center_tile
  end

  # --- root center seeding ---

  test "seeds the root center tile from the title on create" do
    mandala = users(:one).mandalas.create!(title: "Run a marathon")
    assert_equal "Run a marathon", mandala.center_tile.title
  end
end
