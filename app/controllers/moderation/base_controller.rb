class Moderation::BaseController < ApplicationController

  before_filter :verify_moderator

  private

  def verify_moderator
    raise CanCan::AccessDenied unless current_user.try(:moderator?)
  end

end
