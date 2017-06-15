class Officing::ResidenceController < Officing::BaseController

  before_action :load_officer_assignment
  before_action :validate_officer_assignment, only: :create

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

    def load_officer_assignment
      @officer_assignments = current_user.poll_officer.
                               officer_assignments.
                               voting_days.
                               where(date: Date.current)
    end

    def validate_officer_assignment
      if @officer_assignments.blank?
        redirect_to officing_root_path, notice: t("officing.residence.flash.not_allowed")
      end
    end
end
