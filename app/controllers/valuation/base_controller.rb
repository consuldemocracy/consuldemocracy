class Valuation::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :verify_valuator

  skip_authorization_check

  private

    def verify_valuator
      raise CanCan::AccessDenied unless current_user.try(:valuator?) || current_user.try(:administrator?)
    end

end
