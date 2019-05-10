class Officing::ResidenceController < Officing::BaseController

  before_action :load_officer_assignment
  before_action :verify_officer_assignment
  before_action :verify_booth

  def new
    @residence = Officing::Residence.new
  end

  def create
    @residence = Officing::Residence.new(residence_params.merge(officer: current_user.poll_officer))
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
