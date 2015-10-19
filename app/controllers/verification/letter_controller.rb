class Verification::LetterController < ApplicationController
  before_action :authenticate_user!, except: [:edit, :update]
  before_action :check_credentials, only: :update

  before_action :verify_resident!, except: :edit
  before_action :verify_phone!, except: :edit
  before_action :verify_verified!, except: :edit
  before_action :verify_lock, except: :edit

  skip_authorization_check

  def new
    @letter = Verification::Letter.new(user: current_user)
  end

  def create
    @letter = Verification::Letter.new(user: current_user)
    @letter.save
    redirect_to letter_path
  end

  def show
  end

  def edit
    @letter = Verification::Letter.new
  end

  def update
    @letter = Verification::Letter.new(letter_params.merge(user: current_user, verify: true))
    if @letter.valid?
      current_user.update(verified_at: Time.now)
      redirect_to account_path, notice: t('verification.letter.update.flash.success')
    else
      Lock.increase_tries(@letter.user)
      render :edit
    end
  end

  private

    def letter_params
      params.require(:verification_letter).permit(:verification_code, :email, :password)
    end

    def verify_phone!
      unless current_user.confirmed_phone?
        redirect_to verified_user_path, alert: t('verification.letter.alert.unconfirmed_code')
      end
    end

    def check_credentials
      user = User.where(email: letter_params[:email]).first
      if user && user.valid_password?(letter_params[:password])
        sign_in(user)
      else
        redirect_to edit_letter_path, alert: t('devise.failure.invalid', authentication_keys: 'email')
      end
    end

end