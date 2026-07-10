class AddUniqueIndexToGridsParentTileId < ActiveRecord::Migration[8.1]
  def change
    add_index :grids, :parent_tile_id, unique: true, where: "parent_tile_id IS NOT NULL"
  end
end
