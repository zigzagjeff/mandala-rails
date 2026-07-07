json.extract! tile, :id, :grid_id, :position, :title, :subtitle, :agentic_summary, :heading_level
json.child_grid_id tile.child_grid&.id
