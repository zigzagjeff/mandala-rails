class MigrateBodyToActionText < ActiveRecord::Migration[8.1]
  def up
    # Any existing body content is already in action_text_rich_texts
    # via has_rich_text — safe to drop the column
    remove_column :tiles, :body
  end

  def down
    add_column :tiles, :body, :text
  end
end
