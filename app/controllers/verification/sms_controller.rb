class Verification::SmsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  before_action :set_phone, only: :create

  skip_authorization_check

  def new
    @sms = Verification::Sms.new(phone: params[:phone])
  end

  def create
    @sms = Verification::Sms.new(phone: @phone, user: current_user)
    if @sms.save
      redirect_to edit_sms_path, notice: t("verification.sms.create.flash.success")
    else
      render :new
    end
  end

  def edit
    @sms = Verification::Sms.new
  end

  def update
    @sms = Verification::Sms.new(sms_params.merge(user: current_user))
    if @sms.verified?
      current_user.update!(confirmed_phone: current_user.unconfirmed_phone)
      ahoy.track(:level_2_user, user_id: current_user.id) rescue nil

      if VerifiedUser.phone?(current_user)
        current_user.update(verified_at: Time.current)
      end

      redirect_to_next_path
    else
      @error = t("verification.sms.update.error")
      render :edit
    end
  end

  private

    def sms_params
      params.require(:sms).permit(allowed_params)
    end

    def allowed_params
      [:phone, :confirmation_code]
    end

    def set_phone
      if verified_user
        @phone = @verified_user.phone
      else
        @phone = sms_params[:phone]
      end
    end

    def verified_user
      return false unless params[:verified_user]

      @verified_user = VerifiedUser.by_user(current_user).find_by(id: params[:verified_user][:id])
    end

    def redirect_to_next_path
      current_user.reload
      if current_user.level_three_verified?
        redirect_to account_path, notice: t("verification.sms.update.flash.level_three.success")
      else
        redirect_to new_letter_path, notice: t("verification.sms.update.flash.level_two.success")
      end
    end
end
