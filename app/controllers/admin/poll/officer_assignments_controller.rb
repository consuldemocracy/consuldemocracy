class Admin::Poll::OfficerAssignmentsController < Admin::BaseController

  before_action :load_poll
  before_action :redirect_if_blank_required_params, only: [:by_officer]
  before_action :load_booth_assignment, only: [:create]

  def index
    @officers = ::Poll::Officer.
                  includes(:user).
                  order('users.username').
                  where(
                    id: @poll.officer_assignments.select(:officer_id).distinct.map(&:officer_id)
                  ).page(params[:page]).per(50)
  end

  def by_officer
    @poll = ::Poll.includes(:booths).find(params[:poll_id])
    @officer = ::Poll::Officer.includes(:user).find(officer_assignment_params[:officer_id])
    @officer_assignments = ::Poll::OfficerAssignment.
                           joins(:booth_assignment).
                           includes(:recount, :final_recounts, booth_assignment: :booth).
                           where("officer_id = ? AND poll_booth_assignments.poll_id = ?", @officer.id, @poll.id).
                           order(:date)
  end

  def search_officers
    load_search
    @officers = User.joins(:poll_officer).search(@search).order(username: :asc)

    respond_to do |format|
      format.js
    end
  end

  def create
    @officer_assignment = ::Poll::OfficerAssignment.new(booth_assignment: @booth_assignment,
                                                        officer_id: create_params[:officer_id],
                                                        date: create_params[:date])
    @officer_assignment.final = true if @officer_assignment.date > @booth_assignment.poll.ends_at.to_date

    if @officer_assignment.save
      notice = t("admin.poll_officer_assignments.flash.create")
    else
      notice = t("admin.poll_officer_assignments.flash.error_create")
    end

    redirect_params = { poll_id: create_params[:poll_id], officer_id: create_params[:officer_id] }
    redirect_to by_officer_admin_poll_officer_assignments_path(redirect_params), notice: notice
  end

  def destroy
    @officer_assignment = ::Poll::OfficerAssignment.includes(:booth_assignment).find(params[:id])

    if @officer_assignment.destroy
      notice = t("admin.poll_officer_assignments.flash.destroy")
    else
      notice = t("admin.poll_officer_assignments.flash.error_destroy")
    end

    redirect_params = { poll_id: @officer_assignment.poll_id, officer_id: @officer_assignment.officer_id }
    redirect_to by_officer_admin_poll_officer_assignments_path(redirect_params), notice: notice
  end

  private

    def officer_assignment_params
      params.permit(:officer_id)
    end

    def create_params
      params.permit(:poll_id, :booth_id, :date, :officer_id)
    end

    def load_booth_assignment
      find_params = { poll_id: create_params[:poll_id], booth_id: create_params[:booth_id] }
      @booth_assignment = ::Poll::BoothAssignment.includes(:poll).find_by(find_params)
    end

    def load_poll
      @poll = ::Poll.find(params[:poll_id])
    end

    def redirect_if_blank_required_params
      if officer_assignment_params[:officer_id].blank?
        redirect_to admin_poll_path(@poll)
      end
    end

    def search_params
      params.permit(:poll_id, :search)
    end

    def load_search
      @search = search_params[:search]
    end

end
