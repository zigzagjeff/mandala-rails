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
    crumbs = []
    grid = @grid
    while grid.parent_tile
      tile = grid.parent_tile
      crumbs.unshift({ label: tile.content.presence || "(untitled)", grid: tile.grid })
      grid = tile.grid
    end
    crumbs
  end
end
