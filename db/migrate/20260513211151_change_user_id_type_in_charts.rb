class ChangeUserIdTypeInCharts < ActiveRecord::Migration[8.1]
  def up
    execute 'ALTER TABLE charts ALTER COLUMN user_id TYPE bigint USING user_id::text::bigint'
  end

  def down
    execute 'ALTER TABLE charts ALTER COLUMN user_id TYPE uuid USING user_id::text::uuid'
  end
end
