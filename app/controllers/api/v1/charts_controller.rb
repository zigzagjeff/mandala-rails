class Api::V1::ChartsController < Api::V1::BaseController
  def index
    @charts = Current.user.charts.order(created_at: :desc)
  end

  def show
    @chart = Current.user.charts.find(params[:id])
  end

  def create
    @chart = Current.user.charts.new(chart_params)
    if @chart.save
      render :show, status: :created
    else
      render json: { errors: @chart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def chart_params
    params.require(:chart).permit(:title, :mode)
  end
end
