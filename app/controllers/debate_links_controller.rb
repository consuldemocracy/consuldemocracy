class DebateLinksController < ApplicationController
  include FeatureFlags
  include CommentableActions

  before_action :authenticate_user!, except: [:show]

  load_and_authorize_resource class: "Debate"

  feature_flag :debates

  respond_to :html, :js

  private

    def create_params
      params.require(:debate).permit(:title, :external_link, :tag_list, :terms_of_service, :captcha, :captcha_key).merge(link_required: true)
    end

    def debate_params
      params.require(:debate).permit(:title, :external_link, :tag_list, :terms_of_service, :captcha, :captcha_key).merge(link_required: true)
    end

    def after_create_path
      debate_path(@resource)
    end

    def resource_model
      Debate
    end

end
