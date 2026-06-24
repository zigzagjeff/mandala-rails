require "test_helper"

class TileTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @chart = charts(:one)
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

  # --- display_title ---

  test "display_title returns title when present" do
    assert_equal "BFP Community", tiles(:one).display_title
  end

  test "display_title returns '+' when title is blank" do
    tile = @grid.tiles.build(position: 0, title: nil)
    assert_equal "+", tile.display_title
  end

  # --- has_children? ---

  test "has_children? is false with no child grid" do
    assert_not tiles(:one).has_children?
  end

  test "has_children? is true after child grid is created" do
    tile = tiles(:one)
    tile.find_or_create_child_grid!
    assert tile.reload.has_children?
  end

  # --- find_or_create_child_grid! ---

  test "find_or_create_child_grid! creates a child grid with 9 tiles" do
    tile = tiles(:one)
    child = tile.find_or_create_child_grid!
    assert_not_nil child
    assert_equal 9, child.tiles.count
  end

  test "find_or_create_child_grid! seeds center tile title from parent" do
    tile = tiles(:one)
    child = tile.find_or_create_child_grid!
    center = child.tiles.find_by(position: 4)
    assert_equal tile.title, center.title
  end

  test "find_or_create_child_grid! is idempotent" do
    tile = tiles(:one)
    first = tile.find_or_create_child_grid!
    # Reload to clear the cached nil association, mirroring real usage (fresh request)
    second = Tile.find(tile.id).find_or_create_child_grid!
    assert_equal first.id, second.id
  end

  # --- tile_type ---

  test "tile_type is :goal for root grid center tile (position 4)" do
    center = @grid.tiles.create!(position: 4)
    assert_equal :goal, center.tile_type
  end

  test "tile_type is :theme for root grid non-center tile" do
    assert_equal :theme, tiles(:one).tile_type
  end

  test "tile_type is :task for tile in a sub-grid" do
    parent_tile = tiles(:one)
    child_grid = parent_tile.find_or_create_child_grid!
    task_tile = child_grid.tiles.find_by(position: 0)
    assert_equal :task, task_tile.tile_type
  end
end
