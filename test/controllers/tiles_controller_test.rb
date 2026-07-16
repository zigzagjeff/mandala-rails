require "test_helper"

class TilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @mandala = mandalas(:one)
    @tile = tiles(:one)
    sign_in_as(@user)
  end

  # --- rename ---

  test "rename renders an in-place title form inside the tile frame" do
    get rename_mandala_tile_path(@mandala, @tile)
    assert_response :success
    assert_select "turbo-frame#tile_#{@tile.id}" do
      assert_select "form[action=?]", mandala_tile_path(@mandala, @tile)
      assert_select "input[name='tile[title]'][maxlength=?]", Tile::TITLE_MAX_LENGTH.to_s
    end
  end

  # --- update ---

  test "update of a root-grid tile redirects to the mandala" do
    patch mandala_tile_path(@mandala, @tile), params: { tile: { title: "Updated" } }
    assert_redirected_to mandala_path(@mandala)
  end

  test "update of a sub-grid tile redirects to its grid" do
    child_grid = @tile.drill
    sub_tile = child_grid.tiles.find_by(position: 0)
    patch mandala_tile_path(@mandala, sub_tile), params: { tile: { title: "Updated" } }
    assert_redirected_to mandala_grid_path(@mandala, child_grid)
  end

  test "update saves changes" do
    patch mandala_tile_path(@mandala, @tile), params: { tile: { title: "Changed Title" } }
    assert_equal "Changed Title", @tile.reload.title
  end

  # Regression for CHANGELOG 0.2.0: the drill arrow was dropped from the frame
  # a rename replaces. The arrow lives in the shared tile partial, so the frame
  # Turbo extracts from the update's redirect must still carry it.
  test "the drill arrow survives a rename" do
    assert @tile.drillable?
    patch mandala_tile_path(@mandala, @tile), params: { tile: { title: "Renamed" } }
    follow_redirect!
    assert_select "turbo-frame#tile_#{@tile.id} .tile-drill"
  end

  test "update cannot modify another user's tile" do
    other_mandala = mandalas(:two)
    other_tile = tiles(:two)
    patch mandala_tile_path(other_mandala, other_tile),
          params: { tile: { title: "Hijacked" } }
    assert_response :not_found
    assert_equal tiles(:two).title, other_tile.reload.title
  end
end
