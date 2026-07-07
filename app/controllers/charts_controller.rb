class ChartsController < ApplicationController
  def index
    @charts = Current.user.charts.order(created_at: :desc)
  end

  def new
    if Current.user.charts.count >= Chart::LIMIT
      redirect_to charts_path, alert: "You've reached the 9-chart limit. To create a new chart, delete an existing one."
      return
    end
    @chart = Chart.new
  end

  def create
    @chart = Current.user.charts.build(chart_params)
    if @chart.save
      redirect_to charts_path, notice: "Mandala created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @chart = Current.user.charts.find(params[:id])
    @root_grid = @chart.root_grid
    @tiles = @root_grid.tiles.with_previews.positioned
  end

  def edit
    @chart = Current.user.charts.find(params[:id])
  end

  def update
    @chart = Current.user.charts.find(params[:id])
    if @chart.update(chart_params)
      redirect_to chart_path(@chart)
    else
      render :edit, status: :unprocessable_entity
    end
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
