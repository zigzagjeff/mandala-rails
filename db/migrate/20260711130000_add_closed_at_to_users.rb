class AddClosedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :closed_at, :datetime
  end
end
