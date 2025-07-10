class Verification::VerifiedUserController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  skip_authorization_check

  def show
    @verified_users = VerifiedUser.by_user(current_user)
    redirect_to new_sms_path unless user_data_present?
  end

  private

    def user_data_present?
      return false if @verified_users.blank?

      data = false
      @verified_users.each do |vu|
        data = true if vu.phone.present? || vu.email.present?
      end

      data
    end
end
