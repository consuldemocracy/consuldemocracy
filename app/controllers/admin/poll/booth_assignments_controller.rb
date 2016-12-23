class Admin::Poll::BoothAssignmentsController < Admin::BaseController

  before_action :load_booth_assignment, only: :destroy

  def create
    @booth_assignment = ::Poll::BoothAssignment.new(poll_id: booth_assignment_params[:poll], booth_id: booth_assignment_params[:booth])

    if @booth_assignment.save
      notice = t("admin.booth_assignments.flash.create")
    else
      notice = t("admin.booth_assignments.flash.error_create")
    end
    redirect_to admin_poll_path(@booth_assignment.poll_id, anchor: 'tab-booths'), notice: notice
  end

  def destroy
    if @booth_assignment.destroy
      notice = t("admin.booth_assignments.flash.destroy")
    else
      notice = t("admin.booth_assignments.flash.error_destroy")
    end
    redirect_to admin_poll_path(@booth_assignment.poll_id, anchor: 'tab-booths'), notice: notice
  end

  private

    def load_booth_assignment
      @booth_assignment = ::Poll::BoothAssignment.find_by(poll: params[:poll], booth: params[:booth])
    end

    def booth_assignment_params
      params.permit(:booth, :poll)
    end

end