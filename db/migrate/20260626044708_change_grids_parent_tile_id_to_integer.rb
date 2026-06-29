class ChangeGridsParentTileIdToInteger < ActiveRecord::Migration[8.1]
  def up
    change_column :grids, :parent_tile_id, :bigint
  end

  def down
    change_column :grids, :parent_tile_id, :string
  end
end
