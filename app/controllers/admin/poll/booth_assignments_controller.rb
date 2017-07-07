class Admin::Poll::BoothAssignmentsController < Admin::BaseController

  before_action :load_poll, except: [:create, :destroy]

  def index
    @booth_assignments = @poll.booth_assignments.includes(:booth).order('poll_booths.name').page(params[:page]).per(50)
  end

  def search_booths
    load_search
    @booths = ::Poll::Booth.search(@search)
    respond_to do |format|
      format.js
    end
  end

  def show
    @booth_assignment = @poll.booth_assignments.includes(:recounts, :final_recounts, :voters,
                                                         officer_assignments: [officer: [:user]]).find(params[:id])
    @voters_by_date = @booth_assignment.voters.group_by {|v| v.created_at.to_date}
  end

  def create
    @booth_assignment = ::Poll::BoothAssignment.new(poll_id: booth_assignment_params[:poll_id],
                                                    booth_id: booth_assignment_params[:booth_id])

    if @booth_assignment.save
      notice = t("admin.poll_booth_assignments.flash.create")
    else
      notice = t("admin.poll_booth_assignments.flash.error_create")
    end
    redirect_to admin_poll_booth_assignments_path(@booth_assignment.poll_id), notice: notice
  end

  def destroy
    @booth_assignment = ::Poll::BoothAssignment.find(params[:id])

    if @booth_assignment.destroy
      notice = t("admin.poll_booth_assignments.flash.destroy")
    else
      notice = t("admin.poll_booth_assignments.flash.error_destroy")
    end
    redirect_to admin_poll_booth_assignments_path(@booth_assignment.poll_id), notice: notice
  end

  private

    def load_booth_assignment
      @booth_assignment = ::Poll::BoothAssignment.find(params[:id])
    end

    def booth_assignment_params
      params.permit(:booth_id, :poll_id)
    end

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end

end
