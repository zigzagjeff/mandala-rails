class Mandala < ApplicationRecord
  include Eventable

  belongs_to :user
  has_many :grids, dependent: :destroy

  validates :title, presence: true

  after_create :seed_root_grid

  def root_grid
    grids.find_by(parent_tile_id: nil)
  end

  def center_tile
    root_grid.center_tile
  end

  private

  def seed_root_grid
    grids.create!.tap do |grid|
      Event.suppressing_recording { grid.center_tile.update!(title:) }
    end
  end
end
