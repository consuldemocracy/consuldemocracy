class Api::ApiController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :null_session

  skip_authorization_check
  before_action :verify_administrator

  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user.try(:administrator?)
    end
end
