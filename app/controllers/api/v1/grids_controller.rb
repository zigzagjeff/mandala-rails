class Api::V1::GridsController < Api::V1::BaseController
  def show
    @grid = Current.user.grids.find(params[:id])
  end
end
