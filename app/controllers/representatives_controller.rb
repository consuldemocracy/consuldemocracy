class RepresentativesController < ApplicationController

  before_action :authenticate_user!
  skip_authorization_check

  def new
    @user = current_user
    @forums = Forum.all
  end

  def create
    current_user.update(representative_id: params[:user][:representative_id])
    redirect_to new_representative_path, notice: t("flash.actions.create.representative")
  end

end