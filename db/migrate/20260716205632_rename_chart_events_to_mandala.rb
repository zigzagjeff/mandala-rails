class RenameChartEventsToMandala < ActiveRecord::Migration[8.1]
  # The Chart -> Mandala rename (#138) renamed tables, columns, and indexes, but
  # events carry the old name as data too: eventable_type is polymorphic, and
  # action is built from the class name via Eventable#eventable_prefix. Left
  # alone, every event Chart recorded points at a class that no longer exists.
  def up
    execute "UPDATE events SET eventable_type = 'Mandala' WHERE eventable_type = 'Chart'"
    execute "UPDATE events SET action = 'mandala_created' WHERE action = 'chart_created'"
    execute "UPDATE events SET action = 'mandala_title_changed' WHERE action = 'chart_title_changed'"

    # #138 discarded mode itself, not just its column, so its events go with it.
    execute "DELETE FROM events WHERE action = 'chart_mode_changed'"
  end

  # Partly irreversible, like the column drop it follows: the mode events are
  # gone for good. The rest invert.
  def down
    execute "UPDATE events SET eventable_type = 'Chart' WHERE eventable_type = 'Mandala'"
    execute "UPDATE events SET action = 'chart_created' WHERE action = 'mandala_created'"
    execute "UPDATE events SET action = 'chart_title_changed' WHERE action = 'mandala_title_changed'"
  end
end
