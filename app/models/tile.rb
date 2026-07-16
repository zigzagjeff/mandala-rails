class Tile < ApplicationRecord
  include Eventable

  belongs_to :grid
  has_one :child_grid, class_name: "Grid", foreign_key: :parent_tile_id, primary_key: :id, dependent: :destroy
  has_rich_text :body

  delegate :mandala, to: :grid

  serialize :metadata, coder: JSON

  CENTER_POSITION = 4
  TITLE_MAX_LENGTH = 60
  SUBTITLE_MAX_LENGTH = 120
  BODY_PREVIEW_LENGTH = 80

  validates :position, presence: true,
                       inclusion: { in: Grid::POSITIONS },
                       uniqueness: { scope: :grid_id }
  validates :title, length: { maximum: TITLE_MAX_LENGTH }, allow_blank: true
  validates :subtitle, length: { maximum: SUBTITLE_MAX_LENGTH }, allow_blank: true

  scope :positioned, -> { order(:position) }
  scope :with_previews, -> { with_rich_text_body.includes(:child_grid) }

  def has_children?
    child_grid.present?
  end

  def title_placeholder
    center? ? "Name the center" : "Add a tile"
  end

  def body_preview
    body.to_plain_text.gsub(/\[\s?[xX]?\]/, "").squish.truncate(BODY_PREVIEW_LENGTH)
  end

  def center?
    position == CENTER_POSITION
  end

  def drillable?
    grid.root? && !center?
  end

  def drill
    child_grid || create_child_grid_once
  end

  def heading_level
    center? ? grid.depth + 1 : grid.depth + 2
  end

  private
    def create_child_grid_once
      Grid.create_or_find_by!(mandala: mandala, parent_tile: self).tap do |grid|
        if grid.previously_new_record?
          Event.suppressing_recording do
            grid.center_tile.update!(title: title)
          end
          track_event "drilled"
        end
      end
    end
end
