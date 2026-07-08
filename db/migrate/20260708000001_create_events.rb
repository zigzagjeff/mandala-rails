class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :chart, null: false, foreign_key: true, index: false
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :eventable, polymorphic: true, null: false
      t.string :action, null: false
      t.json :particulars, null: false, default: {}
      t.timestamps

      t.index [ :chart_id, :created_at ]
    end
  end
end
