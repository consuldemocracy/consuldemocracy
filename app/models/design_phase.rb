class DesignPhase < ActiveRecord::Base

  # load_and_authorize_resource

  def show
  end

  def index
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def design_phases_params
    params.require(:design_phase).permit(:name, :description, :activated)
  end


end
