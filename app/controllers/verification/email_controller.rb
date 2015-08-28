class Verification::EmailController < ApplicationController
  before_action :authenticate_user!
  before_action :set_verified_user
  skip_authorization_check

  def show
    if Email.find(current_user, params[:email_verification_token])
      current_user.update(verified_at: Time.now)
      redirect_to account_path, notice: t('verification.email.show.flash.success')
    else
      redirect_to verified_user_path, alert: t('verification.email.show.alert.failure')
    end
  end

  def create
    @email = Email.new(@verified_user)
    if @email.save
      current_user.reload
      Mailer.email_verification(current_user, @email.recipient, @email.encrypted_token).deliver_now
      redirect_to account_path, notice: t('verification.email.create.flash.success', email: @verified_user.email)
    else
      redirect_to verified_user_path, alert: t('verification.email.create.alert.failure')
    end
  end

  private

    def set_verified_user
      @verified_user = VerifiedUser.by_user(current_user).by_email(params[:recipient]).first
    end
end