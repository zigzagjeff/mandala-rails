class AddApiTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :api_token, :string
    add_index :users, :api_token, unique: true

    reversible do |dir|
      dir.up do
        select_values("SELECT id FROM users").each do |id|
          update "UPDATE users SET api_token = #{connection.quote(SecureRandom.base58(24))} WHERE id = #{id.to_i}"
        end
      end
    end
  end
end
