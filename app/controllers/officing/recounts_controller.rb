class Officing::RecountsController < Officing::BaseController
  before_action :load_poll
  before_action :load_officer_assignment, only: :create

  def new
    @officer_assignments = ::Poll::OfficerAssignment.
                  includes(:recount, booth_assignment: :booth).
                  joins(:booth_assignment).
                  voting_days.
                  where(id: current_user.poll_officer.officer_assignment_ids).
                  where("poll_booth_assignments.poll_id = ?", @poll.id).
                  order(date: :asc)
    @recounted = @officer_assignments.select {|oa| oa.recount.present?}.reverse
  end

  def create
    @recount = ::Poll::Recount.find_or_initialize_by(booth_assignment_id: @officer_assignment.booth_assignment_id,
                                                     date: @officer_assignment.date)
    @recount.officer_assignment_id = @officer_assignment.id
    @recount.count = recount_params[:count]

    if @recount.save
      msg = { notice: t("officing.recounts.flash.create") }
    else
      msg = { alert: t("officing.recounts.flash.error_create") }
    end
    redirect_to new_officing_poll_recount_path(@poll), msg
  end

  private

    def load_poll
      @poll = Poll.find(params[:poll_id])
    end

    def load_officer_assignment
      @officer_assignment = current_user.poll_officer.
                            officer_assignments.find_by(id: recount_params[:officer_assignment_id])
      if @officer_assignment.blank?
        redirect_to new_officing_poll_recount_path(@poll), alert: t("officing.recounts.flash.error_create")
      end
    end

    def recount_params
      params.permit(:officer_assignment_id, :count)
    end

end
