class ChartsController < ApplicationController
  def index
    @charts = Current.user.charts.order(created_at: :desc)
  end

  def new
    @chart = Chart.new
  end

  def create
    @chart = Current.user.charts.build(chart_params)
    if @chart.save
      root_grid = @chart.grids.create!(parent_tile_id: nil)
      9.times { |i| root_grid.tiles.create!(position: i) }
      redirect_to charts_path, notice: "Mandala created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @chart = Current.user.charts.find(params[:id])
    @root_grid = @chart.root_grid
    @tiles = @root_grid.tiles.order(:position)
  end

  def destroy
    Current.user.charts.find(params[:id]).destroy
    redirect_to charts_path, notice: "Mandala deleted."
  end

  private

  def chart_params
    params.require(:chart).permit(:title, :mode)
  end
end
