class Moderation::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :verify_moderator

  skip_authorization_check

  private

    def verify_moderator
      raise CanCan::AccessDenied unless current_user&.moderator? || current_user&.administrator?
    end
end
