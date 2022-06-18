class ContainersController < ApplicationController
  before_filter :authorize
  before_action :is_admin
  before_action :set_container, only: [:show, :edit, :update, :destroy]

  def index
    @containers = Container.all
  end

  def show
  end

  def new
    @container = Container.new
  end

  def edit
  end

  def create
    @container = Container.new(container_params)

    if @container.save
      redirect_to @container, notice: 'Container was successfully created.'
    else
      render action: 'new' 
    end
  end

  def update
    if @container.update(container_params)
      redirect_to @container, notice: 'Container was successfully updated.'
    else
      render action: 'edit' 
    end
  end

  def destroy
    @container.destroy
    redirect_to containers_url 
  end

  private

  def set_container
    @container = Container.find(params[:id])
  end

  def container_params
    params.require(:container).permit(:container_type, :length, :width, :height, :capacity, :load, :container_weight, :max_gross_weight)
  end
end
