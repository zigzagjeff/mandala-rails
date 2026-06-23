class CreateGrids < ActiveRecord::Migration[8.1]
  def change
    create_table :grids do |t|
      t.references :chart, null: false, foreign_key: true
      t.string :parent_tile_id

      t.timestamps
    end
  end
end
