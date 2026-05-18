class TilesController < ApplicationController
  before_action :set_chart
  before_action :set_tile

  def edit
  end

  def drill
    child_grid = @tile.find_or_create_child_grid!
    redirect_to chart_grid_path(@chart, child_grid)
  end

  def update
    if @tile.update(tile_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chart_path(@chart) }
      end
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
    params.require(:tile).permit(:title, :subtitle, :body)
  end
end
