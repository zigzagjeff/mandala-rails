class Tiles::DrillsController < ApplicationController
  before_action :set_mandala, :set_tile

  def create
    if @tile.drillable?
      redirect_to mandala_grid_path(@mandala, @tile.drill), status: :see_other
    else
      redirect_to mandala_path(@mandala), status: :see_other
    end
  end

  private

  def set_mandala
    @mandala = Current.user.mandalas.find(params[:mandala_id])
  end

  def set_tile
    @tile = Tile.joins(:grid).find_by!(grids: { mandala_id: @mandala.id }, id: params[:tile_id])
  end
end
