class RenameChartsToMandalas < ActiveRecord::Migration[8.1]
  def change
    rename_table :charts, :mandalas

    rename_column :grids, :chart_id, :mandala_id
    rename_index :grids, "index_grids_on_chart_id", "index_grids_on_mandala_id"

    rename_column :events, :chart_id, :mandala_id
    rename_index :events, "index_events_on_chart_id_and_created_at", "index_events_on_mandala_id_and_created_at"

    # Deliberately discarded, not migrated: issue #138 decision 1 drops the
    # planning/brainstorm mode entirely. Reversible — type given, column nullable.
    remove_column :mandalas, :mode, :string
  end
end
