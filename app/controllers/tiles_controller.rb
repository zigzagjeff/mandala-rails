class TilesController < ApplicationController
  before_action :set_mandala
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

  def set_mandala
    @mandala = Current.user.mandalas.find(params[:mandala_id])
  end

  def set_tile
    @tile = Tile.joins(:grid).find_by!(grids: { mandala_id: @mandala.id }, id: params[:id])
  end

  def tile_params
    params.require(:tile).permit(:title, :subtitle, :body, body: {})
  end

  def surface_path
    @tile.grid.root? ? mandala_path(@mandala) : mandala_grid_path(@mandala, @tile.grid)
  end
end
