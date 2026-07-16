class Mandala < ApplicationRecord
  include Eventable

  LIMIT = 9

  belongs_to :user
  has_many :grids, dependent: :destroy

  validates :title, presence: true
  validate :mandala_limit_not_exceeded, on: :create

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

  def mandala_limit_not_exceeded
    return unless user
    if user.mandalas.count >= LIMIT
      errors.add(:base, "You've reached the 9-mandala limit. The Mandala Chart is built on Miller's Law — the mind works best with 7 ± 2 chunks. To create a new mandala, delete an existing one.")
    end
  end
end
