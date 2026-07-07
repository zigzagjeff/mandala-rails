class AddDepthToGrids < ActiveRecord::Migration[8.1]
  def up
    add_column :grids, :depth, :integer, null: false, default: 0

    execute <<~SQL
      WITH RECURSIVE grid_depths(id, depth) AS (
        SELECT id, 0 FROM grids WHERE parent_tile_id IS NULL
        UNION ALL
        SELECT grids.id, grid_depths.depth + 1
        FROM grids
        JOIN tiles ON tiles.id = grids.parent_tile_id
        JOIN grid_depths ON grid_depths.id = tiles.grid_id
      )
      UPDATE grids SET depth = (SELECT depth FROM grid_depths WHERE grid_depths.id = grids.id)
    SQL
  end

  def down
    remove_column :grids, :depth
  end
end
