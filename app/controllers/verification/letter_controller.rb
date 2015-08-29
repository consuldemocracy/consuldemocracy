class Verification::LetterController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_phone_or_email!
  skip_authorization_check

  def new
    @letter = Verification::Letter.new(user: current_user)
  end

  def create
    @letter = Verification::Letter.new(user: current_user)
    if @letter.save
      redirect_to account_path, notice: t('verification.letter.create.flash.success')
    else
      flash.now.alert = t('verification.letter.create.alert.failure')
      render :new
    end
  end

  private

    def letter_params
      params.require(:letter).permit()
    end

    def verify_phone_or_email!
      unless current_user.confirmed_phone?
        redirect_to verified_user_path, alert: t('verification.letter.alert.unconfirmed_personal_data')
      end
    end
end