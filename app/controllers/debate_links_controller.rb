class DebateLinksController < ApplicationController
  include CommentableActions
 
  load_and_authorize_resource class: "Debate"

  respond_to :html, :js

  private
    def create_params
       params.require(:debate).permit(:title,  :external_link, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def debate_params
       params.require(:debate).permit(:title,  :external_link, :tag_list, :terms_of_service, :captcha, :captcha_key)
    end

    def resource_model
      Debate
    end 

    def after_create_path
     debate_path(@resource)
   end
end
