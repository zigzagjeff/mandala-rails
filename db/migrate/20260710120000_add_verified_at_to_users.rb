class AddVerifiedAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :verified_at, :datetime

    # Grandfather every account that existed before verification did — a nil here
    # would nag long-standing users to prove an address they've used for months.
    execute "UPDATE users SET verified_at = CURRENT_TIMESTAMP"
  end

  def down
    remove_column :users, :verified_at
  end
end
