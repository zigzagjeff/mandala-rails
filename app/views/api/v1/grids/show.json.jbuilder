json.extract! @grid, :id, :mandala_id, :parent_tile_id, :depth
json.tiles @grid.tiles.positioned, partial: "api/v1/tiles/tile", as: :tile
