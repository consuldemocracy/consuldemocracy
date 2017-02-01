class Officing::ResidenceController < Officing::BaseController

  def new
    @residence = Officing::Residence.new
  end

  def create
    @residence = Officing::Residence.new(residence_params)
    if @residence.save
      redirect_to new_officing_voter_path(id: @residence.user.id), notice: t("officing.residence.flash.create")
    else
      render :new
    end
  end

  private

    def residence_params
      params.require(:residence).permit(:document_number, :document_type, :year_of_birth)
    end
end