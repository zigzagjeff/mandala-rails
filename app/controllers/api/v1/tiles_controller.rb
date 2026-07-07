class Api::V1::TilesController < Api::V1::BaseController
  before_action :set_tile

  def show
  end

  def update
    if @tile.update(tile_params)
      render :show
    else
      render json: { errors: @tile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def drill
    if @tile.drillable?
      @grid = @tile.find_or_create_child_grid!
      render "api/v1/grids/show"
    else
      render json: { errors: [ "Tile cannot be drilled" ] }, status: :unprocessable_entity
    end
  end

  private

  def set_tile
    @tile = Current.user.tiles.find(params[:id])
  end

  def tile_params
    params.require(:tile).permit(:title, :subtitle, :body, :agentic_summary)
  end
end
