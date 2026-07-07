class Grid < ApplicationRecord
  belongs_to :chart
  belongs_to :parent_tile, class_name: "Tile", optional: true
  has_many :tiles, dependent: :destroy

  POSITIONS = (0..8)

  before_create { self.depth = root? ? 0 : parent_tile.grid.depth + 1 }
  after_create :seed_tiles

  def root?
    parent_tile_id.nil?
  end

  def center_tile
    tiles.find_by(position: Tile::CENTER_POSITION)
  end

  private

  def seed_tiles
    POSITIONS.each { |position| tiles.create!(position: position) }
  end
end
