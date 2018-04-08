class Officing::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :verify_officer

  skip_authorization_check

  def verify_officer
    raise CanCan::AccessDenied unless current_user.try(:poll_officer?)
  end
end