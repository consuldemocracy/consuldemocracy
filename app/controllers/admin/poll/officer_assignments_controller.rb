class Admin::Poll::OfficerAssignmentsController < Admin::BaseController

  before_action :redirect_if_blank_required_params, only: [:index]
  before_action :load_booth_assignment, only: [:create]

  def index
    @poll = ::Poll.includes(:booths).find(officer_assignment_params[:poll])
    @officer = ::Poll::Officer.includes(:user).find(officer_assignment_params[:officer])
    @officer_assignments = ::Poll::OfficerAssignment.
                           joins(:booth_assignment).
                           includes(booth_assignment: :booth).
                           where("officer_id = ? AND poll_booth_assignments.poll_id = ?", @officer.id, @poll.id).
                           order(:date)
  end

  def create
    @officer_assignment = ::Poll::OfficerAssignment.new(booth_assignment: @booth_assignment,
                                                        officer_id: create_params[:officer_id],
                                                        date: create_params[:date])

    if @officer_assignment.save
      notice = t("admin.poll_officer_assignments.flash.create")
    else
      notice = t("admin.poll_officer_assignments.flash.error_create")
    end
    redirect_to admin_officer_assignments_path(officer: create_params[:officer_id], poll: create_params[:poll_id]), notice: notice
  end

  def destroy
    @officer_assignment = ::Poll::OfficerAssignment.includes(:booth_assignment).find(params[:id])

    if @officer_assignment.destroy
      notice = t("admin.poll_officer_assignments.flash.destroy")
    else
      notice = t("admin.poll_officer_assignments.flash.error_destroy")
    end
    redirect_to admin_officer_assignments_path(officer: @officer_assignment.officer_id, poll: @officer_assignment.poll_id), notice: notice
  end

  private

    def officer_assignment_params
      params.permit(:officer, :poll)
    end

    def create_params
      params.permit(:poll_id, :booth_id, :date, :officer_id)
    end

    def load_booth_assignment
      @booth_assignment = ::Poll::BoothAssignment.find_by(poll_id: create_params[:poll_id], booth_id: create_params[:booth_id])
    end

    def redirect_if_blank_required_params
      if officer_assignment_params[:officer].blank?
        if officer_assignment_params[:poll].blank?
          redirect_to admin_polls_path
        else
          redirect_to admin_poll_path(officer_assignment_params[:poll])
        end
      end
    end

end