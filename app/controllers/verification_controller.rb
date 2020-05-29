class VerificationController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_lock

  skip_authorization_check

  def show
    redirect_to next_step_path[:path], notice: next_step_path[:notice]
  end

  private

    def next_step_path(user = current_user)
      if user.organization?
        { path: account_path }
      elsif user.level_three_verified?
        { path: account_path, notice: t("verification.redirect_notices.already_verified") }
      elsif user.verification_letter_sent?
        { path: edit_letter_path }
      elsif user.level_two_verified?
        { path: new_letter_path }
      elsif user.verification_sms_sent?
        { path: edit_sms_path }
      elsif user.verification_email_sent?
        { path: verified_user_path, notice: t("verification.redirect_notices.email_already_sent") }
      elsif user.residence_verified?
        { path: verified_user_path }
      else
        { path: new_residence_path }
      end
    end
end
