class Mandala < ApplicationRecord
  include Eventable

  belongs_to :user
  has_many :grids, dependent: :destroy
  has_one :root_grid, -> { where(parent_tile_id: nil) }, class_name: "Grid"

  delegate :center_tile, to: :root_grid

  validates :title, presence: true

  after_create :seed_root_grid

  private

  def seed_root_grid
    grids.create!.tap do |grid|
      Event.suppressing_recording { grid.center_tile.update!(title:) }
    end
  end
end
