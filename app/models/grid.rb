class Grid < ApplicationRecord
  belongs_to :chart
  belongs_to :parent_tile, class_name: "Tile", optional: true
  has_many :tiles, dependent: :destroy

  def root?
    parent_tile_id.nil?
  end
end
