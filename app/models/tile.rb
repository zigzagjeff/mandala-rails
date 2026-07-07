class Tile < ApplicationRecord
  belongs_to :grid
  has_one :child_grid, class_name: "Grid", foreign_key: :parent_tile_id, primary_key: :id, dependent: :destroy
  has_rich_text :body

  serialize :metadata, coder: JSON

  CENTER_POSITION = 4
  TITLE_MAX_LENGTH = 60
  SUBTITLE_MAX_LENGTH = 120

  validates :position, presence: true,
                       inclusion: { in: 0..8 },
                       uniqueness: { scope: :grid_id }
  validates :title, length: { maximum: TITLE_MAX_LENGTH }, allow_blank: true
  validates :subtitle, length: { maximum: SUBTITLE_MAX_LENGTH }, allow_blank: true

  def has_children?
    child_grid.present?
  end

  def display_title
    title.presence || ""
  end

  def center?
    position == CENTER_POSITION
  end

  def find_or_create_child_grid!
    child_grid || begin
      child = grid.chart.grids.create!(parent_tile_id: id)
      9.times { |i| child.tiles.create!(position: i, title: i == CENTER_POSITION ? title : nil) }
      child
    end
  end

  def heading_level
    center? ? grid.depth + 1 : grid.depth + 2
  end

  # Used by agent pipeline and UI to classify tiles without a stored column.
  def tile_type
    if grid.root?
      center? ? :goal : :theme
    else
      :task
    end
  end
end
