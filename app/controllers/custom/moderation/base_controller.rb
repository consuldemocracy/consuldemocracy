require_dependency Rails.root.join('app', 'controllers', 'moderation', 'base_controller').to_s


class Moderation::BaseController < ApplicationController
  layout 'admin'

  private

    def verify_moderator
      raise CanCan::AccessDenied unless current_user.try(:moderator?) || current_user.try(:administrator?) || current_user.try(:animator?)
    end

end
