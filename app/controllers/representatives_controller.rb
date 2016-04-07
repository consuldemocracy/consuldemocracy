class RepresentativesController < ApplicationController

  before_action :authenticate_user!
  skip_authorization_check

  def create
    representative = Forum.find(representative_params[:id])
    current_user.representative = representative
    current_user.save
    redirect_to representative, notice: t("flash.actions.create.representative")
  end

  private

    def representative_params
      params.require(:forum).permit(:id)
    end

end