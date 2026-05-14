class Chart < ApplicationRecord
  belongs_to :user
  has_many :grids, dependent: :destroy

  validates :title, presence: true
  validates :mode, inclusion: { in: %w[planning brainstorm] }

  def root_grid
    grids.find_by(parent_tile_id: nil)
  end
end
