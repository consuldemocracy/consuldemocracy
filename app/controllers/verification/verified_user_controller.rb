class Verification::VerifiedUserController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  def show
    @verified_users = VerifiedUser.by_user(current_user)
    redirect_to new_sms_path if @verified_users.blank?
  end
end