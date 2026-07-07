class GridsController < ApplicationController
  before_action :set_chart

  def show
    @grid = @chart.grids.find(params[:id])
    @parent_tile = @grid.parent_tile
    @tiles = @grid.tiles.order(:position)
    @breadcrumb = build_breadcrumb
  end

  private

  def set_chart
    @chart = Current.user.charts.find(params[:chart_id])
  end

  def build_breadcrumb
    # 2 queries (all grids + their parent tiles) instead of 2 per depth level.
    grids_by_id = @chart.grids.includes(:parent_tile).index_by(&:id)

    crumbs = []
    # The view renders @parent_tile as the final, non-linked label, so the
    # walk starts one level above it.
    grid = @parent_tile && grids_by_id[@parent_tile.grid_id]
    while grid && (tile = grid.parent_tile)
      crumbs.unshift({ label: tile.display_title, grid: grid })
      grid = grids_by_id[tile.grid_id]
    end
    crumbs
  end
end
