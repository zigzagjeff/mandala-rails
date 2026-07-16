class Api::V1::MandalasController < Api::V1::BaseController
  def index
    @mandalas = Current.user.mandalas.order(created_at: :desc)
  end

  def show
    @mandala = Current.user.mandalas.find(params[:id])
  end

  def create
    @mandala = Current.user.mandalas.new(mandala_params)
    if @mandala.save
      render :show, status: :created
    else
      render json: { errors: @mandala.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def mandala_params
    params.require(:mandala).permit(:title)
  end
end
