class CreateCharts < ActiveRecord::Migration[8.1]
  def change
    create_table :charts do |t|
      t.string :title
      t.string :mode
      t.uuid :user_id

      t.timestamps
    end
  end
end
