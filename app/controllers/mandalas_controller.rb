class MandalasController < ApplicationController
  def index
    @mandalas = Current.user.mandalas.order(created_at: :desc)
  end

  def new
    @mandala = Mandala.new
  end

  def create
    @mandala = Current.user.mandalas.build(mandala_params)
    if @mandala.save
      redirect_to mandalas_path, notice: "Mandala created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @mandala = Current.user.mandalas.find(params[:id])
    @root_grid = @mandala.root_grid
    @tiles = @root_grid.tiles.with_previews.positioned
  end

  def edit
    @mandala = Current.user.mandalas.find(params[:id])
  end

  def update
    @mandala = Current.user.mandalas.find(params[:id])
    if @mandala.update(mandala_params)
      redirect_to mandala_path(@mandala)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user.mandalas.find(params[:id]).destroy
    redirect_to mandalas_path, notice: "Mandala deleted."
  end

  private

  def mandala_params
    params.require(:mandala).permit(:title)
  end
end
