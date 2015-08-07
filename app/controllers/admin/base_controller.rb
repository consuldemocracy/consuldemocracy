class Admin::BaseController < ApplicationController

  before_filter :verify_administrator

  private

  def verify_administrator
    raise CanCan::AccessDenied unless current_user.try(:administrator?)
  end

end
