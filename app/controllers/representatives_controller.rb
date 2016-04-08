class RepresentativesController < ApplicationController

  before_action :authenticate_user!
  skip_authorization_check

  def create
    representative = Forum.find(representative_params[:id])
    current_user.representative = representative
    current_user.save
    redirect_to forums_path, notice: t("flash.actions.create.representative")
  end

  def destroy
    current_user.update(representative: nil)
    redirect_to forums_path, notice: t("flash.actions.destroy.representative")
  end

  private

    def representative_params
      params.require(:forum).permit(:id)
    end

end