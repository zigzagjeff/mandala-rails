class TilesController < ApplicationController
  before_action :set_chart
  before_action :set_tile

  helper_method :surface_path

  def edit
  end

  def rename
  end

  def update
    if @tile.update(tile_params)
      redirect_to surface_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_chart
    @chart = Current.user.charts.find(params[:chart_id])
  end

  def set_tile
    @tile = Tile.joins(:grid).find_by!(grids: { chart_id: @chart.id }, id: params[:id])
  end

  def tile_params
    params.require(:tile).permit(:title, :subtitle, :body, body: {})
  end

  def surface_path
    @tile.grid.root? ? chart_path(@chart) : chart_grid_path(@chart, @tile.grid)
  end
end
