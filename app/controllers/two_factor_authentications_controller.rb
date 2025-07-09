class TwoFactorAuthenticationsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: false

  def show
    authorize! :show, :two_factor_authentication
    Rails.logger.info "Inside show action for user #{current_user.id}"
    current_user.generate_two_factor_secret_if_missing!
    @qr_code = current_user.otp_qr_code
  end

  def enable
    Rails.logger.info "Inside enable action for user #{current_user.id}"
    authorize! :manage, :two_factor_authentication

    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.enable_two_factor!
      Rails.logger.info "About to generate backup codes"
      plain_backup_codes = current_user.generate_otp_backup_codes!
      current_user.save!
      flash[:backup_codes] = plain_backup_codes
      flash[:notice] = "Two-factor authentication enabled"
      redirect_to backup_codes_account_two_factor_authentication_path
    else
      flash.now[:alert] = "Invalid OTP"
      render :show
    end
  end
  
  def backup_codes
    # We retrieve them from the flash hash where the 'enable' action stored them.
    @backup_codes = flash[:backup_codes]

    # Security: If a user tries to visit this page directly without having just
    # enabled 2FA, the @backup_codes will be nil. We should redirect them away.
    if @backup_codes.nil?
      redirect_to account_path, alert: "Backup codes are only shown once upon enabling two-factor authentication."
    end
  end

  def destroy
    current_user.update!(otp_required_for_login: false)
    current_user.update!(otp_secret: nil)
    redirect_to root_path, notice: "Two-factor authentication disabled"
  end
end
