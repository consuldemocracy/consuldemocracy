class Officing::FinalRecountsController < Officing::BaseController
  before_action :load_poll
  before_action :load_officer_assignment, only: :create

  def new
    @officer_assignments = ::Poll::OfficerAssignment.
                  includes(:final_recounts, booth_assignment: [:booth]).
                  joins(:booth_assignment).
                  final.
                  where(id: current_user.poll_officer.officer_assignment_ids).
                  where("poll_booth_assignments.poll_id = ?", @poll.id).
                  order(date: :asc)

    @final_recounts = @officer_assignments.select {|oa| oa.final_recounts.any?}.map(&:final_recounts).flatten
  end

  def create
    @final_recount = ::Poll::FinalRecount.find_or_initialize_by(booth_assignment_id: @officer_assignment.booth_assignment_id,
                                                                date: final_recount_params[:date])
    @final_recount.officer_assignment_id = @officer_assignment.id
    @final_recount.count = final_recount_params[:count]

    if @final_recount.save
      msg = { notice: t("officing.final_recounts.flash.create") }
    else
      msg = { alert: t("officing.final_recounts.flash.error_create") }
    end
    redirect_to new_officing_poll_final_recount_path(@poll), msg
  end

  private

    def load_poll
      @poll = Poll.expired.find(params[:poll_id])
    end

    def load_officer_assignment
      @officer_assignment = current_user.poll_officer.
                            officer_assignments.final.find_by(id: final_recount_params[:officer_assignment_id])
      if @officer_assignment.blank?
        redirect_to new_officing_poll_final_recount_path(@poll), alert: t("officing.final_recounts.flash.error_create")
      end
    end

    def final_recount_params
      params.permit(:officer_assignment_id, :count, :date)
    end

end
