class RemoveTileTypeFromTiles < ActiveRecord::Migration[8.1]
  def change
    remove_column :tiles, :tile_type, :string
  end
end
