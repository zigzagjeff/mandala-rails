class Tiles::DrillsController < ApplicationController
  before_action :set_chart, :set_tile

  def create
    if @tile.drillable?
      redirect_to chart_grid_path(@chart, @tile.drill), status: :see_other
    else
      redirect_to chart_path(@chart), status: :see_other
    end
  end

  private

  def set_chart
    @chart = Current.user.charts.find(params[:chart_id])
  end

  def set_tile
    @tile = Tile.joins(:grid).find_by!(grids: { chart_id: @chart.id }, id: params[:tile_id])
  end
end
