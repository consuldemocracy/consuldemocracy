class Communication::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :verify_communication_user

  skip_authorization_check

  private

    def verify_communication_user
      raise CanCan::AccessDenied unless current_user.try(:animator?) || current_user.try(:administrator?)
    end

end
