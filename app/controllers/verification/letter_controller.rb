class Verification::LetterController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_resident!
  before_action :verify_phone!
  skip_authorization_check

  def new
    @letter = Verification::Letter.new(user: current_user)
  end

  def create
    @letter = Verification::Letter.new(user: current_user)
    if @letter.save
      redirect_to edit_letter_path, notice: t('verification.letter.create.flash.success')
    else
      flash.now.alert = t('verification.letter.create.alert.failure')
      render :new
    end
  end

  def edit
    @letter = Verification::Letter.new(user: current_user)
  end

  def update
    @letter = Verification::Letter.new(letter_params.merge(user: current_user))
    if @letter.verify?
      current_user.update(verified_at: Time.now)
      redirect_to account_path, notice: t('verification.letter.update.flash.success')
    else
      @error = t('verification.letter.update.error')
      render :edit
    end
  end

  private

    def letter_params
      params.require(:letter).permit(:verification_code)
    end

    def verify_phone!
      unless current_user.confirmed_phone?
        redirect_to verified_user_path, alert: t('verification.letter.alert.unconfirmed_code')
      end
    end
end