class Verification::LetterController < ApplicationController
  before_action :authenticate_user!, except: [:edit, :update]
  before_action :login_via_form, only: :update

  before_action :verify_resident!, if: :signed_in?
  before_action :verify_phone!, if: :signed_in?
  before_action :verify_verified!, if: :signed_in?
  before_action :verify_lock, if: :signed_in?

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
      current_user.update(verified_at: Time.current)
      redirect_to account_path, notice: t('verification.letter.update.flash.success')
    else
      Lock.increase_tries(@letter.user) if @letter.user
      render :edit
    end
  end

  private

    def letter_params
      params.require(:verification_letter).permit(:verification_code, :email, :password)
    end

    def verify_phone!
      unless current_user.sms_verified?
        redirect_to verified_user_path, alert: t('verification.letter.alert.unconfirmed_code')
      end
    end

    def login_via_form
      user = User.find_by email: letter_params[:email]
      if user && user.valid_password?(letter_params[:password])
        sign_in(user)
      end
    end

end
