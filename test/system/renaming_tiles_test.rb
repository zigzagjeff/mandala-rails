require "application_system_test_case"

class RenamingTilesTest < ApplicationSystemTestCase
  setup { sign_in_as users(:one) }

  # Regression for CHANGELOG 0.2.0: the drill arrow was dropped from the frame
  # the rename replaces. The arrow lives in the shared tile partial, so a rename
  # that re-renders the frame must bring it back with the tile (C8.6/C8.7).
  test "a drillable tile keeps its drill arrow after renaming" do
    tile = tiles(:one)
    visit chart_path(charts(:one))

    assert_selector "#tile_#{tile.id} .tile-drill"

    rename_tile tile, to: "Renamed Community"

    assert_selector "#tile_#{tile.id}", text: "Renamed Community"
    assert_selector "#tile_#{tile.id} .tile-drill"
  end
end
