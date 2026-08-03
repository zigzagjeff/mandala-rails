require "test_helper"

class TileTest < ActiveSupport::TestCase
  setup do
    @mandala = mandalas(:one)
    @grid = grids(:one)
  end

  # --- validations ---

  test "position must be 0–8" do
    tile = @grid.tiles.build(position: 9)
    assert_not tile.valid?
    assert tile.errors[:position].any?
  end

  test "position must be unique per grid" do
    existing = @grid.tiles.first
    tile = @grid.tiles.build(position: existing.position)
    assert_not tile.valid?
    assert tile.errors[:position].any?
  end

  test "title length cannot exceed TITLE_MAX_LENGTH" do
    tile = @grid.tiles.build(position: 0, title: "a" * (Tile::TITLE_MAX_LENGTH + 1))
    assert_not tile.valid?
    assert tile.errors[:title].any?
  end

  test "subtitle length cannot exceed SUBTITLE_MAX_LENGTH" do
    tile = @grid.tiles.build(position: 0, subtitle: "a" * (Tile::SUBTITLE_MAX_LENGTH + 1))
    assert_not tile.valid?
    assert tile.errors[:subtitle].any?
  end

  test "title at exact max length is valid" do
    tile = @grid.tiles.build(position: 0, title: "a" * Tile::TITLE_MAX_LENGTH)
    assert tile.valid?
  end

  # --- title_placeholder ---

  test "title_placeholder names the center on the root center tile" do
    center = @grid.tiles.create!(position: 4)
    assert_equal "Name the center", center.title_placeholder
  end

  test "title_placeholder invites a tile on root surrounding tiles" do
    assert_equal "Add a tile", tiles(:one).title_placeholder
  end

  test "title_placeholder invites a tile on sub-grid surrounding tiles" do
    child = tiles(:one).drill
    assert_equal "Add a tile", child.tiles.find_by(position: 0).title_placeholder
  end

  # --- has_children? ---

  test "has_children? is false with no child grid" do
    assert_not tiles(:one).has_children?
  end

  test "has_children? is true after child grid is created" do
    tile = tiles(:one)
    tile.drill
    assert tile.reload.has_children?
  end

  # --- drillable? ---

  test "drillable? is true for a titled root surrounding tile" do
    assert tiles(:one).drillable?
  end

  test "drillable? is false until the tile is named" do
    blank = @grid.tiles.create!(position: 0)
    assert_not blank.drillable?

    blank.update!(title: "Now it has a name")
    assert blank.drillable?
  end

  test "drillable? is false for the root center tile" do
    center = @grid.tiles.create!(position: 4, title: "My Planning Mandala")
    assert_not center.drillable?
  end

  test "drillable? is false in a sub-grid even when titled" do
    sub_tile = tiles(:one).drill.tiles.find_by(position: 0)
    sub_tile.update!(title: "Deep enough")
    assert_not sub_tile.drillable?
  end

  # --- drill ---

  test "drill creates a child grid with 9 tiles" do
    tile = tiles(:one)
    child = tile.drill
    assert_not_nil child
    assert_equal 9, child.tiles.count
  end

  test "drill seeds center tile title from parent" do
    tile = tiles(:one)
    child = tile.drill
    center = child.tiles.find_by(position: 4)
    assert_equal tile.title, center.title
  end

  test "drill is idempotent" do
    tile = tiles(:one)
    first = tile.drill
    # Reload to clear the cached nil association, mirroring real usage (fresh request)
    second = Tile.find(tile.id).drill
    assert_equal first.id, second.id
  end

  test "drill does not duplicate when a child grid appears after its nil check" do
    tile = tiles(:one)
    assert_nil tile.child_grid
    Grid.create!(mandala: tile.mandala, parent_tile_id: tile.id)

    tile.drill

    assert_equal 1, Grid.where(parent_tile_id: tile.id).count
  end

  test "the database refuses a second child grid for the same tile" do
    tile = tiles(:one)
    Grid.create!(mandala: tile.mandala, parent_tile_id: tile.id)

    assert_raises ActiveRecord::RecordNotUnique do
      Grid.create!(mandala: tile.mandala, parent_tile_id: tile.id)
    end
  end

  # --- depth ---

  test "drill sets child depth one below the parent grid" do
    child = tiles(:one).drill
    assert_equal 1, child.depth

    grandchild = child.tiles.find_by(position: 0).drill
    assert_equal 2, grandchild.depth
  end

  # --- heading_level ---

  test "heading_level is 1 for the root center tile" do
    center = @grid.tiles.create!(position: 4)
    assert_equal 1, center.heading_level
  end

  test "heading_level is 2 for root surrounding tiles" do
    assert_equal 2, tiles(:one).heading_level
  end

  test "heading_level is 2 for a child grid center tile" do
    child = tiles(:one).drill
    assert_equal 2, child.tiles.find_by(position: 4).heading_level
  end

  test "heading_level is 3 for child grid surrounding tiles" do
    child = tiles(:one).drill
    assert_equal 3, child.tiles.find_by(position: 0).heading_level
  end
end
