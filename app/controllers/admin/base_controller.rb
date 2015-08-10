class Admin::BaseController < ApplicationController

  skip_authorization_check
  before_filter :verify_administrator

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user.try(:administrator?)
    end

end
