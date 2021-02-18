class Officing::BallotSheetsController < Officing::BaseController
  before_action :verify_booth
  before_action :load_poll
  before_action :load_officer_assignments, only: [:new, :create]

  def index
    load_ballot_sheets
  end

  def show
    load_ballot_sheet
  end

  def new
  end

  def create
    load_officer_assignment

    @ballot_sheet = Poll::BallotSheet.new(ballot_sheet_params)

    if @ballot_sheet.save
      redirect_to officing_poll_ballot_sheet_path(@poll, @ballot_sheet)
    else
      flash.now[:alert] = @ballot_sheet.errors.full_messages.join(", ")
      render :new
    end
  end

  private

    def load_poll
      @poll = Poll.find(params[:poll_id])
    end

    def load_ballot_sheets
      @ballot_sheets = Poll::BallotSheet.where(poll: @poll)
    end

    def load_ballot_sheet
      @ballot_sheet = Poll::BallotSheet.find(params[:id])
    end

    def load_officer_assignments
      @officer_assignments = ::Poll::OfficerAssignment.
                  includes(booth_assignment: [:booth]).
                  joins(:booth_assignment).
                  final.
                  where(id: current_user.poll_officer.officer_assignment_ids).
                  where("poll_booth_assignments.poll_id = ?", @poll.id).
                  where(date: Date.current)
    end

    def load_officer_assignment
      @officer_assignment = current_user.poll_officer.officer_assignments.final
                                        .find_by(id: ballot_sheet_params[:officer_assignment_id])
    end

    def ballot_sheet_params
      params.permit(:data, :poll_id, :officer_assignment_id)
    end
end
