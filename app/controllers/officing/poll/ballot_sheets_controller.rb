class Officing::PollBallotSheetsController < Officing::BaseController

  before_action :verify_booth
  before_action :load_poll
  before_action :load_ballot_sheets, only: :index
  before_action :load_ballot_sheet, only: :show

  before_action :load_officer_assignments, only: :new
  before_action :load_officer_assignment, only: :create
  before_action :check_officer_assignment, only: :create

  helper_method :namespace

  def index
  end

  def show
  end

  def new
  end

  def create
    Poll::BallotSheet.create(ballot_sheet_params)

    render :show
  end

  private

  def namespace
    "officing"
  end

  def load_poll
    @poll = Poll.find(params[:poll_id])
  end

  def load_ballot_sheets
    @ballot_sheets = Poll::BallotSheet.where(poll: @poll)
  end

  def load_ballot_sheet
    @ballot_sheet = Poll::BallotSheet.find(params[:ballot_sheet_id])
  end

  def load_officer_assignments
    @officer_assignments = ::Poll::OfficerAssignment.
                includes(booth_assignment: [:booth]).
                joins(:booth_assignment).
                final.
                where(id: current_user.poll_officer.officer_assignment_ids).
                where("poll_booth_assignments.poll_id = ?", @poll_budget.id).
                where(date: Date.current)
  end

  def ballot_sheet_params
    params.permit(:csv_data, :poll_id, :officer_assignment_id)
  end

end
