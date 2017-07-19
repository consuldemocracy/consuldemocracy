class FollowsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    followable = find_followable
    @follow = Follow.create(user: current_user, followable: followable)
    flash.now[:notice] = t("shared.followable.#{followable_translation_key(@follow.followable)}.create.notice_html")
    render :refresh_follow_button
  end

  def destroy
    @follow = Follow.find(params[:id])
    @follow.destroy
    flash.now[:notice] = t("shared.followable.#{followable_translation_key(@follow.followable)}.destroy.notice_html")
    render :refresh_follow_button
  end

  private

  def find_followable
    params[:followable_type].constantize.find(params[:followable_id])
  end

  def followable_translation_key(followable)
    followable.class.name.parameterize.gsub("-", "_")
  end

end
