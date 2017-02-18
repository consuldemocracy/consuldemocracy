class EnvelopesController < ApplicationController
  skip_authorization_check
  layout 'nvotes'

  def new
    @residence = Officing::Residence.new(letter: true)
  end

  def create
    @residence = Officing::Residence.new(residence_params.merge(officer: current_user.poll_officer, letter: true))
    if @residence.save
      redirect_to new_envelope_path, notice: t("officing.residence.flash.create")
    else
      render :new
    end
  end

  private

    def residence_params
      params.require(:residence).permit(:document_number, :document_type, :postal_code)
    end



end
