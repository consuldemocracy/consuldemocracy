THIS_IS_AN_INTENTIONAL_ERROR
class TwoFactorAuthenticationController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource class: false

  def show
    authorize! :show, :two_factor_authentication

    Rails.logger.info "Inside show action for user #{current_user.id}"
    current_user.generate_two_factor_secret_if_missing! 
#    current_user.generate_otp_secret unless current_user.otp_secret.present?
    Rails.logger.info "Generated OTP secret for user #{current_user.id}"

    @qr_code = current_user.otp_qr_code
  end

  def enable
    Rails.logger.info "Inside enable action for user #{current_user.id}"
    authorize! :manage, :two_factor_authentication

    Rails.logger.info "Inside enable action for user #{current_user.id} otp is #{params[:otp_attempt]}"

    if current_user.validate_and_consume_otp!(params[:otp_attempt])
#      current_user.update(otp_required_for_login: true)
#      current_user.otp_secret = User.generate_otp_secret
#      current_user.save!
      current_user.enable_two_factor!
      Rails.logger.info "About to generate backup codes"
      plain_backup_codes = current_user.generate_otp_backup_codes!
         Rails.logger.info "Generated backup codes "
       Rails.logger.info "Generated backup codes: #{@backup_codes.inspect}"
       Rails.logger.info "IMMEDIATE CHECK - otp_backup_codes on current_user: #{current_user.otp_backup_codes.inspect}"
      Rails.logger.info "IMMEDIATE CHECK - current_user changed?: #{current_user.changed?}"
      Rails.logger.info "IMMEDIATE CHECK - current_user changes: #{current_user.changes.inspect}"
      # Inspect the user object before save
      Rails.logger.info "User before save: #{current_user.inspect}"    
      current_user.save!
      Rails.logger.info "User after save: #{current_user.attributes.inspect}"
      flash[:backup_codes] = plain_backup_codes
      flash[:notice] = 'Two-factor authentication enabled'
      redirect_to backup_codes_account_two_factor_authentication_path
    else
      flash.now[:alert] = 'Invalid OTP'
      render :show
    end
  end
  
  
#  def new
#    @two_factor_authentication = TwoFactorAuthentication.new
#  end
  def backup_codes
    # This action is purely for displaying the codes.
    # We retrieve them from the flash hash where the 'enable' action stored them.
    @backup_codes = flash[:backup_codes]

    # Security: If a user tries to visit this page directly without having just
    # enabled 2FA, the @backup_codes will be nil. We should redirect them away.
    if @backup_codes.nil?
      redirect_to account_path, alert: "Backup codes are only shown once upon enabling two-factor authentication."
    end
  end


  def destroy
    current_user.update(otp_required_for_login: false)
    current_user.update(otp_secret: nil)
    redirect_to root_path, notice: 'Two-factor authentication disabled'
  end
end
