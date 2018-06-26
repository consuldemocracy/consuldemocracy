require_dependency Rails.root.join('app', 'controllers', 'admin', 'base_controller').to_s

class Admin::BaseController < ApplicationController

  private

    def verify_administrator
      raise CanCan::AccessDenied unless (current_user.try(:administrator?) || current_user.try(:animator?))
    end

end
