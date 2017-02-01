class Officing::ResultsController < Officing::BaseController
  before_action :load_poll
  before_action :load_officer_assignment, only: :create

  def new
    @officer_assignments = ::Poll::OfficerAssignment.
                  includes(booth_assignment: [:booth]).
                  joins(:booth_assignment).
                  final.
                  where(id: current_user.poll_officer.officer_assignment_ids).
                  where("poll_booth_assignments.poll_id = ?", @poll.id).
                  order(date: :asc)
  end

  def create
    if false
      notice = t("officing.results.flash.create")
    else
      notice = t("officing.results.flash.error_create")
    end
    redirect_to new_officing_poll_result_path(@poll), notice: notice
  end

  private
    def load_poll
      @poll = Poll.expired.includes(:questions).find(params[:poll_id])
    end

    def load_officer_assignment
      @officer_assignment = current_user.poll_officer.
                            officer_assignments.final.find_by(id: final_recount_params[:officer_assignment_id])
      if @officer_assignment.blank?
        redirect_to new_officing_poll_result_path(@poll), notice: t("officing.results.flash.error_create")
      end
    end

    def final_recount_params
      params.permit(:officer_assignment_id, :count, :date)
    end

end