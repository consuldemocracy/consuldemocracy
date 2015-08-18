class Moderation::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  skip_authorization_check
  before_action :verify_moderator

  private

    def verify_moderator
      raise CanCan::AccessDenied unless current_user.try(:moderator?) || current_user.try(:administrator?)
    end

end
