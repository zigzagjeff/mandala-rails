class CreateTiles < ActiveRecord::Migration[8.1]
  def change
    create_table :tiles do |t|
      t.references :grid, null: false, foreign_key: true
      t.integer :position
      t.string :tile_type
      t.text :content
      t.jsonb :metadata

      t.timestamps
    end
  end
end
