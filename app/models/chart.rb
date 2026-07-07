class Chart < ApplicationRecord
  LIMIT = 9

  belongs_to :user
  has_many :grids, dependent: :destroy

  validates :title, presence: true
  validates :mode, inclusion: { in: %w[planning brainstorm] }
  validate :chart_limit_not_exceeded, on: :create

  def root_grid
    grids.find_by(parent_tile_id: nil)
  end

  def goal_tile
    root_grid.center_tile
  end

  private

  def chart_limit_not_exceeded
    return unless user
    if user.charts.count >= LIMIT
      errors.add(:base, "You've reached the 9-chart limit. The Mandala Chart is built on Miller's Law — the mind works best with 7 ± 2 chunks. To create a new chart, delete an existing one.")
    end
  end
end
