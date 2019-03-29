class Verification::ResidencevaController < ApplicationController

  before_action :authenticate_user!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  skip_authorization_check

  def new
    @residence = Verification::Residenceva.new
    @residence.document_type = current_user.document_type
    @residence.date_of_birth = current_user.date_of_birth
    @residence.postal_code = current_user.postal_code
  end

  def create
    @residence = Verification::Residenceva.new( residence_params.merge(user: current_user ))

    if @residence.save
      current_user.update(verified_at: Time.now)
      redirect_to account_path, notice: t('verification.letter.update.flash.success')
    else
      render :new
    end
  end

  private

  def residence_params
    params.require(:residence).permit(:document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service )
  end
end
