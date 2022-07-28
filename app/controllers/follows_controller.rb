class FollowsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def create
    @follow.save!
    flash.now[:notice] = t("shared.followable.#{followable_translation_key(@follow.followable)}.create.notice")
    render :refresh_follow_button
  end

  def destroy
    @follow.destroy!
    flash.now[:notice] = t("shared.followable.#{followable_translation_key(@follow.followable)}.destroy.notice")
    render :refresh_follow_button
  end

  private

    def follow_params
      params.permit(allowed_params)
    end

    def allowed_params
      [:followable_type, :followable_id]
    end

    def followable_translation_key(followable)
      followable.class.name.parameterize(separator: "_")
    end
end
