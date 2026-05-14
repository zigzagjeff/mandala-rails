class Tile < ApplicationRecord
  belongs_to :grid
  has_one :child_grid, class_name: "Grid", foreign_key: :parent_tile_id, dependent: :destroy

  validates :position, presence: true,
                       inclusion: { in: 0..8 },
                       uniqueness: { scope: :grid_id }

  def has_children?
    child_grid.present?
  end

  def find_or_create_child_grid!
    child_grid || begin
      g = grid.chart.grids.create!(parent_tile: self)
      9.times { |i| g.tiles.create!(position: i, content: i == 4 ? content : nil) }
      g
    end
  end

  def tile_type
    if grid.root?
      position == 4 ? :goal : :theme
    else
      :task
    end
  end
end
