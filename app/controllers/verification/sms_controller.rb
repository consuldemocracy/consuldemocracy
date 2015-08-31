class Verification::SmsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_attemps_left!, only: [:new, :create]
  before_action :set_phone, only: :create

  skip_authorization_check

  def new
    @sms = Verification::Sms.new(phone: params[:phone])
  end

  def create
    @sms = Verification::Sms.new(phone: @phone, user: current_user)
    if @sms.save
      redirect_to edit_sms_path, notice: t('verification.sms.create.flash.success')
    else
      render :new
    end
  end

  def edit
    @sms = Verification::Sms.new
  end

  def update
    @sms = Verification::Sms.new(sms_params.merge(user: current_user))
    if @sms.verify?
      current_user.update(confirmed_phone: current_user.unconfirmed_phone)

      if VerifiedUser.phone?(current_user)
        current_user.update(verified_at: Time.now)
      end

      redirect_to_next_path
    else
      @error = t('verification.sms.update.error')
      render :edit
    end
  end

  private

    def sms_params
      params.require(:sms).permit(:phone, :confirmation_code)
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
      @verified_user = VerifiedUser.by_user(current_user).where(id: params[:verified_user][:id]).first
    end

    def redirect_to_next_path
      current_user.reload
      if current_user.level_three_verified?
        redirect_to account_path, notice: t('verification.sms.update.flash.level_three.success')
      else
        redirect_to new_letter_path, notice: t('verification.sms.update.flash.level_two.success')
      end
    end

    def verify_attemps_left!
      if current_user.sms_confirmation_tries >= 3
        redirect_to account_path, notice: t('verification.sms.alert.verify_attemps_left')
      end
    end

end