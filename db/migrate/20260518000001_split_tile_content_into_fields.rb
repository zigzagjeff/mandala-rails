class SplitTileContentIntoFields < ActiveRecord::Migration[8.1]
  def up
    add_column :tiles, :title, :string
    add_column :tiles, :subtitle, :string
    add_column :tiles, :body, :text
    add_column :tiles, :agentic_summary, :text

    # Migrate existing content values into title; preserve data
    execute "UPDATE tiles SET title = content WHERE content IS NOT NULL"

    remove_column :tiles, :content
  end

  def down
    add_column :tiles, :content, :text

    execute "UPDATE tiles SET content = title WHERE title IS NOT NULL"

    remove_column :tiles, :title
    remove_column :tiles, :subtitle
    remove_column :tiles, :body
    remove_column :tiles, :agentic_summary
  end
end
